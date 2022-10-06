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
#import "XCTestCase+ANBannerAdView.h"
#import "XCTestCase+ANAdResponse.h"
#import "ANAdFetcher+ANTest.h"
#import "ANBannerAdView+ANTest.h"

@interface ANAdViewMRAIDCreativeTestCase : XCTestCase

@property (nonatomic, readwrite, strong) ANAdFetcher *adFetcher;

@end

@implementation ANAdViewMRAIDCreativeTestCase

- (void)setUp {
    [super setUp];
    self.adFetcher = nil;
}

- (void)testExample {
    ANBannerAdView *bannerAdView = [self bannerViewWithFrameSize:CGSizeMake(300, 250)];
    [bannerAdView setAdSize:CGSizeMake(320, 50)];

    self.adFetcher = [[ANAdFetcher alloc] initWithDelegate:bannerAdView];

    NSMutableArray<id>  *adsArray  = [self adsArrayFromFirstTagInJSONResource:kANAdResponseSuccessfulMRAIDListener];

    [self.adFetcher handleStandardAd:adsArray[0]];
    UIView *view = self.adFetcher.adView;
    [bannerAdView setContentView:view];
}

@end
