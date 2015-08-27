/*   Copyright 2014 APPNEXUS INC
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "ANNativeAdFetcher.h"
#import "ANLogging.h"
#import "ANMediatedAd.h"
#import "ANNativeMediatedAdController.h"
#import "ANNativeAdRequestUrlBuilder.h"
#import "ANNativeAdTargetingProtocol.h"
#import "ANAdServerResponse.h"
#import "ANAdFetcher.h"

@interface ANNativeAdFetcher () <ANNativeMediationAdControllerDelegate>

@property (nonatomic, readwrite, weak) id<ANNativeAdFetcherDelegate> delegate;
@property (nonatomic, readwrite, strong) NSString *baseUrlString;

@property (nonatomic, readwrite, strong) NSURLConnection *connection;
@property (nonatomic, readwrite, strong) NSMutableData *data;
@property (nonatomic, readwrite, getter = isLoading) BOOL loading;

@property (nonatomic, readwrite, assign) NSTimeInterval totalLatencyStart;
@property (nonatomic, readwrite, strong) NSMutableArray *mediatedAds;
@property (nonatomic, readwrite, strong) ANNativeStandardAdResponse *nativeAd;
@property (nonatomic, readwrite, strong) ANNativeMediatedAdController *mediationController;

@property (nonatomic, readwrite, assign) BOOL requestShouldBePosted;

@end

@implementation ANNativeAdFetcher

#pragma mark - Initializers

- (instancetype)initWithDelegate:(id<ANNativeAdFetcherDelegate>)delegate
                   baseUrlString:(NSString *)baseUrlString {
    if (self = [self init]) {
        self.delegate = delegate;
        self.baseUrlString = baseUrlString;
        [self requestAd];
    }
    return self;
}

- (instancetype)initWithDelegate:(id<ANNativeAdFetcherDelegate>)delegate {
    return [self initWithDelegate:delegate
                    baseUrlString:kANNativeAdFetcherDefaultBaseUrlString];
}

- (instancetype)init {
    if (self = [super init]) {
        self.data = [NSMutableData data];
        [NSHTTPCookieStorage sharedHTTPCookieStorage].cookieAcceptPolicy = NSHTTPCookieAcceptPolicyAlways;
    }
    return self;
}

#pragma mark - Ad Server Request

- (void)requestAd {
    self.requestShouldBePosted = YES;
    NSURL *adRequestUrl = [ANNativeAdRequestUrlBuilder requestUrlWithAdRequestDelegate:self.delegate
                                                                         baseUrlString:self.baseUrlString];
    [self requestAdWithURL:adRequestUrl];
}

- (void)requestAdWithURL:(NSURL *)URL {
    [self markLatencyStart];
    
    if (!self.isLoading) {
        ANLogInfo(@"fetcher_start");
                
        if (URL) {
            self.connection = [NSURLConnection connectionWithRequest:ANBasicRequestWithURL(URL)
                                                            delegate:self];
            if (self.connection) {
                
                ANLogInfo(@"Beginning loading ad from URL: %@", URL);
                
                if (self.requestShouldBePosted) {
                    ANPostNotifications(kANAdFetcherWillRequestAdNotification, self,
                                        @{kANAdFetcherAdRequestURLKey: URL});
                    self.requestShouldBePosted = NO;
                }

                self.loading = YES;
            } else {
                [self finishRequestWithError:ANError(@"bad_url_connection", ANAdResponseBadURLConnection)];
            }
        } else {
            [self finishRequestWithError:ANError(@"malformed_url", ANAdResponseBadURL)];
        }
    } else {
        ANLogWarn(@"moot_restart");
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self stopAd];
}

- (void)stopAd {
    [self.connection cancel];
    self.connection = nil;
    self.loading = NO;
    self.data = nil;
    self.mediatedAds = nil;
    self.nativeAd = nil;
    [self clearMediationController];
}

- (void)clearMediationController {
    self.mediationController = nil;
}

#pragma mark - Ad Server Response

- (void)processAdServerResponse:(ANAdServerResponse *)response {
    if (!response.containsAds) {
        [self finishRequestWithError:ANError(@"response_no_ads", ANAdResponseUnableToFill)];
        return;
    }
    
    self.mediatedAds = response.mediatedAds;
    
    if (self.mediatedAds.count) {
        self.nativeAd = response.nativeAd;
        [self popAndLoadMediatedAd];
    } else if (response.nativeAd) {
        [self processNativeResponse:response.nativeAd];
    } else {
        [self finishRequestWithError:ANError(@"response_bad_format", ANAdResponseBadFormat)];
    }
}

#pragma mark - Final Response

- (void)finishRequestWithSuccessfulAdObject:(id)adObject {
    self.loading = NO;
    ANAdFetcherResponse *response = [[ANAdFetcherResponse alloc] initAdResponseSuccessWithAdObject:adObject];
    [self processFinalResponse:response];
}

- (void)finishRequestWithError:(NSError *)error {
    self.loading = NO;
    ANLogError(@"no_ad_received_error %@", error.localizedDescription);
    ANAdFetcherResponse *response = [[ANAdFetcherResponse alloc] initAdResponseFailWithError:error];
    [self processFinalResponse:response];
}

- (void)processFinalResponse:(ANAdFetcherResponse *)response {
    if ([self.delegate respondsToSelector:@selector(adFetcher:didFinishRequestWithResponse:)]) {
        [self.delegate adFetcher:self didFinishRequestWithResponse:response];
    }
}

# pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (connection == self.connection) {
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            NSInteger status = [httpResponse statusCode];
            
            if (status >= 400) {
                [connection cancel];
                [self connection:connection didFailWithError:ANError(@"connection_failed %ld", ANAdResponseNetworkError, (long)status)];
                return;
            }
        }
        
        self.data = [NSMutableData data];
        ANLogDebug(@"response_received %@", response);
    } else {
        ANLogDebug(@"response_received_unknown");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)d {
    if (connection == self.connection) {
        [self.data appendData:d];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (connection == self.connection) {
        ANAdServerResponse *adResponse = [[ANAdServerResponse alloc] initWithAdServerData:self.data];
        NSString *responseString = [[NSString alloc] initWithData:self.data
                                                         encoding:NSUTF8StringEncoding];
        ANPostNotifications(kANAdFetcherDidReceiveResponseNotification, self,
                            @{kANAdFetcherAdResponseKey: (responseString ? responseString : @"")});
        [self processAdServerResponse:adResponse];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (connection == self.connection) {
        NSError *anError = ANError(@"ad_request_failed %@%@", ANAdResponseNetworkError, connection, [error localizedDescription]);
        [self finishRequestWithError:anError];
    }
}

#pragma mark - Native

- (void)processNativeResponse:(ANNativeStandardAdResponse *)nativeAd {
    [self finishRequestWithSuccessfulAdObject:nativeAd];
}

#pragma mark - Mediation

- (void)popAndLoadMediatedAd {
    if (self.mediatedAds.count) {
        [self clearMediationController];
        ANMediatedAd *adToParse = self.mediatedAds.firstObject;
        [self.mediatedAds removeObjectAtIndex:0];
        self.mediationController = [ANNativeMediatedAdController initMediatedAd:adToParse
                                                                   withDelegate:self
                                                              adRequestDelegate:self.delegate];
    } else {
        ANLogError(@"No mediated ad to pop. Internal implementation error.");
    }
}

- (void)fireResultCB:(NSString *)resultCBString
              reason:(ANAdResponseCode)reason
            adObject:(id)adObject {
    self.loading = NO;
    [self clearMediationController];

    if (!self.delegate) {
        return;
    }
    
    NSURL *resultURL = [NSURL URLWithString:resultCBString];
    
    if (reason == ANAdResponseSuccessful) {
        if (resultCBString.length) {
            [self fireAndIgnoreResultCB:resultURL];
        }
        [self finishRequestWithSuccessfulAdObject:adObject];
    } else {
        if (self.mediatedAds.count) {
            if (resultURL) {
                [self fireAndIgnoreResultCB:resultURL];
            }
            [self popAndLoadMediatedAd];
        } else {
            if (self.nativeAd) {
                if (resultURL) {
                    [self fireAndIgnoreResultCB:resultURL];
                }
                [self processNativeResponse:self.nativeAd];
            } else if (resultURL) {
                [self requestAdWithURL:resultURL];
            } else {
                [self finishRequestWithError:ANError(@"response_no_ads", ANAdResponseUnableToFill)];
            }
        }
    }
}

- (void)fireAndIgnoreResultCB:(NSURL *)url {
    ANLogDebug(@"Firing resultCB with url %@", url);
    [NSURLConnection sendAsynchronousRequest:ANBasicRequestWithURL(url)
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               
                           }];
}

#pragma mark - Latency

- (void)markLatencyStart {
    self.totalLatencyStart = [NSDate timeIntervalSinceReferenceDate];
}

- (NSTimeInterval)getTotalLatency:(NSTimeInterval)stopTime {
    if ((self.totalLatencyStart > 0) && (stopTime > 0)) {
        return (stopTime - self.totalLatencyStart);
    }
    return -1;
}

@end