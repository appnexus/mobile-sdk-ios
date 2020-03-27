/*   Copyright 2020 APPNEXUS INC
 
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
#import <UIKit/UIKit.h>

#import "XCTestCase+ANBannerAdView.h"
#import "XCTestCase+ANAdResponse.h"
#import "ANUniversalAdFetcher+ANTest.h"
#import "ANBannerAdView+ANTest.h"
#import "ANHTTPStubbingManager.h"
#import "ANSDKSettings+PrivateMethods.h"
#import "ANUniversalTagRequestBuilder.h"
#import "ANNativeRenderingViewController.h"
#import "SDKValidationURLProtocol.h"
#import "NSURLRequest+HTTPBodyTesting.h"

@interface ANBannerNativeRenderAdOMIDViewablityTestCase : XCTestCase <ANBannerAdViewDelegate , SDKValidationURLProtocolDelegate >

@property (nonatomic, readwrite, strong)   ANBannerAdView     *bannerAdView;


//Expectations for OMID
@property (nonatomic, strong) XCTestExpectation *OMID100PercentViewableExpectation;
@property (nonatomic, strong) XCTestExpectation *OMID0PercentViewableExpectation;
@property (nonatomic, strong) XCTestExpectation *OMIDRemoveFriendlyObstructionExpectation;


@property (nonatomic) BOOL percentViewableFulfilled;
@property (nonatomic) BOOL removeFriendlyObstruction;
@property (nonatomic) UIView *friendlyObstruction;


@end



@implementation ANBannerNativeRenderAdOMIDViewablityTestCase

#pragma mark - Test lifecycle.

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
    
    
    self.bannerAdView = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 100, 300, 250)
                                                  placementId:@"13457285"
                                                       adSize:CGSizeMake(300, 250)];
    self.bannerAdView.accessibilityLabel = @"AdView";
    self.bannerAdView.rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    self.bannerAdView.delegate = self;
    self.bannerAdView.shouldAllowNativeDemand = YES;
    self.bannerAdView.enableNativeRendering = YES;
    
    self.bannerAdView.autoRefreshInterval = 0;
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.bannerAdView];
    
    
    
    self.friendlyObstruction=[[UIView alloc]initWithFrame:CGRectMake(0, 100, 300, 250)];
    [self.friendlyObstruction setBackgroundColor:[UIColor yellowColor]];
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.friendlyObstruction];
    
    self.percentViewableFulfilled = NO;
    self.removeFriendlyObstruction = NO;
    
    
    [SDKValidationURLProtocol setDelegate:self];
    [NSURLProtocol registerClass:[SDKValidationURLProtocol class]];
    
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    [[ANHTTPStubbingManager sharedStubbingManager] disable];
    [self.bannerAdView removeFromSuperview];
    [self.friendlyObstruction removeFromSuperview];
    self.bannerAdView.delegate = nil;
    self.bannerAdView.appEventDelegate = nil;
    self.bannerAdView = nil;
    [[UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController dismissViewControllerAnimated:NO
                                                                                                               completion:nil];
    
    // Clear all expectations for next test
    self.OMID100PercentViewableExpectation = nil;
    self.OMID0PercentViewableExpectation = nil;
    self.OMIDRemoveFriendlyObstructionExpectation = nil;
    
    self.percentViewableFulfilled = NO;
    self.removeFriendlyObstruction = NO;
    
}


- (void)testOMIDViewablePercentZero
{
    [self stubRequestWithResponse:@"NativeAsssemblyRendererOMID_Native_RTBResponse"];
    
    self.OMID0PercentViewableExpectation = [self expectationWithDescription:@"Didn't receive OMID view 0% event"];
    self.percentViewableFulfilled = NO;
    
    [self.bannerAdView loadAd];
    
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
        
    }];
    
}



- (void)testOMIDViewablePercent100
{
    [self stubRequestWithResponse:@"NativeAsssemblyRendererOMID_Native_RTBResponse"];
    
    self.friendlyObstruction.alpha = 0;
    [self.bannerAdView addOpenMeasurementFriendlyObstruction:self.friendlyObstruction];
    self.OMID100PercentViewableExpectation = [self expectationWithDescription:@"Didn't receive OMID view 100% event"];
    self.percentViewableFulfilled = NO;
    
    [self.bannerAdView loadAd];
    
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
        
    }];
    
}




- (void)testOMIDViewableRemoveFriendlyObstruction
{
    [self.bannerAdView addOpenMeasurementFriendlyObstruction:self.friendlyObstruction];
    [self.bannerAdView removeOpenMeasurementFriendlyObstruction:self.friendlyObstruction];
    
    [self stubRequestWithResponse:@"NativeAsssemblyRendererOMID_Native_RTBResponse"];
    
    self.OMID0PercentViewableExpectation = [self expectationWithDescription:@"Didn't receive OMID view 0% event"];
    self.percentViewableFulfilled = NO;
    
    [self.bannerAdView loadAd];
    
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
        
    }];
    
    XCTAssertEqual(self.bannerAdView.obstructionViews.count, 0);
}


- (void)testOMIDViewableRemoveAllFriendlyObstruction
{
    [self.bannerAdView addOpenMeasurementFriendlyObstruction:self.friendlyObstruction];
    [self.bannerAdView removeAllOpenMeasurementFriendlyObstructions];
    
    [self stubRequestWithResponse:@"NativeAsssemblyRendererOMID_Native_RTBResponse"];
    
    self.OMID0PercentViewableExpectation = [self expectationWithDescription:@"Didn't receive OMID view 0% event"];
    self.percentViewableFulfilled = NO;
    [self.bannerAdView loadAd];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
        
    }];
    XCTAssertEqual(self.bannerAdView.obstructionViews.count, 0);
}


#pragma mark - ANAdDelegate

- (void)adDidReceiveAd:(id)ad {
    [self.bannerAdView addSubview:self.friendlyObstruction];
}


- (void)ad:(id)ad requestFailedWithError:(NSError *)error {
    
}



# pragma mark - Ad Server Response Stubbing

- (void)stubRequestWithResponse:(NSString *)responseName
{
    NSBundle *currentBundle = [NSBundle bundleForClass:[self class]];
    
    NSString *baseResponse = [NSString stringWithContentsOfFile: [currentBundle pathForResource:responseName ofType:@"json"]
                                                       encoding: NSUTF8StringEncoding
                                                          error: nil ];
    
    ANURLConnectionStub *requestStub = [[ANURLConnectionStub alloc] init];
    
    
    requestStub.requestURL      = [[[ANSDKSettings sharedInstance] baseUrlConfig] utAdRequestBaseUrl];
    requestStub.responseCode    = 200;
    requestStub.responseBody    = baseResponse;
    
    [[ANHTTPStubbingManager sharedStubbingManager] addStub:requestStub];
}


# pragma mark - Intercept HTTP Request Callback

- (void)didReceiveIABResponse:(NSString *)response {
    NSLog(@"OMID response %@",response);
    if ( self.OMID0PercentViewableExpectation && [response containsString:@"%22percentageInView%22%3A0%2C%22"] && !self.percentViewableFulfilled) {
        self.percentViewableFulfilled = YES;
        // Only assert if it has been setup to assert.
        [self.OMID0PercentViewableExpectation fulfill];
        
    }else  if (!self.removeFriendlyObstruction && self.OMID100PercentViewableExpectation && [response containsString:@"%22percentageInView%22%3A100%2C%22"] && !self.percentViewableFulfilled) {
        self.percentViewableFulfilled = YES;
        // Only assert if it has been setup to assert.
        [self.OMID100PercentViewableExpectation fulfill];
        
    }
    else  if ( self.removeFriendlyObstruction && self.OMIDRemoveFriendlyObstructionExpectation && [response containsString:@"%22percentageInView%22%3A0%2C%22"] && !self.percentViewableFulfilled) {
        self.percentViewableFulfilled = YES;
        // Only assert if it has been setup to assert.
        [self.OMIDRemoveFriendlyObstructionExpectation fulfill];
        
    }
    
    
}


@end
