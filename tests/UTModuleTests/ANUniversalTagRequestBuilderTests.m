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
#import "ANUniversalAdFetcher.h"
#import "ANGlobal.h"
#import "ANTestGlobal.h"
#import "ANReachability.h"
#import "TestANUniversalFetcher.h"
#import "ANGDPRSettings.h"


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
}



#pragma mark - UT Tests.

- (void)testUTRequest
{
    NSString                *urlString        = [[[ANSDKSettings sharedInstance] baseUrlConfig] utAdRequestBaseUrl];
    TestANUniversalFetcher  *adFetcher        = [[TestANUniversalFetcher alloc] initWithPlacementId:videoPlacementID];
    dispatch_queue_t         backgroundQueue  = dispatch_queue_create("QUEUE FOR testUTRequest.",  DISPATCH_QUEUE_SERIAL);

    XCTestExpectation  *expectation  = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];

    //
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), backgroundQueue,
    ^{
        NSURLRequest  *request  = [ANUniversalTagRequestBuilder buildRequestWithAdFetcherDelegate:adFetcher.delegate baseUrlString:urlString];

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

        // externalUid
        NSString *externalUid = user[@"external_uid"];
        XCTAssertNotNil(externalUid);
        XCTAssertEqualObjects(externalUid, @"AppNexus");
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
        XCTAssertEqualObjects(idfa, ANUDID());

        //
        [expectation fulfill];
    });

    //
    [self waitForExpectationsWithTimeout:UTMODULETESTS_TIMEOUT handler:nil];
}


- (void)testUTRequestForDuration
{
 
    NSString                *urlString      = [[[ANSDKSettings sharedInstance] baseUrlConfig] utAdRequestBaseUrl];
    TestANUniversalFetcher  *adFetcher      = [[TestANUniversalFetcher alloc] initWithPlacementId:videoPlacementID];
    NSURLRequest            *request        = [ANUniversalTagRequestBuilder buildRequestWithAdFetcherDelegate:adFetcher.delegate baseUrlString:urlString];
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
                       
                       // externalUid
                       NSString *externalUid = user[@"external_uid"];
                       XCTAssertNotNil(externalUid);
                       XCTAssertEqualObjects(externalUid, @"AppNexus");
                       
                       
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

- (void)testUTRequestForSetGDPRConsentTrue
{
    [ANGDPRSettings setConsentRequired:true];
    [ANGDPRSettings setConsentString:@"a390129402948384453"];
    
    NSString                *urlString      = [[[ANSDKSettings sharedInstance] baseUrlConfig] utAdRequestBaseUrl];
    TestANUniversalFetcher  *adFetcher      = [[TestANUniversalFetcher alloc] initWithPlacementId:videoPlacementID];
    NSURLRequest            *request        = [ANUniversalTagRequestBuilder buildRequestWithAdFetcherDelegate:adFetcher.delegate baseUrlString:urlString];
    XCTestExpectation       *expectation    = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    
    
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
                       
                       NSDictionary *gdpr_consent = jsonDict[@"gdpr_consent"];
                       XCTAssertNotNil(gdpr_consent);
                       XCTAssertEqual(gdpr_consent.count, 2);
                       XCTAssertNotNil(gdpr_consent[@"consent_required"]);
                       XCTAssertTrue([gdpr_consent[@"consent_required"] boolValue]);
                       XCTAssertNotNil(gdpr_consent[@"consent_string"]);
                       [expectation fulfill];
                   });
    
    [self waitForExpectationsWithTimeout:UTMODULETESTS_TIMEOUT handler:nil];
}

- (void)testUTRequestForSetGDPRConsentFalse
{
    [ANGDPRSettings setConsentRequired:false];
    [ANGDPRSettings setConsentString:@"a390129402948384453"];
    
    NSString                *urlString      = [[[ANSDKSettings sharedInstance] baseUrlConfig] utAdRequestBaseUrl];
    TestANUniversalFetcher  *adFetcher      = [[TestANUniversalFetcher alloc] initWithPlacementId:videoPlacementID];
    NSURLRequest            *request        = [ANUniversalTagRequestBuilder buildRequestWithAdFetcherDelegate:adFetcher.delegate baseUrlString:urlString];
    XCTestExpectation       *expectation    = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    
    
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
                       
                       NSDictionary *gdpr_consent = jsonDict[@"gdpr_consent"];
                       XCTAssertNotNil(gdpr_consent);
                       XCTAssertEqual(gdpr_consent.count, 2);
                       XCTAssertNotNil(gdpr_consent[@"consent_required"]);
                       XCTAssertFalse([gdpr_consent[@"consent_required"] boolValue]);
                       XCTAssertNotNil(gdpr_consent[@"consent_string"]);
                       [expectation fulfill];
                   });
    
    [self waitForExpectationsWithTimeout:UTMODULETESTS_TIMEOUT handler:nil];
}


- (void)testUTRequestForSetGDPRDefaultConsent
{


    [ANGDPRSettings reset];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"IABConsent_ConsentString"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"IABConsent_SubjectToGDPR"];
    
    NSString                *urlString      = [[[ANSDKSettings sharedInstance] baseUrlConfig] utAdRequestBaseUrl];
    TestANUniversalFetcher  *adFetcher      = [[TestANUniversalFetcher alloc] initWithPlacementId:videoPlacementID];
    NSURLRequest            *request        = [ANUniversalTagRequestBuilder buildRequestWithAdFetcherDelegate:adFetcher.delegate baseUrlString:urlString];
    XCTestExpectation       *expectation    = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    
    
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
                       XCTAssertNil(jsonDict[@"gdpr_consent"]);
                       [expectation fulfill];
                   });
    
    [self waitForExpectationsWithTimeout:UTMODULETESTS_TIMEOUT handler:nil];
}

- (void)testUTRequestCheckConsentForGDPRIABConsentStringWithTrue
{
    [ANGDPRSettings reset];
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"IABConsent_SubjectToGDPR"];
    [[NSUserDefaults standardUserDefaults] setObject:@"a390129402948384453" forKey:@"IABConsent_ConsentString"];
  
    NSString                *urlString      = [[[ANSDKSettings sharedInstance] baseUrlConfig] utAdRequestBaseUrl];
    TestANUniversalFetcher  *adFetcher      = [[TestANUniversalFetcher alloc] initWithPlacementId:videoPlacementID];
    NSURLRequest            *request        = [ANUniversalTagRequestBuilder buildRequestWithAdFetcherDelegate:adFetcher.delegate baseUrlString:urlString];
    XCTestExpectation       *expectation    = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    
    
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
                      
                       NSDictionary *gdpr_consent = jsonDict[@"gdpr_consent"];
                       XCTAssertNotNil(gdpr_consent);
                       XCTAssertEqual(gdpr_consent.count, 2);
                       XCTAssertNotNil(gdpr_consent[@"consent_required"]);
                       XCTAssertTrue([gdpr_consent[@"consent_required"] boolValue]);
                       XCTAssertNotNil(gdpr_consent[@"consent_string"]);
                       [expectation fulfill];
                   });
    
    [self waitForExpectationsWithTimeout:UTMODULETESTS_TIMEOUT handler:nil];
}


- (void)testUTRequestCheckConsentForIABConsentStringWithFalse
{
     [ANGDPRSettings  reset];
    [[NSUserDefaults standardUserDefaults] setObject:@"a390129402948384453" forKey:@"IABConsent_ConsentString"];
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"IABConsent_SubjectToGDPR"];
    
    NSString                *urlString      = [[[ANSDKSettings sharedInstance] baseUrlConfig] utAdRequestBaseUrl];
    TestANUniversalFetcher  *adFetcher      = [[TestANUniversalFetcher alloc] initWithPlacementId:videoPlacementID];
    NSURLRequest            *request        = [ANUniversalTagRequestBuilder buildRequestWithAdFetcherDelegate:adFetcher.delegate baseUrlString:urlString];
    XCTestExpectation       *expectation    = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    
    
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
                       
                       NSDictionary *gdpr_consent = jsonDict[@"gdpr_consent"];
                       XCTAssertNotNil(gdpr_consent);
                       XCTAssertEqual(gdpr_consent.count, 2);
                       XCTAssertNotNil(gdpr_consent[@"consent_required"]);
                       XCTAssertFalse([gdpr_consent[@"consent_required"] boolValue]);
                       XCTAssertNotNil(gdpr_consent[@"consent_string"]);
                       [expectation fulfill];
                   });
    
    [self waitForExpectationsWithTimeout:UTMODULETESTS_TIMEOUT handler:nil];
}


- (void)testUTRequestWithOneCustomKeywordsValue
{
    
    NSString                *urlString  = [[[ANSDKSettings sharedInstance] baseUrlConfig] utAdRequestBaseUrl];
    TestANUniversalFetcher  *adFetcher  = [[TestANUniversalFetcher alloc] initWithPlacementId:videoPlacementID];

    [adFetcher addCustomKeywordWithKey:@"state" value:@"NY"];
    
    NSURLRequest        *request        = [ANUniversalTagRequestBuilder buildRequestWithAdFetcherDelegate:adFetcher.delegate baseUrlString:urlString];
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
        NSArray *keywords = jsonDict[@"keywords"];
        
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
    NSString                *urlString = [[[ANSDKSettings sharedInstance] baseUrlConfig] utAdRequestBaseUrl];
    TestANUniversalFetcher  *adFetcher = [[TestANUniversalFetcher alloc] initWithPlacementId:videoPlacementID];
    
    [adFetcher addCustomKeywordWithKey:@"state" value:@"NY"];
    [adFetcher addCustomKeywordWithKey:@"state" value:@"NJ"];
    [adFetcher addCustomKeywordWithKey:@"county" value:@"essex"];
    [adFetcher addCustomKeywordWithKey:@"county" value:@"morris"];

    NSURLRequest        *request        = [ANUniversalTagRequestBuilder buildRequestWithAdFetcherDelegate:adFetcher.delegate baseUrlString:urlString];
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
        NSArray *keywords = jsonDict[@"keywords"];
        
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
    
    NSString *urlString = [[[ANSDKSettings sharedInstance] baseUrlConfig] utAdRequestBaseUrl];
    
    TestANUniversalFetcher *adFetcher = [[TestANUniversalFetcher alloc] initWithPlacementId:@"1281482"];
    
    NSURLRequest *request = [ANUniversalTagRequestBuilder buildRequestWithAdFetcherDelegate:adFetcher.delegate baseUrlString:urlString];
    
    NSString *contentType =  [request valueForHTTPHeaderField:@"content-type"];
    XCTAssertNotNil(contentType);
    XCTAssertEqualObjects(@"application/json", contentType);
    
    
}

- (void)testUTRequestWithContentURLCustomKeywordsValue
{
    
    NSString                *urlString  = [[[ANSDKSettings sharedInstance] baseUrlConfig] utAdRequestBaseUrl];
    TestANUniversalFetcher  *adFetcher  = [[TestANUniversalFetcher alloc] initWithPlacementId:videoPlacementID];
    
    [adFetcher addCustomKeywordWithKey:@"content_url" value:@"http://www.appnexus.com"];
    
    NSURLRequest        *request        = [ANUniversalTagRequestBuilder buildRequestWithAdFetcherDelegate:adFetcher.delegate baseUrlString:urlString];
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
        NSArray *keywords = jsonDict[@"keywords"];

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

@end
