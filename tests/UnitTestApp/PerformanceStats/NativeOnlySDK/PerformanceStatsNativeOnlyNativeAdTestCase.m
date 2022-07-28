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
#import "ANNativeAdRequest.h"
#import "ANGlobal.h"
#import "ANTestGlobal.h"
#import "ANHTTPStubbingManager.h"
#import "ANSDKSettings+PrivateMethods.h"
#import "NSURLRequest+HTTPBodyTesting.h"
#import "ANLogManager.h"
#import "ANNativeAdResponse.h"
#import "ANTimeTracker.h"
#import "XandrAd.h"


@interface PerformanceStatsNativeOnlyNativeAdTestCase : XCTestCase <ANNativeAdRequestDelegate>

@property (nonatomic, readwrite, strong)  ANNativeAdRequest     *adRequest;

@property (nonatomic, strong) XCTestExpectation *firstLoadAdResponseReceivedExpectation;
@property (nonatomic, strong) XCTestExpectation *secondLoadAdResponseReceivedExpectation;
@property (nonatomic, strong) NSString *testCase;

@end

@implementation PerformanceStatsNativeOnlyNativeAdTestCase

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    [self clearAd];
    // Init here if not the tests will crash
    [[XandrAd sharedInstance] initWithMemberID:1 preCacheRequestObjects:true completionHandler:nil];
    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
    
}

- (void)tearDown {
    [self clearAd];
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

-(void) setupVideoAdWithPlacement:(NSString *)placement{
    
    self.adRequest = [[ANNativeAdRequest alloc] init];
    self.adRequest.delegate = self;
    [self.adRequest setPlacementId:placement];
    self.adRequest.forceCreativeId = 142877136;
    
    
}


- (void)testNativeAd
{
    [self setupVideoAdWithPlacement:NATIVE_PLACEMENT];
    
    self.firstLoadAdResponseReceivedExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    self.testCase = PERFORMANCESTATSRTBAD_FIRST_REQUEST_NATIVE_SDK;
    [[ANTimeTracker sharedInstance] setTimeAt:PERFORMANCESTATSRTBAD_FIRST_REQUEST_NATIVE_SDK];
    
    [self.adRequest loadAd];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval/2
                                 handler:^(NSError * _Nullable error) {
        
    }];
    
    
    [self setupVideoAdWithPlacement:NATIVE_PLACEMENT];

    self.secondLoadAdResponseReceivedExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    self.testCase = PERFORMANCESTATSRTBAD_SECOND_REQUEST_NATIVE_SDK;
    [[ANTimeTracker sharedInstance] getDiffereanceAt:PERFORMANCESTATSRTBAD_SECOND_REQUEST_NATIVE_SDK];

    [self.adRequest loadAd];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval
                                 handler:^(NSError * _Nullable error) {

    }];
    
}

-(void)clearAd{
    
    [[ANHTTPStubbingManager sharedStubbingManager] disable];
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    
    self.adRequest.delegate = nil;
    self.adRequest = nil;
    
    self.firstLoadAdResponseReceivedExpectation = nil;
     self.secondLoadAdResponseReceivedExpectation = nil;
    for (UIView *additionalView in [[ANGlobal getKeyWindow].rootViewController.view subviews]){
          [additionalView removeFromSuperview];
      }
}

- (void)adRequest:(nonnull ANNativeAdRequest *)request didFailToLoadWithError:(nonnull NSError *)error withAdResponseInfo:(nullable ANAdResponseInfo *)adResponseInfo {
    NSLog(@"didFailToLoadWithError");
}

- (void)adRequest:(nonnull ANNativeAdRequest *)request didReceiveResponse:(nonnull ANNativeAdResponse *)response {
    NSLog(@"didReceiveResponse");
    
    
    
    if( [self.testCase isEqualToString:PERFORMANCESTATSRTBAD_FIRST_REQUEST_NATIVE_SDK]){
        
        [[ANTimeTracker sharedInstance] getDiffereanceAt:@"adDidReceiveAd-FirstRequest"];
        
        NSString *adLoadKey = [NSString stringWithFormat:@"%@%@",NATIVE_SDK,PERFORMANCESTATSRTBAD_FIRST_REQUEST_NATIVE_SDK];
        [ANTimeTracker saveSet:adLoadKey date:[NSDate date] loadTime:[ANTimeTracker sharedInstance].timeTaken];
        NSLog(@"PerformanceStats RTB %@ - %@",adLoadKey, [ANTimeTracker getData:adLoadKey]);

        XCTAssertGreaterThan(PERFORMANCESTATSRTBNATIVEAD_FIRST_LOAD,[ANTimeTracker sharedInstance].timeTaken);
        
        XCTAssertGreaterThan(PERFORMANCESTATSRTB_NETWORK_FIRST_LOAD,[[ANTimeTracker sharedInstance] getTimeTakenByNetworkCall]);

        [self.firstLoadAdResponseReceivedExpectation fulfill];
        
    }else if( [self.testCase isEqualToString:PERFORMANCESTATSRTBAD_SECOND_REQUEST_NATIVE_SDK]){
        
        
        [[ANTimeTracker sharedInstance] getDiffereanceAt:@"adDidReceiveAd-SecondRequest"];
        
        NSString *adLoadKey = [NSString stringWithFormat:@"%@%@",NATIVE_SDK,PERFORMANCESTATSRTBAD_SECOND_REQUEST_NATIVE_SDK];
        [ANTimeTracker saveSet:adLoadKey date:[NSDate date] loadTime:[ANTimeTracker sharedInstance].timeTaken];
        NSLog(@"PerformanceStats RTB %@ - %@",adLoadKey, [ANTimeTracker getData:adLoadKey]);
        
        XCTAssertGreaterThan(PERFORMANCESTATSRTBNATIVEAD_SECOND_LOAD,[ANTimeTracker sharedInstance].timeTaken);
        
        XCTAssertGreaterThan(PERFORMANCESTATSRTB_NETWORK_SECOND_LOAD,[[ANTimeTracker sharedInstance] getTimeTakenByNetworkCall]);

        [self.secondLoadAdResponseReceivedExpectation fulfill];
    }
    
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


@end
