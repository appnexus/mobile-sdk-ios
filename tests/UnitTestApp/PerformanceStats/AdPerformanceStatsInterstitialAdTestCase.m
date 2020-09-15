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
#import "ANInterstitialAd.h"
#import "ANGlobal.h"
#import "ANHTTPStubbingManager.h"
#import "ANSDKSettings+PrivateMethods.h"
#import "ANTimeTracker.h"
@interface AdPerformanceStatsInterstitialAdTestCase : XCTestCase <ANInterstitialAdDelegate>
@property (nonatomic, readwrite, strong)  ANInterstitialAd      *interstitial;
@property (nonatomic, strong) XCTestExpectation *firstLoadAdResponseReceivedExpectation;
@property (nonatomic, strong) XCTestExpectation *secondLoadAdResponseReceivedExpectation;
@property (nonatomic, strong) NSString *testCase;
@end

@implementation AdPerformanceStatsInterstitialAdTestCase

- (void)setUp {
    
    [self clearAd];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    [self clearAd];
}

-(void)clearAd{
    
    [[ANHTTPStubbingManager sharedStubbingManager] disable];
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    
    self.interstitial.delegate = nil;
    self.interstitial.appEventDelegate = nil;
    [self.interstitial removeFromSuperview];
    self.interstitial = nil;
    
    self.firstLoadAdResponseReceivedExpectation = nil;
    self.secondLoadAdResponseReceivedExpectation = nil;
    for (UIView *additionalView in [[UIApplication sharedApplication].keyWindow.rootViewController.view subviews]){
        [additionalView removeFromSuperview];
    }
}

-(void) setupInterstitialWithPlacement:(NSString *)placement{
    self.interstitial = [[ANInterstitialAd alloc] init];
    self.interstitial.placementId = placement;
    self.interstitial.forceCreativeId = 223272198;
    self.interstitial.delegate = self;
}

- (void)testInterstitialAd {
    [self setupInterstitialWithPlacement:INTERSTITIAL_PLACEMENT];
    self.testCase = PERFORMANCESTATSRTBAD_FIRST_REQUEST;
    [[ANTimeTracker sharedInstance] setTimeAt:PERFORMANCESTATSRTBAD_FIRST_REQUEST];
    [self.interstitial loadAd];
    
    
    self.firstLoadAdResponseReceivedExpectation = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
        
    }];
    
    [self setupInterstitialWithPlacement:INTERSTITIAL_PLACEMENT];
    self.testCase = PERFORMANCESTATSRTBAD_SECOND_REQUEST;
    [[ANTimeTracker sharedInstance] getDiffereanceAt:PERFORMANCESTATSRTBAD_SECOND_REQUEST];
    [self.interstitial loadAd];
    self.secondLoadAdResponseReceivedExpectation = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
        
    }];
    
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
    NSLog(@"Interstitial Ad Did ReceiveAd ");
    
    if( [self.testCase isEqualToString:PERFORMANCESTATSRTBAD_FIRST_REQUEST]){
        
        [[ANTimeTracker sharedInstance] getDiffereanceAt:@"adDidReceiveAd-FirstRequest"];
        
        NSString *adLoadKey = [NSString stringWithFormat:@"%@%@",INTERSTITIAL,PERFORMANCESTATSRTBAD_FIRST_REQUEST];
        [ANTimeTracker saveSet:adLoadKey date:[NSDate date] loadTime:[ANTimeTracker sharedInstance].timeTaken];
        NSLog(@"PerformanceStats RTB %@ - %@",adLoadKey, [ANTimeTracker getData:adLoadKey]);
        
        XCTAssertGreaterThan(PERFORMANCESTATSRTBINTERSTITIALAD_FIRST_LOAD,[ANTimeTracker sharedInstance].timeTaken);
        XCTAssertGreaterThan(PERFORMANCESTATSRTBINTERSTITIALAD_WEBVIEW_FIRST_LOAD,[[ANTimeTracker sharedInstance] getTimeTakenByWebview]);
        
        XCTAssertGreaterThan(PERFORMANCESTATSRTB_NETWORK_FIRST_LOAD,[[ANTimeTracker sharedInstance] getTimeTakenByNetworkCall]);
        
        [self.firstLoadAdResponseReceivedExpectation fulfill];
        
    }else if( [self.testCase isEqualToString:PERFORMANCESTATSRTBAD_SECOND_REQUEST]){
        
        [[ANTimeTracker sharedInstance] getDiffereanceAt:@"adDidReceiveAd-SecondRequest"];
        
        NSString *adLoadKey = [NSString stringWithFormat:@"%@%@",INTERSTITIAL,PERFORMANCESTATSRTBAD_SECOND_REQUEST];
        [ANTimeTracker saveSet:adLoadKey date:[NSDate date] loadTime:[ANTimeTracker sharedInstance].timeTaken];
        NSLog(@"PerformanceStats RTB %@ - %@",adLoadKey, [ANTimeTracker getData:adLoadKey]);
        
        XCTAssertGreaterThan(PERFORMANCESTATSRTBINTERSTITIALAD_SECOND_LOAD,[ANTimeTracker sharedInstance].timeTaken);
        XCTAssertGreaterThan(PERFORMANCESTATSRTBINTERSTITIALAD_WEBVIEW_SECOND_LOAD,[[ANTimeTracker sharedInstance] getTimeTakenByWebview]);
        XCTAssertGreaterThan(PERFORMANCESTATSRTB_NETWORK_SECOND_LOAD,[[ANTimeTracker sharedInstance] getTimeTakenByNetworkCall]);
        [self.secondLoadAdResponseReceivedExpectation fulfill];
    }
    
}


- (void)ad:(id<ANAdProtocol>)ad requestFailedWithError:(NSError *)error
{
    NSLog(@"Interstitial Ad Failed ");
}

@end
