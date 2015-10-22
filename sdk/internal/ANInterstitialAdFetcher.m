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

@interface ANInterstitialAdFetcher () <NSURLConnectionDataDelegate, ANAdWebViewControllerLoadingDelegate>

@property (nonatomic, readwrite, weak) id<ANInterstitialAdFetcherDelegate> delegate;

@property (nonatomic, readwrite, strong) NSURLConnection *connection;
@property (nonatomic, readwrite, strong) NSMutableData *data;

@property (nonatomic, readwrite, strong) ANMRAIDContainerView *standardAdView;

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
}

#pragma mark - Ad Response

- (void)processAdResponse:(ANUniversalTagAdServerResponse *)response {
    BOOL responseAdsExist = response && response.containsAds;

    if (!responseAdsExist) {
        ANLogWarn(@"response_no_ads");
        [self finishRequestWithError:ANError(@"response_no_ads", ANAdResponseUnableToFill)];
        return;
    }
    
    if (response.videoAd) {
        ANAdFetcherResponse *adFetcherResponse = [ANAdFetcherResponse responseWithAdObject:response.videoAd];
        [self processFinalResponse:adFetcherResponse];
    } else {
        [self handleStandardAd:response.standardAd];
    }
}

- (void)finishRequestWithError:(NSError *)error {
    ANAdFetcherResponse *response = [ANAdFetcherResponse responseWithError:error];
    [self processFinalResponse:response];
}

- (void)processFinalResponse:(ANAdFetcherResponse *)response {
    [self sendDelegateFinishedResponse:response];
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
    [self processFinalResponse:response];
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
        [self processAdResponse:adResponse];
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

@end