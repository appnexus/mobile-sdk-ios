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

#import "ANUniversalAdFetcher.h"
#import "ANLogging.h"
#import "ANUniversalTagRequestBuilder.h"
#import "ANUniversalTagAdServerResponse.h"

#import "ANRTBVideoAd.h"
#import "ANCSMVideoAd.h"
#import "ANVideoAdPlayer.h"
#import "ANSDKSettings+PrivateMethods.h"

#import "ANAdFetcher.h"

#import "ANMRAIDContainerView.h"



@interface ANUniversalAdFetcher () <NSURLConnectionDataDelegate, ANVideoAdProcessorDelegate, ANAdWebViewControllerLoadingDelegate>

@property (nonatomic, readwrite, weak)    id<ANUniversalAdFetcherDelegate>  delegate;

@property (nonatomic, readwrite, strong)  NSURLConnection           *connection;
@property (nonatomic, readwrite, strong)  NSMutableData             *data;

@property (nonatomic, readwrite, strong)  NSMutableArray            *ads;
@property (nonatomic, readwrite, strong)  NSURL                     *noAdUrl;
@property (nonatomic, readwrite, assign)  NSTimeInterval            totalLatencyStart;

@property (nonatomic, readwrite, strong)  NSArray                   *impressionUrls;

@property (nonatomic, readwrite, strong)  ANMRAIDContainerView      *standardAdView;

@end




@implementation ANUniversalAdFetcher

#pragma mark - Lifecycle.

- (instancetype)initWithDelegate:(id<ANUniversalAdFetcherDelegate>)delegate {
    if (self = [self init]) {
        self.delegate = delegate;
        self.data = [NSMutableData data];
    }
    return self;
}




#pragma mark - Ad Request

- (void)requestAd
{
ANLogMark();
    NSString      *urlString  = [[[ANSDKSettings sharedInstance] baseUrlConfig] utAdRequestBaseUrl];
    NSURLRequest  *request    = [ANUniversalTagRequestBuilder buildRequestWithAdFetcherDelegate:self.delegate baseUrlString:urlString];

    self.connection = [NSURLConnection connectionWithRequest:request
                                                    delegate:self];

    if (!self.connection) {
        ANAdFetcherResponse *response = [ANAdFetcherResponse responseWithError:ANError(@"bad_url_connection", ANAdResponseBadURLConnection)];
        [self processFinalResponse:response];
    } else {
        ANLogDebug(@"Starting request: %@", request);
    }
}

- (void)stopAdLoad
{
ANLogMark();
    [self.connection cancel];
    self.connection = nil;
    self.data = nil;
    self.ads = nil;
}



#pragma mark - Ad Response

- (void)processAdServerResponse:(ANUniversalTagAdServerResponse *)response
{
ANLogMark();
    BOOL containsAds = (response.ads != nil) && (response.ads.count > 0);

    if (!containsAds) {
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

- (void)sendDelegateFinishedResponse:(ANAdFetcherResponse *)response
{
    ANLogMark();
    if ([self.delegate respondsToSelector:@selector(universalAdFetcher:didFinishRequestWithResponse:)]) {
        [self.delegate universalAdFetcher:self didFinishRequestWithResponse:response];
    }
}


- (void)continueWaterfall
{
ANLogMark();
    // stop waterfall if delegate reference (adview) was lost
    if (!self.delegate) {
        return;
    }
    
    BOOL adsLeft = (self.ads.count > 0);
    
    if (!adsLeft) {
        ANLogWarn(@"response_no_ads");
        if (self.noAdUrl) {
            ANLogDebug(@"(no_ad_url, %@)", self.noAdUrl);
            [self fireAndIgnoreResultCB:self.noAdUrl];
        }
        [self finishRequestWithError:ANError(@"response_no_ads", ANAdResponseUnableToFill)];
        return;
    }
    
    id nextAd = [self.ads firstObject];
    [self.ads removeObjectAtIndex:0];

    if ([nextAd isKindOfClass:[ANRTBVideoAd class]]) {
        [self handleRTBVideoAd:nextAd];

    } else if([nextAd isKindOfClass:[ANCSMVideoAd class]]){
        [self handleCSMVideoAd:nextAd];

    } else if ( [nextAd isKindOfClass:[ANStandardAd class]] ) {
        [self handleStandardAd:nextAd];

    } else {
        ANLogError(@"Implementation error: Unknown ad in ads waterfall.  (class=%@)", [nextAd class]);
    }
}



#pragma mark - Ad handlers.

// VAST ad.
//
- (void)handleRTBVideoAd:(ANRTBVideoAd *)videoAd
{
    if (!videoAd.assetURL && !videoAd.content) {
        [self continueWaterfall];
    }
    
    NSString *notifyUrlString = videoAd.notifyUrlString;

    if (notifyUrlString.length > 0) {
        ANLogDebug(@"(notify_url, %@)", notifyUrlString);
        [self fireAndIgnoreResultCB:[NSURL URLWithString:notifyUrlString]];
    }

    if (! [[ANVideoAdProcessor alloc] initWithDelegate:self withAdVideoContent:videoAd])  {
        ANLogError(@"FAILED to create ANVideoAdProcessor object.");
    }
}



// Video ad.
//
-(void) handleCSMVideoAd:(id) videoAd {
    if (! [[ANVideoAdProcessor alloc] initWithDelegate:self withAdVideoContent:videoAd])  {
        ANLogError(@"FAILED to create ANVideoAdProcessor object.");
    }
}


- (void)handleStandardAd:(ANStandardAd *)standardAd
{
    ANLogMark();
    // Compare the size of the received impression with what the requested ad size is. If the two are different, send the ad delegate a message.
    CGSize receivedSize = CGSizeMake([standardAd.width floatValue], [standardAd.height floatValue]);
    CGSize requestedSize = [self getAdSizeFromDelegate];

    CGRect receivedRect = CGRectMake(CGPointZero.x, CGPointZero.y, receivedSize.width, receivedSize.height);
    CGRect requestedRect = CGRectMake(CGPointZero.x, CGPointZero.y, requestedSize.width, requestedSize.height);

    if (!CGRectContainsRect(requestedRect, receivedRect)) {
        ANLogInfo(@"adsize_too_big %d%d%d%d", (int)receivedRect.size.width, (int)receivedRect.size.height,
                  (int)requestedRect.size.width, (int)requestedRect.size.height);
    }

    CGSize sizeOfCreative = (    (receivedSize.width > 0)
                              && (receivedSize.height > 0)) ? receivedSize : requestedSize;

    if (self.standardAdView) {
        self.standardAdView.loadingDelegate = nil;
    }

    if ([self.delegate respondsToSelector:@selector(universalAdFetcher:impressionUrls:)])
    {
        [self.delegate universalAdFetcher:self impressionUrls:standardAd.impressionUrls];
            //FIX x -- need a (deep) copy?
            //FIX x race condition if standardAd is destroyed?
            //FIX  incorporate int o adObject.
    }

    self.standardAdView = [[ANMRAIDContainerView alloc] initWithSize:sizeOfCreative
                                                                HTML:standardAd.content
                                                      webViewBaseURL:[NSURL URLWithString:[[[ANSDKSettings sharedInstance] baseUrlConfig] webViewBaseUrl]]];
    self.standardAdView.loadingDelegate = self;
    // Allow ANJAM events to always be passed to the ANAdView
    self.standardAdView.webViewController.adViewANJAMDelegate = self.delegate;

}




#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
ANLogMark();
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

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)d
{
ANLogMark();
    if (connection == self.connection) {
        [self.data appendData:d];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
ANLogMark();
    if (connection == self.connection)
    {
        NSString *responseString = [[NSString alloc] initWithData:self.data
                                                         encoding:NSUTF8StringEncoding];
        ANLogDebug(@"Response JSON %@", responseString);
        ANPostNotifications(kANAdFetcherDidReceiveResponseNotification, self,
                            @{kANAdFetcherAdResponseKey: (responseString ? responseString : @"")});

        //
        ANUniversalTagAdServerResponse *adResponse = [ANUniversalTagAdServerResponse responseWithData:self.data];
        [self processAdServerResponse:adResponse];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
ANLogMark();
    if (connection == self.connection) {
        NSError *connectionError = ANError(@"ad_request_failed %@%@", ANAdResponseNetworkError, connection, [error localizedDescription]);
        ANLogError(@"%@", connectionError);
        ANAdFetcherResponse *response = [ANAdFetcherResponse responseWithError:connectionError];
        [self processFinalResponse:response];
    }
}




#pragma mark - ANUniversalAdFetcherDelegate.

- (CGSize)getAdSizeFromDelegate {
    if ([self.delegate respondsToSelector:@selector(requestedSizeForAdFetcher:)]) {
        return [self.delegate requestedSizeForAdFetcher:self];
    }
    return CGSizeZero;
}


#pragma mark - ANAdWebViewControllerLoadingDelegate.

- (void)didCompleteFirstLoadFromWebViewController:(ANAdWebViewController *)controller
{
    ANLogMark();
    if (self.standardAdView.webViewController == controller) {
        ANAdFetcherResponse *response = [ANAdFetcherResponse responseWithAdObject:self.standardAdView];
        [self processFinalResponse:response];
    }
}




#pragma mark - ANVideoAdProcessor delegate

- (void) videoAdProcessor:(ANVideoAdProcessor *)videoProcessor didFinishVideoProcessing: (ANVideoAdPlayer *)adVideo{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            ANLogMark();
            ANAdFetcherResponse *adFetcherResponse = [ANAdFetcherResponse responseWithAdObject:adVideo];
            [self processFinalResponse:adFetcherResponse];
        });
    });
}

- (void) videoAdProcessor:(ANVideoAdProcessor *)videoProcessor didFailVideoProcessing: (NSError *)error{
    [self continueWaterfall];
}

- (void)fireAndIgnoreResultCB:(NSURL *)url {
    // just fire resultCB asnychronously and ignore result
    [NSURLConnection sendAsynchronousRequest:ANBasicRequestWithURL(url)
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

                           }];
}



@end
