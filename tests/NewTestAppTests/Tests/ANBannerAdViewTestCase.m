/*   Copyright 2017 APPNEXUS INC
 
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

#import <XCTest/XCTest.h>
#import "ANBannerAdView.h"
#import "ANMediationContainerView.h"

@interface ANBannerAdViewTestCase : XCTestCase

@end

@implementation ANBannerAdViewTestCase

// Test dynamic width contentView with manually sized ANBannerAdView
- (void)test1 {
    ANMediationContainerView *bannerContentView = [[ANMediationContainerView alloc] initWithMediatedView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 250)]];
    ANBannerAdView *bannerAdView = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    
    
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootViewController.view addSubview:containerView];


}

@end
