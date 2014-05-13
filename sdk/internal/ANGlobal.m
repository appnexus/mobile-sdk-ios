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

#import "ANGlobal.h"
#import "ANBasicConfig.h"

#import "ANLogging.h"

#import <sys/utsname.h>
#import <AdSupport/AdSupport.h>

NSString *const kANFirstLaunchKey = @"kANFirstLaunchKey";

NSString *ANUserAgent()
{
    static NSString *userAgent = nil;
	
    if (userAgent == nil)
    {
        UIWebView *webview = [[UIWebView alloc] init];
        userAgent = [[webview stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"] copy];
		webview.delegate = nil;
		[webview stopLoading];
    }
    
    return userAgent;
}

NSString *ANDeviceModel()
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

BOOL ANAdvertisingTrackingEnabled()
{
    // Beginning in iOS 6, Apple allows users to turn off advertising tracking in their settings, which we must respect.
    // By default, this value is YES. If a user does turn this off, use the unique identifier *only* for the following:
    // Frequency capping, conversion events, estimating number of unique users, security and fraud detection, and debugging.
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0
    if (NSClassFromString(@"ASIdentifierManager"))
    {
        return [ASIdentifierManager sharedManager].isAdvertisingTrackingEnabled;
    }
#endif
    
    return YES;
}

BOOL isFirstLaunch()
{
	BOOL isFirstLaunch = ![[NSUserDefaults standardUserDefaults] boolForKey:kANFirstLaunchKey];
	
	if (isFirstLaunch)
    {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:kANFirstLaunchKey];
    }
    
    return isFirstLaunch;
}

NSString *ANUDID() {
    static NSString *udidComponent = @"";
    
    if ([udidComponent isEqualToString:@""]) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0
        if (NSClassFromString(@"ASIdentifierManager")) {
            // iOS 6: Use the ASIdentifierManager provided method of getting the identifier
            NSString *advertisingIdentifier = [[ASIdentifierManager sharedManager]
                                               .advertisingIdentifier UUIDString];
            
            if (advertisingIdentifier) {
                udidComponent = advertisingIdentifier;
            }
            else {
                ANLogWarn(@"No advertisingIdentifier retrieved. Cannot generate udidComponent.");
            }
        }
#endif
	}
	
    return udidComponent;
}

NSString *ANErrorString(NSString *key) {
    return NSLocalizedStringFromTable(key, AN_ERROR_TABLE, @"");
}

NSBundle *ANResourcesBundle() {
    static NSBundle *resBundle;
    if (!resBundle) {
        NSString *resBundlePath = [[NSBundle mainBundle] pathForResource:AN_RESOURCE_BUNDLE ofType:@"bundle"];
        resBundle = resBundlePath ? [NSBundle bundleWithPath:resBundlePath] : [NSBundle mainBundle];
    }
    return resBundle;
}

NSString *convertToNSString(id value) {
    if ([value isKindOfClass:[NSString class]]) return value;
    if ([value respondsToSelector:@selector(stringValue)]) {
        return [value stringValue];
    }
    ANLogWarn(@"Failed to convert to NSString");
    return nil;
}

CGRect adjustAbsoluteRectInWindowCoordinatesForOrientationGivenRect(CGRect rect) {
    CGRect screenBounds = [UIScreen mainScreen].bounds;
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

NSString *ANMRAIDBundlePath() {
    NSBundle *resBundle = ANResourcesBundle();
    if (!resBundle) {
        ANLogError(@"Resource not found. Make sure the %@ bundle is included in project", AN_RESOURCE_BUNDLE);
        return @"";
    }
    NSString *mraidBundlePath = [resBundle pathForResource:@"MRAID" ofType:@"bundle"];
    if (!mraidBundlePath) {
        ANLogError(@"Resource not found. Make sure the %@ bundle is included in project", AN_RESOURCE_BUNDLE);
        return @"";
    }
    return mraidBundlePath;
}

BOOL hasHttpPrefix(NSString *url) {
    return ([url hasPrefix:@"http"] || [url hasPrefix:@"https"]);
}

static NSMutableSet *invalidNetworks;

NSMutableSet *ANInvalidNetworks() {
    if (!invalidNetworks) {
        invalidNetworks = [NSMutableSet new];
    }
    return invalidNetworks;
}

void ANAddInvalidNetwork(NSString *network) {
    if (!invalidNetworks) {
        invalidNetworks = [NSMutableSet new];
    }
    [invalidNetworks addObject:network];
}

static BOOL notificationsEnabled = NO;

void ANSetNotificationsEnabled(BOOL enabled) {
    notificationsEnabled = enabled;
}

void ANPostNotifications(NSString *name, id object, NSDictionary *userInfo) {
    if (notificationsEnabled) {
        [[NSNotificationCenter defaultCenter] postNotificationName:name
                                                            object:object
                                                          userInfo:userInfo];
    }
}