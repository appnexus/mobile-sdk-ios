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
#import "ANMultiAdRequest.h"
#import "ANHTTPStubbingManager.h"
#import "ANNativeAdRequest.h"
#import "ANSDKSettings+PrivateMethods.h"
#import "ANAdFetcher+ANTest.h"
#import "ANNativeAdRequest+ANTest.h"
#import "ANTimeTracker.h"
#import "XandrAd.h"





@interface AdPerformanceStatsNativeOnlyMARAdTestCase : XCTestCase<ANMultiAdRequestDelegate>
@property (nonatomic, readwrite, strong)            ANMultiAdRequest    *mar;

@property (nonatomic,readwrite,strong) ANNativeAdRequest *nativeAdRequest1;
@property (nonatomic,readwrite,strong) ANNativeAdRequest *nativeAdRequest2;

@property (nonatomic, strong) XCTestExpectation *firstLoadAdResponseReceivedExpectation;
@property (nonatomic, strong) XCTestExpectation *secondLoadAdResponseReceivedExpectation;
@property (nonatomic, strong) NSString *testCase;



@end

@implementation AdPerformanceStatsNativeOnlyMARAdTestCase

#pragma mark - Test lifecycle.

- (void)setUp {
    [super setUp];
    [self clearCountsAndExpectations];
    // Init here if not the tests will crash
    [[XandrAd sharedInstance] initWithMemberID:1 preCacheRequestObjects:true completionHandler:nil];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}



- (void)clearCountsAndExpectations
{
    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
    self.firstLoadAdResponseReceivedExpectation = nil;
    self.secondLoadAdResponseReceivedExpectation = nil;
    
    self.nativeAdRequest1 = nil;
    self.nativeAdRequest2 = nil;
    self.mar = nil;
    for (UIView *additionalView in [[ANGlobal getKeyWindow].rootViewController.view subviews]){
          [additionalView removeFromSuperview];
      }
}


#pragma mark - Test methods.



-(void)createAllMARCombination {
    
    self.nativeAdRequest1 = [self setNativeAdUnit:NATIVE_PLACEMENT];
    self.nativeAdRequest2 = [self setNativeAdUnit:NATIVE_PLACEMENT];
    
    self.mar = [[ANMultiAdRequest alloc] initWithMemberId:10094 andDelegate:self];
        
    [self.mar addAdUnit:self.nativeAdRequest1];
    [self.mar addAdUnit:self.nativeAdRequest2];
    
    [self.mar load];
    
}


-(void)testMAR{
    self.testCase = PERFORMANCESTATSRTBAD_FIRST_REQUEST_NATIVE_SDK;
    [self createAllMARCombination];
    [[ANTimeTracker sharedInstance] setTimeAt:PERFORMANCESTATSRTBAD_FIRST_REQUEST_NATIVE_SDK];
    
    self.firstLoadAdResponseReceivedExpectation = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval*2
                                 handler:^(NSError *error) {
        
    }];
    
    self.testCase = PERFORMANCESTATSRTBAD_SECOND_REQUEST_NATIVE_SDK;
    [[ANTimeTracker sharedInstance] getDiffereanceAt:PERFORMANCESTATSRTBAD_SECOND_REQUEST];
    [self createAllMARCombination];
    self.secondLoadAdResponseReceivedExpectation = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval*2
                                 handler:^(NSError *error) {
        
    }];
    
}



- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [self clearCountsAndExpectations];
    
}


#pragma mark - ANAdDelegate

- (void)multiAdRequestDidComplete:(ANMultiAdRequest *)mar{
    NSLog(@"multiAdRequest - multiAdRequestDidComplete");
    
    if( [self.testCase isEqualToString:PERFORMANCESTATSRTBAD_FIRST_REQUEST_NATIVE_SDK]){

        [[ANTimeTracker sharedInstance] getDiffereanceAt:@"adDidReceiveAd-FirstRequest"];

        NSString *adLoadKey = [NSString stringWithFormat:@"%@%@",MAR,PERFORMANCESTATSRTBAD_FIRST_REQUEST_NATIVE_SDK];
        [ANTimeTracker saveSet:adLoadKey date:[NSDate date] loadTime:[ANTimeTracker sharedInstance].timeTaken];
        
        XCTAssertGreaterThan(PERFORMANCESTATSRTBMARAD_FIRST_LOAD,[ANTimeTracker sharedInstance].timeTaken);
        
        XCTAssertGreaterThan(PERFORMANCESTATSRTB_NETWORK_FIRST_LOAD,[[ANTimeTracker sharedInstance] getTimeTakenByNetworkCall]);
        
        [self.firstLoadAdResponseReceivedExpectation fulfill];
        
    }else if( [self.testCase isEqualToString:PERFORMANCESTATSRTBAD_SECOND_REQUEST_NATIVE_SDK]){
        
        [[ANTimeTracker sharedInstance] getDiffereanceAt:@"adDidReceiveAd-SecondRequest"];
        
        NSString *adLoadKey = [NSString stringWithFormat:@"%@%@",MAR_NATIVE_SDK,PERFORMANCESTATSRTBAD_SECOND_REQUEST_NATIVE_SDK];

        [ANTimeTracker saveSet:adLoadKey date:[NSDate date] loadTime:[ANTimeTracker sharedInstance].timeTaken];
        
        XCTAssertGreaterThan(PERFORMANCESTATSRTBMARAD_SECOND_LOAD,[ANTimeTracker sharedInstance].timeTaken);
        
        XCTAssertGreaterThan(PERFORMANCESTATSRTB_NETWORK_SECOND_LOAD,[[ANTimeTracker sharedInstance] getTimeTakenByNetworkCall]);
        
        [self.secondLoadAdResponseReceivedExpectation fulfill];
    }
}

- (void)multiAdRequest:(ANMultiAdRequest *)mar didFailWithError:(NSError *)error{
    NSLog(@"multiAdRequest - didFailWithError %@",error);
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


-(ANNativeAdRequest *) setNativeAdUnit : (NSString *)placement {
    ANNativeAdRequest *nativeAdRequest= [[ANNativeAdRequest alloc] init];
    nativeAdRequest.placementId = placement;
    nativeAdRequest.shouldLoadIconImage = YES;
    nativeAdRequest.shouldLoadMainImage = YES;
    return nativeAdRequest;
}

@end
