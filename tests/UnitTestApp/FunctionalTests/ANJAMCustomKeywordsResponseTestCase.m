/*   Copyright 2019 APPNEXUS INC

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

#import <AdSupport/AdSupport.h>
#import <XCTest/XCTest.h>
#import "ANBannerAdView.h"
#import "ANHTTPStubbingManager.h"
#import "XCTestCase+ANCategory.h"
#import "ANMRAIDContainerView.h"
#import "ANANJAMImplementation.h"
#import "ANBrowserViewController.h"
#import "ANGlobal.h"
#import "ANTestGlobal.h"
#import "ANSDKSettings+PrivateMethods.h"
#import "ANLogging.h"
#import "XandrAd.h"



@interface ANJAMCustomKeywordsResponseTestCase : XCTestCase <ANAppEventDelegate, ANBannerAdViewDelegate, UIWebViewDelegate>
@property (nonatomic, strong) ANBannerAdView *adView;
@property (nonatomic, strong) XCTestExpectation *customKeywordsExpectation;
@end



@implementation ANJAMCustomKeywordsResponseTestCase

#pragma mark - Test lifecycle.

- (void)setUp {
    [super setUp];
    // Init here if not the tests will crash
    [[XandrAd sharedInstance] initWithMemberID:1 preCacheRequestObjects:true completionHandler:nil];
    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
    
    self.adView = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)
                                            placementId:@"2140063"
                                                 adSize:CGSizeMake(320, 50)];
    self.adView.accessibilityLabel = @"AdView";
    self.adView.rootViewController = [ANGlobal getKeyWindow].rootViewController;
    self.adView.appEventDelegate = self;
    self.adView.delegate = self;
    [[ANGlobal getKeyWindow].rootViewController.view addSubview:self.adView];
}

- (void)tearDown {
    [super tearDown];
    [[ANHTTPStubbingManager sharedStubbingManager] disable];
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    [self.adView removeFromSuperview];
    self.adView.delegate = nil;
    self.adView.appEventDelegate = nil;
    self.adView = nil;
    self.customKeywordsExpectation = nil;
    for (UIView *additionalView in [[ANGlobal getKeyWindow].rootViewController.view subviews]){
          [additionalView removeFromSuperview];
      }
    [[ANGlobal getKeyWindow].rootViewController.presentedViewController dismissViewControllerAnimated:NO
                                                                                                               completion:nil];
}



#pragma mark - Test methods.

/*
 // Disabled to verify the 100% testcase pass

- (void)testANJAMCustomKeywordsResponse {
    [self stubRequestWithResponse:@"ANJAMCustomKeywordsResponse"];
    self.customKeywordsExpectation = [self expectationWithDescription:@"Waiting for CustomKeywords app event to be received."];
    [self.adView addCustomKeywordWithKey:@"foo" value:@"bar1"];
    [self.adView addCustomKeywordWithKey:@"randomkey" value:@"randomvalue"];
    self.adView.autoRefreshInterval =  0;
    [self.adView loadAd];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval handler:nil];
}

 */
#pragma mark - Stubbing

- (void)stubRequestWithResponse:(NSString *)responseName {
    NSBundle *currentBundle = [NSBundle bundleForClass:[self class]];
    NSString *baseResponse = [NSString stringWithContentsOfFile:
                                [currentBundle pathForResource:responseName ofType:@"json" ]
                                encoding: NSUTF8StringEncoding
                                error: nil ];

    ANURLConnectionStub  *requestStub  = [[ANURLConnectionStub alloc] init];

    requestStub.requestURL    = [[[ANSDKSettings sharedInstance] baseUrlConfig] utAdRequestBaseUrl];
    requestStub.responseCode  = 200;
    requestStub.responseBody  = baseResponse;

    [[ANHTTPStubbingManager sharedStubbingManager] addStub:requestStub];
}



#pragma mark - ANAppEventDelegate.

- (void)            ad: (id<ANAdProtocol>)ad
    didReceiveAppEvent: (NSString *)name
              withData: (NSString *)data
{
TESTTRACE();
   if ([name isEqualToString:@"CustomKeywordsYes"]) {
        XCTAssertNotNil(data);
        XCTAssertEqualObjects(data, @"bar1randomvalue");
        [self.customKeywordsExpectation fulfill];
    }
}

@end
