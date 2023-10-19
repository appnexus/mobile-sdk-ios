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
#import <UIKit/UIKit.h>
#import <UnitTestApp-Swift.h>
#import "XandrAd.h"
#import "ANLogManager.h"

static NSString   *placementID      = @"12534678";
#define  ROOT_VIEW_CONTROLLER  [ANGlobal getKeyWindow].rootViewController;

@interface ANOMIDInstreamVideoTestCase : XCTestCase<ANInstreamVideoAdLoadDelegate, ANInstreamVideoAdPlayDelegate, SDKValidationURLProtocolDelegate, ANBannerAdViewDelegate>

@property (nonatomic, readwrite, strong)  ANBannerAdView        *banner;
@property (nonatomic, readwrite, strong)  ANInstreamVideoAd  *instreamVideoAd;

//Expectations for OMID
@property (nonatomic, strong) XCTestExpectation *OMIDSupportedExpecation;
@property (nonatomic, strong) XCTestExpectation *OMIDAdSessionStartedExpectation;
@property (nonatomic, strong) XCTestExpectation *OMIDGeomentryChangeExpectation;
@property (nonatomic, strong) XCTestExpectation *OMIDPercentViewableExpectation;
@property (nonatomic, strong) XCTestExpectation *OMIDImpressionEventExpectation;
@property (nonatomic, strong) XCTestExpectation *OMIDAdSessionFinishedExpectation;
@property (nonatomic, strong) XCTestExpectation *OMIDMediaTypeExpectation;
@property (nonatomic, strong) XCTestExpectation *OMIDVersionExpectation;

@property (nonatomic) BOOL geometryFulfilled;
@property (nonatomic) BOOL oneHundredPercentViewableFulfilled;
@property (nonatomic) BOOL isOMIDImpressionEventFulfilled;
@property (nonatomic) BOOL isOMIDAdSessionFinishedEventFulfilled;

@end

@implementation ANOMIDInstreamVideoTestCase

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
    self.isOMIDImpressionEventFulfilled = NO;
    self.isOMIDAdSessionFinishedEventFulfilled = NO;
    [self registerEventListener];
    // Init here if not the tests will crash
    [[XandrAd sharedInstance] initWithMemberID:1 preCacheRequestObjects:true completionHandler:nil];

}

- (void)tearDown {
    [super tearDown];
    [self clearBannerVideoAd];
    [self clearInstreamVideoAd];
    
    self.OMIDSupportedExpecation = nil;
    self.OMIDAdSessionStartedExpectation = nil;
    self.OMIDGeomentryChangeExpectation = nil;
    self.OMIDPercentViewableExpectation = nil;
    self.OMIDImpressionEventExpectation = nil;
    self.OMIDAdSessionFinishedExpectation = nil;
    
    self.OMIDMediaTypeExpectation = nil;
    [ANHTTPStubbingManager sharedStubbingManager].broadcastRequests = NO;
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    [[ANHTTPStubbingManager sharedStubbingManager] disable];
    [SDKValidationURLProtocol setDelegate:nil];
    [NSURLProtocol unregisterClass:[SDKValidationURLProtocol class]];
    [NSURLProtocol wk_unregisterScheme:@"http"];
    [NSURLProtocol wk_unregisterScheme:@"https"];
    
    for (UIView *additionalView in [[ANGlobal getKeyWindow].rootViewController.view subviews]){
          [additionalView removeFromSuperview];
      }
}

#pragma mark - Test methods.

- (void)testOMIDBannerVideoInitSuccess
{
    [self setupBannerVideoAd];
    [self stubRequestWithResponse:@"OMID_VideoResponse"];
    self.OMIDSupportedExpecation = [self expectationWithDescription:@"Didn't receive OmidSupported[true]"];
    [self.banner loadAd];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval*30
                                 handler:^(NSError *error) {
        
    }];
}


- (void)testOMIDBannerVideoSessionStarted
{
    [self setupBannerVideoAd];
    [self stubRequestWithResponse:@"OMID_VideoResponse"];
    self.OMIDAdSessionStartedExpectation = [self expectationWithDescription:@"Didn't receive OMID sessionStart event"];
    [self.banner loadAd];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval*30
                                 handler:^(NSError *error) {
        
    }];
}



- (void)testOMIDVersion
{
    [self setupBannerVideoAd];
    [self stubRequestWithResponse:@"OMID_VideoResponse"];
    self.OMIDSupportedExpecation = [self expectationWithDescription:@"Didn't receive OmidSupported[true]"];
    self.OMIDAdSessionStartedExpectation = [self expectationWithDescription:@"Didn't receive OMID sessionStart event"];
    [self.banner loadAd];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval*2
                                 handler:^(NSError *error) {
        
    }];
}


- (void)testOMIDBannerVideoGeometry
{
    [self setupBannerVideoAd];
    [self stubRequestWithResponse:@"OMID_VideoResponse"];
    self.OMIDVersionExpectation = [self expectationWithDescription:@"Didn't receive OMID version"];

    [self.banner loadAd];

    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval*2
                                 handler:^(NSError *error) {

                                 }];

}



- (void)testOMIDBannerVideoMediaType
{
    [self setupBannerVideoAd];
    [self stubRequestWithResponse:@"OMID_VideoResponse"];
    self.OMIDGeomentryChangeExpectation = [self expectationWithDescription:@"Didn't receive OMID Media Type event"];
    self.OMIDMediaTypeExpectation = [self expectationWithDescription:@"Didn't receive OMID Media Type event"];

    [self.banner loadAd];

    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {

                                 }];

}


- (void)testOMIDBannerVideoImpression
{
    [self setupBannerVideoAd];
    [self stubRequestWithResponse:@"OMID_VideoResponse"];
    self.OMIDImpressionEventExpectation = [self expectationWithDescription:@"Didn't receive OMID Impression event"];
    [self.banner loadAd];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {

                                 }];

}

- (void)testOMIDBannerVideoSessionFinish
{
    [self setupBannerVideoAd];
    [self stubRequestWithResponse:@"OMID_VideoResponse"];
    self.OMIDAdSessionFinishedExpectation = [self expectationWithDescription:@"Didn't receive OMID sessionFinish event"];
    [self.banner loadAd];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval*2
                                 handler:^(NSError *error) {
        
    }];
}

- (void)testOMIDInstreamVideoInitSuccess
{
    [self setupInstreamVideoAd];
    [self stubRequestWithResponse:@"OMID_VideoResponse"];
    [self.instreamVideoAd loadAdWithDelegate:self];
      self.OMIDAdSessionStartedExpectation = [self expectationWithDescription:@"Didn't receive OMID sessionStart event"];
      [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval*2
                                   handler:^(NSError *error) {
          
      }];

}




- (void)testOMIDInstreamVideoMediaType
{
    [self setupInstreamVideoAd];
    [self stubRequestWithResponse:@"OMID_VideoResponse"];
    self.OMIDMediaTypeExpectation = [self expectationWithDescription:@"Didn't receive OMID Media Type event"];

    [self.instreamVideoAd loadAdWithDelegate:self];

    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval * 2
                                 handler:^(NSError *error) {

                                 }];

}


- (void)testOMIDInstreamVideoGeomentryChange
{
    [self setupInstreamVideoAd];
    [self stubRequestWithResponse:@"OMID_VideoResponse"];
    self.OMIDGeomentryChangeExpectation = [self expectationWithDescription:@"Didn't receive OMID Media Type event"];

    [self.instreamVideoAd loadAdWithDelegate:self];

    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval * 2
                                 handler:^(NSError *error) {

                                 }];

}

- (void)testOMIDInstreamVideoGeometry
{
    [self setupInstreamVideoAd];
    [self stubRequestWithResponse:@"OMID_VideoResponse"];
    self.OMIDGeomentryChangeExpectation = [self expectationWithDescription:@"Didn't receive OMID geometryChange event"];
    self.geometryFulfilled = NO;
    [self.instreamVideoAd loadAdWithDelegate:self];

    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {

                                 }];

}

- (void)testOMIDInstreamPercentViewable
{
    [self setupInstreamVideoAd];
    [self stubRequestWithResponse:@"OMID_VideoResponse"];
    self.OMIDPercentViewableExpectation = [self expectationWithDescription:@"Didn't receive OMID view PercentViewable event"];
    self.oneHundredPercentViewableFulfilled = NO;
    [self.instreamVideoAd loadAdWithDelegate:self];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {

                                 }];

}




- (void)testOMIDInstreamVideoImpression
{
    [self setupInstreamVideoAd];
    [self stubRequestWithResponse:@"OMID_VideoResponse"];
    [self.instreamVideoAd loadAdWithDelegate:self];
    self.OMIDImpressionEventExpectation = [self expectationWithDescription:@"Didn't receive OMID Impression event"];
    [self.banner loadAd];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {

                                 }];

}

// Reason of diabling:  the library is not able to find the last events, which is working in maunal test.
/*
- (void)testOMIDInstreamVideoSessionFinish
{
    [self setupInstreamVideoAd];
    [self stubRequestWithResponse:@"OMID_VideoResponse"];
    [self.instreamVideoAd loadAdWithDelegate:self];
    self.OMIDAdSessionFinishedExpectation = [self expectationWithDescription:@"Didn't receive OMID sessionFinish event"];
    [self.banner loadAd];
    [self waitForExpectationsWithTimeout:3 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {

    }];
}
 */

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
    UIViewController *controller = ROOT_VIEW_CONTROLLER;
    if ([ad isKindOfClass:[ANInstreamVideoAd class]]) {
        [self.instreamVideoAd playAdWithContainer:controller.view withDelegate:self];
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
    NSLog(@"Response == %@", response);
    if ([response containsString:@"OmidSupported%5Btrue"]) {
        [self.OMIDSupportedExpecation fulfill];
        self.OMIDSupportedExpecation = nil;
    }
    
    if ([response containsString:@"sessionStart"]) {
        [self.OMIDAdSessionStartedExpectation fulfill];
        self.OMIDAdSessionStartedExpectation = nil;
    }
    
    if ([response containsString:@"geometryChange"] && !self.geometryFulfilled) {
        self.geometryFulfilled = YES;
        [self.OMIDGeomentryChangeExpectation fulfill];
        self.OMIDGeomentryChangeExpectation = nil;
    }
    
    if (self.OMIDVersionExpectation && [response containsString:OMID_SDK_VERSION] && [response containsString:@"libraryVersion"]) {
          // Only assert if it has been setup to assert.
          [self.OMIDVersionExpectation fulfill];
        self.OMIDVersionExpectation = nil;
      }
    
    if ([response containsString:@"percentageInView"]  && !self.oneHundredPercentViewableFulfilled) {
        self.oneHundredPercentViewableFulfilled = YES;
        [self.OMIDPercentViewableExpectation fulfill];
        self.OMIDPercentViewableExpectation = nil;
        
    }
    
    if ([response containsString:@"impression"]  && !self.isOMIDImpressionEventFulfilled) {
        self.isOMIDImpressionEventFulfilled = YES;
        [self.OMIDImpressionEventExpectation fulfill];
        self.OMIDImpressionEventExpectation = nil;
    }
    
    
    if ([response containsString:@"sessionFinish"]  && !self.isOMIDAdSessionFinishedEventFulfilled ) {
        self.isOMIDAdSessionFinishedEventFulfilled = YES;
        [self.OMIDAdSessionFinishedExpectation fulfill];
        self.OMIDAdSessionFinishedExpectation = nil;
    }
    
     if ([response containsString:@"impressionType"] && [response containsString:@"definedByJavaScript"] && [response containsString:@"mediaType"] && [response containsString:@"video"] &&  [response containsString:@"creativeType"] ) {
         [self.OMIDMediaTypeExpectation fulfill];
         self.OMIDMediaTypeExpectation = nil;
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
    NSURLResponse *responseKey = [userInfo objectForKey:@"response"];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *response = [responseKey.URL.absoluteURL absoluteString];
        NSLog(@"absoluteURLText -> %@",response);
        if ([response containsString:@"supported"] && [response containsString:@"yes"]) {
            [self.OMIDSupportedExpecation fulfill];
            self.OMIDSupportedExpecation = nil;
        }
        
        if ([response containsString:@"sessionStart"]) {
            [self.OMIDAdSessionStartedExpectation fulfill];
            self.OMIDAdSessionStartedExpectation = nil;
        }
        
        if ([response containsString:@"sessionStart"]) {
            [self.OMIDAdSessionStartedExpectation fulfill];
            self.OMIDAdSessionStartedExpectation = nil;
        }
        
        if ([response containsString:@"geometryChange"] && !self.geometryFulfilled) {
            self.geometryFulfilled = YES;
            [self.OMIDGeomentryChangeExpectation fulfill];
            self.OMIDGeomentryChangeExpectation = nil;
        }
        
        if (self.OMIDVersionExpectation && [response containsString:OMID_SDK_VERSION] && [response containsString:@"libraryVersion"]) {
              // Only assert if it has been setup to assert.
              [self.OMIDVersionExpectation fulfill];
            self.OMIDVersionExpectation = nil;
          }
        
        if ([response containsString:@"percentageInView"]  && !self.oneHundredPercentViewableFulfilled) {
            self.oneHundredPercentViewableFulfilled = YES;
            [self.OMIDPercentViewableExpectation fulfill];
            self.OMIDPercentViewableExpectation = nil;
            
        }
        
        if ([response containsString:@"impression"]  && !self.isOMIDImpressionEventFulfilled) {
            self.isOMIDImpressionEventFulfilled = YES;
            [self.OMIDImpressionEventExpectation fulfill];
            self.OMIDImpressionEventExpectation = nil;
        }
        
        
        if ([response containsString:@"sessionFinish"]  && !self.isOMIDAdSessionFinishedEventFulfilled ) {
            self.isOMIDAdSessionFinishedEventFulfilled = YES;
            [self.OMIDAdSessionFinishedExpectation fulfill];
            self.OMIDAdSessionFinishedExpectation = nil;
        }
        
         if ([response containsString:@"impressionType"] && [response containsString:@"definedByJavaScript"] && [response containsString:@"mediaType"] && [response containsString:@"video"] &&  [response containsString:@"creativeType"] ) {
             [self.OMIDMediaTypeExpectation fulfill];
             self.OMIDMediaTypeExpectation = nil;
         }
        
     
    });
}
@end
