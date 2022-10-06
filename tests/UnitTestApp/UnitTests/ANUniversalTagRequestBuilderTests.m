/*   Copyright 2017 APPNEXUS INC
 
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
#import "ANAdFetcher.h"
#import "ANGlobal.h"
#import "ANTestGlobal.h"
#import "ANReachability.h"
#import "TestANUniversalFetcher.h"
#import "ANGDPRSettings.h"
#if __has_include(<AppTrackingTransparency/AppTrackingTransparency.h>)
    #import <AppTrackingTransparency/AppTrackingTransparency.h>
#endif

static NSString *const   kTestUUID              = @"0000-000-000-00";
static NSTimeInterval    UTMODULETESTS_TIMEOUT  = 20.0;

static NSString  *videoPlacementID  = @"9924001";



@interface ANUniversalTagRequestBuilderTests : XCTestCase
    //EMPTY
@end



@implementation ANUniversalTagRequestBuilderTests

#pragma mark - Test lifecycle.

- (void)setUp {
    [super setUp];
    
}

- (void)tearDown {
    [super tearDown];
    [ANGDPRSettings reset];
    [ANSDKSettings sharedInstance].disableIDFAUsage  = NO;
    [ANSDKSettings sharedInstance].disableIDFVUsage  = NO;
}



#pragma mark - UT Tests.

- (void)testUTRequest
{
    TestANUniversalFetcher  *adFetcher        = [[TestANUniversalFetcher alloc] initWithPlacementId:videoPlacementID];
    dispatch_queue_t         backgroundQueue  = dispatch_queue_create("QUEUE FOR testUTRequest.",  DISPATCH_QUEUE_SERIAL);

    XCTestExpectation  *expectation  = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];

    //
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), backgroundQueue,
    ^{
        NSURLRequest  *request  = [ANUniversalTagRequestBuilder buildRequestWithAdFetcherDelegate:adFetcher.delegate];

        NSError  *error;
        id        jsonObject  = [NSJSONSerialization JSONObjectWithData: request.HTTPBody
                                                                options: kNilOptions
                                                                  error: &error];
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
        XCTAssertEqual(placementId, [videoPlacementID integerValue]);

        NSArray *sizes = tag[@"sizes"];
        XCTAssertNotNil(sizes);
        XCTAssertEqual(sizes.count, 1);
        NSDictionary *size = [sizes firstObject];
        XCTAssertEqual([size[@"width"] integerValue], 1);
        XCTAssertEqual([size[@"height"] integerValue], 1);

        NSArray *allowedMediaTypes = tag[@"allowed_media_types"];
        
        
        XCTAssertNotNil(allowedMediaTypes);
        XCTAssertEqual((ANAllowedMediaType)[allowedMediaTypes[0] integerValue], ANAllowedMediaTypeVideo);

        
        NSNumber *disablePSA = tag[@"disable_psa"];
        XCTAssertNotNil(disablePSA);
        XCTAssertEqual([disablePSA integerValue], 1);

        // User
        NSNumber *gender = user[@"gender"];
        XCTAssertNotNil(gender);

        NSString * deviceLanguage = [[NSLocale preferredLanguages] firstObject];
        NSString *language = user[@"language"];
        XCTAssertEqualObjects(language, deviceLanguage);

        // Device
        NSString *userAgent = device[@"useragent"];
        XCTAssertNotNil(userAgent);

        NSString *deviceMake = device[@"make"];
        XCTAssertEqualObjects(deviceMake, @"Apple");

        NSString *deviceModel = device[@"model"];
        XCTAssertTrue(deviceModel.length > 0);

        XCTAssertNil(jsonDict[@"auction_timeout_ms"]);

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

        
        if (@available(iOS 14, *)) {
    #if __has_include(<AppTrackingTransparency/AppTrackingTransparency.h>)
            if ([ATTrackingManager trackingAuthorizationStatus] == ATTrackingManagerAuthorizationStatusAuthorized){
                NSNumber *lmt = device[@"limit_ad_tracking"];
                XCTAssertNotNil(lmt);
                XCTAssertEqual([lmt boolValue], NO);
                
                // Device Id Start
                NSDictionary *deviceId = device[@"device_id"];
                XCTAssertNotNil(deviceId);
                NSString *idfa = deviceId[@"idfa"];
                XCTAssertNotNil(idfa);
                XCTAssertEqualObjects(idfa, @"00000000-0000-0000-0000-000000000000");
                
            }else {
                
                    NSNumber *lmt = device[@"limit_ad_tracking"];
                    XCTAssertNil(lmt);
                    NSDictionary *deviceId = device[@"device_id"];
                    XCTAssertNil(deviceId);
                }
    #endif
        }else{
            
            
            NSNumber *lmt = device[@"limit_ad_tracking"];
            XCTAssertNotNil(lmt);
            XCTAssertEqual([lmt boolValue], ANAdvertisingTrackingEnabled() ? NO : YES);

            // get the objective c type of the NSNumber for limit_ad_tracking

            // Device Id Start
            NSDictionary *deviceId = device[@"device_id"];
            XCTAssertNotNil(deviceId);
            NSString *idfa = deviceId[@"idfa"];
            XCTAssertNotNil(idfa);
        }
      
        
        //
        [expectation fulfill];
    });

    //
    [self waitForExpectationsWithTimeout:UTMODULETESTS_TIMEOUT handler:nil];
}

- (void)testUTRequestWithPurpose1AndConsentSetTrue
{
    TestANUniversalFetcher  *adFetcher        = [[TestANUniversalFetcher alloc] initWithPlacementId:videoPlacementID];
    dispatch_queue_t         backgroundQueue  = dispatch_queue_create("QUEUE FOR testUTRequest.",  DISPATCH_QUEUE_SERIAL);

    XCTestExpectation  *expectation  = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    [ANGDPRSettings setConsentRequired:[NSNumber numberWithInt:1]];
    [ANGDPRSettings setPurposeConsents:@"1010"];

    //
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), backgroundQueue,
    ^{
        NSURLRequest  *request  = [ANUniversalTagRequestBuilder buildRequestWithAdFetcherDelegate:adFetcher.delegate];

        NSError  *error;
        id        jsonObject  = [NSJSONSerialization JSONObjectWithData: request.HTTPBody
                                                                options: kNilOptions
                                                                  error: &error];
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

        
        if (@available(iOS 14, *)) {
#if __has_include(<AppTrackingTransparency/AppTrackingTransparency.h>)
            if ([ATTrackingManager trackingAuthorizationStatus] == ATTrackingManagerAuthorizationStatusAuthorized){
                
                NSDictionary *deviceId = device[@"device_id"];
                XCTAssertNotNil(deviceId);
                NSString *idfa = deviceId[@"idfa"];
                XCTAssertEqualObjects(idfa, @"00000000-0000-0000-0000-000000000000");
                
                
            }else{
                NSDictionary *deviceId = device[@"device_id"];
                XCTAssertNil(deviceId);
            }
    #endif
        }else{
            // Device Id Start
            NSDictionary *deviceId = device[@"device_id"];
            XCTAssertNotNil(deviceId);
            NSString *idfa = deviceId[@"idfa"];
            XCTAssertNotNil(idfa);

        }


        //
        [expectation fulfill];
    });

    //
    [self waitForExpectationsWithTimeout:UTMODULETESTS_TIMEOUT handler:nil];
}

- (void)testUTRequestWithPurpose1SetTrueAndConsentSetFalse
{
    TestANUniversalFetcher  *adFetcher        = [[TestANUniversalFetcher alloc] initWithPlacementId:videoPlacementID];
    dispatch_queue_t         backgroundQueue  = dispatch_queue_create("QUEUE FOR testUTRequest.",  DISPATCH_QUEUE_SERIAL);

    XCTestExpectation  *expectation  = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    [ANGDPRSettings setConsentRequired:[NSNumber numberWithInt:0]];
    [ANGDPRSettings setPurposeConsents:@"1010"];

    //
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), backgroundQueue,
    ^{
        NSURLRequest  *request  = [ANUniversalTagRequestBuilder buildRequestWithAdFetcherDelegate:adFetcher.delegate];

        NSError  *error;
        id        jsonObject  = [NSJSONSerialization JSONObjectWithData: request.HTTPBody
                                                                options: kNilOptions
                                                                  error: &error];
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


     
        
        if (@available(iOS 14, *)) {
#if __has_include(<AppTrackingTransparency/AppTrackingTransparency.h>)
            if ([ATTrackingManager trackingAuthorizationStatus] == ATTrackingManagerAuthorizationStatusAuthorized){
                // Device Id Start
                NSDictionary *deviceId = device[@"device_id"];
                XCTAssertNotNil(deviceId);
                NSString *idfa = deviceId[@"idfa"];
                XCTAssertEqualObjects(idfa, @"00000000-0000-0000-0000-000000000000");

                
            }else{
                NSDictionary *deviceId = device[@"device_id"];
                XCTAssertNil(deviceId);
            }
    #endif
        }else{
            // Device Id Start
            NSDictionary *deviceId = device[@"device_id"];
            XCTAssertNotNil(deviceId);
            NSString *idfa = deviceId[@"idfa"];
            XCTAssertNotNil(idfa);
        }
        
        
        //
        [expectation fulfill];
    });

    //
    [self waitForExpectationsWithTimeout:UTMODULETESTS_TIMEOUT handler:nil];
}

- (void)testUTRequestWithPurpose1SetFalse
{
    TestANUniversalFetcher  *adFetcher        = [[TestANUniversalFetcher alloc] initWithPlacementId:videoPlacementID];
    dispatch_queue_t         backgroundQueue  = dispatch_queue_create("QUEUE FOR testUTRequest.",  DISPATCH_QUEUE_SERIAL);

    XCTestExpectation  *expectation  = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    
    [ANGDPRSettings setPurposeConsents:@"00"];

    //
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), backgroundQueue,
    ^{
        NSURLRequest  *request  = [ANUniversalTagRequestBuilder buildRequestWithAdFetcherDelegate:adFetcher.delegate];

        NSError  *error;
        id        jsonObject  = [NSJSONSerialization JSONObjectWithData: request.HTTPBody
                                                                options: kNilOptions
                                                                  error: &error];
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


        // Device Id Start
        NSDictionary *deviceId = device[@"device_id"];
        XCTAssertNil(deviceId);
        

        //
        [expectation fulfill];
    });

    //
    [self waitForExpectationsWithTimeout:UTMODULETESTS_TIMEOUT handler:nil];
}

- (void)testUTRequestWithoutPurpose1ConsentTrue
{
    TestANUniversalFetcher  *adFetcher        = [[TestANUniversalFetcher alloc] initWithPlacementId:videoPlacementID];
    dispatch_queue_t         backgroundQueue  = dispatch_queue_create("QUEUE FOR testUTRequest.",  DISPATCH_QUEUE_SERIAL);

    XCTestExpectation  *expectation  = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    
    [ANGDPRSettings setConsentRequired:[NSNumber numberWithInt:1]];

    //
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), backgroundQueue,
    ^{
        NSURLRequest  *request  = [ANUniversalTagRequestBuilder buildRequestWithAdFetcherDelegate:adFetcher.delegate];

        NSError  *error;
        id        jsonObject  = [NSJSONSerialization JSONObjectWithData: request.HTTPBody
                                                                options: kNilOptions
                                                                  error: &error];
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


        // Device Id Start
        NSDictionary *deviceId = device[@"device_id"];
        XCTAssertNil(deviceId);
        //
        [expectation fulfill];
    });

    //
    [self waitForExpectationsWithTimeout:UTMODULETESTS_TIMEOUT handler:nil];
}

- (void)testUTRequestWithoutPurpose1ConsentFalse
{
    TestANUniversalFetcher  *adFetcher        = [[TestANUniversalFetcher alloc] initWithPlacementId:videoPlacementID];
    dispatch_queue_t         backgroundQueue  = dispatch_queue_create("QUEUE FOR testUTRequest.",  DISPATCH_QUEUE_SERIAL);

    XCTestExpectation  *expectation  = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    
    [ANGDPRSettings setConsentRequired:[NSNumber numberWithInt:0]];

    //
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), backgroundQueue,
    ^{
        NSURLRequest  *request  = [ANUniversalTagRequestBuilder buildRequestWithAdFetcherDelegate:adFetcher.delegate];

        NSError  *error;
        id        jsonObject  = [NSJSONSerialization JSONObjectWithData: request.HTTPBody
                                                                options: kNilOptions
                                                                  error: &error];
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

        
        if (@available(iOS 14, *)) {
#if __has_include(<AppTrackingTransparency/AppTrackingTransparency.h>)
            if ([ATTrackingManager trackingAuthorizationStatus] == ATTrackingManagerAuthorizationStatusAuthorized){
                // Device Id Start
                NSDictionary *deviceId = device[@"device_id"];
                XCTAssertNotNil(deviceId);
                NSString *idfa = deviceId[@"idfa"];
                XCTAssertNotNil(idfa);
                XCTAssertEqualObjects(idfa, @"00000000-0000-0000-0000-000000000000");
            }else{
                NSDictionary *deviceId = device[@"device_id"];
                XCTAssertNil(deviceId);
            }
#endif
        }else{
            // Device Id Start
            NSDictionary *deviceId = device[@"device_id"];
            XCTAssertNotNil(deviceId);
            NSString *idfa = deviceId[@"idfa"];
            XCTAssertNotNil(idfa);
        }
        
        //
        [expectation fulfill];
    });

    //
    [self waitForExpectationsWithTimeout:UTMODULETESTS_TIMEOUT handler:nil];
}


- (void)testUTRequestForDuration
{
 
    TestANUniversalFetcher  *adFetcher      = [[TestANUniversalFetcher alloc] initWithPlacementId:videoPlacementID];
    NSURLRequest            *request        = [ANUniversalTagRequestBuilder buildRequestWithAdFetcherDelegate:adFetcher.delegate];
    XCTestExpectation       *expectation    = [self expectationWithDescription:@"Dummy expectation"];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(),
                   ^{
                       NSError *error;
                       
                       id jsonObject = [NSJSONSerialization JSONObjectWithData:request.HTTPBody
                                                                       options:kNilOptions
                                                                         error:&error];
                       TESTTRACEM(@"jsonObject=%@", jsonObject);
                       
                       XCTAssertNil(error);
                       XCTAssertNotNil(jsonObject);
                       XCTAssertTrue([jsonObject isKindOfClass:[NSDictionary class]]);
                       NSDictionary *jsonDict = (NSDictionary *)jsonObject;
                       
                       NSArray *tags = jsonDict[@"tags"];
                       NSDictionary *user = jsonDict[@"user"];
                       
                       XCTAssertNotNil(tags);
                       // Tags
                       XCTAssertEqual(tags.count, 1);
                       NSDictionary *tag = [tags firstObject];
                       
                       NSDictionary *video = tag[@"video"];
                       XCTAssertNotNil(video);
                       XCTAssertEqual(video.count, 2);
                       XCTAssertNotNil(video[@"minduration"]);
                       XCTAssertNotNil(video[@"maxduration"]);
                       
                       XCTAssertEqual([video[@"minduration"] integerValue], 5);
                       XCTAssertEqual([video[@"maxduration"] integerValue], 180);
                       
                        NSArray *allowedMediaTypes = tag[@"allowed_media_types"];
                        XCTAssertNotNil(allowedMediaTypes);
                       
                       int allowedMediaTypesValue = [[NSString stringWithFormat:@"%@",(NSValue *)allowedMediaTypes[0]] intValue];
                       XCTAssertEqual(allowedMediaTypesValue ,(ANAllowedMediaType)ANAllowedMediaTypeVideo);
                       
                       [expectation fulfill];
                   });
    
    [self waitForExpectationsWithTimeout:UTMODULETESTS_TIMEOUT handler:nil];
}

- (void)testUTRequestWithOneCustomKeywordsValue
{
    
    TestANUniversalFetcher  *adFetcher  = [[TestANUniversalFetcher alloc] initWithPlacementId:videoPlacementID];

    [adFetcher addCustomKeywordWithKey:@"state" value:@"NY"];
    
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
        
        NSArray *tags = jsonDict[@"tags"];
        NSDictionary *user = jsonDict[@"user"];
        NSDictionary *device = jsonDict[@"device"];
        NSArray *keywords = jsonDict[@"tags"][0][@"keywords"];
        
        XCTAssertNotNil(tags);
        XCTAssertNotNil(user);
        XCTAssertNotNil(device);
        XCTAssertNotNil(keywords); // no keywords passed unless set in the targeting
        
        for (NSDictionary *keyword in keywords) {
            XCTAssertNotNil(keyword[@"key"]);
            NSString *key = keyword[@"key"];
            NSArray *value = keyword[@"value"];
            if ([key isEqualToString:@"state"]) {
                XCTAssertEqualObjects(value, @[@"NY"]);
            }
        }
        
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:UTMODULETESTS_TIMEOUT handler:nil];
}

- (void)testUTRequestWithMultipleCustomKeywordsValues
{
    TestANUniversalFetcher  *adFetcher = [[TestANUniversalFetcher alloc] initWithPlacementId:videoPlacementID];
    
    [adFetcher addCustomKeywordWithKey:@"state" value:@"NY"];
    [adFetcher addCustomKeywordWithKey:@"state" value:@"NJ"];
    [adFetcher addCustomKeywordWithKey:@"county" value:@"essex"];
    [adFetcher addCustomKeywordWithKey:@"county" value:@"morris"];

    NSURLRequest        *request        = [ANUniversalTagRequestBuilder buildRequestWithAdFetcherDelegate:adFetcher.delegate];
    XCTestExpectation   *expectation    = [self expectationWithDescription:@"Dummy expectation"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(),
    ^{
        NSError *error;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:request.HTTPBody
                                                        options:kNilOptions
                                                          error:&error];
        TESTTRACEM(@"jsonObject=%@", jsonObject);

        XCTAssertNil(error);
        XCTAssertNotNil(jsonObject);
        XCTAssertTrue([jsonObject isKindOfClass:[NSDictionary class]]);
        NSDictionary *jsonDict = (NSDictionary *)jsonObject;
        
        NSArray *tags = jsonDict[@"tags"];
        NSDictionary *user = jsonDict[@"user"];
        NSDictionary *device = jsonDict[@"device"];
        NSArray *keywords = jsonDict[@"tags"][0][@"keywords"];
        
        XCTAssertNotNil(tags);
        XCTAssertNotNil(user);
        XCTAssertNotNil(device);
        XCTAssertNotNil(keywords); // no keywords passed unless set in the targeting
        
        for (NSDictionary *keyword in keywords) {
            XCTAssertNotNil(keyword[@"key"]);
            NSString *key = keyword[@"key"];
            NSArray *value = keyword[@"value"];
            if ([key isEqualToString:@"state"]){
                XCTAssertTrue( [value containsObject: @"NJ"] );
                XCTAssertTrue( [value containsObject: @"NY"] );
            }
            if ([key isEqualToString:@"county"]) {
                XCTAssertTrue( [value containsObject: @"essex"] );
                XCTAssertTrue( [value containsObject: @"morris"] );
            }
        }
        
        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout:UTMODULETESTS_TIMEOUT handler:nil];
}

- (void)testRequestContentType {
    
    TestANUniversalFetcher *adFetcher = [[TestANUniversalFetcher alloc] initWithPlacementId:@"1281482"];
    
    NSURLRequest *request = [ANUniversalTagRequestBuilder buildRequestWithAdFetcherDelegate:adFetcher.delegate];
    
    NSString *contentType =  [request valueForHTTPHeaderField:@"content-type"];
    XCTAssertNotNil(contentType);
    XCTAssertEqualObjects(@"application/json", contentType);
    
    
}

- (void)testUTRequestWithContentURLCustomKeywordsValue
{
    
    TestANUniversalFetcher  *adFetcher  = [[TestANUniversalFetcher alloc] initWithPlacementId:videoPlacementID];
    
    [adFetcher addCustomKeywordWithKey:@"content_url" value:@"http://www.appnexus.com"];
    
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
        NSArray *keywords = jsonDict[@"tags"][0][@"keywords"];

        XCTAssertNotNil(keywords);
        
        for (NSDictionary *keyword in keywords) {
            XCTAssertNotNil(keyword[@"key"]);
            NSString *key = keyword[@"key"];
            NSArray *value = keyword[@"value"];
            if ([key isEqualToString:@"content_url"]) {
                XCTAssertEqualObjects(value, @[@"http://www.appnexus.com"]);
            }
        }
        
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:UTMODULETESTS_TIMEOUT handler:nil];
}

/**
 API To verify : disableIDFAUsage
 If disableIDFAUsage is set to default value(No) then the device_id should not be nil
 */
- (void)testUTRequestDisableIDFAUsageDefault
{
    
    TestANUniversalFetcher  *adFetcher        = [[TestANUniversalFetcher alloc] initWithPlacementId:videoPlacementID];
    dispatch_queue_t         backgroundQueue  = dispatch_queue_create("QUEUE FOR testUTRequest.",  DISPATCH_QUEUE_SERIAL);

    XCTestExpectation  *expectation  = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    
    [ANGDPRSettings setPurposeConsents:@"1010"];

    //
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), backgroundQueue,
    ^{
        NSURLRequest  *request  = [ANUniversalTagRequestBuilder buildRequestWithAdFetcherDelegate:adFetcher.delegate];

        NSError  *error;
        id        jsonObject  = [NSJSONSerialization JSONObjectWithData: request.HTTPBody
                                                                options: kNilOptions
                                                                  error: &error];
        TESTTRACEM(@"jsonObject=%@", jsonObject);

        // JSON foundation.
        XCTAssertNil(error);
        XCTAssertNotNil(jsonObject);
        XCTAssertTrue([jsonObject isKindOfClass:[NSDictionary class]]);
        NSDictionary *jsonDict = (NSDictionary *)jsonObject;
        NSDictionary *device = jsonDict[@"device"];
        XCTAssertNotNil(device);
        // Device Id Start
        
        
        if (@available(iOS 14, *)) {
#if __has_include(<AppTrackingTransparency/AppTrackingTransparency.h>)
            if ([ATTrackingManager trackingAuthorizationStatus] == ATTrackingManagerAuthorizationStatusAuthorized){
                // Device Id Start
                NSDictionary *deviceId = device[@"device_id"];
                XCTAssertNotNil(deviceId);
                
            }else{
                NSDictionary *deviceId = device[@"device_id"];
                XCTAssertNil(deviceId);
            }
#endif
        }else{
            // Device Id Start
            NSDictionary *deviceId = device[@"device_id"];
            XCTAssertNotNil(deviceId);
        }
        
        
        
        [expectation fulfill];
    });

    //
    [self waitForExpectationsWithTimeout:UTMODULETESTS_TIMEOUT handler:nil];
}
/**
 API To verify : disableIDFAUsage
 If disableIDFAUsage is set to true then device_id should be nil
 */
- (void)testUTRequestDisableIDFAUsageSetToTrue
{
    [ANSDKSettings sharedInstance].disableIDFAUsage  = YES;

    TestANUniversalFetcher  *adFetcher        = [[TestANUniversalFetcher alloc] initWithPlacementId:videoPlacementID];
    dispatch_queue_t         backgroundQueue  = dispatch_queue_create("QUEUE FOR testUTRequest.",  DISPATCH_QUEUE_SERIAL);

    XCTestExpectation  *expectation  = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    
    [ANGDPRSettings setPurposeConsents:@"1010"];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), backgroundQueue,
    ^{
        NSURLRequest  *request  = [ANUniversalTagRequestBuilder buildRequestWithAdFetcherDelegate:adFetcher.delegate];

        NSError  *error;
        id        jsonObject  = [NSJSONSerialization JSONObjectWithData: request.HTTPBody
                                                                options: kNilOptions
                                                                  error: &error];
        TESTTRACEM(@"jsonObject=%@", jsonObject);

        // JSON foundation.
        XCTAssertNil(error);
        XCTAssertNotNil(jsonObject);
        XCTAssertTrue([jsonObject isKindOfClass:[NSDictionary class]]);
        NSDictionary *jsonDict = (NSDictionary *)jsonObject;
        NSDictionary *device = jsonDict[@"device"];
        XCTAssertNotNil(device);
        // Device Id Start
        NSDictionary *deviceId = device[@"device_id"];
        XCTAssertNil(deviceId);
        
        [expectation fulfill];
    });

    //
    [self waitForExpectationsWithTimeout:UTMODULETESTS_TIMEOUT handler:nil];
}

/**
 API To verify : disableIDFAUsage
 If disableIDFAUsage is set to false then device_id should not be nil
 */
- (void)testUTRequestDisableIDFAUsageSetToFalse
{
    [ANSDKSettings sharedInstance].disableIDFAUsage  = YES;
    [ANSDKSettings sharedInstance].disableIDFAUsage  = NO;
    TestANUniversalFetcher  *adFetcher        = [[TestANUniversalFetcher alloc] initWithPlacementId:videoPlacementID];
    dispatch_queue_t         backgroundQueue  = dispatch_queue_create("QUEUE FOR testUTRequest.",  DISPATCH_QUEUE_SERIAL);

    XCTestExpectation  *expectation  = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    
    [ANGDPRSettings setPurposeConsents:@"1010"];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), backgroundQueue,
    ^{
        NSURLRequest  *request  = [ANUniversalTagRequestBuilder buildRequestWithAdFetcherDelegate:adFetcher.delegate];

        NSError  *error;
        id        jsonObject  = [NSJSONSerialization JSONObjectWithData: request.HTTPBody
                                                                options: kNilOptions
                                                                  error: &error];
        TESTTRACEM(@"jsonObject=%@", jsonObject);

        // JSON foundation.
        XCTAssertNil(error);
        XCTAssertNotNil(jsonObject);
        XCTAssertTrue([jsonObject isKindOfClass:[NSDictionary class]]);
        NSDictionary *jsonDict = (NSDictionary *)jsonObject;
        NSDictionary *device = jsonDict[@"device"];
        XCTAssertNotNil(device);
        
        if (@available(iOS 14, *)) {
#if __has_include(<AppTrackingTransparency/AppTrackingTransparency.h>)
            if ([ATTrackingManager trackingAuthorizationStatus] == ATTrackingManagerAuthorizationStatusAuthorized){
                // Device Id Start
                NSDictionary *deviceId = device[@"device_id"];
                XCTAssertNotNil(deviceId);
                
            }else{
                NSDictionary *deviceId = device[@"device_id"];
                XCTAssertNil(deviceId);
            }
#endif
        }else{
            // Device Id Start
            NSDictionary *deviceId = device[@"device_id"];
            XCTAssertNotNil(deviceId);
        }
        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout:UTMODULETESTS_TIMEOUT handler:nil];
}


/**
 Tests To verify : disableIDFVUsage
 1) If disableIDFVUsage is set to default value(No) then the IDFV should be automatically be set as external_uid in /ut/v3 if there is no IDFA present and no Publisher first party ID set by the user.
 2) If disableIDFVUsage is set to default value(No) and if IDFA is present in the request then we should not set IDFV automatically as external_uid.
 */
- (void)testUTRequestDisableIDFVUsageDefault
{
    
    TestANUniversalFetcher  *adFetcher        = [[TestANUniversalFetcher alloc] initWithPlacementId:videoPlacementID];
    dispatch_queue_t         backgroundQueue  = dispatch_queue_create("QUEUE FOR testUTRequest.",  DISPATCH_QUEUE_SERIAL);

    XCTestExpectation  *expectation  = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    
    [ANGDPRSettings setPurposeConsents:@"1010"];

    //
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), backgroundQueue,
    ^{
        NSURLRequest  *request  = [ANUniversalTagRequestBuilder buildRequestWithAdFetcherDelegate:adFetcher.delegate];

        NSError  *error;
        id        jsonObject  = [NSJSONSerialization JSONObjectWithData: request.HTTPBody
                                                                options: kNilOptions
                                                                  error: &error];
        TESTTRACEM(@"jsonObject=%@", jsonObject);

        // JSON foundation.
        XCTAssertNil(error);
        XCTAssertNotNil(jsonObject);
        XCTAssertTrue([jsonObject isKindOfClass:[NSDictionary class]]);
        NSDictionary *jsonDict = (NSDictionary *)jsonObject;
        NSDictionary *user = jsonDict[@"user"];
        XCTAssertNotNil(user);

            //ANAdvertisingTrackingEnabled is TRUE if ATTrackingManagerAuthorizationStatusAuthorized.
            if(ANAdvertisingTrackingEnabled()){
                
                // in cases where IDFA is present IDFV should not be automatically set as external_uid
                NSString *external_uid = user[@"external_uid"];
                XCTAssertNil(external_uid);
            }else{
                // in cases where IDFA is absent IDFV should be automatically set as external_uid is there is not publisher set external_uid(first party id)
                NSString *external_uid = user[@"external_uid"];
                XCTAssertNotNil(external_uid);
                NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
                XCTAssertTrue([idfv isEqualToString:external_uid]);
            }
        [expectation fulfill];
    });

    //
    [self waitForExpectationsWithTimeout:UTMODULETESTS_TIMEOUT handler:nil];
}



/**
 Tests To verify : disableIDFVUsage set to YES
 If disableIDFVUsage is set to YES then the IDFV should not be automatically be set as external_uid in /ut/v3 for all cases.
 */
- (void)testUTRequestDisableIDFVUsageYES
{
    
    TestANUniversalFetcher  *adFetcher        = [[TestANUniversalFetcher alloc] initWithPlacementId:videoPlacementID];
    ANSDKSettings.sharedInstance.disableIDFVUsage = YES;
    dispatch_queue_t         backgroundQueue  = dispatch_queue_create("QUEUE FOR testUTRequest.",  DISPATCH_QUEUE_SERIAL);

    XCTestExpectation  *expectation  = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    
    [ANGDPRSettings setPurposeConsents:@"1010"];

    //
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), backgroundQueue,
    ^{
        NSURLRequest  *request  = [ANUniversalTagRequestBuilder buildRequestWithAdFetcherDelegate:adFetcher.delegate];

        NSError  *error;
        id        jsonObject  = [NSJSONSerialization JSONObjectWithData: request.HTTPBody
                                                                options: kNilOptions
                                                                  error: &error];
        TESTTRACEM(@"jsonObject=%@", jsonObject);

        // JSON foundation.
        XCTAssertNil(error);
        XCTAssertNotNil(jsonObject);
        XCTAssertTrue([jsonObject isKindOfClass:[NSDictionary class]]);
        NSDictionary *jsonDict = (NSDictionary *)jsonObject;
        NSDictionary *user = jsonDict[@"user"];
        XCTAssertNotNil(user);
        
        
        //If disableIDFVUsage is set to YES then the IDFV should not be automatically be set as external_uid in /ut/v3 for all cases.
        NSString *external_uid = user[@"external_uid"];
        XCTAssertNil(external_uid);
 
        
        
        [expectation fulfill];
    });

    //
    [self waitForExpectationsWithTimeout:UTMODULETESTS_TIMEOUT handler:nil];
}


@end
