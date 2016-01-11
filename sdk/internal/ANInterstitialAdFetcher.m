/*   Copyright 2015 APPNEXUS INC
 
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

#import "ANInterstitialAdFetcher.h"
#import "ANLogging.h"
#import "ANAdWebViewController.h"
#import "ANStandardAd.h"
#import "ANMRAIDContainerView.h"
#import "ANUniversalTagRequestBuilder.h"
#import "ANUniversalTagAdServerResponse.h"
#import "ANMediatedAd.h"
#import "ANMediationAdViewController.h"
#import "ANSSMStandardAd.h"
#import "ANSSMVideoAd.h"
#import "ANSSMContentFetcher.h"

@interface ANInterstitialAdFetcher () <NSURLConnectionDataDelegate,
ANAdWebViewControllerLoadingDelegate, ANSSMContentFetcherDelegate>

@property (nonatomic, readwrite, weak) id<ANInterstitialAdFetcherDelegate> delegate;

@property (nonatomic, readwrite, strong) NSURLConnection *connection;
@property (nonatomic, readwrite, strong) NSMutableData *data;

@property (nonatomic, readwrite, strong) ANMRAIDContainerView *standardAdView;

@property (nonatomic, readwrite, strong) NSMutableArray *ads;
@property (nonatomic, readwrite, strong) NSURL *noAdUrl;
@property (nonatomic, readwrite, strong) ANMediationAdViewController *mediationController;
@property (nonatomic, readwrite, assign) NSTimeInterval totalLatencyStart;

@property (nonatomic, readwrite, strong) NSArray *impressionUrls;

@property (nonatomic, readwrite, strong) id currentSSMAd;
@property (nonatomic, readwrite, strong) ANSSMContentFetcher *contentFetcher;

@end


@implementation ANInterstitialAdFetcher

- (instancetype)initWithDelegate:(id<ANInterstitialAdFetcherDelegate>)delegate {
    if (self = [self init]) {
        self.delegate = delegate;
        self.data = [NSMutableData data];
        [self requestAd];
    }
    return self;
}

- (void)sendDelegateFinishedResponse:(ANAdFetcherResponse *)response {
    if ([self.delegate respondsToSelector:@selector(adFetcher:didFinishRequestWithResponse:)]) {
        [self.delegate interstitialAdFetcher:self didFinishRequestWithResponse:response];
    }
}

#pragma mark - Ad Request

- (void)requestAd {
    [self markLatencyStart];
    NSURLRequest *request = [ANUniversalTagRequestBuilder buildRequestWithAdFetcherDelegate:self.delegate
                                                                              baseUrlString:kANInterstitialAdFetcherDefaultRequestUrlString];
    self.connection = [NSURLConnection connectionWithRequest:request
                                                    delegate:self];
    if (!self.connection) {
        ANAdFetcherResponse *response = [ANAdFetcherResponse responseWithError:ANError(@"bad_url_connection", ANAdResponseBadURLConnection)];
        [self processFinalResponse:response];
    } else {
        ANLogDebug(@"Starting request: %@", request);
    }
}

- (void)stopAdLoad {
    [self.connection cancel];
    self.connection = nil;
    self.data = nil;
    self.ads = nil;
    [self clearMediationController];
}

#pragma mark - Ad Response

- (void)processAdServerResponse:(ANUniversalTagAdServerResponse *)response {
    BOOL numberOfAds = response.ads != nil ? response.ads.count : 0;

    if (numberOfAds == 0) {
        ANLogWarn(@"response_no_ads");
        [self finishRequestWithError:ANError(@"response_no_ads", ANAdResponseUnableToFill)];
        return;
    }
    
    if (response.noAdUrlString) {
        self.noAdUrl = [NSURL URLWithString:response.noAdUrlString];
    }
    self.ads = response.ads;
    [self continueWaterfall];
}

- (void)finishRequestWithError:(NSError *)error {
    ANAdFetcherResponse *response = [ANAdFetcherResponse responseWithError:error];
    [self processFinalResponse:response];
}

- (void)processFinalResponse:(ANAdFetcherResponse *)response {
    self.ads = nil;
    [self sendDelegateFinishedResponse:response];
}

- (void)continueWaterfall {
    BOOL numberOfAdsLeft = self.ads.count > 0;
    
    if (numberOfAdsLeft == 0) {
        ANLogWarn(@"response_no_ads");
        if (self.noAdUrl) {
            ANLogDebug(@"(no_ad_url, %@)", self.noAdUrl);
            [self fireAndIgnoreResultCB:self.noAdUrl];
        }
        [self finishRequestWithError:ANError(@"response_no_ads", ANAdResponseUnableToFill)];
        return;
    }
    
    // stop waterfall if delegate reference (adview) was lost
    if (!self.delegate) {
        return;
    }
    
    id nextAd = [self.ads firstObject];
    [self.ads removeObjectAtIndex:0];
    self.impressionUrls = nil;
    self.currentSSMAd = nil;
    if ([nextAd isKindOfClass:[ANMediatedAd class]]) {
        ANMediatedAd *mediatedAd = (ANMediatedAd *)nextAd;
        self.impressionUrls = mediatedAd.impressionUrls;
        [self handleMediatedAd:mediatedAd];
    } else if ([nextAd isKindOfClass:[ANVideoAd class]]) {
        [self handleVideoAd:nextAd];
    } else if ([nextAd isKindOfClass:[ANStandardAd class]]) {
        ANStandardAd *standardAd = (ANStandardAd *)nextAd;
        self.impressionUrls = standardAd.impressionUrls;
        [self handleStandardAd:standardAd];
    } else if ([nextAd isKindOfClass:[ANSSMVideoAd class]]) {
        self.currentSSMAd = nextAd;
        self.contentFetcher = [[ANSSMContentFetcher alloc] initWithUrlString:((ANSSMVideoAd *)nextAd).urlString
                                                                    delegate:self];
    } else if ([nextAd isKindOfClass:[ANSSMStandardAd class]]) {
        self.currentSSMAd = nextAd;
        self.contentFetcher = [[ANSSMContentFetcher alloc] initWithUrlString:((ANSSMStandardAd *)nextAd).urlString
                                                                    delegate:self];
    } else {
        ANLogError(@"Implementation error: Unknown ad in ads waterfall");
    }
}

#pragma mark - Standard Ads

- (void)handleStandardAd:(ANStandardAd *)standardAd {
    CGSize receivedSize = CGSizeMake([standardAd.width floatValue], [standardAd.height floatValue]);
    
    // Setting the base URL to /ut will result in mraid.js not loading properly from the server
    // which will cause rendering issues for certain MRAID creatives.
    self.standardAdView = [[ANMRAIDContainerView alloc] initWithSize:receivedSize
                                                                HTML:standardAd.content
                                                      webViewBaseURL:[NSURL URLWithString:AN_BASE_URL]];
    self.standardAdView.webViewController.loadingDelegate = self;
}

- (void)didCompleteFirstLoadFromWebViewController:(ANAdWebViewController *)controller {
    ANAdFetcherResponse *response = [ANAdFetcherResponse responseWithAdObject:self.standardAdView];
    response.impressionUrls = self.impressionUrls;
    [self processFinalResponse:response];
}

#pragma mark - VAST Ads

- (void)handleVideoAd:(ANVideoAd *)videoAd {
    NSString *notifyUrlString = videoAd.notifyUrlString;
    if (notifyUrlString.length > 0) {
        ANLogDebug(@"(notify_url, %@)", notifyUrlString);
        [self fireAndIgnoreResultCB:[NSURL URLWithString:notifyUrlString]];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ANVast *vastDataModel = [[ANVast alloc] initWithContent:videoAd.content];
        vastDataModel.videoAd = videoAd;
        videoAd.vastDataModel = vastDataModel;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!vastDataModel) {
                ANLogDebug(@"Invalid VAST content, unable to use");
                [self continueWaterfall];
            } else {
                ANAdFetcherResponse *adFetcherResponse = [ANAdFetcherResponse responseWithAdObject:videoAd];
                [self processFinalResponse:adFetcherResponse];
            }
        });
    });
}

#pragma mark - Mediated Ads

- (void)handleMediatedAd:(ANMediatedAd *)mediatedAd {
    [self clearMediationController];
    // Casting ANInterstitialAdFetcher to ANAdFetcher is intentional, even if they have no relation.
    // This class implements the necessary methods from ANAdFether in order to avoid any issues.
    self.mediationController = [ANMediationAdViewController initMediatedAd:mediatedAd
                                                               withFetcher:(ANAdFetcher *)self
                                                            adViewDelegate:self.delegate];
}

- (void)clearMediationController {
    self.mediationController = nil;
}

- (void)fireAndIgnoreResultCB:(NSURL *)url {
    // just fire resultCB asnychronously and ignore result
    [NSURLConnection sendAsynchronousRequest:ANBasicRequestWithURL(url)
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               
                           }];
}

- (void)fireResultCB:(NSString *)resultCBString
              reason:(ANAdResponseCode)reason
            adObject:(id)adObject
           auctionID:(NSString *)auctionID {
    NSURL *resultURL = [NSURL URLWithString:resultCBString];
    if ([resultCBString length] > 0) {
        [self fireAndIgnoreResultCB:resultURL];
    }
    if (reason == ANAdResponseSuccessful) {
        ANAdFetcherResponse *response = [ANAdFetcherResponse responseWithAdObject:adObject];
        response.auctionID = auctionID;
        response.impressionUrls = self.impressionUrls;
        [self processFinalResponse:response];
    } else {
        [self continueWaterfall];
    }
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (connection == self.connection) {
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            NSInteger status = [httpResponse statusCode];
            
            if (status >= 400) {
                [connection cancel];
                NSError *statusError = ANError(@"connection_failed %ld", ANAdResponseNetworkError, (long)status);
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
        ANUniversalTagAdServerResponse *adResponse = [ANUniversalTagAdServerResponse responseWithData:self.data];
        NSString *responseString = [[NSString alloc] initWithData:self.data
                                                         encoding:NSUTF8StringEncoding];
        ANPostNotifications(kANAdFetcherDidReceiveResponseNotification, self,
                            @{kANAdFetcherAdResponseKey: (responseString ? responseString : @"")});
        [self processAdServerResponse:adResponse];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (connection == self.connection) {
        NSError *connectionError = ANError(@"ad_request_failed %@%@", ANAdResponseNetworkError, connection, [error localizedDescription]);
        ANLogError(@"%@", connectionError);
        ANAdFetcherResponse *response = [ANAdFetcherResponse responseWithError:connectionError];
        [self processFinalResponse:response];
    }
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

#pragma mark - ANSSMContentFetcherDelegate

- (void)contentFetcher:(ANSSMContentFetcher *)fetcher didLoadContent:(NSString *)content {
    if ([self.currentSSMAd isKindOfClass:[ANSSMStandardAd class]]) {
        ANSSMStandardAd *ssmAd = (ANSSMStandardAd *)self.currentSSMAd;
        ANStandardAd *standardAd = [[ANStandardAd alloc] init];
        standardAd.content = content;
        standardAd.width = ssmAd.width;
        standardAd.height = ssmAd.height;
        standardAd.impressionUrls = ssmAd.impressionUrls;
        NSRange mraidJSRange = [standardAd.content rangeOfString:kANUniversalTagAdServerResponseMraidJSFilename];
        if (mraidJSRange.location != NSNotFound) {
            standardAd.mraid = YES;
        }
        [self.ads insertObject:standardAd atIndex:0];
        [self continueWaterfall];
    } else if ([self.currentSSMAd isKindOfClass:[ANSSMVideoAd class]]) {
        ANSSMVideoAd *ssmAd = (ANSSMVideoAd *)self.currentSSMAd;
        ANVideoAd *videoAd = [[ANVideoAd alloc] init];
        videoAd.content = content;
        videoAd.impressionUrls = ssmAd.impressionUrls;
        videoAd.notifyUrlString = ssmAd.notifyUrlString;
        videoAd.errorUrls = ssmAd.errorUrls;
        videoAd.videoEventTrackers = ssmAd.videoEventTrackers;
        videoAd.videoClickUrls = ssmAd.videoClickUrls;
        [self.ads insertObject:videoAd atIndex:0];
        [self continueWaterfall];
    } else {
        [self contentFetcherFailedToLoadContent:fetcher];
    }
}

- (void)contentFetcherFailedToLoadContent:(ANSSMContentFetcher *)fetcher {
    [self continueWaterfall];
}

@end