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
#import "ANUSPrivacySettings.h"
#import "ANOMIDImplementation.h"


static NSString *const   kTestUUID              = @"0000-000-000-00";
static NSTimeInterval    UTMODULETESTS_TIMEOUT  = 20.0;

static NSString  *placementID  = @"9924001";



@interface ANUniversalTagRequestBuilderFunctionalTests : XCTestCase
    //EMPTY
@end



@implementation ANUniversalTagRequestBuilderFunctionalTests

#pragma mark - Test lifecycle.

- (void)setUp {
    [super setUp];
    
}

- (void)tearDown {
    [super tearDown];
    
    [ANGDPRSettings reset];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"IABTCF_TCString"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"IABTCF_gdprApplies"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"IABTCF_PurposeConsents"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"IABConsent_ConsentString"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"IABConsent_SubjectToGDPR"];
    [[ANSDKSettings sharedInstance] setAuctionTimeout:0];
    
    for (UIView *additionalView in [[UIApplication sharedApplication].keyWindow.rootViewController.view subviews]){
          [additionalView removeFromSuperview];
      }
}

- (void)testUTRequestForSetGDPRConsentTrue
{
    [ANGDPRSettings setConsentRequired:[NSNumber numberWithInt:1]];
    [ANGDPRSettings setConsentString:@"a390129402948384453"];
    
    TestANUniversalFetcher  *adFetcher      = [[TestANUniversalFetcher alloc] initWithPlacementId:placementID];
    NSURLRequest            *request        = [ANUniversalTagRequestBuilder buildRequestWithAdFetcherDelegate:adFetcher.delegate];
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
                       XCTAssertTrue(gdpr_consent[@"consent_required"]);
                       XCTAssertNotNil(gdpr_consent[@"consent_string"]);
                       [expectation fulfill];
                   });
    
    [self waitForExpectationsWithTimeout:UTMODULETESTS_TIMEOUT handler:nil];
}

- (void)testUTRequestForSetGDPRConsentFalse
{
    [ANGDPRSettings setConsentRequired:[NSNumber numberWithInt:0]];
    [ANGDPRSettings setConsentString:@"a390129402948384453"];
    
    TestANUniversalFetcher  *adFetcher      = [[TestANUniversalFetcher alloc] initWithPlacementId:placementID];
    NSURLRequest            *request        = [ANUniversalTagRequestBuilder buildRequestWithAdFetcherDelegate:adFetcher.delegate];
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
                       XCTAssertTrue([gdpr_consent[@"consent_required"] isEqualToNumber:[NSNumber numberWithBool:NO]]);
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
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"IABTCF_TCString"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"IABTCF_gdprApplies"];
    
    TestANUniversalFetcher  *adFetcher      = [[TestANUniversalFetcher alloc] initWithPlacementId:placementID];
    NSURLRequest            *request        = [ANUniversalTagRequestBuilder buildRequestWithAdFetcherDelegate:adFetcher.delegate];
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
    
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:1] forKey:@"IABTCF_gdprApplies"];
    [[NSUserDefaults standardUserDefaults] setObject:@"a390129402948384453" forKey:@"IABTCF_TCString"];
  
    TestANUniversalFetcher  *adFetcher      = [[TestANUniversalFetcher alloc] initWithPlacementId:placementID];
    NSURLRequest            *request        = [ANUniversalTagRequestBuilder buildRequestWithAdFetcherDelegate:adFetcher.delegate];
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
                       XCTAssertTrue(gdpr_consent[@"consent_required"]);
                       XCTAssertNotNil(gdpr_consent[@"consent_string"]);
                       [expectation fulfill];
                   });
    
    [self waitForExpectationsWithTimeout:UTMODULETESTS_TIMEOUT handler:nil];
}

- (void)testUTRequestCheckConsentForTCFConsentStringWithTrue
{
    [ANGDPRSettings reset];
    
    [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"IABTCF_gdprApplies"];
    [[NSUserDefaults standardUserDefaults] setObject:@"a390129402948384453" forKey:@"IABTCF_TCString"];
  
    TestANUniversalFetcher  *adFetcher      = [[TestANUniversalFetcher alloc] initWithPlacementId:placementID];
    NSURLRequest            *request        = [ANUniversalTagRequestBuilder buildRequestWithAdFetcherDelegate:adFetcher.delegate];
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
                       XCTAssertTrue(gdpr_consent[@"consent_required"]);
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
    
    TestANUniversalFetcher  *adFetcher      = [[TestANUniversalFetcher alloc] initWithPlacementId:placementID];
    NSURLRequest            *request        = [ANUniversalTagRequestBuilder buildRequestWithAdFetcherDelegate:adFetcher.delegate];
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
                       XCTAssertTrue([gdpr_consent[@"consent_required"] isEqualToNumber:[NSNumber numberWithBool:NO]]);
                       XCTAssertNotNil(gdpr_consent[@"consent_string"]);
                       [expectation fulfill];
                   });
    
    [self waitForExpectationsWithTimeout:UTMODULETESTS_TIMEOUT handler:nil];
}

- (void)testUTRequestCheckConsentForTCFConsentStringWithFalse
{
     [ANGDPRSettings  reset];
    [[NSUserDefaults standardUserDefaults] setObject:@"a390129402948384453" forKey:@"IABTCF_TCString"];
    [[NSUserDefaults standardUserDefaults] setValue:@"0" forKey:@"IABTCF_gdprApplies"];
    
    TestANUniversalFetcher  *adFetcher      = [[TestANUniversalFetcher alloc] initWithPlacementId:placementID];
    NSURLRequest            *request        = [ANUniversalTagRequestBuilder buildRequestWithAdFetcherDelegate:adFetcher.delegate];
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
                       XCTAssertTrue([gdpr_consent[@"consent_required"] isEqualToNumber:[NSNumber numberWithBool:NO]]);
                       XCTAssertNotNil(gdpr_consent[@"consent_string"]);
                       [expectation fulfill];
                   });
    
    [self waitForExpectationsWithTimeout:UTMODULETESTS_TIMEOUT handler:nil];
}

- (void)testUTRequestForSetUSPrivacyString
{
    [ANUSPrivacySettings setUSPrivacyString:@"1yn"];
    
    TestANUniversalFetcher  *adFetcher      = [[TestANUniversalFetcher alloc] initWithPlacementId:placementID];
    NSURLRequest            *request        = [ANUniversalTagRequestBuilder buildRequestWithAdFetcherDelegate:adFetcher.delegate];
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
                       NSString *privacyString = jsonDict[@"us_privacy"];
                       XCTAssertNotNil(privacyString);
                       XCTAssertTrue(privacyString, @"1yn");
                       [expectation fulfill];
                   });
    
    [self waitForExpectationsWithTimeout:UTMODULETESTS_TIMEOUT handler:nil];
}

- (void)testUTRequestForSetUSPrivacyDefaultString
{
    [ANUSPrivacySettings reset];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"IABUSPrivacy_String"];
    
    TestANUniversalFetcher  *adFetcher      = [[TestANUniversalFetcher alloc] initWithPlacementId:placementID];
    NSURLRequest            *request        = [ANUniversalTagRequestBuilder buildRequestWithAdFetcherDelegate:adFetcher.delegate];
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
                       XCTAssertNil(jsonDict[@"us_privacy"]);
                       [expectation fulfill];
                   });
    
    [self waitForExpectationsWithTimeout:UTMODULETESTS_TIMEOUT handler:nil];
}

- (void)testUTRequestCheckForIAB_USPrivacyString
{
    [ANUSPrivacySettings reset];
    [[NSUserDefaults standardUserDefaults] setObject:@"1yn" forKey:@"IABUSPrivacy_String"];
  
    TestANUniversalFetcher  *adFetcher      = [[TestANUniversalFetcher alloc] initWithPlacementId:placementID];
    NSURLRequest            *request        = [ANUniversalTagRequestBuilder buildRequestWithAdFetcherDelegate:adFetcher.delegate];
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
                      
                       NSString *privacyString = jsonDict[@"us_privacy"];
                       XCTAssertNotNil(privacyString);
                       XCTAssertTrue(privacyString, @"1yn");
                       [expectation fulfill];
                   });
    
    [self waitForExpectationsWithTimeout:UTMODULETESTS_TIMEOUT handler:nil];
}


- (void)testUTRequestForAuctionTimeoutNonZero
{
    [[ANSDKSettings sharedInstance] setAuctionTimeout:200];
    
    NSString                *urlString      = [[[ANSDKSettings sharedInstance] baseUrlConfig] utAdRequestBaseUrl];
    TestANUniversalFetcher  *adFetcher      = [[TestANUniversalFetcher alloc] initWithPlacementId:placementID];
    NSURLRequest            *request        = [ANUniversalTagRequestBuilder buildRequestWithAdFetcherDelegate:adFetcher.delegate];

    
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
        XCTAssertNotNil(jsonDict[@"auction_timeout_ms"]);
        XCTAssertEqual([jsonDict[@"auction_timeout_ms"]  intValue], 200);
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:UTMODULETESTS_TIMEOUT handler:nil];
}

- (void)testUTRequestForAuctionTimeoutZero
{
    [[ANSDKSettings sharedInstance] setAuctionTimeout:0];
    
    NSString                *urlString      = [[[ANSDKSettings sharedInstance] baseUrlConfig] utAdRequestBaseUrl];
    TestANUniversalFetcher  *adFetcher      = [[TestANUniversalFetcher alloc] initWithPlacementId:placementID];
    NSURLRequest            *request        = [ANUniversalTagRequestBuilder buildRequestWithAdFetcherDelegate:adFetcher.delegate];
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
        XCTAssertNil(jsonDict[@"auction_timeout_ms"]);
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:UTMODULETESTS_TIMEOUT handler:nil];
}


- (void)testUTRequestForAuctionTimeoutZeroDefault
{
    
    
    NSString                *urlString      = [[[ANSDKSettings sharedInstance] baseUrlConfig] utAdRequestBaseUrl];
    TestANUniversalFetcher  *adFetcher      = [[TestANUniversalFetcher alloc] initWithPlacementId:placementID];
    NSURLRequest            *request        = [ANUniversalTagRequestBuilder buildRequestWithAdFetcherDelegate:adFetcher.delegate];
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
        XCTAssertNil(jsonDict[@"auction_timeout_ms"]);
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:UTMODULETESTS_TIMEOUT handler:nil];
}


- (void)testUTRequestForAuctionTimeoutNegativevalue
{
    
    [[ANSDKSettings sharedInstance] setAuctionTimeout:-10];
    
    
    NSString                *urlString      = [[[ANSDKSettings sharedInstance] baseUrlConfig] utAdRequestBaseUrl];
    TestANUniversalFetcher  *adFetcher      = [[TestANUniversalFetcher alloc] initWithPlacementId:placementID];
    NSURLRequest            *request        = [ANUniversalTagRequestBuilder buildRequestWithAdFetcherDelegate:adFetcher.delegate];
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
        XCTAssertNil(jsonDict[@"auction_timeout_ms"]);
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:UTMODULETESTS_TIMEOUT handler:nil];
}



- (void)testUTRequestForOMIDSignalEnableBannerAd
{
    [self setUpOMIDTestCaseForAd:@[ @(ANAllowedMediaTypeBanner) ] andEnableOMID:YES];
}

- (void)testUTRequestForOMIDSignalDisableBannerAd
{
    [self setUpOMIDTestCaseForAd:@[ @(ANAllowedMediaTypeBanner) ]  andEnableOMID:NO];
}

- (void)testUTRequestForOMIDSignalEnableInterstitialAd
{
    [self setUpOMIDTestCaseForAd:@[ @(ANAllowedMediaTypeInterstitial) ]  andEnableOMID:YES];
}

- (void)testUTRequestForOMIDSignalDisableInterstitialAd
{
    [self setUpOMIDTestCaseForAd:@[ @(ANAllowedMediaTypeInterstitial) ] andEnableOMID:NO];
}


- (void)testUTRequestForOMIDSignalEnableVideoAd
{
    [self setUpOMIDTestCaseForAd:@[ @(ANAllowedMediaTypeVideo) ]  andEnableOMID:YES];
}

- (void)testUTRequestForOMIDSignalDisableVideoAd
{
    [self setUpOMIDTestCaseForAd:@[ @(ANAllowedMediaTypeVideo) ]  andEnableOMID:NO];
}

- (void)testUTRequestForOMIDSignalEnableNativeAd
{
    [self setUpOMIDTestCaseForAd:@[ @(ANAllowedMediaTypeNative) ] andEnableOMID:YES];
}


- (void)testUTRequestForOMIDSignalDisableNativeAd
{
    [self setUpOMIDTestCaseForAd:@[ @(ANAllowedMediaTypeNative) ] andEnableOMID:NO];
}

- (void)testUTRequestForOMIDSignalEnableBannerNativeVideoAd
{
    [self setUpOMIDTestCaseForAd:@[ @(ANAllowedMediaTypeNative) ,@(ANAllowedMediaTypeVideo),@(ANAllowedMediaTypeBanner)] andEnableOMID:YES];
}


- (void)testUTRequestForOMIDSignalDisableBannerNativeVideoAd
{
    [self setUpOMIDTestCaseForAd:@[ @(ANAllowedMediaTypeNative) ,@(ANAllowedMediaTypeVideo),@(ANAllowedMediaTypeBanner)] andEnableOMID:NO];
}

- (void)testUTRequestForOMIDSignalEnableNativeVideoAd
{
    [self setUpOMIDTestCaseForAd:@[ @(ANAllowedMediaTypeNative) ,@(ANAllowedMediaTypeVideo)] andEnableOMID:YES];
}


- (void)testUTRequestForOMIDSignalDisableNativeVideoAd
{
    [self setUpOMIDTestCaseForAd:@[ @(ANAllowedMediaTypeNative) ,@(ANAllowedMediaTypeVideo)] andEnableOMID:NO];
}


- (void)testUTRequestForOMIDSignalEnableBannerNativeAd
{
    [self setUpOMIDTestCaseForAd:@[ @(ANAllowedMediaTypeNative) ,@(ANAllowedMediaTypeBanner)] andEnableOMID:YES];
}


- (void)testUTRequestForOMIDSignalDisableBannerNativeAd
{
    [self setUpOMIDTestCaseForAd:@[ @(ANAllowedMediaTypeNative) ,@(ANAllowedMediaTypeBanner)] andEnableOMID:NO];
}


- (void)testUTRequestForOMIDSignalEnableBannerVideoAd
{
    [self setUpOMIDTestCaseForAd:@[@(ANAllowedMediaTypeVideo),@(ANAllowedMediaTypeBanner)] andEnableOMID:YES];
}


- (void)testUTRequestForOMIDSignalDisableBannerVideoAd
{
    [self setUpOMIDTestCaseForAd:@[@(ANAllowedMediaTypeVideo),@(ANAllowedMediaTypeBanner)] andEnableOMID:NO];
}

-(void)setUpOMIDTestCaseForAd:(NSArray<NSValue *> *)mediaType andEnableOMID:(Boolean)OMIDSignalEnable{
    [[ANSDKSettings sharedInstance] setEnableOpenMeasurement:OMIDSignalEnable];
    
    TestANUniversalFetcher  *adFetcher      = [[TestANUniversalFetcher alloc] initWithPlacementId:placementID andAllowMediaType:mediaType];
    NSURLRequest            *request        = [ANUniversalTagRequestBuilder buildRequestWithAdFetcherDelegate:adFetcher.delegate];
    XCTestExpectation       *expectation    = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(),
                   ^{
        NSError *error;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:request.HTTPBody
                                                        options:kNilOptions
                                                          error:&error];
        TESTTRACEM(@"jsonObject=%@", jsonObject);
        XCTAssertNil(error);
        if(OMIDSignalEnable){
            [self OMIDSignalEnableAssert:jsonObject andMediaType:mediaType andTagIndex:0];
        }else{
            [self OMIDSignalDisableAssert:jsonObject andMediaType:mediaType andTagIndex:0];
        }
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:UTMODULETESTS_TIMEOUT handler:nil];
}

-(void)OMIDSignalEnableAssert:(NSDictionary *)jsonObject andMediaType:(NSArray<NSValue *> *)mediaType andTagIndex:(int)index{
    
    XCTAssertNotNil(jsonObject);
    XCTAssertTrue([jsonObject isKindOfClass:[NSDictionary class]]);
    NSDictionary *jsonDict = (NSDictionary *)jsonObject;
    NSDictionary *iab_support = jsonDict[@"iab_support"];
    XCTAssertNotNil(iab_support);
    XCTAssertEqual(iab_support.count, 2);
    XCTAssertNotNil(iab_support[@"omidpn"]);
    XCTAssertNotNil(iab_support[@"omidpv"]);
    XCTAssertEqualObjects(iab_support[@"omidpn"],AN_OMIDSDK_PARTNER_NAME);
    XCTAssertEqualObjects(iab_support[@"omidpv"],[ANSDKSettings sharedInstance].sdkVersion);
    
    NSArray *tags = jsonDict[@"tags"];
    XCTAssertNotNil(tags);
    XCTAssertEqual(tags.count, index + 1  );
    
    if( [mediaType containsObject:@(ANAllowedMediaTypeNative)]){
        XCTAssertEqualObjects(tags[index][@"native_frameworks"],@[@(6)]);
    }
    
    if( [mediaType containsObject:@(ANAllowedMediaTypeBanner)]){
        XCTAssertEqualObjects(tags[index][@"banner_frameworks"],@[@(6)]);
    }
    
    if( [mediaType containsObject:@(ANAllowedMediaTypeVideo)]){
        XCTAssertEqualObjects(tags[index][@"video_frameworks"],@[@(6)]);
    }
    
}

-(void)OMIDSignalDisableAssert:(NSDictionary *)jsonObject andMediaType:(NSArray<NSValue *> *)mediaType andTagIndex:(int)index{
    
    XCTAssertNotNil(jsonObject);
    XCTAssertTrue([jsonObject isKindOfClass:[NSDictionary class]]);
    NSDictionary *jsonDict = (NSDictionary *)jsonObject;
    
    NSDictionary *iab_support = jsonDict[@"iab_support"];
    XCTAssertNil(iab_support);
    XCTAssertEqual(iab_support.count, 0);
    XCTAssertFalse([iab_support objectForKey:@"omidpn"]);
    XCTAssertFalse([iab_support objectForKey:@"omidpv"]);
    
    NSArray *tags = jsonDict[@"tags"];
    XCTAssertNotNil(tags);
    XCTAssertEqual(tags.count, 1 );
    
    if( [mediaType containsObject:@(ANAllowedMediaTypeNative)]){
        XCTAssertFalse([tags[index] objectForKey:@"native_frameworks"]);
    }
    
    if( [mediaType containsObject:@(ANAllowedMediaTypeBanner)]){
        XCTAssertFalse([tags[index] objectForKey:@"banner_frameworks"]);
    }
    
    if( [mediaType containsObject:@(ANAllowedMediaTypeVideo)]){
        XCTAssertFalse([tags[index] objectForKey:@"video_frameworks"]);
    }
    
}

@end
