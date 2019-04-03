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

#import "ANAdView.h"
#import "ANAdViewInternalDelegate.h"

static NSString *const kANAdViewAdWasClickedNotification = @"adWasClicked";
static NSString *const kANAdViewAdWillPresentNotification = @"adWillPresent";
static NSString *const kANAdViewAdDidPresentNotification = @"adDidPresent";
static NSString *const kANAdViewAdWillCloseNotification = @"adWillClose";
static NSString *const kANAdViewAdDidCloseNotification = @"adDidClose";
static NSString *const kANAdViewAdWillLeaveApplicationNotification = @"adWillLeaveApplication";
static NSString *const kANAdViewAdDidReceiveAppEventNotification = @"adDidReceiveAppEvent";
static NSString *const kANAdViewAdFailedToDisplayNotification = @"adFailedToDisplay";

@interface ANAdView (ANTest) <ANAdViewInternalDelegate>

@end