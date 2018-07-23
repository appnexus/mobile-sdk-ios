/*   Copyright 2018 APPNEXUS INC
 
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
#import "ANHTTPStubbingManager.h"
#import "ANBannerAdView+ANTest.h"
#import "ANSDKSettings+PrivateMethods.h"


@interface ANBannerAdTestCase : XCTestCase<ANBannerAdViewDelegate>
@property (nonatomic, readwrite, strong)  ANBannerAdView        *banner;
@property (nonatomic, readwrite, strong)  UIView        *bannerSuperView;
@property (nonatomic, strong) XCTestExpectation *loadAdSuccesfulException;

@end

@implementation ANBannerAdTestCase

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    self.banner = nil;
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
}


-(void) setupBannerMagicSize{
    
    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
    
    self.bannerSuperView = [[UIView alloc]initWithFrame:CGRectMake(0, 0 , 320, 430)];
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.bannerSuperView];
    
    
    
    NSString *adID = @"13653381";
    int adWidth  = 10;
    int adHeight = 10;
    NSArray *sizes = [NSArray arrayWithObjects:
                      [NSValue valueWithCGSize:CGSizeMake(adWidth, adHeight)],
                      nil];
    ANSDKSettings.sharedInstance.sizesThatShouldConstrainToSuperview  = sizes;
    
    
    CGRect rect = CGRectMake(0, 0, self.bannerSuperView.frame.size.width, self.bannerSuperView.frame.size.height);
    CGSize size = CGSizeMake(adWidth, adHeight);
    
    
    self.banner = [[ANBannerAdView alloc] initWithFrame:rect
                                            placementId:adID
                                                 adSize:size];
    self.banner.accessibilityLabel = @"AdView";
    self.banner.autoRefreshInterval = 0;
    self.banner.delegate = self;
    [self.bannerSuperView addSubview:self.banner];
}

- (void)testBannerAllowMagicSize {
    [self setupBannerMagicSize];
    [self stubRequestWithResponse:@"SuccessfulAllowMagicSizeBannerObjectResponse"];
    [self.banner loadAd];
    
    self.loadAdSuccesfulException = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    
    XCTAssertEqual(self.banner.frame.size.width, self.bannerSuperView.frame.size.width);
    XCTAssertEqual(self.banner.frame.size.height, self.bannerSuperView.frame.size.height);
    XCTAssertEqual(self.banner.loadedAdSize.width, 10);
    XCTAssertEqual(self.banner.loadedAdSize.height, 10);
    XCTAssertEqual(self.banner.adType, ANAdTypeBanner);
    XCTAssertEqualObjects(self.banner.creativeId, @"106954775");
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

- (void)adDidReceiveAd:(id<ANAdProtocol>)ad {
    [self.loadAdSuccesfulException fulfill];
}


- (void)ad:(id<ANAdProtocol>)ad requestFailedWithError:(NSError *)error {
    [self.loadAdSuccesfulException fulfill];
    
}

@end
