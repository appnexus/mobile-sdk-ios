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
#import "ANAdAdapterCSRNativeBannerFacebook+ANTest.h"
#import "ANHTTPStubbingManager.h"
#import "ANNativeAdView.h"

@interface ANNativeAdDidLogImpressionAPITestCase: XCTestCase <ANNativeAdRequestDelegate, ANNativeAdDelegate >

@property (nonatomic, readwrite, strong)   ANNativeAdResponse     *nativeResponse;
@property (nonatomic, readwrite, strong)  ANNativeAdRequest     *nativeRequest;
@property (nonatomic) ANNativeAdView *nativeAdView;

//Expectations for AdDidLogImpressionAPI
@property (nonatomic, strong) XCTestExpectation *adDidLogImpressionAPIForCSRAd;
@property (nonatomic, strong) XCTestExpectation *adDidLogImpressionAPIForNativeStandardAd;

@end

@implementation ANNativeAdDidLogImpressionAPITestCase


- (void)setUp {
    [super setUp];
    
    [self clearObject];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
    
    
    self.nativeRequest = [[ANNativeAdRequest alloc] init];
    self.nativeRequest.delegate = self;
    
    self.nativeAdView=[[ANNativeAdView alloc]initWithFrame:CGRectMake(0, 100, 300, 250)];
    [[ANGlobal getKeyWindow].rootViewController.view addSubview:self.nativeAdView];
    
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
    self.adDidLogImpressionAPIForCSRAd = nil;
    self.adDidLogImpressionAPIForNativeStandardAd = nil;
    self.nativeRequest = nil;
    self.nativeResponse = nil;
    
    for (UIView *additionalView in [[ANGlobal getKeyWindow].rootViewController.view subviews]){
             [additionalView removeFromSuperview];
         }
}

- (void)testCSRNativeBannerWithAdDidLogImpressionAPI
{
    [self stubRequestWithResponse:@"CSR_Facebook_Banner_Native_AdDidLogImpression"];
    self.adDidLogImpressionAPIForCSRAd = [self expectationWithDescription:@"Didn't get callbacks of CSRAd for adDidLogImpression"];
    [self.nativeRequest loadAd];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
        
    }];
    
}

- (void)testNativeStandardAdWithAdDidLogImpressionAPI
{
    [self stubRequestWithResponse:@"SuccessfulNativeStandardAdResponse"];
    self.adDidLogImpressionAPIForNativeStandardAd = [self expectationWithDescription:@"Didn't get callbacks of NativeStandard Ad for adDidLogImpression"];
    [self.nativeRequest loadAd];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
        
    }];
    
}

- (void)populateNativeViewWithResponse {
    ANNativeAdView *nativeAdView = self.nativeAdView;
    nativeAdView.iconImageView.image = self.nativeResponse.iconImage;
    nativeAdView.titleLabel.text = self.nativeResponse.title;
    nativeAdView.bodyLabel.text = self.nativeResponse.body;
    nativeAdView.mainImageView.image = self.nativeResponse.mainImage;
    [nativeAdView.callToActionButton setTitle:self.nativeResponse.callToAction forState:UIControlStateNormal];
}

#pragma mark - ANAdDelegate

- (void)adRequest:(ANNativeAdRequest *)request didReceiveResponse:(ANNativeAdResponse *)response
{
    self.nativeResponse = (ANNativeAdResponse *)response;
    self.nativeResponse.delegate = self;
    [self populateNativeViewWithResponse];
    UIImageView *imageview = [[UIImageView alloc]
                              initWithFrame:CGRectMake(50, 50, 20, 20)];
    UIViewController *rvc = [ANGlobal getKeyWindow].rootViewController;
    NSError *registerError;

    if(self.nativeResponse.customElements[kANNativeCSRObject]) {
        ANAdAdapterCSRNativeBannerFacebook *csrAdObject = self.nativeResponse.customElements[kANNativeCSRObject];
        [csrAdObject registerViewForTracking:self.nativeAdView
                               withRootViewController:rvc
                                     iconImageView:imageview
                                    clickableViews:@[self.nativeAdView]];
        
    }else{
        [self.nativeResponse registerViewForTracking:self.nativeAdView
                                withRootViewController:rvc
                                        clickableViews:@[self.nativeAdView]
                                                 error:&registerError];
    }
    
}

- (void)adRequest:(ANNativeAdRequest *)request didFailToLoadWithError:(NSError *)error
{

}

#pragma mark - ANNativeAdRequestDelegate

- (void)adDidLogImpression:(id)ad {
    if (self.adDidLogImpressionAPIForCSRAd) {
         [self.adDidLogImpressionAPIForCSRAd fulfill];
    }else if (self.adDidLogImpressionAPIForNativeStandardAd){
        [self.adDidLogImpressionAPIForNativeStandardAd fulfill];
    }
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
