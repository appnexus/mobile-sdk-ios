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
#import <CoreLocation/CoreLocation.h>

#import "ANHTTPStubbingManager.h"
#import "ANBannerAdView+ANTest.h"
#import "ANSDKSettings+PrivateMethods.h"
#import "ANTestGlobal.h"



@interface ANBannerAdTestCase : XCTestCase<ANBannerAdViewDelegate>

@property (nonatomic, readwrite, strong)  ANBannerAdView        *banner;
@property (nonatomic, readwrite, strong)  UIView        *bannerSuperView;

@property (nonatomic, readwrite)  BOOL  receiveAdSuccess;
@property (nonatomic, readwrite)  BOOL  receiveAdFailure;

@property (nonatomic, strong) XCTestExpectation *loadAdResponseReceivedExpectation;
@property (nonatomic, strong) XCTestExpectation *loadAdResponseFailedExpectation;

@property (nonatomic, readwrite)  BOOL  locationEnabledForCreative;

@end

@implementation ANBannerAdTestCase

#pragma mark - Test lifecycle.

- (void)setUp {
    [super setUp];
    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;

    self.banner = nil;

    self.receiveAdSuccess = NO;
    self.receiveAdFailure = NO;
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
    [[ANHTTPStubbingManager sharedStubbingManager] disable];
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    
    ANSDKSettings.sharedInstance.locationEnabledForCreative = NO;
    ANSDKSettings.sharedInstance.HTTPSEnabled = NO;
    self.banner.delegate = nil;
    self.banner.appEventDelegate = nil;
    [self.banner removeFromSuperview];
    self.banner = nil;
    [[UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController dismissViewControllerAnimated:NO
                                                                                                               completion:nil];
    
    self.loadAdResponseReceivedExpectation = nil;
    
}


-(void) setupBannerWithPlacement:(NSString *)placement withFrame:(CGRect)frame andSize:(CGSize)size{
    
    
    self.banner = [[ANBannerAdView alloc] initWithFrame:frame
                                            placementId:placement
                                                 adSize:size];
    self.banner.accessibilityLabel = @"AdView";
    self.banner.autoRefreshInterval = 0;
    self.banner.delegate = self;
}




#pragma mark - Test methods.

- (void)testIncorrectWidth
{
    self.bannerSuperView = [[UIView alloc]initWithFrame:CGRectMake(0, 0 , 320, 430)];
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.bannerSuperView];

    CGRect rect = CGRectMake(0, 0, self.bannerSuperView.frame.size.width, self.bannerSuperView.frame.size.height);
    int adWidth  = 0;
    int adHeight = 10;
    NSArray *sizes = [NSArray arrayWithObjects:
                      [NSValue valueWithCGSize:CGSizeMake(adWidth, adHeight)],
                      nil];
    ANSDKSettings.sharedInstance.sizesThatShouldConstrainToSuperview  = sizes;
    CGSize size = CGSizeMake(adWidth, adHeight);
    [self setupBannerWithPlacement:@"13653381" withFrame:rect andSize:size];

    [self.bannerSuperView addSubview:self.banner];


    [self stubRequestWithResponse:@"SuccessfulAllowMagicSizeBannerObjectResponse"];
    [self.banner loadAd];

    XCTAssertTrue(self.receiveAdFailure);
    XCTAssertFalse(self.receiveAdSuccess);
}

- (void)testIncorrectHeight
{
    self.bannerSuperView = [[UIView alloc]initWithFrame:CGRectMake(0, 0 , 320, 430)];
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.bannerSuperView];

    CGRect rect = CGRectMake(0, 0, self.bannerSuperView.frame.size.width, self.bannerSuperView.frame.size.height);
    int adWidth  = 10;
    int adHeight = -42;
    NSArray *sizes = [NSArray arrayWithObjects:
                      [NSValue valueWithCGSize:CGSizeMake(adWidth, adHeight)],
                      nil];
    ANSDKSettings.sharedInstance.sizesThatShouldConstrainToSuperview  = sizes;
    CGSize size = CGSizeMake(adWidth, adHeight);
    [self setupBannerWithPlacement:@"13653381" withFrame:rect andSize:size];

    [self.bannerSuperView addSubview:self.banner];


    [self stubRequestWithResponse:@"SuccessfulAllowMagicSizeBannerObjectResponse"];
    [self.banner loadAd];

    XCTAssertTrue(self.receiveAdFailure);
    XCTAssertFalse(self.receiveAdSuccess);
}

- (void)testBannerAllowMagicSize {
    
    self.bannerSuperView = [[UIView alloc]initWithFrame:CGRectMake(0, 0 , 320, 430)];
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.bannerSuperView];
    
    CGRect rect = CGRectMake(0, 0, self.bannerSuperView.frame.size.width, self.bannerSuperView.frame.size.height);
    int adWidth  = 10;
    int adHeight = 10;
    NSArray *sizes = [NSArray arrayWithObjects:
                      [NSValue valueWithCGSize:CGSizeMake(adWidth, adHeight)],
                      nil];
    ANSDKSettings.sharedInstance.sizesThatShouldConstrainToSuperview  = sizes;
    CGSize size = CGSizeMake(adWidth, adHeight);
    [self setupBannerWithPlacement:@"13653381" withFrame:rect andSize:size];
    
    [self.bannerSuperView addSubview:self.banner];
    
    
    [self stubRequestWithResponse:@"SuccessfulAllowMagicSizeBannerObjectResponse"];
    [self.banner loadAd];
    
    self.loadAdResponseReceivedExpectation = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
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

-(void)testBannerAdLocationPopupBlocked{
    
    ANSDKSettings.sharedInstance.HTTPSEnabled = YES;
    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
    [self stubRequestWithResponse:@"SuccessfulLocationCreativeForBannerAdResponse"];
    
    self.locationEnabledForCreative = NO;
    ANSDKSettings.sharedInstance.locationEnabledForCreative = NO;
    
    
    self.banner = [[ANBannerAdView alloc] initWithFrame: CGRectMake(50 , 50 , 300,250)
                                            placementId: @"1"
                                                 adSize: CGSizeMake(300 , 250)];
    
    self.banner.rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    self.banner.delegate = self;
    [self.banner loadAd];
    UIViewController *copyRootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.banner];
    
    self.loadAdResponseReceivedExpectation = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout:5 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    
    
    [self waitForTimeInterval:8];
    
    XCTAssertFalse([self isLocationPopupExist]);
    
    
    XCTAssertEqual(self.banner.adSize.width, 300);
    XCTAssertEqual(self.banner.adSize.height, 250);
    XCTAssertEqual(self.banner.adType, ANAdTypeBanner);
    XCTAssertEqualObjects(self.banner.creativeId, @"106794309");
    [UIApplication sharedApplication].keyWindow.rootViewController  = copyRootViewController;
}

-(void)testBannerAdLocationPopupUnblocked{
    ANSDKSettings.sharedInstance.HTTPSEnabled = YES;
    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
    [self stubRequestWithResponse:@"SuccessfulLocationCreativeForBannerAdResponse"];
    
    
    self.banner = nil;
    self.locationEnabledForCreative = YES;
    
    
    ANSDKSettings.sharedInstance.locationEnabledForCreative = YES;
    
    self.banner = [[ANBannerAdView alloc] initWithFrame: CGRectMake(50 , 50 , 300,250)
                                            placementId: @"1"
                                                 adSize: CGSizeMake(300 , 250)];
    
    self.banner.rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    self.banner.delegate = self;
    [self.banner loadAd];
    
    
    UIViewController *copyRootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.banner];
    
    
    self.loadAdResponseReceivedExpectation = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout:10 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    
    [self waitForTimeInterval:8];
    if (self.locationEnabledForCreative && [CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusNotDetermined){
        XCTAssertTrue([self isLocationPopupExist]);
    }else{
        XCTAssertFalse([self isLocationPopupExist]);
    }
    XCTAssertEqual(self.banner.loadedAdSize.width, 300);
    XCTAssertEqual(self.banner.loadedAdSize.height, 250);
    XCTAssertEqual(self.banner.adType, ANAdTypeBanner);
    XCTAssertEqualObjects(self.banner.creativeId, @"106794309");
    [UIApplication sharedApplication].keyWindow.rootViewController  = copyRootViewController;
    
}

-(BOOL)isLocationPopupExist {
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIViewController *rootViewController = window.rootViewController;
    
    if ([[rootViewController presentedViewController] isKindOfClass:[UIAlertController class]]) {
        [rootViewController dismissViewControllerAnimated:YES completion:nil];
        return YES;
    }
    return NO;
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

- (void)adDidReceiveAd:(id<ANAdProtocol>)ad
{
    [self.loadAdResponseReceivedExpectation fulfill];
    self.receiveAdSuccess = YES;
}


- (void)ad:(id<ANAdProtocol>)ad requestFailedWithError:(NSError *)error
{
    TESTTRACEM(@"error.info=%@", error.userInfo);

    [self.loadAdResponseReceivedExpectation fulfill];
    [self.loadAdResponseFailedExpectation fulfill];
    self.receiveAdFailure = YES;
}

@end
