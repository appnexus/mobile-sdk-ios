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

BOOL CGSizeLargerThanSize(CGSize firstSize, CGSize secondSize)
{
    if ((firstSize.height > secondSize.height) && (firstSize.width > secondSize.width))
    {
        return YES;
    }
    
    return NO;
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



NSString *ANUdidParameter() {
    static NSString *udidComponent = nil;
    
    if (udidComponent == nil) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0
        if (NSClassFromString(@"ASIdentifierManager")) {
            // iOS 6: Use the ASIdentifierManager provided method of getting the identifier
            NSString *advertisingIdentifier = [[ASIdentifierManager sharedManager]
                                               .advertisingIdentifier UUIDString];
            
            if (advertisingIdentifier != nil) {
                udidComponent = [NSString stringWithFormat:@"&idfa=%@", advertisingIdentifier];
            }
            else {
                ANLogError(@"No advertisingIdentifier retrieved. Cannot generate udidComponent.");
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
    NSString *resBundlePath = [[NSBundle mainBundle] pathForResource:AN_RESOURCE_BUNDLE ofType:@"bundle"];
    return [NSBundle bundleWithPath:resBundlePath];
}
