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
#import "ANBannerAdView.h"
#import "ANGlobal.h"
#import "ANHTTPStubbingManager.h"
#import "ANSDKSettings+PrivateMethods.h"
#import "ANTimeTracker.h"

@interface AdPerformanceStatsBannerNativeRendererAdTestCase : XCTestCase <ANBannerAdViewDelegate>
@property (nonatomic, readwrite, strong)  ANBannerAdView        *bannerAd;
@property (nonatomic, strong) XCTestExpectation *firstLoadAdResponseReceivedExpectation;
@property (nonatomic, strong) XCTestExpectation *secondLoadAdResponseReceivedExpectation;
@property (nonatomic, strong) NSString *testCase;

@end

@implementation AdPerformanceStatsBannerNativeRendererAdTestCase

- (void)setUp {
    [self clearAd];
    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [self clearAd];
}

-(void)clearAd{
    
    [[ANHTTPStubbingManager sharedStubbingManager] disable];
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    
    [self.bannerAd removeFromSuperview];
    self.bannerAd.delegate = nil;
    self.bannerAd.appEventDelegate = nil;
    [self.bannerAd removeFromSuperview];
    self.bannerAd = nil;
    self.firstLoadAdResponseReceivedExpectation = nil;
    self.secondLoadAdResponseReceivedExpectation = nil;
    [[UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController dismissViewControllerAnimated:NO completion:nil];
    
}

-(void) setupBannerWithPlacement:(NSString *)placement withFrame:(CGRect)frame andSize:(CGSize)size{
    self.bannerAd = [[ANBannerAdView alloc] initWithFrame:frame
                                              placementId:placement
                                                   adSize:size];
    self.bannerAd.autoRefreshInterval = 0;
    self.bannerAd.delegate = self;
    self.bannerAd.enableNativeRendering = YES;
    self.bannerAd.shouldAllowNativeDemand = YES;
    
}

- (void)testBannerNativeRendererAd {
    [self stubRequestWithResponse:@"PerformanceStatsRTBBannerNativeRendererAd"];
    
    CGRect rect = CGRectMake(0, 0, 300, 250);
    int adWidth  = 300;
    int adHeight = 250;
    CGSize size = CGSizeMake(adWidth, adHeight);
    [self setupBannerWithPlacement:BANNERNATIVERENDERER_PLACEMENT withFrame:rect andSize:size];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.bannerAd];
    self.testCase = PERFORMANCESTATSRTBAD_FIRST_REQUEST;
    [self.bannerAd loadAd];
    [[ANTimeTracker sharedInstance] setTimeAt:PERFORMANCESTATSRTBAD_FIRST_REQUEST];
    
    self.firstLoadAdResponseReceivedExpectation = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval/2
                                 handler:^(NSError *error) {
        
    }];
    
    
    [self stubRequestWithResponse:@"PerformanceStatsRTBBannerNativeRendererAd"];
    
    [self setupBannerWithPlacement:BANNERNATIVERENDERER_PLACEMENT withFrame:rect andSize:size];
    [[ANTimeTracker sharedInstance] getDiffereanceAt:PERFORMANCESTATSRTBAD_SECOND_REQUEST];
    self.testCase = PERFORMANCESTATSRTBAD_SECOND_REQUEST;
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.bannerAd];
    [self.bannerAd loadAd];
    
    
    self.secondLoadAdResponseReceivedExpectation = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout: kAppNexusRequestTimeoutInterval/2
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

- (void)fulfillExpectation:(XCTestExpectation *)expectation
{
    [expectation fulfill];
}

- (void)waitForTimeInterval:(NSTimeInterval)delay
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"wait"];
    [self performSelector:@selector(fulfillExpectation:) withObject:expectation afterDelay:delay];
    
    [self waitForExpectationsWithTimeout:delay + 1 handler:nil];
}



#pragma mark - ANAdDelegate


- (void)adDidReceiveAd:(id)ad
{
    
    if( [self.testCase isEqualToString:PERFORMANCESTATSRTBAD_FIRST_REQUEST]){
        [[ANTimeTracker sharedInstance] getDiffereanceAt:@"adDidReceiveAd-FirstRequest"];
        NSString *adLoadKey = [NSString stringWithFormat:@"%@%@",BANNERNATIVERENDERER,PERFORMANCESTATSRTBAD_FIRST_REQUEST];
        [ANTimeTracker saveSet:adLoadKey date:[NSDate date] loadTime:[ANTimeTracker sharedInstance].timeTaken];
        NSLog(@"PerformanceStats RTB %@ - %@",adLoadKey, [ANTimeTracker getData:adLoadKey]);
        
        XCTAssertGreaterThan(PERFORMANCESTATSRTBBANNERNATIVERENDERERAD_FIRST_LOAD,[ANTimeTracker sharedInstance].timeTaken);
        XCTAssertGreaterThan(PERFORMANCESTATSRTBBANNERNATIVERENDERERADAD_WEBVIEW_FIRST_LOAD,[[ANTimeTracker sharedInstance] getTimeTakenByWebview]);
        
        XCTAssertGreaterThan(PERFORMANCESTATSRTB_NETWORK_FIRST_LOAD,[[ANTimeTracker sharedInstance] getTimeTakenByNetworkCall]);
        
        [self.firstLoadAdResponseReceivedExpectation fulfill];
        
    }else if( [self.testCase isEqualToString:PERFORMANCESTATSRTBAD_SECOND_REQUEST]){
        [[ANTimeTracker sharedInstance] getDiffereanceAt:@"adDidReceiveAd-SecondRequest"];
        NSString *adLoadKey = [NSString stringWithFormat:@"%@%@",BANNERNATIVERENDERER,PERFORMANCESTATSRTBAD_SECOND_REQUEST];
        [ANTimeTracker saveSet:adLoadKey date:[NSDate date] loadTime:[ANTimeTracker sharedInstance].timeTaken];
        NSLog(@"PerformanceStats RTB %@ - %@",adLoadKey, [ANTimeTracker getData:adLoadKey]);
        
        XCTAssertGreaterThan(PERFORMANCESTATSRTBBANNERNATIVERENDERERAD_SECOND_LOAD,[ANTimeTracker sharedInstance].timeTaken);
        
        XCTAssertGreaterThan(PERFORMANCESTATSRTBBANNERNATIVERENDERERADAD_WEBVIEW_SECOND_LOAD,[[ANTimeTracker sharedInstance] getTimeTakenByWebview]);
        
        XCTAssertGreaterThan(PERFORMANCESTATSRTB_NETWORK_SECOND_LOAD,[[ANTimeTracker sharedInstance] getTimeTakenByNetworkCall]);
        [self.secondLoadAdResponseReceivedExpectation fulfill];
    }
}



- (void)ad:(id<ANAdProtocol>)ad requestFailedWithError:(NSError *)error
{
    NSLog(@"BannerNative Renderer Ad Failed to Load");
}


@end
