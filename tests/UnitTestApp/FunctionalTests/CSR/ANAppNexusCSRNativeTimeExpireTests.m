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
#import "ANUniversalTagRequestBuilder.h"
#import "ANSDKSettings+PrivateMethods.h"
#import "TestANUniversalFetcher.h"
#import "TestANCSRUniversalFetcher.h"
#import "ANReachability.h"
#import "ANAdAdapterCSRNativeBannerFacebook+ANTest.h"
#import "ANAdFetcher+ANTest.h"
#import "ANHTTPStubbingManager.h"
#import "ANSDKSettings+PrivateMethods.h"
#import "SDKValidationURLProtocol.h"
#import "NSURLRequest+HTTPBodyTesting.h"
#import "ANNativeAdResponse+PrivateMethods.h"
#import "ANNativeAdResponse+ANTest.h"



@interface ANAppNexusCSRNativeTimeExpireTests : XCTestCase<ANNativeAdRequestDelegate, ANNativeAdDelegate >

@property (nonatomic, readwrite, strong)   ANNativeAdResponse     *nativeResponse;
@property (nonatomic, readwrite, strong)  ANNativeAdRequest     *nativeRequest;


//Expectations for OMID
@property (nonatomic, strong) XCTestExpectation *CSRAdWillExpireExpectation;

@property (nonatomic) NSString *testcase;
@property (nonatomic) UIView *nativeView;

@end

@implementation ANAppNexusCSRNativeTimeExpireTests

- (void)setUp {
    [super setUp];
    
    [self clearObject];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
    // Init here if not the tests will crash
    [[XandrAd sharedInstance] initWithMemberID:1 preCacheRequestObjects:true completionHandler:nil];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [self clearObject];
}


-(void)clearObject{
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    [[ANHTTPStubbingManager sharedStubbingManager] disable];

    // Clear all expectations for next test
    self.CSRAdWillExpireExpectation = nil;
    self.nativeView = nil;
    self.nativeRequest.delegate = nil;
    self.nativeRequest = nil;
    self.nativeResponse.delegate = nil;
    self.nativeResponse = nil;
    [[ANSDKSettings sharedInstance] setNativeAdAboutToExpireInterval:60];

}


- (void)testCSRAdWillExpireWithSettingAboutToExpireTimeIntervalGreaterThanUpperValue
{
    [[ANSDKSettings sharedInstance] setNativeAdAboutToExpireInterval:4000];
    self.nativeRequest = [[ANNativeAdRequest alloc] init];
    self.nativeRequest.delegate = self;
    self.testcase = @"CSRAdWillExpireExpectation";
    [self stubRequestWithResponse:@"CSR_Facebook_Banner_Native"];

    self.CSRAdWillExpireExpectation = [self expectationWithDescription:@"Didn't receive Click Tracker event"];
    [self.nativeRequest loadAd];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {

    }];

    XCTAssertEqual(ANSDKSettings.sharedInstance.nativeAdAboutToExpireInterval, 4000);
    XCTAssertEqual(self.nativeResponse.aboutToExpireInterval, 60);


}



- (void)testCSRAdWillExpireWithoutSettingAboutToExpireTimeInterval
{
    [[ANSDKSettings sharedInstance] setNativeAdAboutToExpireInterval:0];
    self.nativeRequest = [[ANNativeAdRequest alloc] init];
    self.nativeRequest.delegate = self;
    self.testcase = @"CSRAdWillExpireExpectation";
    [self stubRequestWithResponse:@"CSR_Facebook_Banner_Native"];

    self.CSRAdWillExpireExpectation = [self expectationWithDescription:@"Didn't receive Click Tracker event"];
    [self.nativeRequest loadAd];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {

    }];

    XCTAssertEqual([ANSDKSettings sharedInstance].nativeAdAboutToExpireInterval, 60);
    XCTAssertEqual(self.nativeResponse.aboutToExpireInterval, 60);


}

#pragma mark - ANAdDelegate

- (void)adRequest:(ANNativeAdRequest *)request didReceiveResponse:(ANNativeAdResponse *)response
{
    self.nativeView=[[UIView alloc]initWithFrame:CGRectMake(0, 100, 300, 250)];
    self.nativeResponse = (ANNativeAdResponse *)response;
    self.nativeResponse.delegate = self;
    ANAdAdapterCSRNativeBannerFacebook *fbNativeBanner = (ANAdAdapterCSRNativeBannerFacebook *)response.customElements[kANNativeCSRObject];

    UIImageView *imageview = [[UIImageView alloc]
                              initWithFrame:CGRectMake(50, 50, 20, 20)];
    [fbNativeBanner registerViewForTracking:self.nativeView
                     withRootViewController:[ANGlobal getKeyWindow].rootViewController
                              iconImageView:imageview];
    
}

- (void)adDidExpire:(nonnull id)response {
    NSLog(@"adDidExpire");
}

- (void)adWillExpire:(nonnull id)response {
    NSLog(@"adWillExpire");
    [self.CSRAdWillExpireExpectation fulfill];
    self.CSRAdWillExpireExpectation = nil;
}


- (void)adRequest:(ANNativeAdRequest *)request didFailToLoadWithError:(NSError *)error
{
    
}

- (void)adRequest:(ANNativeAdRequest *)request didFailToLoadWithError:(NSError *)error withAdResponseInfo:(ANAdResponseInfo *)adResponseInfo{
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


@end
