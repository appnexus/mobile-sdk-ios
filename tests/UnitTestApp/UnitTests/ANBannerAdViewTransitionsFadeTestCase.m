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

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "ANBannerAdView.h"
#import "ANAdFetcher.h"
#import "XCTestCase+ANCategory.h"
#import "XCTestCase+ANBannerAdView.h"
#import "ANLogManager.h"
#import "ANBannerAdView+ANTest.h"

@interface ANBannerAdViewTransitionsFadeTestCase : XCTestCase
@property (nonatomic) ANBannerAdView *bannerAdView;
@end

@implementation ANBannerAdViewTransitionsFadeTestCase


- (void)setUp {
    [super setUp];
    [self createBannerView];
}

- (void)tearDown {
    [super tearDown];
    [self cleanupRootViewController];
}

- (void)createBannerView {
    ANBannerAdView *bannerAdView = [self bannerViewWithFrameSize:CGSizeMake(300, 250)];
    self.bannerAdView = bannerAdView;
}

- (void)cleanupRootViewController {
    [self.bannerAdView removeFromSuperview];
    
    for (UIView *additionalView in [[ANGlobal getKeyWindow].rootViewController.view subviews]){
          [additionalView removeFromSuperview];
      }
}

- (void)testFadeTransition {
    // Setup
    ANBannerAdView *bannerAdView = self.bannerAdView;
    bannerAdView.transitionType = ANBannerViewAdTransitionTypeFade;
    bannerAdView.transitionDuration = 2.5f;
    
    // Adding Content View
    [bannerAdView setContentView:[self catContentView]];
    XCTAssert([bannerAdView.transitionInProgress boolValue] == YES);
    [self keyValueObservingExpectationForObject:bannerAdView
                                        keyPath:@"transitionInProgress"
                                  expectedValue:@(NO)];
    [self waitForExpectationsWithTimeout:bannerAdView.transitionDuration + 0.1
                                 handler:^(NSError *error) {
                                     XCTAssert([bannerAdView.transitionInProgress boolValue] == NO);
                                     [bannerAdView removeFromSuperview];
    }];
}

@end
