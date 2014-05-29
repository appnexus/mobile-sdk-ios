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
#import "ANAdWebViewController.h"
#import "ANGlobal.h"
#import "ANLogging.h"
#import "ANMediatedAd.h"
#import "ANMediationAdViewController.h"
#import "ANWebView.h"
#import "NSString+ANCategory.h"
#import "NSTimer+ANCategory.h"

NSString *const kANAdFetcherWillRequestAdNotification = @"kANAdFetcherWillRequestAdNotification";
NSString *const kANAdFetcherAdRequestURLKey = @"kANAdFetcherAdRequestURLKey";
NSString *const kANAdFetcherWillInstantiateMediatedClassNotification = @"kANAdFetcherWillInstantiateMediatedClassKey";
NSString *const kANAdFetcherMediatedClassKey = @"kANAdFetcherMediatedClassKey";

@interface ANAdFetcher () <NSURLConnectionDataDelegate>

@property (nonatomic, readwrite, strong) NSURLConnection *successResultConnection;
@property (nonatomic, readwrite, strong) NSMutableURLRequest *successResultRequest;
@property (nonatomic, readwrite, strong) NSURLConnection *connection;
@property (nonatomic, readwrite, strong) NSMutableURLRequest *request;
@property (nonatomic, readwrite, strong) NSMutableData *data;
@property (nonatomic, readwrite, strong) NSTimer *autoRefreshTimer;
@property (nonatomic, readwrite, strong) NSURL *URL;
@property (nonatomic, readwrite, getter = isLoading) BOOL loading;
@property (nonatomic, readwrite, strong) ANMRAIDAdWebViewController *webViewController;
@property (nonatomic, readwrite, strong) NSMutableArray *mediatedAds;
@property (nonatomic, readwrite, strong) ANMediationAdViewController *mediationController;
@property (nonatomic, readwrite, assign) BOOL requestShouldBePosted;
@property (nonatomic, readwrite, strong) NSString *ANMobileHostname;
@property (nonatomic, readwrite, strong) NSString *ANBaseURL;
@end

@implementation ANAdFetcher

- (id)init
{
	if (self = [super init])
    {
		self.data = [NSMutableData data];
        self.request = [ANAdFetcher initBasicRequest];
		self.successResultRequest = [ANAdFetcher initBasicRequest];
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
    self.request = [ANAdFetcher initBasicRequest];
    
    if (!self.isLoading)
	{
        ANLogInfo(ANErrorString(@"fetcher_start"));
        
        ANLogDebug(ANErrorString(([self getAutoRefreshFromDelegate] > 0.0)
                                 ? @"fetcher_start_auto" : @"fetcher_start_single"));
		
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
				NSDictionary *errorInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"Unable to make request due to bad URL connection.", @"Error: Bad URL connection.")
																	  forKey:NSLocalizedDescriptionKey];
				NSError *badURLConnectionError = [NSError errorWithDomain:AN_ERROR_DOMAIN code:ANAdResponseBadURLConnection userInfo:errorInfo];
				ANAdResponse *response = [ANAdResponse adResponseFailWithError:badURLConnectionError];
                [self processFinalResponse:response];
			}
		}
		else
		{
			NSDictionary *errorInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"Unable to make request due to malformed URL.", @"Error: Malformed URL")
                                                                  forKey:NSLocalizedDescriptionKey];
            NSError *badURLError = [NSError errorWithDomain:AN_ERROR_DOMAIN code:ANAdResponseBadURL userInfo:errorInfo];
            ANAdResponse *response = [ANAdResponse adResponseFailWithError:badURLError];
            [self processFinalResponse:response];
		}
	}
	else
    {
		ANLogWarn(ANErrorString(@"moot_restart"));
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
		ANLogWarn(ANErrorString(@"response_no_ads"));
        NSDictionary *errorInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"Request got successful response from server, but no ads were available.", @"Error: Response was received, but it contained no ads")
                                                              forKey:NSLocalizedDescriptionKey];
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
        ANLogInfo([NSString stringWithFormat:ANErrorString(@"adsize_too_big"),
                   (int)receivedSize.width, (int)receivedSize.height,
                   (int)requestedSize.width, (int)requestedSize.height]);
    }

    CGSize sizeOfCreative = ((receivedSize.width > 0)
                             && (receivedSize.height > 0)) ? receivedSize : requestedSize;

    // Generate a new webview to contain the HTML
    ANWebView *webView = [[ANWebView alloc] initWithFrame:CGRectMake(0, 0, sizeOfCreative.width, sizeOfCreative.height)];
    
    self.webViewController = [[ANMRAIDAdWebViewController alloc] init];
    self.webViewController.isMRAID = response.isMraid;
    self.webViewController.mraidDelegate = self.delegate;
    self.webViewController.mraidDelegate.mraidEventReceiverDelegate = self.webViewController;
    self.webViewController.adFetcher = self;
    self.webViewController.webView = webView;
    webView.delegate = self.webViewController;

    NSString *contentToLoad = response.content;
    contentToLoad = [self prependMRAIDJS:contentToLoad];
    contentToLoad = [self prependSDKJS:contentToLoad];
    
    [webView loadHTMLString:contentToLoad baseURL:[NSURL URLWithString:self.ANBaseURL]];
}

- (NSString *)prependMRAIDJS:(NSString *)content {
    NSString *mraidPath = ANMRAIDBundlePath();
    if ([mraidPath length] < 1) {
        return content;
    }
    NSBundle *mraidBundle = [[NSBundle alloc] initWithPath:ANMRAIDBundlePath()];
    NSData *data = [NSData dataWithContentsOfFile:[mraidBundle pathForResource:@"mraid" ofType:@"js"]];
    NSString *mraidScript = [NSString stringWithFormat:@"<script type=\"text/javascript\">%@</script>",
                             [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
    return [mraidScript stringByAppendingString:content];
}

- (NSString *)prependSDKJS:(NSString *)content {
    NSBundle *resBundle = ANResourcesBundle();
    if (!resBundle) {
        ANLogError(@"Resource not found. Make sure the AppNexusSDKResources bundle is included in project");
        return content;
    }
    NSData *sdkjsData = [NSData dataWithContentsOfFile:[resBundle pathForResource:@"sdkjs" ofType:@"js"]];
    NSData *anjamData = [NSData dataWithContentsOfFile:[resBundle pathForResource:@"anjam" ofType:@"js"]];
    NSString *sdkjs = [[NSString alloc] initWithData:sdkjsData encoding:NSUTF8StringEncoding];
    NSString *anjam  = [[NSString alloc] initWithData:anjamData encoding:NSUTF8StringEncoding];
    
    NSString *sdkjsScript = [NSString stringWithFormat:@"<script type=\"text/javascript\">%@ %@</script>",
                             sdkjs, anjam];
    return [sdkjsScript stringByAppendingString:content];
    
}

- (void)handleMediatedAds:(NSMutableArray *)mediatedAds {
    // pop the front ad
    ANMediatedAd *adToParse = mediatedAds.firstObject;
    [mediatedAds removeObject:adToParse];

    self.mediationController = [ANMediationAdViewController initMediatedAd:adToParse
                                                               withFetcher:self
                                                            adViewDelegate:self.delegate];
}

- (void)clearMediationController {
    // clear any old adapters if they exist
    [self.mediationController clearAdapter];
    self.mediationController = nil;    
}

- (void)finishRequestWithErrorAndRefresh:(NSDictionary *)errorInfo code:(NSInteger)code
{
    self.loading = NO;
    
    NSError *error = [NSError errorWithDomain:AN_ERROR_DOMAIN code:code userInfo:errorInfo];
    ANAdResponse *response = [ANAdResponse adResponseFailWithError:error];
    [self processFinalResponse:response];

    NSTimeInterval interval = [self getAutoRefreshFromDelegate];
    if (interval > 0.0) {
        ANLogInfo(@"No ad received. Will request ad in %f seconds. Error: %@", interval, error.localizedDescription);
    } else {
        ANLogInfo(@"No ad received. Error: %@", error.localizedDescription);
    }
}

- (void)startAutoRefreshTimer {
    if (!self.autoRefreshTimer) {
        ANLogDebug(ANErrorString(@"fetcher_stopped"));
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
                NSDictionary *errorInfo = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:
                                                                              NSLocalizedString(@"Request failed with status code %d", @"Error Description: server request came back with error code."),
                                                                              status]
                                                                      forKey:NSLocalizedDescriptionKey];
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
    }
    // don't process the success resultCB response, just log it.
    else if (connection == self.successResultConnection) {
        if ([response isKindOfClass:[NSHTTPURLResponse class]])
        {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            NSInteger status = [httpResponse statusCode];
            
            ANLogDebug(@"Received response with code %ld from response URL request.", status);
        }
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
    // don't do anything for a succcessful resultCB
    else if (connection == self.successResultConnection) {
        ANLogDebug(@"Success resultCB finished loading");
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (connection == self.connection) {
        NSString *errorMessage = [NSString stringWithFormat:
                                  @"Ad request %@ failed with error %@",
                                  connection, [error localizedDescription]];
        ANLogError(errorMessage);
        
        self.loading = NO;
        
        [self setupAutoRefreshTimerIfNecessary];
        
        NSDictionary *errorInfo = [NSDictionary dictionaryWithObject:errorMessage
                                                              forKey:NSLocalizedDescriptionKey];
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
    
    if (reason == ANAdResponseSuccessful) {
        // fire the resultCB if there is one
        if ([resultCBString length] > 0) {
            // if it was successful, don't act on the response
            self.successResultRequest = [ANAdFetcher initBasicRequest];
            self.successResultRequest.URL = [NSURL URLWithString:[self createResultCBRequest:resultCBString reason:reason]];
            self.successResultConnection = [NSURLConnection connectionWithRequest:self.successResultRequest delegate:self];
        }

        ANAdResponse *response = [ANAdResponse adResponseSuccessfulWithAdObject:adObject];
        response.auctionID = auctionID;
        [self processFinalResponse:response];
    } else {
        // clear all failed mediation controllers
        [self clearMediationController];
        
        if (self.delegate) { // if there is still a delegate to send a successful ad response to
            // fire the resultCB if there is one
            if ([resultCBString length] > 0) {
                // treat failed responses as normal requests
                [self requestAdWithURL:[NSURL URLWithString:[self createResultCBRequest:resultCBString reason:reason]]];
            } else {
                // if no resultCB and no successful ads yet,
                // look for the next ad in the current array
                [self processAdResponse:nil];
            }
        }
    }
}

- (NSString *)createResultCBRequest:(NSString *)baseResultCBString reason:(int)reasonCode {
    NSString *resultCBRequestString = [baseResultCBString
                                       stringByAppendingUrlParameter:@"reason"
                                       value:[NSString stringWithFormat:@"%d",reasonCode]];
    resultCBRequestString = [resultCBRequestString stringByAppendingUrlParameter:@"idfa" value:ANUDID()];
    return resultCBRequestString;
}

@end

