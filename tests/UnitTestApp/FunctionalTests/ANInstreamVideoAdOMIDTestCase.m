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

#import <XCTest/XCTest.h>
#import "XCTestCase+ANCategory.h"
#import "SDKValidationURLProtocol.h"
#import "ANInstreamVideoAd.h"
#import "ANInstreamVideoAd+Test.h"
#import "ANTestGlobal.h"
#import "ANAdView+PrivateMethods.h"
#import "ANHTTPStubbingManager.h"
#import "XCTestCase+ANCategory.h"
#import "ANSDKSettings+PrivateMethods.h"
#import "NSURLRequest+HTTPBodyTesting.h"
#import "NSURLProtocol+WKWebViewSupport.h"
#import "ANBannerAdView+ANTest.h"

static NSString   *placementID      = @"12534678";
#define  ROOT_VIEW_CONTROLLER  [UIApplication sharedApplication].keyWindow.rootViewController;
@interface ANInstreamVideoAdOMIDTestCase : XCTestCase<ANInstreamVideoAdLoadDelegate, ANInstreamVideoAdPlayDelegate, SDKValidationURLProtocolDelegate, ANBannerAdViewDelegate>
@property (nonatomic, readwrite, strong)  ANBannerAdView        *banner;
@property (nonatomic, readwrite, strong)  ANInstreamVideoAd  *instreamVideoAd;

//Expectations for OMID

//Expectations for OMID
@property (nonatomic, strong) XCTestExpectation *OMID100PercentViewableExpectation;
@property (nonatomic, strong) XCTestExpectation *OMID0PercentViewableExpectation;
@property (nonatomic, strong) XCTestExpectation *OMIDRemoveFriendlyObstructionExpectation;


@property (nonatomic) BOOL percentViewableFulfilled;
@property (nonatomic) BOOL removeFriendlyObstruction;
@property (nonatomic) UIView *friendlyObstruction;


@property (nonatomic) UIView *videoView;

@end

@implementation ANInstreamVideoAdOMIDTestCase

- (void)setUp {
    [super setUp];
    [ANLogManager setANLogLevel:ANLogLevelAll];
    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
    [ANHTTPStubbingManager sharedStubbingManager].broadcastRequests = YES;
    [SDKValidationURLProtocol setDelegate:self];
    [NSURLProtocol registerClass:[SDKValidationURLProtocol class]];
    [NSURLProtocol wk_registerScheme:@"http"];
    [NSURLProtocol wk_registerScheme:@"https"];
    
    self.percentViewableFulfilled = NO;
    self.removeFriendlyObstruction = NO;
    
    self.friendlyObstruction=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 250)];
    [self.friendlyObstruction setBackgroundColor:[UIColor yellowColor]];
    
    
}

- (void)tearDown {
    [super tearDown];
    [self.instreamVideoAd removeFromSuperview];
    self.instreamVideoAd = nil;
    [self.banner removeFromSuperview];
    self.banner.delegate = nil;
    self.banner.appEventDelegate = nil;
    self.banner = nil;
    
    self.videoView = nil;
    self.friendlyObstruction = nil;
    
    self.OMID100PercentViewableExpectation = nil;
    self.OMID0PercentViewableExpectation = nil;
    self.OMIDRemoveFriendlyObstructionExpectation = nil;
    
    [ANHTTPStubbingManager sharedStubbingManager].broadcastRequests = NO;
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    [[ANHTTPStubbingManager sharedStubbingManager] disable];
    [NSURLProtocol unregisterClass:[SDKValidationURLProtocol class]];
    [NSURLProtocol wk_unregisterScheme:@"http"];
    [NSURLProtocol wk_unregisterScheme:@"https"];
}

#pragma mark - Test methods.

- (void)testOMIDBannerVideoViewablePercent100
{
    [self setupBannerVideoAd];
    self.friendlyObstruction.alpha = 0.0;
    [self stubRequestWithResponse:@"OMID_VideoResponse"];
    
    self.OMID100PercentViewableExpectation = [self expectationWithDescription:@"Didn't receive OMID view 100% event"];
    self.percentViewableFulfilled = NO;
    
    [self.banner loadAd];
    
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
        
    }];
    [self clearBannerVideoAd];
    
}


- (void)testOMIDInstreamVideoViewablePercent100
{
    [self setupInstreamVideoAd];
    self.friendlyObstruction.alpha = 0.0;
    [self stubRequestWithResponse:@"OMID_VideoResponse"];
    
    self.OMID100PercentViewableExpectation = [self expectationWithDescription:@"Didn't receive OMID view 100% event"];
    self.percentViewableFulfilled = NO;
    [self.instreamVideoAd loadAdWithDelegate:self];

    
    [self waitForExpectationsWithTimeout: kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
        
    }];
    [self clearInstreamVideoAd];
    
}


- (void)testOMIDBannerVideoViewablePercentZero
{
    [self setupBannerVideoAd];
    [self stubRequestWithResponse:@"OMID_VideoResponse"];
    
    self.OMID0PercentViewableExpectation = [self expectationWithDescription:@"Didn't receive OMID view 0% event"];
    self.removeFriendlyObstruction = YES;
    self.percentViewableFulfilled = NO;

    [self.banner loadAd];
    
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
        
    }];
    [self clearBannerVideoAd];
    
}


- (void)testOMIDInstreamVideoViewablePercentZero
{
    
    [self setupInstreamVideoAd];
    [self stubRequestWithResponse:@"OMID_VideoResponse"];
    
    self.OMID0PercentViewableExpectation = [self expectationWithDescription:@"Didn't receive OMID view 0% event"];
    self.removeFriendlyObstruction = YES;
    self.percentViewableFulfilled = NO;
    [self.instreamVideoAd loadAdWithDelegate:self];

    
    [self waitForExpectationsWithTimeout: kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
        
    }];
    [self clearInstreamVideoAd];
    
}



-(void)setupInstreamVideoAd{
    self.instreamVideoAd  = [[ANInstreamVideoAd alloc] initWithPlacementId:placementID];
}

-(void) setupBannerVideoAd{
    self.banner = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 300, 250)
                                            placementId:placementID
                                                 adSize:CGSizeMake(300, 250)];
    self.banner.accessibilityLabel = @"AdView";
    self.banner.autoRefreshInterval = 0;
    self.banner.delegate = self;
    self.banner.shouldAllowVideoDemand =  YES;
    self.banner.rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.banner];
}

-(void) clearBannerVideoAd{
    [self.banner removeFromSuperview];
    self.banner.delegate = nil;
    self.banner.appEventDelegate = nil;
    self.banner = nil;
}

-(void) clearInstreamVideoAd{
    [self.instreamVideoAd removeFromSuperview];
    self.instreamVideoAd = nil;
}

# pragma mark - Ad Server Response Stubbing

- (void)stubRequestWithResponse:(NSString *)responseName {
    NSBundle *currentBundle = [NSBundle bundleForClass:[self class]];
    NSString *baseResponse = [NSString stringWithContentsOfFile:[currentBundle pathForResource:responseName
                                                                                        ofType:@"json"]
                                                       encoding:NSUTF8StringEncoding
                                                          error:nil];
    ANURLConnectionStub *requestStub = [[ANURLConnectionStub alloc] init];
    requestStub.requestURL      = [[[ANSDKSettings sharedInstance] baseUrlConfig] utAdRequestBaseUrl];
    requestStub.responseCode    = 200;
    requestStub.responseBody    = baseResponse;
    [[ANHTTPStubbingManager sharedStubbingManager] addStub:requestStub];
}

#pragma mark - ANAdDelegate.

- (void)adDidReceiveAd:(id)ad
{
    if ([ad isKindOfClass:[ANInstreamVideoAd class]]) {
        self.videoView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 250)];
        [self.videoView setBackgroundColor:[UIColor yellowColor]];
        [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.videoView];
        
        
        [self.instreamVideoAd playAdWithContainer:self.videoView withDelegate:self];
        
        
        
        [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.friendlyObstruction];
        
        
        
    }
}

- (void)ad:(id)ad requestFailedWithError:(NSError *)error
{
}

#pragma mark - ANInstreamVideoAdPlayDelegate.

- (void)adDidComplete:(nonnull id<ANAdProtocol>)ad withState:(ANInstreamVideoPlaybackStateType)state {
    
}


# pragma mark - Intercept HTTP Request Callback

- (void)didReceiveIABResponse:(NSString *)response {
    
    NSLog(@"OMID response %@",response);
    if ([response containsString:@"percentageInView"] && [response containsString:@"100"] && !self.percentViewableFulfilled) {
        self.percentViewableFulfilled = YES;
        [self.OMID100PercentViewableExpectation fulfill];
        
    }
    
    
//    if ([response containsString:@"percentageInView"] && [response containsString:@"0"] && !self.removeFriendlyObstruction && !self.percentViewableFulfilled) {
//        self.removeFriendlyObstruction = YES;
//        [self.OMID0PercentViewableExpectation fulfill];
//    }
    
    
    if ([response containsString:@"percentageInView"] && [response containsString:@"0"] && self.removeFriendlyObstruction) {
        self.removeFriendlyObstruction = NO;
        [self.OMID0PercentViewableExpectation fulfill];
    }
    
    
    
}



- (void)testOMIDBannerVideoViewableRemoveFriendlyObstruction
{
    [self setupBannerVideoAd];
    self.friendlyObstruction.alpha = 0.0;
    [self.banner addOpenMeasurementFriendlyObstruction:self.friendlyObstruction];
    [self stubRequestWithResponse:@"OMID_VideoResponse"];
    
    self.OMID100PercentViewableExpectation = [self expectationWithDescription:@"Didn't receive OMID view 100% event"];
    self.percentViewableFulfilled = NO;
    
    [self.banner loadAd];
    
    [self waitForExpectationsWithTimeout: kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
        
    }];
    
//    self.percentViewableFulfilled = NO;
    self.removeFriendlyObstruction = YES;
    [self.banner removeOpenMeasurementFriendlyObstruction:self.friendlyObstruction];
    
    self.videoView.frame = CGRectMake(self.videoView.frame.origin.x+ 10, self.videoView.frame.origin.y+ 50, self.videoView.frame.size.width+20, self.videoView.frame.size.height+20);
    
    self.banner.frame = CGRectMake(self.videoView.frame.origin.x, self.videoView.frame.origin.y, self.videoView.frame.size.width, self.videoView.frame.size.height);
    
    self.friendlyObstruction.frame = CGRectMake(self.videoView.frame.origin.x , self.videoView.frame.origin.y , self.videoView.frame.size.width, self.videoView.frame.size.height);
    

    self.OMID0PercentViewableExpectation = [self expectationWithDescription:@"Didn't receive OMID view 0% event"];
    
    
    [self waitForExpectationsWithTimeout: kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
        
    }];
    
    
    [self clearBannerVideoAd];
    
}


- (void)testOMIDInstreamVideoViewableRemoveFriendlyObstruction
{
    [self setupInstreamVideoAd];
    self.friendlyObstruction.alpha = 0.0;
    
    [self.instreamVideoAd addOpenMeasurementFriendlyObstruction:self.friendlyObstruction];
    [self stubRequestWithResponse:@"OMID_VideoResponse"];
    
    self.OMID100PercentViewableExpectation = [self expectationWithDescription:@"Didn't receive OMID view 100% event"];

    
    self.percentViewableFulfilled = NO;

    [self.instreamVideoAd loadAdWithDelegate:self];

    
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
        
    }];
    
    
    
    self.removeFriendlyObstruction = YES;
    [self.instreamVideoAd removeOpenMeasurementFriendlyObstruction:self.friendlyObstruction];
    
    
    self.videoView.frame = CGRectMake(self.videoView.frame.origin.x+ 10, self.videoView.frame.origin.y+ 50, self.videoView.frame.size.width+20, self.videoView.frame.size.height+20);
    
    self.instreamVideoAd.frame = CGRectMake(self.videoView.frame.origin.x, self.videoView.frame.origin.y, self.videoView.frame.size.width, self.videoView.frame.size.height);
    
    self.friendlyObstruction.frame = CGRectMake(self.videoView.frame.origin.x , self.videoView.frame.origin.y , self.videoView.frame.size.width, self.videoView.frame.size.height);
    


    self.OMID0PercentViewableExpectation = [self expectationWithDescription:@"Didn't receive OMID view 0% event"];
    
    
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
        
    }];
    [self clearInstreamVideoAd];

}


- (void)testOMIDInstreamVideoViewableRemoveAllFriendlyObstruction
{
    [self setupInstreamVideoAd];
    self.friendlyObstruction.alpha = 0.0;
    
    [self.instreamVideoAd addOpenMeasurementFriendlyObstruction:self.friendlyObstruction];
    [self stubRequestWithResponse:@"OMID_VideoResponse"];
    
    self.OMID100PercentViewableExpectation = [self expectationWithDescription:@"Didn't receive OMID view 100% event"];

    
    self.percentViewableFulfilled = NO;

    [self.instreamVideoAd loadAdWithDelegate:self];

    
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
        
    }];
    
    
    
    self.removeFriendlyObstruction = YES;
    [self.instreamVideoAd removeAllOpenMeasurementFriendlyObstructions];
    
    
    self.videoView.frame = CGRectMake(self.videoView.frame.origin.x+ 10, self.videoView.frame.origin.y+ 50, self.videoView.frame.size.width+20, self.videoView.frame.size.height+20);
    
    self.instreamVideoAd.frame = CGRectMake(self.videoView.frame.origin.x, self.videoView.frame.origin.y, self.videoView.frame.size.width, self.videoView.frame.size.height);
    
    self.friendlyObstruction.frame = CGRectMake(self.videoView.frame.origin.x , self.videoView.frame.origin.y , self.videoView.frame.size.width, self.videoView.frame.size.height);
    


    self.OMID0PercentViewableExpectation = [self expectationWithDescription:@"Didn't receive OMID view 0% event"];
    
    
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
        
    }];
    [self clearInstreamVideoAd];

}


- (void)testOMIDBannerVideoViewableRemoveAllFriendlyObstruction
{
    [self setupBannerVideoAd];
    self.friendlyObstruction.alpha = 0.0;
    [self.banner addOpenMeasurementFriendlyObstruction:self.friendlyObstruction];
    [self stubRequestWithResponse:@"OMID_VideoResponse"];
    
    self.OMID100PercentViewableExpectation = [self expectationWithDescription:@"Didn't receive OMID view 100% event"];
    self.percentViewableFulfilled = NO;
    
    [self.banner loadAd];
    
    [self waitForExpectationsWithTimeout: kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
        
    }];
    
    self.removeFriendlyObstruction = YES;
    [self.banner removeAllOpenMeasurementFriendlyObstructions];
    
    self.videoView.frame = CGRectMake(self.videoView.frame.origin.x+ 10, self.videoView.frame.origin.y+ 50, self.videoView.frame.size.width+20, self.videoView.frame.size.height+20);
    
    self.banner.frame = CGRectMake(self.videoView.frame.origin.x, self.videoView.frame.origin.y, self.videoView.frame.size.width, self.videoView.frame.size.height);
    
    self.friendlyObstruction.frame = CGRectMake(self.videoView.frame.origin.x , self.videoView.frame.origin.y , self.videoView.frame.size.width, self.videoView.frame.size.height);
    

    self.OMID0PercentViewableExpectation = [self expectationWithDescription:@"Didn't receive OMID view 0% event"];
    
    
    [self waitForExpectationsWithTimeout: kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
        
    }];
    
    
    [self clearBannerVideoAd];
    
}



@end
