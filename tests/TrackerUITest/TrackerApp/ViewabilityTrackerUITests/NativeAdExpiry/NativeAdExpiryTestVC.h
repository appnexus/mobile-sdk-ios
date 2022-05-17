/*   Copyright 2022 APPNEXUS INC
 
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

#import <UIKit/UIKit.h>

/*
 About BannerNativeAdViewabilityTrackerTestVC
 Load BannerNativeAd Selected UI Testcase
 To test OMID Events is fired by SDK
 */

@interface NativeAdExpiryTestVC : UIViewController
// Used to set navigation bar title
@property (nonatomic, readwrite, strong) NSString *adType;

@end
