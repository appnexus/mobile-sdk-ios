/*   Copyright 2013 APPNEXUS INC
 
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

#import "ANAdFetcher.h"

#import "ANAdRequestUrl.h"
#import "ANGlobal.h"
#import "ANLogging.h"
#import "ANMediatedAd.h"
#import "ANMediationAdViewController.h"
#import "ANMRAIDContainerView.h"

#import "NSString+ANCategory.h"
#import "NSTimer+ANCategory.h"
#import "UIView+ANCategory.h"

NSString *const kANAdFetcherWillRequestAdNotification = @"kANAdFetcherWillRequestAdNotification";
NSString *const kANAdFetcherAdRequestURLKey = @"kANAdFetcherAdRequestURLKey";
NSString *const kANAdFetcherWillInstantiateMediatedClassNotification = @"kANAdFetcherWillInstantiateMediatedClassKey";
NSString *const kANAdFetcherMediatedClassKey = @"kANAdFetcherMediatedClassKey";

@interface ANAdFetcher () <NSURLConnectionDataDelegate, ANAdWebViewControllerLoadingDelegate>

@property (nonatomic, readwrite, strong) NSURLConnection *connection;
@property (nonatomic, readwrite, strong) NSMutableURLRequest *request;
@property (nonatomic, readwrite, strong) NSMutableData *data;
@property (nonatomic, readwrite, strong) NSTimer *autoRefreshTimer;
@property (nonatomic, readwrite, strong) NSURL *URL;
@property (nonatomic, readwrite, getter = isLoading) BOOL loading;
@property (nonatomic, readwrite, strong) ANMRAIDContainerView *standardAdView;
@property (nonatomic, readwrite, strong) NSMutableArray *mediatedAds;
@property (nonatomic, readwrite, strong) ANMediationAdViewController *mediationController;
@property (nonatomic, readwrite, assign) BOOL requestShouldBePosted;
@property (nonatomic, readwrite, strong) NSString *ANMobileHostname;
@property (nonatomic, readwrite, strong) NSString *ANBaseURL;

// variables for measuring latency.
@property (nonatomic, readwrite, assign) NSTimeInterval totalLatencyStart;
@end

@implementation ANAdFetcher

- (instancetype)init
{
	if (self = [super init])
    {
		self.data = [NSMutableData data];
        self.request = [ANAdFetcher initBasicRequest];
        self.ANMobileHostname = AN_MOBILE_HOSTNAME;
        self.ANBaseURL = AN_BASE_URL;
        [NSHTTPCookieStorage sharedHTTPCookieStorage].cookieAcceptPolicy = NSHTTPCookieAcceptPolicyAlways;
    }
    
	return self;
}

- (void)setEndpoint:(ANMobileEndpoint)endpoint {
    _endpoint = endpoint;
    switch (endpoint) {
        case ANMobileEndpointClientTesting:
            self.ANMobileHostname = AN_MOBILE_HOSTNAME_CTEST;
            self.ANBaseURL = AN_BASE_URL_CTEST;
            break;
        case ANMobileEndpointSandbox:
            self.ANMobileHostname = AN_MOBILE_HOSTNAME_SAND;
            self.ANBaseURL = AN_BASE_URL_SAND;
            break;
        default:
            self.ANMobileHostname = AN_MOBILE_HOSTNAME;
            self.ANBaseURL = AN_BASE_URL;
            break;
    }
}

+ (NSMutableURLRequest *)initBasicRequest {
    NSMutableURLRequest *request =
    [[NSMutableURLRequest alloc] initWithURL:nil
                                 cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                             timeoutInterval:kAppNexusRequestTimeoutInterval];
    
    [request setValue:ANUserAgent() forHTTPHeaderField:@"User-Agent"];
    
    return request;
}

- (void)autoRefreshTimerDidFire:(NSTimer *)timer
{
	[self.connection cancel];
	self.loading = NO;
    
    [self requestAd];
}

- (void)requestAdWithURL:(NSURL *)URL
{
    [self.autoRefreshTimer invalidate];
    [self markLatencyStart];
    self.request = [ANAdFetcher initBasicRequest];
    
    if (!self.isLoading)
	{
        ANLogInfo(@"fetcher_start");
        NSString *errorKey = [self getAutoRefreshFromDelegate] > 0.0 ? @"fetcher_start_auto" : @"fetcher_start_single";
        ANLogDebug(@"%@", errorKey);
		
        NSString *baseUrlString = [NSString stringWithFormat:@"http://%@?", self.ANMobileHostname];
        self.URL = URL ? URL : [ANAdRequestUrl buildRequestUrlWithAdFetcherDelegate:self.delegate
                                                                      baseUrlString:baseUrlString];
		
		if (self.URL != nil)
		{
			self.request.URL = self.URL;
			self.connection = [NSURLConnection connectionWithRequest:self.request delegate:self];
			
			if (self.connection != nil)
			{
				ANLogInfo(@"Beginning loading ad from URL: %@", self.URL);
				
                if (self.requestShouldBePosted) {
                    ANPostNotifications(kANAdFetcherWillRequestAdNotification, self,
                                        @{kANAdFetcherAdRequestURLKey: self.URL});
                    self.requestShouldBePosted = NO;
                }
                
				self.loading = YES;
			}
			else
			{
				NSDictionary *errorInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Unable to make request due to bad URL connection.", @"Error: Bad URL connection.")};
				NSError *badURLConnectionError = [NSError errorWithDomain:AN_ERROR_DOMAIN code:ANAdResponseBadURLConnection userInfo:errorInfo];
				ANAdResponse *response = [ANAdResponse adResponseFailWithError:badURLConnectionError];
                [self processFinalResponse:response];
			}
		}
		else
		{
			NSDictionary *errorInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Unable to make request due to malformed URL.", @"Error: Malformed URL")};
            NSError *badURLError = [NSError errorWithDomain:AN_ERROR_DOMAIN code:ANAdResponseBadURL userInfo:errorInfo];
            ANAdResponse *response = [ANAdResponse adResponseFailWithError:badURLError];
            [self processFinalResponse:response];
		}
	}
	else
    {
		ANLogWarn(@"moot_restart");
    }
}

- (void)requestAd
{
    self.requestShouldBePosted = YES;
    [self requestAdWithURL:nil];
}

- (void)stopAd
{
    [self.autoRefreshTimer invalidate];
    self.autoRefreshTimer = nil;
    
    [self.connection cancel];
    self.connection = nil;

    self.loading = NO;
    self.data = nil;
}

- (NSTimeInterval)getAutoRefreshFromDelegate {
    if ([self.delegate respondsToSelector:@selector(autoRefreshIntervalForAdFetcher:)]) {
        return [self.delegate autoRefreshIntervalForAdFetcher:self];
    }
    return 0.0f;
}

- (CGSize)getAdSizeFromDelegate {
    if ([self.delegate respondsToSelector:@selector(requestedSizeForAdFetcher:)]) {
        return [self.delegate requestedSizeForAdFetcher:self];
    }
    return CGSizeZero;
}

- (void)sendDelegateFinishedResponse:(ANAdResponse *)response {
    if ([self.delegate respondsToSelector:@selector(adFetcher:didFinishRequestWithResponse:)]) {
        [self.delegate adFetcher:self didFinishRequestWithResponse:response];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [self.connection cancel];
    [self.autoRefreshTimer invalidate];
    [self clearMediationController];
}

- (void)clearMediationController {
    /*
     Ad fetcher gets cleared, in the event the mediation controller lives beyond the ad fetcher. The controller maintains a weak reference to the 
     ad fetcher delegate so that messages to the delegate can proceed uninterrupted. Currently, the controller will only live on if it is still 
     displaying inside a banner ad view (in which case it will live on until the individual ad is destroyed).
     */
    self.mediationController.adFetcher = nil;
    self.mediationController = nil;
}

#pragma mark Request Url Construction

- (void)processFinalResponse:(ANAdResponse *)response {
    [self sendDelegateFinishedResponse:response];
    [self startAutoRefreshTimer];
}

- (void)setupAutoRefreshTimerIfNecessary
{
    // stop old autoRefreshTimer
    [self.autoRefreshTimer invalidate];
    self.autoRefreshTimer = nil;
    
    // setup new autoRefreshTimer if refresh interval positive
    NSTimeInterval interval = [self getAutoRefreshFromDelegate];
    if (interval > 0.0f) {
        self.autoRefreshTimer = [NSTimer timerWithTimeInterval:interval
                                                        target:self
                                                      selector:@selector(autoRefreshTimerDidFire:)
                                                      userInfo:nil
                                                       repeats:NO];
    }
}

- (void)processAdResponse:(ANAdResponse *)response
{
    [self clearMediationController];

    BOOL responseAdsExist = response && response.containsAds;
    BOOL oldAdsExist = [self.mediatedAds count] > 0;
    
    if (!responseAdsExist && !oldAdsExist) {
		ANLogWarn(@"response_no_ads");
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
        // no mediatedAds, parse for non-mediated ad response
        [self handleStandardAd:response];
    }
    
}

- (void)handleStandardAd:(ANAdResponse *)response {
    // Compare the size of the received impression with what the requested ad size is. If the two are different, send the ad delegate a message.
    CGSize receivedSize = CGSizeMake([response.width floatValue], [response.height floatValue]);
    CGSize requestedSize = [self getAdSizeFromDelegate];
    
    CGRect receivedRect = CGRectMake(CGPointZero.x, CGPointZero.y, receivedSize.width, receivedSize.height);
    CGRect requestedRect = CGRectMake(CGPointZero.x, CGPointZero.y, requestedSize.width, requestedSize.height);
    
    if (!CGRectContainsRect(requestedRect, receivedRect)) {
        ANLogInfo(@"adsize_too_big %d%d%d%d", (int)receivedSize.width, (int)receivedSize.height,
                                            (int)requestedSize.width, (int)requestedSize.height);
    }

    CGSize sizeOfCreative = ((receivedSize.width > 0)
                             && (receivedSize.height > 0)) ? receivedSize : requestedSize;
    
    if (self.standardAdView) {
        self.standardAdView.webViewController.loadingDelegate = nil;
    }
    
    self.standardAdView = [[ANMRAIDContainerView alloc] initWithSize:sizeOfCreative
                                                                HTML:response.content
                                                      webViewBaseURL:[NSURL URLWithString:self.ANBaseURL]];
    self.standardAdView.webViewController.loadingDelegate = self;
}

- (void)didCompleteFirstLoadFromWebViewController:(ANAdWebViewController *)controller {
    if (self.standardAdView.webViewController == controller) {
        ANAdResponse *response = [ANAdResponse adResponseSuccessfulWithAdObject:self.standardAdView];
        [self processFinalResponse:response];
    }
}

- (void)handleMediatedAds:(NSMutableArray *)mediatedAds {
    // pop the front ad
    ANMediatedAd *adToParse = mediatedAds.firstObject;
    [mediatedAds removeObject:adToParse];

    self.mediationController = [ANMediationAdViewController initMediatedAd:adToParse
                                                               withFetcher:self
                                                            adViewDelegate:self.delegate];
}

- (void)finishRequestWithErrorAndRefresh:(NSDictionary *)errorInfo code:(NSInteger)code
{
    self.loading = NO;
    
    NSError *error = [NSError errorWithDomain:AN_ERROR_DOMAIN code:code userInfo:errorInfo];

    NSTimeInterval interval = [self getAutoRefreshFromDelegate];
    if (interval > 0.0) {
        ANLogInfo(@"No ad received. Will request ad in %f seconds. Error: %@", interval, error.localizedDescription);
    } else {
        ANLogInfo(@"No ad received. Error: %@", error.localizedDescription);
    }

    ANAdResponse *response = [ANAdResponse adResponseFailWithError:error];
    [self processFinalResponse:response];
}

- (void)startAutoRefreshTimer {
    if (!self.autoRefreshTimer) {
        ANLogDebug(@"fetcher_stopped");
    } else if ([self.autoRefreshTimer isScheduled]) {
        ANLogDebug(@"AutoRefresh timer already scheduled.");
    } else {
		[self.autoRefreshTimer scheduleNow];
	}
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
        
        [self setupAutoRefreshTimerIfNecessary];
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
        ANLogError(@"%@", errorMessage);
        
        self.loading = NO;
        
        [self setupAutoRefreshTimerIfNecessary];
        
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
              reason:(ANADRESPONSECODE)reason
            adObject:(id)adObject
           auctionID:(NSString *)auctionID {
    self.loading = NO;
    
    NSURL *resultURL = [NSURL URLWithString:resultCBString];
    
    if (reason == ANAdResponseSuccessful) {
        // mediated ad succeeded. fire resultCB and ignore response
        if ([resultCBString length] > 0) {
            [self fireAndIgnoreResultCB:resultURL];
        }
        
        ANAdResponse *response = [ANAdResponse adResponseSuccessfulWithAdObject:adObject];
        response.auctionID = auctionID;
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
    NSMutableURLRequest *ignoredRequest = [ANAdFetcher initBasicRequest];
    ignoredRequest.URL = url;
    [NSURLConnection sendAsynchronousRequest:ignoredRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (error) {
                                   ANLogInfo(@"Ignored resultCB received response with error: %@", [error localizedDescription]);
                               } else if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                                   NSInteger status = [(NSHTTPURLResponse *)response statusCode];
                                   ANLogInfo(@"Ignored resultCB received response with code %ld", (long)status);
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

