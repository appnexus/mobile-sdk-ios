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
#import <UnitTestApp-Swift.h>
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
#import "XandrAd.h"
#import "ANLogManager.h"

static NSString   *placementID      = @"12534678";
#define  ROOT_VIEW_CONTROLLER  [ANGlobal getKeyWindow].rootViewController;
@interface ANInstreamVideoAdOMIDViewablityTestCase : XCTestCase<ANInstreamVideoAdLoadDelegate, ANInstreamVideoAdPlayDelegate, SDKValidationURLProtocolDelegate, ANBannerAdViewDelegate>
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

@implementation ANInstreamVideoAdOMIDViewablityTestCase

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

    [self registerEventListener];
    // Init here if not the tests will crash
    [[XandrAd sharedInstance] initWithMemberID:1 preCacheRequestObjects:true completionHandler:nil];
}

- (void)tearDown {
    [super tearDown];

    self.videoView = nil;
    self.friendlyObstruction = nil;

    self.OMID100PercentViewableExpectation = nil;
    self.OMID0PercentViewableExpectation = nil;
    self.OMIDRemoveFriendlyObstructionExpectation = nil;

    [ANHTTPStubbingManager sharedStubbingManager].broadcastRequests = NO;
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    [[ANHTTPStubbingManager sharedStubbingManager] disable];
    [SDKValidationURLProtocol setDelegate:nil];
    [NSURLProtocol unregisterClass:[SDKValidationURLProtocol class]];
    [NSURLProtocol wk_unregisterScheme:@"http"];
    [NSURLProtocol wk_unregisterScheme:@"https"];
    [[ANGlobal getKeyWindow].rootViewController.presentedViewController dismissViewControllerAnimated:NO completion:nil];
    for (UIView *additionalView in [[ANGlobal getKeyWindow].rootViewController.view subviews]){
        [additionalView removeFromSuperview];
    }
    [self clearBannerVideoAd];
    [self clearInstreamVideoAd];
}

#pragma mark - Test methods.

- (void)testOMIDBannerVideoViewablePercent100
{
    [self setupBannerVideoAd];
    [self.banner addOpenMeasurementFriendlyObstruction:self.friendlyObstruction];
    [self stubRequestWithResponse:@"OMID_VideoResponse"];

    self.OMID100PercentViewableExpectation = [self expectationWithDescription:@"Didn't receive OMID view 100% event"];
    self.percentViewableFulfilled = NO;

    [self.banner loadAd];

    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval * 30
                                 handler:^(NSError *error) {

    }];

}


- (void)testOMIDInstreamVideoViewablePercent100
{
    [self setupInstreamVideoAd];
    [self stubRequestWithResponse:@"OMID_VideoResponse"];

    self.OMID100PercentViewableExpectation = [self expectationWithDescription:@"Didn't receive OMID view 100% event"];
    self.percentViewableFulfilled = NO;
    [self.instreamVideoAd loadAdWithDelegate:self];

    [self.instreamVideoAd addOpenMeasurementFriendlyObstruction:self.friendlyObstruction];

    [self waitForExpectationsWithTimeout: kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
    }];

}


- (void)testOMIDBannerVideoViewablePercentZero
{
    [self setupBannerVideoAd];
    [self stubRequestWithResponse:@"OMID_VideoResponse"];
    [self.banner addOpenMeasurementFriendlyObstruction:self.friendlyObstruction];

    self.OMID0PercentViewableExpectation = [self expectationWithDescription:@"Didn't receive OMID view 0% event"];
    self.removeFriendlyObstruction = YES;
    self.percentViewableFulfilled = NO;

    [self.banner loadAd];

    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {

    }];

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

}



-(void)setupInstreamVideoAd{
    self.instreamVideoAd  = [[ANInstreamVideoAd alloc] initWithPlacementId:placementID];
}

-(void) setupBannerVideoAd{
    self.banner = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 300, 250)
                                            placementId:placementID
                                                 adSize:CGSizeMake(300, 250)];
  //  self.banner.accessibilityLabel = @"AdView";
    self.banner.autoRefreshInterval = 0;
    self.banner.delegate = self;
    self.banner.shouldAllowVideoDemand =  YES;
    self.banner.rootViewController = [ANGlobal getKeyWindow].rootViewController;
    [[ANGlobal getKeyWindow].rootViewController.view addSubview:self.banner];
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
        [[ANGlobal getKeyWindow].rootViewController.view addSubview:self.videoView];


        [self.instreamVideoAd playAdWithContainer:self.videoView withDelegate:self];



        [[ANGlobal getKeyWindow].rootViewController.view addSubview:self.friendlyObstruction];



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

    if ([response containsString:@"percentageInView"] && [response containsString:@"0"] && self.removeFriendlyObstruction) {
        self.removeFriendlyObstruction = NO;
        [self.OMID0PercentViewableExpectation fulfill];
    }



}


//  registerEventListener is used to register for tracking the URL fired by Application(or SDK)
-(void)registerEventListener{
    [NSURLProtocol registerClass:[WebKitURLProtocol class]];
    [NSURLProtocol wk_registerWithScheme:@"https"];
    [NSURLProtocol wk_registerWithScheme:@"http"];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateNetworkLog:)
                                                 name:@"didReceiveURLResponse"
                                               object:nil];
}

# pragma mark - Ad Server Response Stubbing

// updateNetworkLog: Will return event in fire of URL from Application(or SDK)
- (void) updateNetworkLog:(NSNotification *) notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSURLResponse *response = [userInfo objectForKey:@"response"];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *absoluteURLText = [response.URL.absoluteURL absoluteString];
        NSLog(@"absoluteURLText -> %@",absoluteURLText);
        if ([absoluteURLText containsString:@"percentageInView"] && [absoluteURLText containsString:@"100"] && !self.percentViewableFulfilled) {
            self.percentViewableFulfilled = YES;
            [self.OMID100PercentViewableExpectation fulfill];

        }

        if ([absoluteURLText containsString:@"percentageInView"] && [absoluteURLText containsString:@"0"] && self.removeFriendlyObstruction) {
            self.removeFriendlyObstruction = NO;
            [self.OMID0PercentViewableExpectation fulfill];
        }
     
    });
}

@end
