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

#import <XCTest/XCTest.h>
#import "ANUniversalTagRequestBuilder.h"
#import "ANSDKSettings+PrivateMethods.h"
#import "TestANUniversalFetcher.h"
#import "TestANCSRUniversalFetcher.h"
#import "ANReachability.h"
#import "ANAdAdapterCSRNativeBannerFacebook+ANTest.h"
#import "ANUniversalAdFetcher+ANTest.h"
#import "ANHTTPStubbingManager.h"
#import "ANSDKSettings+PrivateMethods.h"
#import "SDKValidationURLProtocol.h"
#import "NSURLRequest+HTTPBodyTesting.h"


static NSTimeInterval    UTMODULETESTS_TIMEOUT  = 20.0;
static NSString  *PlacementID  = @"9924001";


@interface ANCSRUniversalTagRequestBuilderTests : XCTestCase< SDKValidationURLProtocolDelegate , ANNativeAdResponseProtocol , ANNativeAdRequestDelegate >

@property (nonatomic, readwrite, strong)   ANNativeAdResponse     *nativeResponse;
@property (nonatomic, readwrite, strong)  ANNativeAdRequest     *nativeRequest;


//Expectations for OMID
@property (nonatomic, strong) XCTestExpectation *CSRAdDidReceivedExpectation;
@property (nonatomic, strong) XCTestExpectation *CSRAdFiredImpressionTrackerExpectation;
@property (nonatomic, strong) XCTestExpectation *CSRAdFiredOMIDTrackerExpectation;
@property (nonatomic, strong) XCTestExpectation *CSRAdFiredClickTrackerExpectation;

@property (nonatomic) NSString *testcase;
@property (nonatomic) UIView *nativeView;

@end

@implementation ANCSRUniversalTagRequestBuilderTests


- (void)setUp {
    [super setUp];
    
    [self clearObject];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
    
    
    self.nativeRequest = [[ANNativeAdRequest alloc] init];
    self.nativeRequest.delegate = self;
    
    
    [SDKValidationURLProtocol setDelegate:self];
    [NSURLProtocol registerClass:[SDKValidationURLProtocol class]];
    
    self.nativeView=[[UIView alloc]initWithFrame:CGRectMake(0, 100, 300, 250)];
    
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [self clearObject];
}


-(void)clearObject{
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    [[ANHTTPStubbingManager sharedStubbingManager] disable];
    [[UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController dismissViewControllerAnimated:NO
                                                                                                               completion:nil];
    
    // Clear all expectations for next test
    self.CSRAdDidReceivedExpectation = nil;
    self.CSRAdFiredImpressionTrackerExpectation = nil;
    self.CSRAdFiredClickTrackerExpectation = nil;
    self.CSRAdFiredOMIDTrackerExpectation = nil;
    self.nativeRequest = nil;
    self.nativeResponse = nil;
}

- (void)testUTRequestWithtpuids
{
    TestANCSRUniversalFetcher  *adFetcher  = [[TestANCSRUniversalFetcher alloc] initWithPlacementId:PlacementID];
    
    NSURLRequest        *request        = [ANUniversalTagRequestBuilder buildRequestWithAdFetcherDelegate:adFetcher.delegate];
    XCTestExpectation   *expectation    = [self expectationWithDescription:@"Dummy expectation"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSError *error;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:request.HTTPBody
                                                        options:kNilOptions
                                                          error:&error];
        TESTTRACEM(@"jsonObject=%@", jsonObject);
        
        XCTAssertNil(error);
        XCTAssertNotNil(jsonObject);
        XCTAssertTrue([jsonObject isKindOfClass:[NSDictionary class]]);
        NSDictionary *jsonDict = (NSDictionary *)jsonObject;
        NSArray *tpuids = jsonDict[@"tpuids"];
        XCTAssertNotNil(tpuids);
        XCTAssertNotNil(tpuids[0][@"provider"]);
        XCTAssertEqualObjects(tpuids[0][@"provider"], @"audienceNetwork");
        XCTAssertNotNil(tpuids[0][@"user_id"]);
        
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:UTMODULETESTS_TIMEOUT handler:nil];
}

- (void)testUTRequestForCSR
{
    TestANCSRUniversalFetcher  *adFetcher  = [[TestANCSRUniversalFetcher alloc] initWithPlacementId:PlacementID];
    
    NSURLRequest        *request        = [ANUniversalTagRequestBuilder buildRequestWithAdFetcherDelegate:adFetcher.delegate];
    XCTestExpectation   *expectation    = [self expectationWithDescription:@"Dummy expectation"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSError *error;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:request.HTTPBody
                                                        options:kNilOptions
                                                          error:&error];
        TESTTRACEM(@"jsonObject=%@", jsonObject);
        
        
        // JSON foundation.
        XCTAssertNil(error);
        XCTAssertNotNil(jsonObject);
        XCTAssertTrue([jsonObject isKindOfClass:[NSDictionary class]]);
        NSDictionary *jsonDict = (NSDictionary *)jsonObject;
        
        NSArray *tags = jsonDict[@"tags"];
        NSDictionary *user = jsonDict[@"user"];
        NSDictionary *device = jsonDict[@"device"];
        NSArray *keywords = jsonDict[@"keywords"];
        
        XCTAssertNotNil(tags);
        XCTAssertNotNil(user);
        XCTAssertNotNil(device);
        XCTAssertNil(keywords); // no keywords passed unless set in the targeting
        
        // Tags
        XCTAssertEqual(tags.count, 1);
        NSDictionary *tag = [tags firstObject];
        
        NSInteger placementId = [tag[@"id"] integerValue];
        XCTAssertEqual(placementId, [PlacementID integerValue]);
        
        NSArray *sizes = tag[@"sizes"];
        XCTAssertNotNil(sizes);
        XCTAssertEqual(sizes.count, 1);
        NSDictionary *size = [sizes firstObject];
        XCTAssertEqual([size[@"width"] integerValue], 1);
        XCTAssertEqual([size[@"height"] integerValue], 1);
        
        NSArray *allowedMediaTypes = tag[@"allowed_media_types"];
        
        
        XCTAssertNotNil(allowedMediaTypes);
        XCTAssertEqual((ANAllowedMediaType)[allowedMediaTypes[0] integerValue], ANAllowedMediaTypeNative);
        
        
        NSNumber *disablePSA = tag[@"disable_psa"];
        XCTAssertNotNil(disablePSA);
        XCTAssertEqual([disablePSA integerValue], 1);
        
        // User
        NSNumber *gender = user[@"gender"];
        XCTAssertNotNil(gender);
        
        // externalUid
        NSString *externalUid = user[@"external_uid"];
        XCTAssertNotNil(externalUid);
        XCTAssertEqualObjects(externalUid, @"AppNexus");
        NSString * deviceLanguage = [[NSLocale preferredLanguages] firstObject];
        NSString *language = user[@"language"];
        XCTAssertEqualObjects(language, deviceLanguage);
        
        
        NSString *deviceMake = device[@"make"];
        XCTAssertEqualObjects(deviceMake, @"Apple");
        
        NSString *deviceModel = device[@"model"];
        XCTAssertTrue(deviceModel.length > 0);
        
        NSNumber *connectionType = device[@"connectiontype"];
        XCTAssertNotNil(connectionType);
        
        ANReachability *reachability = [ANReachability sharedReachabilityForInternetConnection];
        ANNetworkStatus status = [reachability currentReachabilityStatus];
        switch (status) {
            case ANNetworkStatusReachableViaWiFi:
                XCTAssertEqual([connectionType integerValue], 1);
                break;
            case ANNetworkStatusReachableViaWWAN:
                XCTAssertEqual([connectionType integerValue], 2);
                break;
            default:
                XCTAssertEqual([connectionType integerValue], 0);
                break;
        }
        
        NSNumber *lmt = device[@"limit_ad_tracking"];
        XCTAssertNotNil(lmt);
        XCTAssertEqual([lmt boolValue], ANAdvertisingTrackingEnabled() ? NO : YES);
        // get the objective c type of the NSNumber for limit_ad_tracking
        // "c" is the BOOL type that is returned from NSNumber objCType for BOOL value
        const char *boolType = "c";
        XCTAssertEqual(strcmp([lmt objCType], boolType), 0);
        
        // Device Id Start
        NSDictionary *deviceId = device[@"device_id"];
        XCTAssertNotNil(deviceId);
        NSString *idfa = deviceId[@"idfa"];
        XCTAssertNotNil(idfa);
        
        XCTAssertNil(error);
        XCTAssertNotNil(jsonObject);
        XCTAssertTrue([jsonObject isKindOfClass:[NSDictionary class]]);
        
        NSArray *tpuids = jsonDict[@"tpuids"];
        XCTAssertNotNil(tpuids);
        XCTAssertNotNil(tpuids[0][@"provider"]);
        XCTAssertEqualObjects(tpuids[0][@"provider"], @"audienceNetwork");
        XCTAssertNotNil(tpuids[0][@"user_id"]);
        
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:UTMODULETESTS_TIMEOUT handler:nil];
}



- (void)testCSRBannerNativeDidReceived
{
    self.testcase = @"testCSRBannerNativeDidReceived";
    [self stubRequestWithResponse:@"CSR_Facebook_Banner_Native"];
    self.CSRAdDidReceivedExpectation = [self expectationWithDescription:@"Didn't receive OMID view 100% event"];
    [self.nativeRequest loadAd];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
        
    }];
    
}




- (void)testCSRAdFiredImpressionTracker
{
    self.testcase = @"CSRAdFiredImpressionTrackerExpectation";
    [self stubRequestWithResponse:@"CSR_Facebook_Banner_Native"];
    self.CSRAdFiredImpressionTrackerExpectation = [self expectationWithDescription:@"Didn't receive Impression Tracker event"];
    [self.nativeRequest loadAd];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
        
    }];
    
}

- (void)testCSRAdFiredOMIDTracker
{
    self.testcase = @"CSRAdFiredOMIDTrackerExpectation";
    [self stubRequestWithResponse:@"CSR_Facebook_Banner_Native"];
    self.CSRAdFiredOMIDTrackerExpectation = [self expectationWithDescription:@"Didn't receive OMID Tracker event"];
    [self.nativeRequest loadAd];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
        
    }];
    
}

- (void)testCSRAdFiredClickTracker
{
    self.testcase = @"CSRAdFiredClickTrackerExpectation";
    [self stubRequestWithResponse:@"CSR_Facebook_Banner_Native"];
    self.CSRAdFiredClickTrackerExpectation = [self expectationWithDescription:@"Didn't receive Click Tracker event"];
    [self.nativeRequest loadAd];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
        
    }];
    
}


#pragma mark - ANAdDelegate

- (void)adRequest:(ANNativeAdRequest *)request didReceiveResponse:(ANNativeAdResponse *)response
{
    self.nativeResponse = (ANNativeAdResponse *)response;
    [self.CSRAdDidReceivedExpectation fulfill];
    
    ANAdAdapterCSRNativeBannerFacebook *fbNativeBanner = (ANAdAdapterCSRNativeBannerFacebook *)response.customElements[kANNativeCSRObject];
    
    UIImageView *imageview = [[UIImageView alloc]
                              initWithFrame:CGRectMake(50, 50, 20, 20)];
    /*registerViewForTracking using Image View without Click Tracker */
    [fbNativeBanner registerViewForTracking:self.nativeView
                     withRootViewController:self
                              iconImageView:imageview];
    
    
}

- (void)adRequest:(ANNativeAdRequest *)request didFailToLoadWithError:(NSError *)error
{
    
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


# pragma mark - Intercept HTTP Request Callback

- (void)didReceiveIABResponse:(NSString *)response {
    NSLog(@"Response %@",response);
    
    if ( self.CSRAdFiredImpressionTrackerExpectation && [response containsString:@"https://appnexustracker.com/impressionTrackerfired"]) {
        // Only assert if it has been setup to assert.
        [self.CSRAdFiredImpressionTrackerExpectation fulfill];
        
    }else if ( self.CSRAdFiredOMIDTrackerExpectation && [response containsString:@"http://iabtechlab.com:66/sendMessage?msg="]) {
        // Only assert if it has been setup to assert.
        [self.CSRAdFiredOMIDTrackerExpectation fulfill];
        
    }else  if (self.CSRAdFiredClickTrackerExpectation  && [response containsString:@"https://appnexustracker.com/clicktrackerfired"]) {
        // Only assert if it has been setup to assert.
        [self.CSRAdFiredClickTrackerExpectation fulfill];
        
    }
}


@end
