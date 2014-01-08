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

#import "ANAdWebViewController.h"
#import "ANGlobal.h"
#import "ANLogging.h"
#import "ANMediatedAd.h"
#import "ANMediationAdViewController.h"
#import "ANReachability.h"
#import "ANWebView.h"
#import "NSString+ANCategory.h"
#import "NSTimer+ANCategory.h"
#import "UIWebView+ANCategory.h"

#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

NSString *const kANAdFetcherWillRequestAdNotification = @"kANAdFetcherWillRequestAdNotification";
NSString *const kANAdFetcherAdRequestURLKey = @"kANAdFetcherAdRequestURLKey";

@interface ANAdFetcher () <NSURLConnectionDataDelegate>

@property (nonatomic, readwrite, strong) NSURLConnection *successResultConnection;
@property (nonatomic, readwrite, strong) NSMutableURLRequest *successResultRequest;
@property (nonatomic, readwrite, strong) NSURLConnection *connection;
@property (nonatomic, readwrite, strong) NSMutableURLRequest *request;
@property (nonatomic, readwrite, strong) NSMutableData *data;
@property (nonatomic, readwrite, strong) NSTimer *autoRefreshTimer;
@property (nonatomic, readwrite, strong) NSURL *URL;
@property (nonatomic, readonly) NSString *placementId;
@property (nonatomic, readwrite, getter = isLoading) BOOL loading;
@property (nonatomic, readwrite, strong) ANAdWebViewController *webViewController;
@property (nonatomic, readwrite, strong) NSMutableArray *mediatedAds;
@property (nonatomic, readwrite, strong) ANMediationAdViewController *mediationController;
@property (nonatomic, readwrite, assign) BOOL requestShouldBePosted;
@end

@implementation ANAdFetcher

@synthesize URL = __URL;
@synthesize autoRefreshTimer = __autoRefreshTimer;
@synthesize loading = __loading;
@synthesize data = __data;
@synthesize request = __request;
@synthesize connection = __connection;
@synthesize webViewController = __webViewController;
@synthesize delegate = __delegate;

- (id)init
{
	if (self = [super init])
    {
		self.data = [NSMutableData data];
        self.request = [ANAdFetcher initBasicRequest];
		self.successResultRequest = [ANAdFetcher initBasicRequest];
        [NSHTTPCookieStorage sharedHTTPCookieStorage].cookieAcceptPolicy = NSHTTPCookieAcceptPolicyAlways;
    }
    
	return self;
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
        
        if ([self.delegate autoRefreshIntervalForAdFetcher:self] > 0.0)
        {
            ANLogDebug(ANErrorString(@"fetcher_start_auto"));
        }
        else
        {
            ANLogDebug(ANErrorString(@"fetcher_start_single"));
        }
		
        self.URL = URL ? URL : [self adURLWithBaseURLString:[NSString stringWithFormat:@"http://%@?", AN_MOBILE_HOSTNAME]];
		
		if (self.URL != nil)
		{
			self.request.URL = self.URL;
			self.connection = [NSURLConnection connectionWithRequest:self.request delegate:self];
			
			if (self.connection != nil)
			{
				ANLogInfo(@"Beginning loading ad from URL: %@", self.URL);
				
                if (self.requestShouldBePosted) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kANAdFetcherWillRequestAdNotification
                                                                        object:self
                                                                      userInfo:[NSDictionary dictionaryWithObject:self.URL
                                                                                                           forKey:kANAdFetcherAdRequestURLKey]];
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	
    [__connection cancel];
	[__autoRefreshTimer invalidate];
}

- (NSString *)placementId
{
    return [self.delegate placementId];
}

#pragma mark Request Url Construction

- (NSString *)URLEncodingFrom:(NSString *)originalString {
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                 (CFStringRef)originalString,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'();:@&=+$,/?%#[]<>",
                                                                                 kCFStringEncodingUTF8);
}

- (NSString *)jsonFormatParameter {
    return @"&format=json";
}

- (NSString *)placementIdParameter {
    if (![self.placementId length] > 0) {
        ANLogError(ANErrorString(@"no_placement_id"));
        return @"";
    }
    
    return [NSString stringWithFormat:@"id=%@", [self URLEncodingFrom:self.placementId]];
}

- (NSString *)sdkVersionParameter {
    return [NSString stringWithFormat:@"&sdkver=%@", AN_SDK_VERSION];
}

- (NSString *)dontTrackEnabledParameter {
    return ANAdvertisingTrackingEnabled() ? @"" : @"&dnt=1";
}

- (NSString *)deviceMakeParameter {
    return @"&devmake=Apple";
}

- (NSString *)deviceModelParameter {
    return [NSString stringWithFormat:@"&devmodel=%@", [self URLEncodingFrom:ANDeviceModel()]];
}

- (NSString *)applicationIdParameter {
    NSString *appId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    return [NSString stringWithFormat:@"&appid=%@", appId];
}

- (NSString *)firstLaunchParameter {
    return isFirstLaunch() ? @"&firstlaunch=true" : @"";
}

- (NSString *)carrierMccMncParameters {
    NSString *param = @"";
    
    CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netinfo subscriberCellularProvider];

    // set the fields to empty string if not available
    NSString *carrierParameter =
    ([[carrier carrierName] length] > 0)
    ? [self URLEncodingFrom:[carrier carrierName]] : @"";
    
    NSString *mccParameter =
    ([[carrier mobileCountryCode] length] > 0)
    ? [self URLEncodingFrom:[carrier mobileCountryCode]] : @"";
    
    NSString *mncParameter =
    ([carrier mobileNetworkCode] > 0)
    ? [self URLEncodingFrom:[carrier mobileNetworkCode]] : @"";
    
    if ([carrierParameter length] > 0) {
        param = [param stringByAppendingString:
                 [NSString stringWithFormat:@"&carrier=%@", carrierParameter]];
    }
    
    if ([mccParameter length] > 0) {
        param = [param stringByAppendingString:
                 [NSString stringWithFormat:@"&mcc=%@", mccParameter]];
    }
    
    if ([mncParameter length] > 0) {
        param = [param stringByAppendingString:
                 [NSString stringWithFormat:@"&mnc=%@", mncParameter]];
    }
    
    return param;
}

- (NSString *)connectionTypeParameter {
    ANReachability *reachability = [ANReachability reachabilityForInternetConnection];
    ANNetworkStatus status = [reachability currentReachabilityStatus];
    return status == ANNetworkStatusReachableViaWiFi ? @"&connection_type=wifi" : @"&connection_type=wan";
}

- (NSString *)supplyTypeParameter {
    return @"&st=mobile_app";
}

- (NSString *)locationParameter {
    ANLocation *location = [self.delegate location];
    NSString *locationParameter = @"";
    
    if (location) {
        NSDate *locationTimestamp = location.timestamp;
        NSTimeInterval ageInSeconds = -1.0 * [locationTimestamp timeIntervalSinceNow];
        NSInteger ageInMilliseconds = (NSInteger)(ageInSeconds * 1000);
        
        locationParameter = [locationParameter
                             stringByAppendingFormat:@"&loc=%f,%f&loc_age=%ld&loc_prec=%f",
                             location.latitude, location.longitude,
                             (long)ageInMilliseconds, location.horizontalAccuracy];
    }
    
    return locationParameter;
}

- (NSString *)orientationParameter {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    return [NSString stringWithFormat:@"&orientation=%@",
            UIInterfaceOrientationIsLandscape(orientation) ? @"h" : @"v"];
}

- (NSString *)userAgentParameter {
    return [NSString stringWithFormat:@"&ua=%@",
            [self URLEncodingFrom:ANUserAgent()]];
}

- (NSString *)languageParameter {
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    return ([language length] > 0) ? [NSString stringWithFormat:@"&language=%@", language] : @"";
}

- (NSString *)devTimeParameter {
    int timeInMiliseconds = (int) [[NSDate date] timeIntervalSince1970];
    return [NSString stringWithFormat:@"&devtime=%d", timeInMiliseconds];
}

- (NSString *)nativeBrowserParameter {
    return [NSString stringWithFormat:@"&native_browser=%d", self.delegate.opensInNativeBrowser];
}

- (NSString *)psaAndReserveParameter {
    BOOL shouldServePsas = [self.delegate shouldServePublicServiceAnnouncements];
    CGFloat reserve = [self.delegate reserve];
    if (reserve > 0.0f) {
        NSString *reserveParameter = [self URLEncodingFrom:[NSString stringWithFormat:@"%f", reserve]];
        return [NSString stringWithFormat:@"&psa=0&reserve=%@", reserveParameter];
    } else {
        return shouldServePsas ? @"&psa=1" : @"&psa=0";
    }
}

- (NSString *)ageParameter {
    NSString *ageValue = [self.delegate age];
    if ([ageValue length] < 1) {
        return @"";
    }
    
    ageValue = [self URLEncodingFrom:ageValue];
    return [NSString stringWithFormat:@"&age=%@", ageValue];
}

- (NSString *)genderParameter {
    ANGender genderValue = [self.delegate gender];
    if (genderValue == MALE) {
        return @"&gender=m";
    } else if (genderValue == FEMALE) {
        return @"&gender=f";
    } else {
        return @"";
    }
}

- (NSString *)customKeywordsParameter {
    NSString *customKeywordsParameter = @"";
    NSMutableDictionary *customKeywords = [self.delegate customKeywords];
    
    if ([customKeywords count] < 1) {
        return @"";
    }
    NSArray *customKeywordsKeys = [customKeywords allKeys];
    
    for (int i = 0; i < [customKeywords count]; i++) {
        NSString *value;
        if ([customKeywordsKeys[i] length] > 0)
            value = [customKeywords valueForKey:customKeywordsKeys[i]];
        if (value) {
            customKeywordsParameter = [customKeywordsParameter stringByAppendingString:
                                       [NSString stringWithFormat:@"&%@=%@",
                                        customKeywordsKeys[i],
                                        [self URLEncodingFrom:value]]];
        }
    }
    return customKeywordsParameter;
}

- (NSURL *)adURLWithBaseURLString:(NSString *)urlString {
    urlString = [urlString stringByAppendingString:[self placementIdParameter]];
	urlString = [urlString stringByAppendingString:ANUdidParameter()];
    urlString = [urlString stringByAppendingString:[self dontTrackEnabledParameter]];
    urlString = [urlString stringByAppendingString:[self deviceMakeParameter]];
    urlString = [urlString stringByAppendingString:[self deviceModelParameter]];
    urlString = [urlString stringByAppendingString:[self carrierMccMncParameters]];
    urlString = [urlString stringByAppendingString:[self applicationIdParameter]];
    urlString = [urlString stringByAppendingString:[self firstLaunchParameter]];

    urlString = [urlString stringByAppendingString:[self locationParameter]];
    urlString = [urlString stringByAppendingString:[self userAgentParameter]];
    urlString = [urlString stringByAppendingString:[self orientationParameter]];
    urlString = [urlString stringByAppendingString:[self connectionTypeParameter]];
    urlString = [urlString stringByAppendingString:[self devTimeParameter]];
    urlString = [urlString stringByAppendingString:[self languageParameter]];

    urlString = [urlString stringByAppendingString:[self nativeBrowserParameter]];
    urlString = [urlString stringByAppendingString:[self psaAndReserveParameter]];
    urlString = [urlString stringByAppendingString:[self ageParameter]];
    urlString = [urlString stringByAppendingString:[self genderParameter]];
    urlString = [urlString stringByAppendingString:[self customKeywordsParameter]];

    urlString = [urlString stringByAppendingString:[self jsonFormatParameter]];
    urlString = [urlString stringByAppendingString:[self supplyTypeParameter]];
    urlString = [urlString stringByAppendingString:[self sdkVersionParameter]];
    
    if ([self.delegate respondsToSelector:@selector(extraParametersForAdFetcher:)]) {
        NSArray *extraParameters = [self.delegate extraParametersForAdFetcher:self];
        
        for (NSString *param in extraParameters) {
            urlString = [urlString stringByAppendingString:param];
        }
    }
	
	return [NSURL URLWithString:urlString];
}

- (void)processFinalResponse:(ANAdResponse *)response {
    [self.delegate adFetcher:self didFinishRequestWithResponse:response];
    [self startAutoRefreshTimer];
}

- (void)setupAutoRefreshTimerIfNecessary
{
    // stop old autoRefreshTimer
    [self.autoRefreshTimer invalidate];
    self.autoRefreshTimer = nil;
    
    // setup new autoRefreshTimer if refresh interval positive
    NSTimeInterval interval = [self.delegate autoRefreshIntervalForAdFetcher:self];
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
        CGSize sizeOfCreative;
        if ([response.width floatValue] > 0 && [response.height floatValue] > 0)
            sizeOfCreative = CGSizeMake([response.width floatValue], [response.height floatValue]);
        else
            sizeOfCreative = [self.delegate requestedSizeForAdFetcher:self];
        
        // Generate a new webview to contain the HTML
        ANWebView *webView = [[ANWebView alloc] initWithFrame:(CGRect){{0, 0}, {sizeOfCreative.width, sizeOfCreative.height}}];
        webView.backgroundColor = [UIColor clearColor];
        webView.opaque = NO;
        webView.scrollEnabled = NO;
        
        NSURL *baseURL = nil;
        
        
        if (response.isMraid)
        {
            // MRAID adapter
            NSBundle *resBundle = ANResourcesBundle();
            if (!resBundle) {
                ANLogError(@"Resource not found. Make sure the AppNexusSDKResources bundle is included in project");
                return;
            }
            NSString *mraidBundlePath = [resBundle pathForResource:@"MRAID" ofType:@"bundle"];
            if (!mraidBundlePath) {
                ANLogError(@"Resource not found. Make sure the AppNexusSDKResources bundle is included in project");
                return;
            }
            baseURL = [NSURL fileURLWithPath:mraidBundlePath];
            
            ANMRAIDAdWebViewController *mraidWebViewController = [[ANMRAIDAdWebViewController alloc] init];
            mraidWebViewController.mraidDelegate = self.delegate;
            self.webViewController = mraidWebViewController;
        }
        else
        {
            // standard banner ad
            baseURL = self.URL;
            
            self.webViewController = [[ANAdWebViewController alloc] init];
        }
        
        self.webViewController.adFetcher = self;
        self.webViewController.webView = webView;
        webView.delegate = self.webViewController;
        
        // Compare the size of the received impression with what the requested ad size is. If the two are different, send the ad delegate a message.
        CGSize receivedSize = webView.frame.size;
        CGSize requestedSize = [self.delegate requestedSizeForAdFetcher:self];
        
        if (CGSizeLargerThanSize(receivedSize, requestedSize))
        {
            ANLogInfo([NSString stringWithFormat:ANErrorString(@"adsize_too_big"), (int)requestedSize.width, (int)requestedSize.height, (int)receivedSize.width, (int)receivedSize.height]);
        }
        
        [webView loadHTMLString:response.content baseURL:baseURL];
    }
    
}

- (void)handleMediatedAds:(NSMutableArray *)mediatedAds
{
    // pop the front ad
    ANMediatedAd *currentAd = mediatedAds.firstObject;
    [mediatedAds removeObject:currentAd];
    
    ANAdResponseCode errorCode = ANDefaultCode;
    
    if (!currentAd) {
        ANLogDebug(@"ad was null");
        errorCode = ANAdResponseUnableToFill;
        [self finishRequestWithErrorAndRefresh:nil code:errorCode];
    } else {
        ANLogDebug([NSString stringWithFormat:ANErrorString(@"instantiating_class"), currentAd.className]);

        Class adClass = NSClassFromString(currentAd.className);
        
        // Check to see if an instance of this class exists
        if (!adClass) {
            ANLogError(ANErrorString(@"class_not_found_exception"));
            errorCode = ANAdResponseMediatedSDKUnavailable;
        } else {
            id adInstance = [[adClass alloc] init];
            
            if (!adInstance)
            {
                ANLogError([NSString stringWithFormat:ANErrorString(@"instance_exception"), @"ANCustomAdapterBanner or ANCustomAdapterInterstitial"]);
                errorCode = ANAdResponseMediatedSDKUnavailable;
            }
            else {
                [self initMediationController:adInstance resultCB:currentAd.resultCB];

                // Grab the size of the ad - interstitials will ignore this value
                CGSize sizeOfCreative = CGSizeMake([currentAd.width floatValue], [currentAd.height floatValue]);
                BOOL requestedSuccessfully = [self.mediationController
                                              requestAd:sizeOfCreative
                                              serverParameter:currentAd.param
                                              adUnitId:currentAd.adId
                                              adView:self.delegate];

                if (!requestedSuccessfully) {
                    errorCode = ANAdResponseMediatedSDKUnavailable;
                }
            }
        }
    }
    if (errorCode != ANDefaultCode) {
        [self fireResultCB:currentAd.resultCB reason:errorCode adObject:nil];
        return;
    }
    
    // otherwise, no error yet
    // now we wait for a mediation adapter to hit one of our callbacks.
}

- (void)initMediationController:(id<ANCustomAdapter>)adInstance
          resultCB:(NSString *)resultCB {
    // create new mediation controller
    self.mediationController = [ANMediationAdViewController initWithFetcher:self adViewDelegate:self.delegate];
    adInstance.delegate = self.mediationController;
    [self.mediationController setAdapter:adInstance];
    [self.mediationController setResultCBString:resultCB];
    
    //start timeout
    [self.mediationController startTimeout];
}

- (void)clearMediationController {
    // clear any old adapters if they exist
    [self.mediationController clearAdapter];
    self.mediationController = nil;    
}

- (void)finishRequestWithErrorAndRefresh:(NSDictionary *)errorInfo code:(NSInteger)code
{
    self.loading = NO;
    
    NSTimeInterval interval = [self.delegate autoRefreshIntervalForAdFetcher:self];
    ANLogInfo(@"No ad received. Will request ad in %f seconds.", interval);
    
    NSError *error = [NSError errorWithDomain:AN_ERROR_DOMAIN code:code userInfo:errorInfo];
    ANAdResponse *response = [ANAdResponse adResponseFailWithError:error];
    [self processFinalResponse:response];
}

- (void)startAutoRefreshTimer {
    if (self.autoRefreshTimer == nil) {
        ANLogDebug(ANErrorString(@"fetcher_stopped"));
    } else if ([self.autoRefreshTimer isScheduled]) {
        ANLogDebug(@"AutoRefresh timer already scheduled.");
    } else {
		[self.autoRefreshTimer scheduleNow];
	}
}

# pragma mark -
# pragma mark NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	@synchronized(self)
	{
		if (connection == self.connection)
		{
			if ([response isKindOfClass:[NSHTTPURLResponse class]])
			{
				NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
				NSInteger status = [httpResponse statusCode];
				
				if (status >= 400)
				{
					[connection cancel];
					NSDictionary *errorInfo = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:
																				  NSLocalizedString(@"Request failed with status code %d", @"Error Description: server request came back with error code."),
																				  status]
																		  forKey:NSLocalizedDescriptionKey];
					NSError *statusError = [NSError errorWithDomain:AN_ERROR_DOMAIN
															   code:status
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
		else if (connection == self.successResultConnection)
		{
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
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)d
{
	@synchronized(self)
	{
		if (connection == self.connection)
		{
			[self.data appendData:d];
		}
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	@synchronized(self)
	{
		if (connection == self.connection)
		{
            ANAdResponse *adResponse = [[ANAdResponse alloc] init];
            adResponse = [adResponse processResponseData:self.data];
            [self processAdResponse:adResponse];
		}
        // don't do anything for a succcessful resultCB
        else if (connection == self.successResultConnection) {
            ANLogDebug(@"Success resultCB finished loading");
        }
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	@synchronized(self)
	{
		if (connection == self.connection)
		{
			ANLogError(@"Ad view connection %@ failed with error %@", connection, error);
			
			self.loading = NO;
			
			[self setupAutoRefreshTimerIfNecessary];
			ANAdResponse *failureResponse = [ANAdResponse adResponseFailWithError:error];
            [self processFinalResponse:failureResponse];
		}
	}
}

#pragma mark handling resultCB

- (void)fireResultCB:(NSString *)resultCBString
              reason:(ANAdResponseCode)reason
            adObject:(id)adObject {
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
        [self processFinalResponse:response];
    } else {
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

- (NSString *)createResultCBRequest:(NSString *)baseResultCBString reason:(int)reasonCode {
    NSString *resultCBRequestString = [baseResultCBString
                                       stringByAppendingUrlParameter:@"reason"
                                       value:[NSString stringWithFormat:@"%d",reasonCode]];
    resultCBRequestString = [resultCBRequestString stringByAppendingString:ANUdidParameter()];
    return resultCBRequestString;
}

@end

