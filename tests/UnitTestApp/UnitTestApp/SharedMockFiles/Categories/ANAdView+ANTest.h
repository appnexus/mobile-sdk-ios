/*   Copyright 2014 APPNEXUS INC
 
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

#import "ANAdView+PrivateMethods.h"
#import "ANAdViewInternalDelegate.h"



static NSString * _Nonnull const kANAdViewAdWasClickedNotification              = @"adWasClicked";
static NSString * _Nonnull const kANAdViewAdWillPresentNotification             = @"adWillPresent";
static NSString * _Nonnull const kANAdViewAdDidPresentNotification              = @"adDidPresent";
static NSString * _Nonnull const kANAdViewAdWillCloseNotification               = @"adWillClose";
static NSString * _Nonnull const kANAdViewAdDidCloseNotification                = @"adDidClose";
static NSString * _Nonnull const kANAdViewAdWillLeaveApplicationNotification    = @"adWillLeaveApplication";
static NSString * _Nonnull const kANAdViewAdDidReceiveAppEventNotification      = @"adDidReceiveAppEvent";
static NSString * _Nonnull const kANAdViewAdFailedToDisplayNotification         = @"adFailedToDisplay";



@interface ANAdView (ANTest) <ANAdViewInternalDelegate>
@property (nonatomic, readwrite, weak, nullable)    id<ANAppEventDelegate>   appEventDelegate;


@end
