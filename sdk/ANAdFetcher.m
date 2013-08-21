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

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0
#import <AdSupport/AdSupport.h>
#endif

#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

NSString *const kANAdFetcherWillRequestAdNotification = @"kANAdFetcherWillRequestAdNotification";
NSString *const kANAdFetcherDidReceiveResponseNotification = @"kANAdFetcherDidReceiveResponseNotification";
NSString *const kANAdFetcherAdRequestURLKey = @"kANAdFetcherAdRequestURLKey";
NSString *const kANAdFetcherAdResponseKey = @"kANAdFetcherAdResponseKey";

NSString *const kANAdRequestComponentOrientationPortrait = @"portrait";
NSString *const kANAdRequestComponentOrientationLandscape = @"landscape";
NSString *const kANAdResponseAdsKey = @"ads";
NSString *const kANAdResponseTypeKey = @"type";
NSString *const kANAdResponseWidthKey = @"width";
NSString *const kANAdResponseHeightKey = @"height";
NSString *const kANAdResponseContentKey = @"content";

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 50000
@interface ANAdFetcher () <NSURLConnectionDataDelegate>
#else
@interface ANAdFetcher ()
#endif

@property (nonatomic, readwrite, strong) NSURLConnection *connection;
@property (nonatomic, readwrite, strong) NSMutableURLRequest *request;
@property (nonatomic, readwrite, strong) NSMutableData *data;
@property (nonatomic, readwrite, strong) NSTimer *autorefreshTimer;
@property (nonatomic, readwrite, strong) NSURL *URL;
@property (nonatomic, readonly) NSString *placementId;
@property (nonatomic, readwrite, getter = isLoading) BOOL loading;
@property (nonatomic, readwrite, strong) ANAdWebViewController *webViewController;

- (void)startAutorefreshTimer;
- (NSURL *)adURL;
- (void)processResponseData:(NSData *)data;

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
		
        self.request = [[NSMutableURLRequest alloc] initWithURL:nil
													cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
												timeoutInterval:kAppNexusRequestTimeoutInterval];
		
		[self.request setValue:ANUserAgent() forHTTPHeaderField:@"User-Agent"];
    }
    
	return self;
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
        ANLogInfo(NSLocalizedStringFromTable(@"fetcher_start", AN_ERROR_TABLE, @""));
        
        if ([self.delegate autorefreshIntervalForAdFetcher:self] > 0.0)
        {
            ANLogDebug(NSLocalizedStringFromTable(@"fetcher_start_auto", AN_ERROR_TABLE, @""));
        }
        else
        {
            ANLogDebug(NSLocalizedStringFromTable(@"fetcher_start_single", AN_ERROR_TABLE, @""));
        }
        
        self.URL = URL ? URL : [self adURL];
		
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
		ANLogWarn(NSLocalizedStringFromTable(@"moot_restart", AN_ERROR_TABLE, @""));
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
        ANLogError(NSLocalizedStringFromTable(@"no_placement_id", AN_ERROR_TABLE, @""));
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
    NSString *locationParamater = @"";
    CLLocation *location = lastKnownLocation();
    
    if (location != nil)
    {
        CLLocationCoordinate2D coordinate = location.coordinate;
        locationParamater = [locationParamater stringByAppendingFormat:@"&loc=%f,%f", coordinate.latitude, coordinate.longitude];
        
        NSDate *locationTimestamp = location.timestamp;
        NSTimeInterval ageInSeconds = -1.0 * [locationTimestamp timeIntervalSinceNow];
        NSInteger ageInMilliseconds = (NSInteger)(ageInSeconds * 1000);
        
        locationParamater = [locationParamater stringByAppendingFormat:@"&loc_age=%d", ageInMilliseconds];
        CLLocationAccuracy horizontalAccuracy = location.horizontalAccuracy;
        locationParamater = [locationParamater stringByAppendingFormat:@"&loc_prec=%f", horizontalAccuracy];
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

- (NSURL *)adURL
{
	NSString *urlString = [NSString stringWithFormat:@"http://%@/mob?", AN_MOBILE_HOSTNAME];
    
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

- (void)processResponseData:(NSData *)data
{
    NSError *error = nil;
    
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    if (error == nil)
    {
        NSArray *ads = [jsonDict objectForKey:kANAdResponseAdsKey];
        
        if ([ads count] > 0)
        {
            // TODO: What happens if we have multiple ads? For now, just grab one...
            NSDictionary *ad = [ads objectAtIndex:0];
            
            // Grab the size of the ad
            NSString *widthString = [ad objectForKey:kANAdResponseWidthKey];
            NSString *heightString = [ad objectForKey:kANAdResponseHeightKey];
            
            // Grab the type of the ad
            NSString *typeString = [ad objectForKey:kANAdResponseTypeKey];
            
            // Grab the ad's content
            NSString *contentString = [ad objectForKey:kANAdResponseContentKey];
            
            ANLogDebug(@"Received %@ ad with size %@x%@ and content: %@", typeString, widthString, heightString, contentString);
            
            NSRange mraidJSRange = [contentString rangeOfString:@"mraid.js"];
            
            CGSize sizeOfCreative;
            if ([widthString floatValue] > 0 && [heightString floatValue] > 0)
            {
                sizeOfCreative = CGSizeMake([widthString floatValue], [heightString floatValue]);
            }
            else
            {
                sizeOfCreative = [self.delegate requestedSizeForAdFetcher:self];
            }
            
            // Generate a new webview to contain the HTML
            ANWebView *webView = [[ANWebView alloc] initWithFrame:(CGRect){{0, 0}, {sizeOfCreative.width, sizeOfCreative.height}}];
            webView.backgroundColor = [UIColor whiteColor];
            webView.opaque = NO;
            webView.scrollEnabled = NO;
            
            NSURL *baseURL = nil;
			
            if (mraidJSRange.location != NSNotFound)
            {
                // MRAID adapter
                NSString *mraidBundlePath = [[NSBundle mainBundle] pathForResource:@"MRAID" ofType:@"bundle"];
                baseURL = [NSURL fileURLWithPath:mraidBundlePath];
                
                self.webViewController = [[ANMRAIDAdWebViewController alloc] init];
                self.webViewController.adFetcher = self;
            }
            else
            {
                // Regular banner ad
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
                ANLogError([NSString stringWithFormat:NSLocalizedStringFromTable(@"adsize_too_big", AN_ERROR_TABLE, @""), (int)requestedSize.width, (int)requestedSize.height, (int)receivedSize.width, (int)receivedSize.height]);
            }
            
            [webView loadHTMLString:contentString baseURL:baseURL];
		}
        else
        {
			self.loading = NO;
			
            NSTimeInterval interval = [self.delegate autorefreshIntervalForAdFetcher:self];
            ANLogInfo(@"No ad received. Will request ad in %f seconds.", interval);
            
            NSDictionary *errorInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"Request got successful response from server, but no ads were available.", @"Error: Response was received, but it contained no ads")
                                                                  forKey:NSLocalizedDescriptionKey];
            NSError *noAdsError = [NSError errorWithDomain:AN_ERROR_DOMAIN code:ANAdResponseNoAds userInfo:errorInfo];
            ANAdResponse *response = [ANAdResponse adResponseFailWithError:noAdsError];
            [self.delegate adFetcher:self didFinishRequestWithResponse:response];
            
			
            [self startAutorefreshTimer];
        }
    }
    else
    {
		self.loading = NO;
		
        ANLogError(@"Ad response could not be parsed. Failed with error %@", error);
        
        ANAdResponse *response = [ANAdResponse adResponseFailWithError:error];
        [self.delegate adFetcher:self didFinishRequestWithResponse:response];
    }
}

- (void)startAutorefreshTimer
{
    if (self.autorefreshTimer == nil)
	{
		ANLogDebug(NSLocalizedStringFromTable(@"fetcher_stopped", AN_ERROR_TABLE, @""));
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

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)d
{
	[self.data appendData:d];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *response = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
    ANLogDebug(@"Ad fetcher %@ received response: %@", self, response);
	
	response = response ? response : @"";
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kANAdFetcherDidReceiveResponseNotification object:self userInfo:[NSDictionary dictionaryWithObject:response forKey:kANAdFetcherAdResponseKey]];
	
	[self processResponseData:self.data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	ANLogError(@"Ad view connection %@ failed with error %@", connection, error);
    
	self.loading = NO;
    
    ANAdResponse *failureResponse = [ANAdResponse adResponseFailWithError:error];
    [self.delegate adFetcher:self didFinishRequestWithResponse:failureResponse];
    
    [self setupAutorefreshTimerIfNecessary];
	[self startAutorefreshTimer];
}

@end
