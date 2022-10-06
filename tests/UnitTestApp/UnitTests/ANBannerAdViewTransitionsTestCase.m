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

@interface ANBannerAdViewTransitionsTestCase : XCTestCase
@property (nonatomic, weak) ANBannerAdView *bannerAdView;
@property (nonatomic, strong) NSLayoutConstraint *centerXConstraint;
@property (nonatomic, strong) NSLayoutConstraint *centerYConstraint;
@end

@implementation ANBannerAdViewTransitionsTestCase


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
    UIViewController *rootViewController = [ANGlobal getKeyWindow].rootViewController;
    bannerAdView.rootViewController = rootViewController;
    [rootViewController.view addSubview:bannerAdView];

    self.centerXConstraint = [NSLayoutConstraint constraintWithItem:rootViewController.view
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:bannerAdView
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0f
                                                           constant:0.0f];
    self.centerYConstraint = [NSLayoutConstraint constraintWithItem:rootViewController.view
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:bannerAdView
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0f
                                                           constant:0.0f];
    [rootViewController.view addConstraints:@[self.centerXConstraint, self.centerYConstraint]];
    self.bannerAdView = bannerAdView;
}

- (void)cleanupRootViewController {
    [self.bannerAdView.rootViewController.view removeConstraints:@[self.centerXConstraint, self.centerYConstraint]];
    self.centerXConstraint = nil;
    self.centerYConstraint = nil;
    [self.bannerAdView removeFromSuperview];
    
    for (UIView *additionalView in [[ANGlobal getKeyWindow].rootViewController.view subviews]){
          [additionalView removeFromSuperview];
      }
}

- (void)testFlipTransition {
    // Setup
    ANBannerAdView *bannerAdView = self.bannerAdView;
    bannerAdView.transitionType = ANBannerViewAdTransitionTypeFlip;
    bannerAdView.transitionDuration = 2.5f;
    
    // Adding first content view
    UIView *catContentView = [self catContentView];
    [bannerAdView setContentView:catContentView];
    [XCTestCase delayForTimeInterval:bannerAdView.transitionDuration + 2.0f];
    XCTAssert([bannerAdView.transitionInProgress boolValue] == NO);
    XCTAssert([bannerAdView.subviews count] == 1);
    XCTAssert([bannerAdView.subviews firstObject] == catContentView);
    
    // Adding second content view
    UIView *dogContentView = [self dogContentView];
    [bannerAdView setContentView:dogContentView];
    [XCTestCase delayForTimeInterval:bannerAdView.transitionDuration + 2.0f];
    XCTAssert([bannerAdView.transitionInProgress boolValue] == NO);
    XCTAssert([[bannerAdView subviews] count] == 1);
    XCTAssert([bannerAdView.subviews firstObject] == dogContentView);

    [bannerAdView removeFromSuperview];
}

- (void)testFlipTransition2 {
    // Setup
    ANBannerAdView *bannerAdView = self.bannerAdView;
    bannerAdView.transitionType = ANBannerViewAdTransitionTypeFlip;
    bannerAdView.transitionDuration = 2.5f;

    // Adding first content view
    UIView *catContentView = [self catContentView];
    [bannerAdView setContentView:catContentView];
    [XCTestCase delayForTimeInterval:1.5f];
    
    // Adding second content view (first transition still in progress)
    UIView *dogContentView = [self dogContentView];
    [bannerAdView setContentView:dogContentView];
    [XCTestCase delayForTimeInterval:2.0f];
    
    // Second transition should still be in progress
    XCTAssert([bannerAdView.transitionInProgress boolValue] == YES);
    // First transition would be over by this point, but the first view should still be in the hierarchy
    XCTAssert([bannerAdView.subviews count] == 2);
    
    [XCTestCase delayForTimeInterval:1.0f];
    
    // Second transition should be over by this point
    XCTAssert([bannerAdView.transitionInProgress boolValue] == NO);
    XCTAssert([bannerAdView.subviews count] == 1);
    XCTAssert([bannerAdView.subviews firstObject] == dogContentView);
}

@end
