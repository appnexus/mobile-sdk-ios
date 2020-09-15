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


#import <sys/utsname.h>
#import <AdSupport/AdSupport.h>
#import "ANGlobal.h"
#import "ANLogging.h"
#import "ANSDKSettings+PrivateMethods.h"
#import "ANHTTPNetworkSession.h"
#import "ANOMIDImplementation.h"
#import "ANGDPRSettings.h"
#import "ANReachability.h"
#import "ANCarrierObserver.h"


NSString * __nonnull const  ANInternalDelgateTagKeyPrimarySize                             = @"ANInternalDelgateTagKeyPrimarySize";
NSString * __nonnull const  ANInternalDelegateTagKeySizes                                  = @"ANInternalDelegateTagKeySizes";
NSString * __nonnull const  ANInternalDelegateTagKeyAllowSmallerSizes                      = @"ANInternalDelegateTagKeyAllowSmallerSizes";

NSString * __nonnull const  kANUniversalAdFetcherWillRequestAdNotification                 = @"kANUniversalAdFetcherWillRequestAdNotification";
NSString * __nonnull const  kANUniversalAdFetcherAdRequestURLKey                           = @"kANUniversalAdFetcherAdRequestURLKey";
NSString * __nonnull const  kANUniversalAdFetcherWillInstantiateMediatedClassNotification  = @"kANUniversalAdFetcherWillInstantiateMediatedClassNotification";
NSString * __nonnull const  kANUniversalAdFetcherMediatedClassKey                          = @"kANUniversalAdFetcherMediatedClassKey";
 
NSString * __nonnull const  kANUniversalAdFetcherDidReceiveResponseNotification            = @"kANUniversalAdFetcherDidReceiveResponseNotification";
NSString * __nonnull const  kANUniversalAdFetcherAdResponseKey                             = @"kANUniversalAdFetcherAdResponseKey";

NSMutableURLRequest  *utMutableRequest = nil;


NSString *__nonnull ANDeviceModel()
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return @(systemInfo.machine);
}

BOOL ANAdvertisingTrackingEnabled() {
    // If a user does turn this off, use the unique identifier *only* for the following:
    // - Frequency capping
    // - Conversion events
    // - Estimating number of unique users
    // - Security and fraud detection
    // - Debugging
    return [ASIdentifierManager sharedManager].isAdvertisingTrackingEnabled;
}


NSString * __nonnull const kANFirstLaunchKey = @"kANFirstLaunchKey";

BOOL ANIsFirstLaunch()
{
	BOOL isFirstLaunch = ![[NSUserDefaults standardUserDefaults] boolForKey:kANFirstLaunchKey];
	
	if (isFirstLaunch)
    {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:kANFirstLaunchKey];
    }
    
    return isFirstLaunch;
}


NSString * __nonnull ANUUID()
{
    return  [[[NSUUID alloc] init] UUIDString];
}

NSString *__nonnull ANAdvertisingIdentifier() {
    static NSString *udidComponent = @"";
    
    if ([udidComponent isEqualToString:@""]) {
        NSString *advertisingIdentifier = [[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString];
        
        if (advertisingIdentifier) {
            udidComponent = advertisingIdentifier;
            ANLogInfo(@"IDFA = %@", advertisingIdentifier);
        } else {
            ANLogWarn(@"No advertisingIdentifier retrieved. Cannot generate udidComponent.");
        }
	}
	
    return udidComponent;
}

NSString *__nonnull ANErrorString( NSString * __nonnull key) {
    return NSLocalizedStringFromTableInBundle(key, AN_ERROR_TABLE, ANResourcesBundle(), @"");
}

NSError *__nonnull ANError(NSString *__nonnull key, NSInteger code, ...) {
    NSDictionary *errorInfo = nil;
    va_list args;
    va_start(args, code);
    NSString *localizedDescription = ANErrorString(key);
    if (localizedDescription) {
        localizedDescription = [[NSString alloc] initWithFormat:localizedDescription
                                                      arguments:args];
    } else {
        ANLogWarn(@"Could not find localized error string for key %@", key);
        localizedDescription = @"";
    }
    va_end(args);
    errorInfo = @{NSLocalizedDescriptionKey: localizedDescription};
    return [NSError errorWithDomain:AN_ERROR_DOMAIN
                               code:code
                           userInfo:errorInfo];
}

NSBundle *__nonnull ANResourcesBundle() {
    static dispatch_once_t resBundleToken;
    static NSBundle *resBundle;
    static ANGlobal *globalInstance;
    dispatch_once(&resBundleToken, ^{
        globalInstance = [[ANGlobal alloc] init];
        resBundle = [NSBundle bundleForClass:[globalInstance class]];
    });
    return resBundle;
}

NSString *__nullable ANPathForANResource(NSString *__nullable name, NSString *__nullable type) {
    NSString *path = [ANResourcesBundle() pathForResource:name ofType:type];
    if (!path) {
        ANLogError(@"Could not find resource %@.%@. Please make sure that all the resources in sdk/resources are included in your app target's \"Copy Bundle Resources\".", name, type);
    }
    return path;
}

NSString *__nullable ANConvertToNSString(id __nullable value) {
    if ([value isKindOfClass:[NSString class]]) return value;
    if ([value respondsToSelector:@selector(stringValue)]) {
        return [value stringValue];
    }
    ANLogWarn(@"Failed to convert to NSString");
    return nil;
}

CGRect ANAdjustAbsoluteRectInWindowCoordinatesForOrientationGivenRect(CGRect rect) {
    // If portrait, no adjustment is necessary.
    if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) {
        return rect;
    }
    
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    // iOS 8
    if (!CGPointEqualToPoint(screenBounds.origin, CGPointZero) || screenBounds.size.width > screenBounds.size.height) {
        return rect;
    }
    
    // iOS 7 and below
    CGFloat flippedOriginX = screenBounds.size.height - (rect.origin.y + rect.size.height);
    CGFloat flippedOriginY = screenBounds.size.width - (rect.origin.x + rect.size.width);
    
    CGRect adjustedRect;
    switch ([UIApplication sharedApplication].statusBarOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
            adjustedRect = CGRectMake(flippedOriginX, rect.origin.x, rect.size.height, rect.size.width);
            break;
        case UIInterfaceOrientationLandscapeRight:
            adjustedRect = CGRectMake(rect.origin.y, flippedOriginY, rect.size.height, rect.size.width);
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            adjustedRect = CGRectMake(flippedOriginY, flippedOriginX, rect.size.width, rect.size.height);
            break;
        default:
            adjustedRect = rect;
            break;
    }
    
    return adjustedRect;
}

NSString *__nullable ANMRAIDBundlePath() {
    NSString *mraidPath = ANPathForANResource(@"ANMRAID", @"bundle");
    if (!mraidPath) {
        ANLogError(@"Could not find ANMRAID.bundle. Please make sure that ANMRAID.bundle resource in sdk/resources is included in your app target's \"Copy Bundle Resources\".");
        return nil;
    }
    return mraidPath;
}

BOOL ANHasHttpPrefix(NSString * __nonnull url) {
    return ([url hasPrefix:@"http"] || [url hasPrefix:@"https"]);
}

static BOOL notificationsEnabled = NO;

void ANSetNotificationsEnabled(BOOL enabled) {
    notificationsEnabled = enabled;
}

void ANPostNotifications(NSString * __nonnull name, id __nullable object, NSDictionary * __nullable userInfo) {
    if (notificationsEnabled) {
        [[NSNotificationCenter defaultCenter] postNotificationName:name
                                                            object:object
                                                          userInfo:userInfo];
    }
}

CGRect ANPortraitScreenBounds() {
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    if ([UIApplication sharedApplication].statusBarOrientation != UIInterfaceOrientationPortrait) {
        if (!CGPointEqualToPoint(screenBounds.origin, CGPointZero) || screenBounds.size.width > screenBounds.size.height) {
            // need to orient screen bounds
            switch ([UIApplication sharedApplication].statusBarOrientation) {
                case UIInterfaceOrientationLandscapeLeft:
                    return CGRectMake(0, 0, screenBounds.size.height, screenBounds.size.width);
                    break;
                case UIInterfaceOrientationLandscapeRight:
                    return CGRectMake(0, 0, screenBounds.size.height, screenBounds.size.width);
                    break;
                case UIInterfaceOrientationPortraitUpsideDown:
                    return CGRectMake(0, 0, screenBounds.size.width, screenBounds.size.height);
                    break;
                default:
                    break;
            }
        }
    }
    return screenBounds;
}

CGRect ANPortraitScreenBoundsApplyingSafeAreaInsets() {
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    if (@available(iOS 11.0, *)) {
        CGFloat topPadding = window.safeAreaInsets.top;
        CGFloat bottomPadding = window.safeAreaInsets.bottom;
        CGFloat leftPadding = window.safeAreaInsets.left;
        CGFloat rightPadding = window.safeAreaInsets.right;
        screenBounds = CGRectMake(leftPadding, topPadding, screenBounds.size.width - (leftPadding + rightPadding), screenBounds.size.height - (topPadding + bottomPadding));
    }
    if ([UIApplication sharedApplication].statusBarOrientation != UIInterfaceOrientationPortrait) {
        if (!CGPointEqualToPoint(screenBounds.origin, CGPointZero) || screenBounds.size.width > screenBounds.size.height) {
            // need to orient screen bounds
            switch ([UIApplication sharedApplication].statusBarOrientation) {
                case UIInterfaceOrientationLandscapeLeft:
                    return CGRectMake(0, 0, screenBounds.size.height, screenBounds.size.width);
                    break;
                case UIInterfaceOrientationLandscapeRight:
                    return CGRectMake(0, 0, screenBounds.size.height, screenBounds.size.width);
                    break;
                case UIInterfaceOrientationPortraitUpsideDown:
                    return CGRectMake(0, 0, screenBounds.size.width, screenBounds.size.height);
                    break;
                default:
                    break;
            }
        }
    }
    return screenBounds;
}

NSURLRequest * __nonnull ANBasicRequestWithURL(NSURL * __nonnull URL) {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL
                                                                cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                            timeoutInterval:kAppNexusRequestTimeoutInterval];
    [request setValue:[ANGlobal getUserAgent] forHTTPHeaderField:@"User-Agent"];
    return [request copy];
}

NSNumber * __nullable ANiTunesIDForURL(NSURL * __nonnull URL) {
    if ([URL.host isEqualToString:@"itunes.apple.com"]) {
        NSRegularExpression *idPattern = [[NSRegularExpression alloc] initWithPattern:@"id(\\d+)"
                                                                              options:0
                                                                                error:nil];
        NSRange idRange = [idPattern rangeOfFirstMatchInString:URL.absoluteString
                                                       options:0
                                                         range:NSMakeRange(0, URL.absoluteString.length)];
        if (idRange.length != 0) {
            NSString *idString = [[URL.absoluteString substringWithRange:idRange] substringFromIndex:2];
            return @([idString longLongValue]);
        }
    }
    return nil;
}

BOOL ANCanPresentFromViewController(UIViewController * __nullable viewController) {
    return viewController.view.window != nil ? YES : NO;
}




@implementation ANGlobal

+ (void)load {
    
    // No need for "dispatch once" since `load` is called only once during app launch.
    [ANGlobal getUserAgent];
    [self constructAdServerRequestURL];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUserAgentDidChangeNotification:) name:@"kUserAgentDidChangeNotification" object:nil];
    
}

+(nullable NSMutableURLRequest *) adServerRequestURL {
    return utMutableRequest;
}

+ (void) constructAdServerRequestURL {
    NSString      *urlString  = [[[ANSDKSettings sharedInstance] baseUrlConfig] utAdRequestBaseUrl];
    NSURL                *URL             = [NSURL URLWithString:urlString];
    
    utMutableRequest = (NSMutableURLRequest *)ANBasicRequestWithURL(URL);
    [utMutableRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [utMutableRequest setHTTPMethod:@"POST"];
    
    [ANHTTPNetworkSession startTaskWithHttpRequest:utMutableRequest];
}

+ (void)handleUserAgentDidChangeNotification:(NSNotification *)notification {
    [utMutableRequest setValue:[ANGlobal getUserAgent] forHTTPHeaderField:@"user-agent"];
    [[NSNotificationCenter defaultCenter] removeObserver:@"kUserAgentDidChangeNotification"];
}

+ (void) openURL: (nonnull NSString *)urlString
{
    if (@available(iOS 10.0, *)) {
        if([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:nil];
            return;
        }
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}


#pragma mark - Custom keywords.

// See also [AdSettings -setCustomKeywordsAsMapInEntryPoint:].
//
// Use alias for default separator string of comma (,).
//
+ (NSMutableDictionary<NSString *, NSString *> * __nonnull)convertCustomKeywordsAsMapToStrings: (NSDictionary<NSString *, NSArray<NSString *> *> * __nonnull)keywordsMap
                                                                           withSeparatorString: (nonnull NSString *)separatorString
{
    NSMutableDictionary<NSString *, NSString *>  *keywordsMapToStrings  = [[NSMutableDictionary alloc] init];

    for (NSString *key in keywordsMap)
    {
        NSArray   *mapValuesArray  = [keywordsMap objectForKey:key];
        NSString  *mapValueString  = [mapValuesArray componentsJoinedByString:separatorString];

        [keywordsMapToStrings setObject:mapValueString forKey:key];
    }

    return  [keywordsMapToStrings mutableCopy];
}


// Use this method to test for the existence of a property, then return its value if it is implemented by the target object.
// Should also work for methods that have no arguments.
//
// NB  Does not distinguish between a return value of nil and the case where the object does not respond to the getter selector.
//
+ (nullable id) valueOfGetterProperty: (nonnull NSString *)stringOfGetterProperty
                            forObject: (nonnull id)objectImplementingGetterProperty
{
    SEL  getterMethod  = NSSelectorFromString(stringOfGetterProperty);

    if ([objectImplementingGetterProperty respondsToSelector:getterMethod]) {
        return  ((id (*)(id, SEL))[objectImplementingGetterProperty methodForSelector:getterMethod])(objectImplementingGetterProperty, getterMethod);
    }

    return  nil;
}

+ (ANAdType) adTypeStringToEnum:(nonnull NSString *)adTypeString
{
    NSString  *adTypeStringVerified  = ANConvertToNSString(adTypeString);

    if ([adTypeStringVerified length] < 1) {
        ANLogError(@"Could not resolve string from adTypeString.");
        return  ANAdTypeUnknown;
    }

    //
    NSString  *adTypeStringLowercase  = [adTypeString lowercaseString];

    if ([adTypeStringLowercase compare:@"banner"] == NSOrderedSame) {
        return  ANAdTypeBanner;

    } else if ([adTypeStringLowercase compare:@"video"] == NSOrderedSame) {
        return  ANAdTypeVideo;

    } else if ([adTypeStringLowercase compare:@"native"] == NSOrderedSame) {
        return  ANAdTypeNative;
    }

    ANLogError(@"UNRECOGNIZED adTypeString.  (%@)", adTypeString);
    return  ANAdTypeUnknown;
}


//
+ (nonnull NSString *) getUserAgent
{
    static NSString  *userAgent               = nil;
    static BOOL       userAgentQueryIsActive  = NO;

    // Return customUserAgent if provided
    NSString *customUserAgent = ANSDKSettings.sharedInstance.customUserAgent;
    if(customUserAgent && customUserAgent.length != 0){
        ANLogDebug(@"userAgent=%@", customUserAgent);
        return customUserAgent;
    }

    if (!userAgent) {
        if (!userAgentQueryIsActive)
        {
            @synchronized (self) {
                userAgentQueryIsActive = YES;
            }

            dispatch_async(dispatch_get_main_queue(),
            ^{
                WKWebView  *webViewForUserAgent  = [[WKWebView alloc] init];
                UIWindow   *currentWindow        = [UIApplication sharedApplication].keyWindow;

                [webViewForUserAgent setHidden:YES];
                [currentWindow addSubview:webViewForUserAgent];

                [webViewForUserAgent evaluateJavaScript: @"navigator.userAgent"
                                      completionHandler: ^(id __nullable userAgentString, NSError * __nullable error)
                                      {
                                          ANLogDebug(@"userAgentString=%@", userAgentString);
                                          userAgent = userAgentString;
                                          

                                          [webViewForUserAgent stopLoading];
                                          [webViewForUserAgent removeFromSuperview];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"kUserAgentDidChangeNotification" object:nil userInfo:nil];
                                          @synchronized (self) {
                                              userAgentQueryIsActive = NO;
                                          }
                                      } ];
            });
        }
    }

    //
    ANLogDebug(@"userAgent=%@", userAgent);
    return userAgent;
}

#pragma mark - Get Video Orientation Method

+ (ANVideoOrientation) parseVideoOrientation:(NSString *)aspectRatio {
    double aspectRatioValue = [aspectRatio doubleValue];
    return aspectRatio == 0? ANUnknown : (aspectRatioValue == 1)? ANSquare : (aspectRatioValue > 1)? ANLandscape : ANPortrait;
}

+ (void) setWebViewCookie:(nonnull WKWebView*)webView{
    if([ANGDPRSettings canAccessDeviceData]){
         
         for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
             // Skip cookies that will break our script
             if ([cookie.value rangeOfString:@"'"].location != NSNotFound) {
                 continue;
             }
             if (@available(iOS 11.0, *)) {
                 [webView.configuration.websiteDataStore.httpCookieStore setCookie:cookie completionHandler:nil];
             } else {
                 // Fallback on earlier versions
                 [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
             }
         }
     }
}
@end
