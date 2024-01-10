/*
 *
 *    Copyright 2018 APPNEXUS INC
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

#import <XCTest/XCTest.h>
#import "ANBannerAdView.h"
#import "ANInterstitialAd.h"
#import "ANInterstitialAd+ANTest.h"
#import "ANHTTPStubbingManager.h"
#import "ANSDKSettings+PrivateMethods.h"
#import "XCTestCase+ANAdResponse.h"
#import "ANMRAIDContainerView.h"
#import "ANLogging+Make.h"
#import "ANLog.h"
#import "XandrAd.h"
#define  ROOT_VIEW_CONTROLLER  [ANGlobal getKeyWindow].rootViewController;

// The Test cases are based on this https://corpwiki.appnexus.com/display/CT/OM-+IOS+Test+Cases+for+MS-3289
// And also depend on https://acdn.adnxs.com/mobile/omsdk/validation-verification-scripts-fortesting/omsdk-js-1.4.9/Validation-Script/omid-validation-verification-script-v1.js to send ANJAM events back to it. This is configured via the Stubbed response setup

@interface ANOMIDSessionFinishBannerHTMLTest : XCTestCase <ANBannerAdViewDelegate, ANAppEventDelegate, ANInterstitialAdDelegate>
@property (nonatomic, readwrite, strong)   ANBannerAdView     *bannerAdView;
@property (nonatomic, strong) XCTestExpectation *OMIDSessionFinishEventExpectation;

@end

@implementation  ANOMIDSessionFinishBannerHTMLTest

- (void)setUp {
    [super setUp];
    [ANLogManager setANLogLevel:ANLogLevelAll];
    [ANLogManager setNotificationsEnabled:YES];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;

    self.bannerAdView = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 300, 250)
                                                  placementId:@"13457285"
                                                       adSize:CGSizeMake(300, 250)];
    self.bannerAdView.accessibilityLabel = @"AdView";
    self.bannerAdView.rootViewController = [ANGlobal getKeyWindow].rootViewController;
    self.bannerAdView.delegate = self;
    self.bannerAdView.appEventDelegate = self;
    [[ANGlobal getKeyWindow].rootViewController.view addSubview:self.bannerAdView];
    // Init here if not the tests will crash
    [[XandrAd sharedInstance] initWithMemberID:1 preCacheRequestObjects:true completionHandler:nil];

}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    [[ANHTTPStubbingManager sharedStubbingManager] disable];
    [self.bannerAdView removeFromSuperview];
    self.bannerAdView.delegate = nil;
    self.bannerAdView.appEventDelegate = nil;
    self.bannerAdView = nil;
    [[ANGlobal getKeyWindow].rootViewController.presentedViewController dismissViewControllerAnimated:NO
                                                                                                               completion:nil];
    [ANLogManager setNotificationsEnabled:NO];

    // Clear all expectations for next test
    self.OMIDSessionFinishEventExpectation = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    for (UIView *additionalView in [[ANGlobal getKeyWindow].rootViewController.view subviews]){
          [additionalView removeFromSuperview];
      }

}

- (void)testOMIDSessionFinishRemoveAd
{

    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(receiveTestNotification:)
        name:@"kANLoggingNotification"
        object:nil];

    [self stubRequestWithResponse:@"OMID_TestResponse"];

    self.OMIDSessionFinishEventExpectation = [self expectationWithDescription:@"Didn't receive OMID Session Finish event"];

    [self.bannerAdView loadAd];
    [self waitForExpectationsWithTimeout:900
                                 handler:^(NSError *error) {
    }];
}



#pragma mark - Stubbing

- (void) stubRequestWithResponse:(NSString *)responseName {
    NSBundle *currentBundle = [NSBundle bundleForClass:[self class]];
    NSString *baseResponse = [NSString stringWithContentsOfFile: [currentBundle pathForResource:responseName
                                                                                         ofType:@"json" ]
                                                       encoding: NSUTF8StringEncoding
                                                          error: nil ];

    ANURLConnectionStub  *requestStub  = [[ANURLConnectionStub alloc] init];

    requestStub.requestURL    = [[[ANSDKSettings sharedInstance] baseUrlConfig] utAdRequestBaseUrl];
    requestStub.responseCode  = 200;
    requestStub.responseBody  = baseResponse;

    [[ANHTTPStubbingManager sharedStubbingManager] addStub:requestStub];
}

#pragma mark - ANAdDelegate

- (void)adDidReceiveAd:(id)ad {

}


- (void)ad:(id)ad requestFailedWithError:(NSError *)error {

}


- (void) receiveTestNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"kANLoggingNotification"]) {
        NSDictionary *userInfo = [notification userInfo];
        NSString * message  = userInfo[@"kANLogMessageKey"] ;
        
        if ( self.OMIDSessionFinishEventExpectation && [message containsString:@"\"type\":\"sessionFinish\""]) {
            [self.OMIDSessionFinishEventExpectation fulfill];
        }

        
    }
        NSLog (@"Successfully received the test notification!");
}
@end

