/*   Copyright 2019 Xandr INC
 
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

#import "AppDelegate.h"
#import "ANLogManager.h"
#import "ANHTTPStubbingManager.h"
#import "ANTestGlobal.h"
#import "ANGlobal.h"
#if __has_include(<AppTrackingTransparency/AppTrackingTransparency.h>)
    #import <AppTrackingTransparency/AppTrackingTransparency.h>
#endif

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [ANGlobal userAgent];

    [ANLogManager setANLogLevel:ANLogLevelAll];
    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
  
    
    // Override point for customization after application launch.
    return YES;
}


- (void)requestTrackingAuthorization{
    // Checking the OS version before calling the Tracking Consent dialog, it's available only in iOS 14 and above
    if (@available(iOS 14, *)) {
#if __has_include(<AppTrackingTransparency/AppTrackingTransparency.h>)
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus authStatus) {
            switch (authStatus) {
                case ATTrackingManagerAuthorizationStatusNotDetermined:
                    NSLog(@"Tracking Authorization Status==NotDetermined");
                    break;
                case ATTrackingManagerAuthorizationStatusRestricted:
                    NSLog(@"Tracking Authorization Status==Restricted");
                    break;
                case ATTrackingManagerAuthorizationStatusDenied:
                    NSLog(@"Tracking Authorization Status==Denied");
                    break;
                case ATTrackingManagerAuthorizationStatusAuthorized:
                    NSLog(@"Tracking Authorization Status==Authorized");
                    break;
            }
        }];
#endif
    }
}

#if __IPHONE_9_0
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
#else
    - (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
#endif
        
        return UIInterfaceOrientationMaskAll;
    }
    
    

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if (@available(iOS 14, *)) {
            [self requestTrackingAuthorization];
        }
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
