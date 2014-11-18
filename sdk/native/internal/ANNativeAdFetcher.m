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
#import "ANNativeMediatedAd.h"
#import "ANNativeMediatedAdController.h"
#import "ANNativeAdRequestUrlBuilder.h"
#import "ANNativeAdTargetingProtocol.h"

@interface ANNativeAdFetcher () <ANNativeMediationAdControllerDelegate>

@property (nonatomic, readwrite, strong) NSURLConnection *connection;
@property (nonatomic, readwrite, strong) NSMutableURLRequest *request;
@property (nonatomic, readwrite, strong) NSMutableData *data;
@property (nonatomic, readwrite, strong) NSURL *URL;
@property (nonatomic, readwrite, getter = isLoading) BOOL loading;
@property (nonatomic, readwrite, strong) NSMutableArray *mediatedAds;
@property (nonatomic, readwrite, strong) ANNativeMediatedAdController *mediationController;
@property (nonatomic, readwrite, assign) BOOL requestShouldBePosted;

// variables for measuring latency.
@property (nonatomic, readwrite, assign) NSTimeInterval totalLatencyStart;

@property (nonatomic, readwrite, weak) id<ANNativeAdFetcherDelegate> delegate;
@property (nonatomic, readwrite, strong) NSString *baseUrlString;

@end

@implementation ANNativeAdFetcher

- (instancetype)initWithDelegate:(id<ANNativeAdFetcherDelegate>)delegate
                   baseUrlString:(NSString *)baseUrlString {
    if (!baseUrlString) {
        return [self initWithDelegate:delegate];
    }
    
    if (self = [self init]) {
        self.delegate = delegate;
        self.baseUrlString = baseUrlString;
        [self requestAd];
    }
    return self;
}

- (instancetype)initWithDelegate:(id<ANNativeAdFetcherDelegate>)delegate {
    if (self = [self init]) {
        self.delegate = delegate;
        [self requestAd];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        self.data = [NSMutableData data];
        self.request = [[self class] initBasicRequest];
        self.baseUrlString = kANNativeAdFetcherDefaultBaseUrlString;
        [NSHTTPCookieStorage sharedHTTPCookieStorage].cookieAcceptPolicy = NSHTTPCookieAcceptPolicyAlways;
    }
    return self;
}

+ (NSMutableURLRequest *)initBasicRequest {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:nil
                                                                cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                            timeoutInterval:kAppNexusRequestTimeoutInterval];
    [request setValue:ANUserAgent() forHTTPHeaderField:@"User-Agent"];
    return request;
}

- (void)requestAdWithURL:(NSURL *)URL {
    [self markLatencyStart];
    self.request = [[self class] initBasicRequest];
    
    if (!self.isLoading) {
        ANLogInfo(ANErrorString(@"fetcher_start"));
                
        self.URL = URL ? URL : [ANNativeAdRequestUrlBuilder requestUrlWithAdRequestDelegate:self.delegate
                                                                              baseUrlString:self.baseUrlString];
        if (self.URL != nil) {
            self.request.URL = self.URL;
            self.connection = [NSURLConnection connectionWithRequest:self.request delegate:self];
            
            if (self.connection != nil) {
                ANLogInfo(@"Beginning loading ad from URL: %@", self.URL);
                
                if (self.requestShouldBePosted) {
                    ANLogDebug(@"self.requestShouldBePosted");
                    self.requestShouldBePosted = NO;
                }
                
                self.loading = YES;
            }
            else {
                NSDictionary *errorInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Unable to make request due to bad URL connection.", @"Error: Bad URL connection.")};
                NSError *badURLConnectionError = [NSError errorWithDomain:AN_ERROR_DOMAIN code:ANAdResponseBadURLConnection userInfo:errorInfo];
                ANAdResponse *response = [ANAdResponse adResponseFailWithError:badURLConnectionError];
                [self processFinalResponse:response];
            }
        }
        else {
            NSDictionary *errorInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Unable to make request due to malformed URL.", @"Error: Malformed URL")};
            NSError *badURLError = [NSError errorWithDomain:AN_ERROR_DOMAIN code:ANAdResponseBadURL userInfo:errorInfo];
            ANAdResponse *response = [ANAdResponse adResponseFailWithError:badURLError];
            [self processFinalResponse:response];
        }
    }
    else {
        ANLogWarn(ANErrorString(@"moot_restart"));
    }
}

- (void)requestAd {
    self.requestShouldBePosted = YES;
    [self requestAdWithURL:nil];
}

- (void)stopAd {
    [self.connection cancel];
    self.connection = nil;
    
    self.loading = NO;
    self.data = nil;
}

- (void)sendDelegateFinishedResponse:(ANAdResponse *)response {
    if ([self.delegate respondsToSelector:@selector(adFetcher:didFinishRequestWithResponse:)]) {
        [self.delegate adFetcher:self didFinishRequestWithResponse:response];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.connection cancel];
    [self clearMediationController];
}

- (void)clearMediationController {
    /*
     Ad fetcher gets cleared, in the event the mediation controller lives beyond the ad fetcher. The controller maintains a weak reference to the
     ad fetcher delegate so that messages to the delegate can proceed uninterrupted. Currently, the controller will only live on if it is still
     displaying inside a banner ad view (in which case it will live on until the individual ad is destroyed).
     */
    self.mediationController = nil;
}

#pragma mark Request Url Construction

- (void)processFinalResponse:(ANAdResponse *)response {
    [self sendDelegateFinishedResponse:response];
}

- (void)processAdResponse:(ANAdResponse *)response {
    [self clearMediationController];
    
    BOOL responseAdsExist = response && response.containsAds;
    BOOL oldAdsExist = [self.mediatedAds count] > 0;
    
    if (!responseAdsExist && !oldAdsExist) {
        ANLogWarn(ANErrorString(@"response_no_ads"));
        NSDictionary *errorInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Request got successful response from server, but no ads were available.", @"Error: Response was received, but it contained no ads")};
        [self finishRequestWithErrorAndRefresh:errorInfo code:ANAdResponseUnableToFill];
        return;
    }
    
    // if mediatedAds is null as a result of this loop,
    // then it must be a non-mediated ad
    if (responseAdsExist) {
        self.mediatedAds = response.mediatedAds;
    }
    
    if ([self.mediatedAds count] > 0) {
        // mediated
        [self handleMediatedAds:self.mediatedAds];
    }
    else {
        ANLogError(ANErrorString(@"response_bad_format"));
        NSDictionary *errorInfo = @{NSLocalizedDescriptionKey: ANErrorString(@"response_bad_format")};
        [self finishRequestWithErrorAndRefresh:errorInfo code:ANAdResponseBadFormat];
    }
}

- (void)handleMediatedAds:(NSMutableArray *)mediatedAds {
    // pop the front ad
    ANNativeMediatedAd *adToParse = mediatedAds.firstObject;
    [mediatedAds removeObject:adToParse];
    
    self.mediationController = [ANNativeMediatedAdController initMediatedAd:adToParse
                                                                withDelegate:self
                                                           adRequestDelegate:self.delegate];
}

- (void)finishRequestWithErrorAndRefresh:(NSDictionary *)errorInfo code:(NSInteger)code {
    self.loading = NO;
    
    NSError *error = [NSError errorWithDomain:AN_ERROR_DOMAIN code:code userInfo:errorInfo];
    ANLogInfo(@"No ad received. Error: %@", error.localizedDescription);
    ANAdResponse *response = [ANAdResponse adResponseFailWithError:error];
    [self processFinalResponse:response];
}

# pragma mark -
# pragma mark NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (connection == self.connection) {
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            NSInteger status = [httpResponse statusCode];
            
            if (status >= 400) {
                [connection cancel];
                NSDictionary *errorInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:
                                                                        NSLocalizedString(@"Request failed with status code %d", @"Error Description: server request came back with error code."),
                                                                        status]};
                NSError *statusError = [NSError errorWithDomain:AN_ERROR_DOMAIN
                                                           code:ANAdResponseNetworkError
                                                       userInfo:errorInfo];
                [self connection:connection didFailWithError:statusError];
                return;
            }
        }
        
        self.data = [NSMutableData data];
        ANLogDebug(@"Received response: %@", response);
    } else {
        ANLogDebug(@"Received response from unknown");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)d {
    if (connection == self.connection) {
        [self.data appendData:d];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (connection == self.connection) {
        ANAdResponse *adResponse = [[ANAdResponse alloc] init];
        adResponse = [adResponse processResponseData:self.data];
        [self processAdResponse:adResponse];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (connection == self.connection) {
        NSString *errorMessage = [NSString stringWithFormat:
                                  @"Ad request %@ failed with error %@",
                                  connection, [error localizedDescription]];
        ANLogError(errorMessage);
        
        self.loading = NO;
        
        NSDictionary *errorInfo = @{NSLocalizedDescriptionKey: errorMessage};
        NSError *ANError = [NSError errorWithDomain:AN_ERROR_DOMAIN
                                               code:ANAdResponseNetworkError
                                           userInfo:errorInfo];
        
        ANAdResponse *failureResponse = [ANAdResponse adResponseFailWithError:ANError];
        [self processFinalResponse:failureResponse];
    }
}

#pragma mark handling resultCB

- (void)fireResultCB:(NSString *)resultCBString
              reason:(ANAdResponseCode)reason
            adObject:(id)adObject {
    self.loading = NO;
    
    NSURL *resultURL = [NSURL URLWithString:resultCBString];
    
    if (reason == ANAdResponseSuccessful) {
        // mediated ad succeeded. fire resultCB and ignore response
        if ([resultCBString length] > 0) {
            [self fireAndIgnoreResultCB:resultURL];
        }
        
        ANAdResponse *response = [ANAdResponse adResponseSuccessfulWithAdObject:adObject];
        [self processFinalResponse:response];
    } else {
        // mediated ad failed. clear mediation controller
        [self clearMediationController];
        
        // stop waterfall if delegate reference (adview) was lost
        if (!self.delegate) {
            return;
        }
        
        // fire the resultCB if there is one
        if ([resultCBString length] > 0) {
            // treat the LAST (failed) resultCB responses as normal requests
            if ([self.mediatedAds count] == 0) {
                [self requestAdWithURL:resultURL];
            } else {
                // otherwise, just fire resultCB asnychronously and ignore result
                [self fireAndIgnoreResultCB:resultURL];
                // not the last ad in waterfall, so continue to next ad
                [self processAdResponse:nil];
            }
        } else {
            // if no resultCB and no successful ads yet,
            // simply continue waterfall
            [self processAdResponse:nil];
        }
    }
}

- (void)fireAndIgnoreResultCB:(NSURL *)url {
    // just fire resultCB asnychronously and ignore result
    NSMutableURLRequest *ignoredRequest = [[self class] initBasicRequest];
    ignoredRequest.URL = url;
    [NSURLConnection sendAsynchronousRequest:ignoredRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (error) {
                                   ANLogInfo(@"Ignored resultCB received response with error: %@", [error localizedDescription]);
                               } else if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                                   NSInteger status = [(NSHTTPURLResponse *)response statusCode];
                                   ANLogInfo(@"Ignored resultCB received response with code %ld", status);
                               } else {
                                   ANLogInfo(@"Ignored resultCB received response.");
                               }
                           }];
}

#pragma mark Total Latency Measurement

/**
 * Mark the beginning of an ad request for latency recording
 */
- (void)markLatencyStart {
    self.totalLatencyStart = [NSDate timeIntervalSinceReferenceDate];
}

/**
 * Returns the time difference since ad request start
 */
- (NSTimeInterval)getTotalLatency:(NSTimeInterval)stopTime {
    if ((self.totalLatencyStart > 0) && (stopTime > 0)) {
        return (stopTime - self.totalLatencyStart);
    }
    // return -1 if invalid parameters
    return -1;
}

@end