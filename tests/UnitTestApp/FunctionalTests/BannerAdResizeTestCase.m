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
#import "ANBannerAdView.h"
#import "ANGlobal.h"
#import "XCTestCase+ANCategory.h"
#import "UIView+ANCategory.h"



@interface BannerAdResizeTestCase : XCTestCase<ANBannerAdViewDelegate>

@property (nonatomic, readwrite, strong)  ANBannerAdView        *banner;
@property (nonatomic, readwrite, strong)  UIView        *bannerSuperView;

@property (nonatomic, readwrite)  BOOL  receiveAdSuccess;

@property (nonatomic, readwrite)  BOOL  shouldResizeAdToFitContainer;
@property (nonatomic, strong) XCTestExpectation *loadAdShouldResizeAdToFitContainerExpectation;

@property (nonatomic, readwrite) CGAffineTransform transformValue;

@end

@implementation BannerAdResizeTestCase

#pragma mark - Test lifecycle.

- (void)setUp {
    [super setUp];
    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
    
    self.banner = nil;
    
    self.receiveAdSuccess = NO;
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
    [[ANHTTPStubbingManager sharedStubbingManager] disable];
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    self.receiveAdSuccess = NO;
    self.shouldResizeAdToFitContainer = NO;
    self.banner.delegate = nil;
    self.banner.appEventDelegate = nil;
    [self.banner removeFromSuperview];
    self.banner = nil;
    self.bannerSuperView = nil;
    [[ANGlobal getKeyWindow].rootViewController.presentedViewController dismissViewControllerAnimated:NO
                                                                                                               completion:nil];
    self.loadAdShouldResizeAdToFitContainerExpectation = nil;
    for (UIView *additionalView in [[ANGlobal getKeyWindow].rootViewController.view subviews]){
          [additionalView removeFromSuperview];
      }
}


-(void) setupBannerWithPlacement:(NSString *)placement withFrame:(CGRect)frame andSize:(CGSize)size{
    
    
    self.banner = [[ANBannerAdView alloc] initWithFrame:frame
                                            placementId:placement
                                                 adSize:size];
    self.banner.accessibilityLabel = @"AdView";
    self.banner.autoRefreshInterval = 0;
    self.banner.delegate = self;
}




- (void)testBannerRTBShouldResizeAdToFitContainerFalse {
    
    self.shouldResizeAdToFitContainer = NO;
    self.bannerSuperView = [[UIView alloc]initWithFrame:CGRectMake(0, 0 , 320, 400)];
    [[ANGlobal getKeyWindow].rootViewController.view addSubview:self.bannerSuperView];
    
    CGRect rect = CGRectMake(0, 0, self.bannerSuperView.frame.size.width, self.bannerSuperView.frame.size.height);
    int adWidth  = 300;
    int adHeight = 250;
    CGSize size = CGSizeMake(adWidth, adHeight);
    
    
    CGFloat  horizontalScaleFactor   = self.bannerSuperView.frame.size.width / adWidth;
    CGFloat  verticalScaleFactor     = self.bannerSuperView.frame.size.height / adHeight;
    CGFloat  scaleFactor             = horizontalScaleFactor < verticalScaleFactor ? horizontalScaleFactor : verticalScaleFactor;
    self.transformValue = CGAffineTransformMakeScale(scaleFactor, scaleFactor);
    
    
    
    [self setupBannerWithPlacement:@"1" withFrame:rect andSize:size];
    [self stubRequestWithResponse:@"SuccessfulRTBShouldResizeAdToFitContainer"];
    self.banner.shouldResizeAdToFitContainer = NO;
    
    [self.banner loadAd];
    [self.bannerSuperView addSubview:self.banner];
    
    self.loadAdShouldResizeAdToFitContainerExpectation = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout:4 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    
    XCTAssertEqual(self.banner.adResponseInfo.adType, ANAdTypeBanner);
    
}

- (void)testBannerRTBShouldResizeAdToFitContainerTrue {
    
    self.shouldResizeAdToFitContainer = YES;
    self.bannerSuperView = [[UIView alloc]initWithFrame:CGRectMake(0, 0 , 320, 400)];
    [[ANGlobal getKeyWindow].rootViewController.view addSubview:self.bannerSuperView];
    
    CGRect rect = CGRectMake(0, 0, self.bannerSuperView.frame.size.width, self.bannerSuperView.frame.size.height);
    int adWidth  = 300;
    int adHeight = 250;
    CGSize size = CGSizeMake(adWidth, adHeight);
    
    
    CGFloat  horizontalScaleFactor   = self.bannerSuperView.frame.size.width / adWidth;
    CGFloat  verticalScaleFactor     = self.bannerSuperView.frame.size.height / adHeight;
    CGFloat  scaleFactor             = horizontalScaleFactor < verticalScaleFactor ? horizontalScaleFactor : verticalScaleFactor;
    self.transformValue = CGAffineTransformMakeScale(scaleFactor, scaleFactor);
    
    
    
    [self setupBannerWithPlacement:@"1" withFrame:rect andSize:size];
    [self stubRequestWithResponse:@"SuccessfulRTBShouldResizeAdToFitContainer"];
    self.banner.shouldResizeAdToFitContainer = YES;
    
    [self.banner loadAd];
    [self.bannerSuperView addSubview:self.banner];
    
    self.loadAdShouldResizeAdToFitContainerExpectation = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout:4 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    XCTAssertEqual(self.banner.adResponseInfo.adType, ANAdTypeBanner);
    XCTAssertTrue(self.receiveAdSuccess);
    
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
    self.receiveAdSuccess = YES;

    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        ANBannerAdView *bannerAdObject = (ANBannerAdView *)ad;
        if(self.shouldResizeAdToFitContainer){
            
            XCTAssertEqual(self.transformValue.a, bannerAdObject.contentView.transform.a);
            XCTAssertEqual(self.transformValue.d, bannerAdObject.contentView.transform.d);
            
        }else{
            XCTAssertNotEqual(self.transformValue.a, bannerAdObject.contentView.transform.a);
            XCTAssertNotEqual(self.transformValue.d, bannerAdObject.contentView.transform.d);
            
        }
        [self.loadAdShouldResizeAdToFitContainerExpectation fulfill];
        
    });
    
    
}



- (void)ad:(id<ANAdProtocol>)ad requestFailedWithError:(NSError *)error
{
    TESTTRACEM(@"error.info=%@", error.userInfo);
    self.receiveAdSuccess = NO;

    [self.loadAdShouldResizeAdToFitContainerExpectation fulfill];
}

@end
