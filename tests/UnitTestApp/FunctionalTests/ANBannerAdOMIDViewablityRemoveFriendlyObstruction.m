/*
 *
 *    Copyright 2020 APPNEXUS INC
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
#import "ANHTTPStubbingManager.h"
#import "ANSDKSettings+PrivateMethods.h"
#import "XCTestCase+ANAdResponse.h"
#import "ANAdView+PrivateMethods.h"
#import "XandrAd.h"
#define  ROOT_VIEW_CONTROLLER  [ANGlobal getKeyWindow].rootViewController;

@interface ANBannerAdOMIDViewablityRemoveFriendlyObstruction : XCTestCase <ANBannerAdViewDelegate, ANAppEventDelegate>
@property (nonatomic, readwrite, strong)   ANBannerAdView     *bannerAdView;


//Expectations for OMID
@property (nonatomic, strong) XCTestExpectation *OMID100PercentViewableExpectation;
@property (nonatomic, strong) XCTestExpectation *OMIDRemoveFriendlyObstructionExpectation;


@property (nonatomic) UIView *friendlyObstruction;

@end

@implementation ANBannerAdOMIDViewablityRemoveFriendlyObstruction

- (void)setUp {
    [super setUp];
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
    self.bannerAdView.autoRefreshInterval = 0;
    [[ANGlobal getKeyWindow].rootViewController.view addSubview:self.bannerAdView];

    
    
    self.friendlyObstruction=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 250)];
    [self.friendlyObstruction setBackgroundColor:[UIColor yellowColor]];
    [[ANGlobal getKeyWindow].rootViewController.view addSubview:self.friendlyObstruction];
    // Init here if not the tests will crash
    [[XandrAd sharedInstance] initWithMemberID:1 preCacheRequestObjects:true completionHandler:nil];


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
    [[ANGlobal getKeyWindow].rootViewController.presentedViewController dismissViewControllerAnimated:NO
                                                                                                               completion:nil];

    // Clear all expectations for next test
    self.OMID100PercentViewableExpectation = nil;
    self.OMIDRemoveFriendlyObstructionExpectation = nil;

    for (UIView *additionalView in [[ANGlobal getKeyWindow].rootViewController.view subviews]){
          [additionalView removeFromSuperview];
      }
}



- (void)testOMIDViewableRemoveFriendlyObstruction
{
    [self stubRequestWithResponse:@"OMID_TestResponse"];
    
    [self.bannerAdView addOpenMeasurementFriendlyObstruction:self.friendlyObstruction];
    self.OMID100PercentViewableExpectation = [self expectationWithDescription:@"Didn't receive OMID view 100% event"];
    
    [self.bannerAdView loadAd];
    
    [self waitForExpectationsWithTimeout:900
                                 handler:^(NSError *error) {
        
    }];

    self.OMIDRemoveFriendlyObstructionExpectation = [self expectationWithDescription:@"Didn't receive OMID view 0% event"];

    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (4.0 * NSEC_PER_SEC));
      dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
         [self.bannerAdView removeOpenMeasurementFriendlyObstruction:self.friendlyObstruction];

        self.friendlyObstruction.frame = CGRectMake(self.bannerAdView.frame.origin.x+10 , self.bannerAdView.frame.origin.y , self.bannerAdView.frame.size.width, self.bannerAdView.frame.size.height);

         self.bannerAdView.frame = CGRectMake(self.bannerAdView.frame.origin.x+10, self.bannerAdView.frame.origin.y, self.bannerAdView.frame.size.width, self.bannerAdView.frame.size.height);
         
      
      });
    
    
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

#pragma mark - ANAppEventDelegate.
- (void)            ad: (id<ANAdProtocol>)ad
    didReceiveAppEvent: (NSString *)name
              withData: (NSString *)data
{
    NSLog(@"Data is %@",data);
    if ([name isEqualToString:@"OMIDEvent"]) {
        
        if ([data containsString:@"\"percentageInView\":0"]) {
            if (self.OMIDRemoveFriendlyObstructionExpectation) {
                // Only assert if it has been setup to assert.
                [self.OMIDRemoveFriendlyObstructionExpectation fulfill];
                
            }
        }
        else  if (self.OMID100PercentViewableExpectation && [data containsString:@"\"percentageInView\":100"]) {
            // Only assert if it has been setup to assert.
            [self.OMID100PercentViewableExpectation fulfill];
            
        }
        
    }
}


@end

