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
#import "NSTimer+ANCategory.h"
#import "UIWebView+ANCategory.h"
#import "ANReachability.h"
#import "ANAdResponse.h"
#import "ANAdWebViewController.h"
#import "ANGlobal.h"
#import "ANLogging.h"
#import "ANWebView.h"
#import "NSString+ANCategory.h"
#import "ANCustomAdapter.h"
#import "ANMediatedAd.h"
#import "ANLocation.h"
#import "ANMediationAdViewController.h"

#import <iAd/iAd.h>

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0
#import <AdSupport/AdSupport.h>
#endif

#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

NSString *const kANAdFetcherWillRequestAdNotification = @"kANAdFetcherWillRequestAdNotification";
NSString *const kANAdFetcherAdRequestURLKey = @"kANAdFetcherAdRequestURLKey";

NSString *const kANAdRequestComponentOrientationPortrait = @"portrait";
NSString *const kANAdRequestComponentOrientationLandscape = @"landscape";

@interface ANAdFetcher () <NSURLConnectionDataDelegate>

@property (nonatomic, readwrite, strong) NSURLConnection *successResultConnection;
@property (nonatomic, readwrite, strong) NSMutableURLRequest *successResultRequest;
@property (nonatomic, readwrite, strong) NSURLConnection *connection;
@property (nonatomic, readwrite, strong) NSMutableURLRequest *request;
@property (nonatomic, readwrite, strong) NSMutableData *data;
@property (nonatomic, readwrite, strong) NSTimer *autorefreshTimer;
@property (nonatomic, readwrite, strong) NSURL *URL;
@property (nonatomic, readonly) NSString *placementId;
@property (nonatomic, readwrite, getter = isLoading) BOOL loading;
@property (nonatomic, readwrite, strong) ANAdWebViewController *webViewController;
@property (nonatomic, readwrite, strong) NSMutableArray *mediatedAds;
@property (nonatomic, readwrite, strong) ANMediationAdViewController *mediationController;

- (void)startAutorefreshTimer;
- (void)processAdResponse:(ANAdResponse *)response;

@end

@implementation ANAdFetcher

@synthesize URL = __URL;
@synthesize autorefreshTimer = __autorefreshTimer;
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

- (void)autorefreshTimerDidFire:(NSTimer *)timer
{
	[self.connection cancel];
	self.loading = NO;
    
    [self requestAd];
}

- (void)requestAdWithURL:(NSURL *)URL
{
    [self.autorefreshTimer invalidate];
    
    if (!self.isLoading)
	{
        ANLogInfo(ANErrorString(@"fetcher_start"));
        
        if ([self.delegate autorefreshIntervalForAdFetcher:self] > 0.0)
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
				
				[[NSNotificationCenter defaultCenter] postNotificationName:kANAdFetcherWillRequestAdNotification
																	object:self
																  userInfo:[NSDictionary dictionaryWithObject:self.URL forKey:kANAdFetcherAdRequestURLKey]];
				self.loading = YES;
			}
			else
			{
				NSDictionary *errorInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"Unable to make request due to bad URL connection.", @"Error: Bad URL connection.")
																	  forKey:NSLocalizedDescriptionKey];
				NSError *badURLConnectionError = [NSError errorWithDomain:AN_ERROR_DOMAIN code:ANAdResponseBadURLConnection userInfo:errorInfo];
				ANAdResponse *response = [ANAdResponse adResponseFailWithError:badURLConnectionError];
				[self.delegate adFetcher:self didFinishRequestWithResponse:response];
			}
		}
		else
		{
			NSDictionary *errorInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"Unable to make request due to malformed URL.", @"Error: Malformed URL")
                                                                  forKey:NSLocalizedDescriptionKey];
            NSError *badURLError = [NSError errorWithDomain:AN_ERROR_DOMAIN code:ANAdResponseBadURL userInfo:errorInfo];
            ANAdResponse *response = [ANAdResponse adResponseFailWithError:badURLError];
            [self.delegate adFetcher:self didFinishRequestWithResponse:response];
		}
	}
	else
    {
		ANLogWarn(ANErrorString(@"moot_restart"));
    }
}

- (void)requestAd
{
    [self requestAdWithURL:nil];
}

- (void)stopAd
{
    [self.autorefreshTimer invalidate];
    self.autorefreshTimer = nil;
    
    [self.connection cancel];
    self.connection = nil;
    
    self.loading = NO;
    self.data = nil;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	
    [__connection cancel];
	[__autorefreshTimer invalidate];
}

- (NSString *)placementId
{
    return [self.delegate placementIdForAdFetcher:self];
}

- (NSString *)jsonFormatParameter
{
    return @"&format=json";
}

- (NSString *)placementIdParameter
{
    if (![self.placementId length] > 0)
    {
        ANLogError(ANErrorString(@"no_placement_id"));
        return @"";
    }
    
    return [NSString stringWithFormat:@"&id=%@", [self.placementId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

- (NSString *)versionComponent
{
    return [NSString stringWithFormat:@"&sdkver=%@", AN_SDK_VERSION];
}

- (NSString *)dontTrackEnabledParameter
{
    NSString *donttrackEnabled = @"";
    
    if (!ANAdvertisingTrackingEnabled()) {
        donttrackEnabled = @"&dnt=1";
    }
    
    return donttrackEnabled;
}

- (NSString *)deviceMakeParameter
{
    return @"&devmake=Apple";
}

- (NSString *)deviceModelParameter
{
    NSString *modelComponent = [NSString stringWithFormat:@"&devmodel=%@", [ANDeviceModel() stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    return modelComponent;
}

- (NSString *)applicationIdParameter
{
    NSString *appId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    return [NSString stringWithFormat:@"&appid=%@", appId];
}

- (NSString *)firstLaunchParameter
{
    if (isFirstLaunch())
    {
        return [NSString stringWithFormat:@"&firstlaunch=true"];
    }
    
    return @"";
}



- (NSString *)carrierParameter
{
    NSString *carrierParameter = @"";
    
    ANReachability *reachability = [ANReachability reachabilityForInternetConnection];
    ANNetworkStatus status = [reachability currentReachabilityStatus];
    
    if (status == ANNetworkStatusReachableViaWiFi)
    {
        carrierParameter = @"wifi";
    }
    else
    {
        CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
        CTCarrier *carrier = [netinfo subscriberCellularProvider];
        
        if ([[carrier carrierName] length] > 0)
        {
            carrierParameter = [carrier carrierName];
        }
    }
	
    if ([carrierParameter length] > 0)
    {
		carrierParameter = [carrierParameter stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        carrierParameter = [NSString stringWithFormat:@"&carrier=%@", carrierParameter];
    }
    
    return carrierParameter;
}

- (NSString *)locationParameter
{
    ANLocation *location = [self.delegate location];
    NSString *locationParamater = @"";
    
    if (location != nil)
    {
        NSDate *locationTimestamp = location.timestamp;
        NSTimeInterval ageInSeconds = -1.0 * [locationTimestamp timeIntervalSinceNow];
        NSInteger ageInMilliseconds = (NSInteger)(ageInSeconds * 1000);
        
        locationParamater = [locationParamater
                             stringByAppendingFormat:@"&loc=%f,%f&loc_age=%d&loc_prec=%f",
                             location.latitude, location.longitude,
                             ageInMilliseconds, location.horizontalAccuracy];
    }
    
    return locationParamater;
}

- (NSString *)isTestParameter
{
    if (AN_DEBUG_MODE)
    {
        return @"&istest=true";
    }
    
    return @"";
}

- (NSString *)orientationParameter
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    return [NSString stringWithFormat:@"&orientation=%@", UIInterfaceOrientationIsLandscape(orientation) ? @"h" : @"v"];
}

- (NSString *)userAgentParameter
{
    return [NSString stringWithFormat:@"&ua=%@", [ANUserAgent() stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

- (NSString *)supplyTypeParameter
{
    return @"&st=mobile_app";
}

- (NSString *)psasAndReserveParameter
{
    BOOL shouldServePsas = [self.delegate shouldServePublicServiceAnnouncements];
    CGFloat reserve = [self.delegate reserve];
    if (reserve > 0.0f) {
        NSString *reserveParameter = [[NSString stringWithFormat:@"%f", reserve] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        return [NSString stringWithFormat:@"&psas=0&reserve=%@", reserveParameter];
    } else {
        return shouldServePsas ? @"&psas=1" : @"&psas=0";
    }
}

- (NSString *)ageParameter
{
    NSString *ageValue = [self.delegate age];
    if ([ageValue length] < 1) {
        return @"";
    }
    
    ageValue = [ageValue stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return [NSString stringWithFormat:@"&age=%@", ageValue];
}

- (NSString *)genderParameter
{
    ANGender genderValue = [self.delegate gender];
    if (genderValue == MALE) {
        return @"&gender=m";
    } else if (genderValue == FEMALE) {
        return @"&gender=f";
    } else {
        return @"";
    }
}

- (NSString *)customSegmentsParameter
{
    NSString *customSegmentsParameter = @"";
    NSMutableDictionary *customSegments = [self.delegate customSegments];
    
    if ([customSegments count] < 1) {
        return @"";
    }
    NSArray *customKeyArray = [customSegments allKeys];
    
    for (int i = 0; i < [customSegments count]; i++) {
        NSString *value;
        if ([customKeyArray[i] length] > 0)
            value = [customSegments valueForKey:customKeyArray[i]];
        if (value) {
            customSegmentsParameter = [customSegmentsParameter stringByAppendingString:
                                       [NSString stringWithFormat:@"&%@=%@",
                                        customKeyArray[i],
                                        [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        }
    }
    return customSegmentsParameter;
}

- (NSURL *)adURLWithBaseURLString:(NSString *)urlString
{
	
	urlString = [urlString stringByAppendingString:ANUdidParameter()];
    urlString = [urlString stringByAppendingString:[self placementIdParameter]];
    urlString = [urlString stringByAppendingString:[self dontTrackEnabledParameter]];
    urlString = [urlString stringByAppendingString:[self deviceMakeParameter]];
    urlString = [urlString stringByAppendingString:[self applicationIdParameter]];
    urlString = [urlString stringByAppendingString:[self firstLaunchParameter]];
    urlString = [urlString stringByAppendingString:[self deviceModelParameter]];
    urlString = [urlString stringByAppendingString:[self carrierParameter]];
    urlString = [urlString stringByAppendingString:[self locationParameter]];
    urlString = [urlString stringByAppendingString:[self isTestParameter]];
    urlString = [urlString stringByAppendingString:[self orientationParameter]];
    urlString = [urlString stringByAppendingString:[self jsonFormatParameter]];
    urlString = [urlString stringByAppendingString:[self userAgentParameter]];
    urlString = [urlString stringByAppendingString:[self supplyTypeParameter]];
    urlString = [urlString stringByAppendingString:[self psasAndReserveParameter]];
    urlString = [urlString stringByAppendingString:[self ageParameter]];
    urlString = [urlString stringByAppendingString:[self genderParameter]];
    urlString = [urlString stringByAppendingString:[self customSegmentsParameter]];
    
    if ([self.delegate respondsToSelector:@selector(extraParametersForAdFetcher:)])
    {
        NSArray *extraParameters = [self.delegate extraParametersForAdFetcher:self];
        
        for (NSString *param in extraParameters)
        {
            urlString = [urlString stringByAppendingString:param];
        }
    }
	
	return [NSURL URLWithString:urlString];
}

- (void)setupAutorefreshTimerIfNecessary
{
    NSTimeInterval interval = [self.delegate autorefreshIntervalForAdFetcher:self];
    
    if (interval > 0.0f)
    {
        self.autorefreshTimer = [NSTimer timerWithTimeInterval:interval
                                                        target:self
                                                      selector:@selector(autorefreshTimerDidFire:)
                                                      userInfo:nil
                                                       repeats:NO];
    }
    else
    {
        [self.autorefreshTimer invalidate];
        self.autorefreshTimer = nil;
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
        webView.backgroundColor = [UIColor whiteColor];
        webView.opaque = NO;
        webView.scrollEnabled = NO;
        
        NSURL *baseURL = nil;
        
        
        if (response.isMraid)
        {
            // MRAID adapter
            NSString *mraidBundlePath = [[NSBundle mainBundle] pathForResource:@"MRAID" ofType:@"bundle"];
            baseURL = [NSURL fileURLWithPath:mraidBundlePath];
            
            self.webViewController = [[ANMRAIDAdWebViewController alloc] init];
            self.webViewController.adFetcher = self;
        }
        else
        {
            // standard banner ad
            baseURL = self.URL;
            
            self.webViewController = [[ANAdWebViewController alloc] init];
            self.webViewController.adFetcher = self;
        }
        
        self.webViewController.webView = webView;
        webView.delegate = self.webViewController;
        
        // Compare the size of the received impression with what the requested ad size is. If the two are different, send the ad delegate a message.
        CGSize receivedSize = webView.frame.size;
        CGSize requestedSize = [self.delegate requestedSizeForAdFetcher:self];
        
        if (CGSizeLargerThanSize(receivedSize, requestedSize))
        {
            ANLogError([NSString stringWithFormat:ANErrorString(@"adsize_too_big"), (int)requestedSize.width, (int)requestedSize.height, (int)receivedSize.width, (int)receivedSize.height]);
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
                                              location:[self.delegate location]
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
    self.mediationController = [ANMediationAdViewController initWithFetcher:self];
    adInstance.delegate = self.mediationController;
    adInstance.responseURLString = resultCB;
    [self.mediationController setAdapter:adInstance];
    
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
    
    NSTimeInterval interval = [self.delegate autorefreshIntervalForAdFetcher:self];
    ANLogInfo(@"No ad received. Will request ad in %f seconds.", interval);
    
    NSError *error = [NSError errorWithDomain:AN_ERROR_DOMAIN code:code userInfo:errorInfo];
    ANAdResponse *response = [ANAdResponse adResponseFailWithError:error];
    [self.delegate adFetcher:self didFinishRequestWithResponse:response];
    
    [self startAutorefreshTimer];
}

- (void)startAutorefreshTimer
{
    if (self.autorefreshTimer == nil)
	{
		ANLogDebug(ANErrorString(@"fetcher_stopped"));
	}
    else if ([self.autorefreshTimer isScheduled])
	{
		ANLogDebug(@"Autorefresh timer already scheduled.");
	}
	else
	{
		[self.autorefreshTimer scheduleNow];
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
				int status = [httpResponse statusCode];
				
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
			
			ANLogDebug(@"Response %@ received", response);
			
			[self setupAutorefreshTimerIfNecessary];
		}
        // don't process the success resultCB response, just log it.
		else if (connection == self.successResultConnection)
		{
			if ([response isKindOfClass:[NSHTTPURLResponse class]])
			{
				NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
				int status = [httpResponse statusCode];
				
				ANLogDebug(@"Received response %@ with code %d from response URL request.", httpResponse, status);
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
			
			ANAdResponse *failureResponse = [ANAdResponse adResponseFailWithError:error];
			[self.delegate adFetcher:self didFinishRequestWithResponse:failureResponse];
			
			[self setupAutorefreshTimerIfNecessary];
			[self startAutorefreshTimer];
		}
	}
}

#pragma mark handling resultCB

- (void)fireResultCB:(NSString *)resultCBString
              reason:(ANAdResponseCode)reason
            adObject:(id)adObject {
    self.loading = NO;
    // fire the resultCB if there is one
    if ([resultCBString length] > 0) {
        // if it was successful, don't act on the response
        if (reason == ANAdResponseSuccessful) {
            self.successResultRequest.URL = [NSURL URLWithString:[self createResultCBRequest:resultCBString reason:reason]];
            self.successResultConnection = [NSURLConnection connectionWithRequest:self.successResultRequest delegate:self];
            
        	ANAdResponse *response = [ANAdResponse adResponseSuccessfulWithAdObject:adObject];
            [self.delegate adFetcher:self didFinishRequestWithResponse:response];
        }
        // otherwise treat it as a normal request
        else {
            [self requestAdWithURL:[NSURL URLWithString:[self createResultCBRequest:resultCBString reason:reason]]];
        }
    } else if (reason != ANAdResponseSuccessful) {
        // if no resultCB and no ads yet, look for the next ad in the current array
        [self processAdResponse:nil];
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

