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
#import "ANNativeAdResponse.h"

@interface ANNativeAdOMIDViewablityTestCase : XCTestCase < SDKValidationURLProtocolDelegate , ANNativeAdResponseProtocol , ANNativeAdRequestDelegate >

@property (nonatomic, readwrite, strong)   ANNativeAdResponse     *nativeResponse;

@property (nonatomic, readwrite, strong)  ANNativeAdRequest     *adRequest;


//Expectations for OMID
@property (nonatomic, strong) XCTestExpectation *OMID100PercentViewableExpectation;
@property (nonatomic, strong) XCTestExpectation *OMID0PercentViewableExpectation;
@property (nonatomic, strong) XCTestExpectation *OMIDRemoveFriendlyObstructionExpectation;


@property (nonatomic) BOOL percentViewableFulfilled;
@property (nonatomic) BOOL removeFriendlyObstruction;
@property (nonatomic) UIView *friendlyObstruction;

@property (nonatomic) UIView *nativeView;

@property (nonatomic) NSString *testcase;


@end



@implementation ANNativeAdOMIDViewablityTestCase

#pragma mark - Test lifecycle.

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
    
    
    self.adRequest = [[ANNativeAdRequest alloc] init];
    self.adRequest.delegate = self;
    
    self.percentViewableFulfilled = NO;
    self.removeFriendlyObstruction = NO;
    self.friendlyObstruction=[[UIView alloc]initWithFrame:CGRectMake(0, 100, 300, 250)];
    self.nativeView=[[UIView alloc]initWithFrame:CGRectMake(0, 100, 300, 250)];
    
    self.nativeView.backgroundColor = UIColor.blueColor;
    self.nativeView.backgroundColor = UIColor.greenColor;
    
    [SDKValidationURLProtocol setDelegate:self];
    [NSURLProtocol registerClass:[SDKValidationURLProtocol class]];
    
    
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    [[ANHTTPStubbingManager sharedStubbingManager] disable];
    [self.friendlyObstruction removeFromSuperview];
    [[UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController dismissViewControllerAnimated:NO
                                                                                                               completion:nil];
    
    // Clear all expectations for next test
    self.OMID100PercentViewableExpectation = nil;
    self.OMID0PercentViewableExpectation = nil;
    self.OMIDRemoveFriendlyObstructionExpectation = nil;
    
    self.percentViewableFulfilled = NO;
    self.removeFriendlyObstruction = NO;
    self.adRequest = nil;
    self.nativeResponse = nil;
}



- (void)testBannerNativeOMIDViewablePercent0
{
    
    self.testcase = @"testBannerNativeOMIDViewablePercent0";
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.nativeView];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.friendlyObstruction];
    
    [self stubRequestWithResponse:@"NativeAsssemblyRendererOMID_Native_RTBResponse"];
    
    self.OMID0PercentViewableExpectation = [self expectationWithDescription:@"Didn't receive OMID view 0% event"];
    self.percentViewableFulfilled = NO;
    
    [self.adRequest loadAd];
    
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
        
    }];
    
}



- (void)testBannerNativeOMIDViewablePercent100
{
    self.testcase = @"testBannerNativeOMIDViewablePercent100";
    
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.nativeView];
    
    //    [self.friendlyObstruction setBackgroundColor:[UIColor yellowColor]];
    //    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.friendlyObstruction];
    //
    
    [self stubRequestWithResponse:@"NativeAsssemblyRendererOMID_Native_RTBResponse"];
    
    self.friendlyObstruction.alpha = 0;
    self.OMID100PercentViewableExpectation = [self expectationWithDescription:@"Didn't receive OMID view 100% event"];
    self.percentViewableFulfilled = NO;
    
    [self.adRequest loadAd];
    
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
        
    }];
    
}




- (void)testBannerNativeOMIDViewableRemoveFriendlyObstruction
{
    self.testcase = @"testBannerNativeOMIDViewableRemoveFriendlyObstruction";
    
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.nativeView];
    
    [self.friendlyObstruction setBackgroundColor:[UIColor yellowColor]];
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.friendlyObstruction];
    
    [self stubRequestWithResponse:@"NativeAsssemblyRendererOMID_Native_RTBResponse"];
    
    self.OMID0PercentViewableExpectation = [self expectationWithDescription:@"Didn't receive OMID view 0% event"];
    self.percentViewableFulfilled = NO;
    
    [self.adRequest loadAd];
    
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
        
    }];
    
    XCTAssertEqual(self.nativeResponse.obstructionViews.count, 0);
}


- (void)testBannerNativeOMIDViewableRemoveAllFriendlyObstruction
{
    self.testcase = @"testBannerNativeOMIDViewableRemoveAllFriendlyObstruction";
    
    
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.nativeView];
    
    [self.friendlyObstruction setBackgroundColor:[UIColor yellowColor]];
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.friendlyObstruction];
    
    
    [self stubRequestWithResponse:@"NativeAsssemblyRendererOMID_Native_RTBResponse"];
    
    self.OMID0PercentViewableExpectation = [self expectationWithDescription:@"Didn't receive OMID view 0% event"];
    self.percentViewableFulfilled = NO;
    [self.adRequest loadAd];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
        
    }];
    XCTAssertEqual(self.nativeResponse.obstructionViews.count, 0);
}


#pragma mark - ANAdDelegate

- (void)adRequest:(ANNativeAdRequest *)request didReceiveResponse:(ANNativeAdResponse *)response
{
    self.nativeResponse = (ANNativeAdResponse *)response;
    
    if([self.testcase isEqualToString:@"testBannerNativeOMIDViewablePercent100"]){
        [self.nativeResponse addOpenMeasurementFriendlyObstruction:self.friendlyObstruction];
        
    }else if([self.testcase isEqualToString:@"testBannerNativeOMIDViewableRemoveFriendlyObstruction"]){
        
        [self.nativeResponse addOpenMeasurementFriendlyObstruction:self.friendlyObstruction];
        [self.nativeResponse removeOpenMeasurementFriendlyObstruction:self.friendlyObstruction];
        
        
    }else if([self.testcase isEqualToString:@"testBannerNativeOMIDViewableRemoveAllFriendlyObstruction"]){
        
        [self.nativeResponse addOpenMeasurementFriendlyObstruction:self.friendlyObstruction];
        [self.nativeResponse removeAllOpenMeasurementFriendlyObstructions];
        
        
    }
    
    [self.nativeResponse registerViewForTracking:self.nativeView withRootViewController:self clickableViews:@[] error:nil];
    
}

- (void)adRequest:(ANNativeAdRequest *)request didFailToLoadWithError:(NSError *)error
{
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
