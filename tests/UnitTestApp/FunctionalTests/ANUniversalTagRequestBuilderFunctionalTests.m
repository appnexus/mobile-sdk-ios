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
#import "ANUSPrivacySettings.h"
#import "ANOMIDImplementation.h"
#import "ANDSASettings.h"
#import "ANDSATransparencyInfo.h"
#if __has_include(<AppTrackingTransparency/AppTrackingTransparency.h>)
    #import <AppTrackingTransparency/AppTrackingTransparency.h>
#endif

static NSString *const   kTestUUID              = @"0000-000-000-00";
static NSTimeInterval    UTMODULETESTS_TIMEOUT  = 40.0;

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
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"IABTCF_AddtlConsent"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"IABGPP_HDR_GppString"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"IABGPP_GppSID"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"IABGPP_TCFEU2_PurposeConsents"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"IABGPP_TCFEU2_gdprApplies"];
    [[ANSDKSettings sharedInstance] setAuctionTimeout:0];
    ANSDKSettings.sharedInstance.geoOverrideCountryCode = nil;
    ANSDKSettings.sharedInstance.geoOverrideZipCode = nil;
    ANSDKSettings.sharedInstance.publisherUserId = nil;
    ANSDKSettings.sharedInstance.userIdArray = nil;
    ANSDKSettings.sharedInstance.doNotTrack = NO; // Reset Donot Track to default value
    ANSDKSettings.sharedInstance.contentLanguage = nil;
    
    for (UIView *additionalView in [[ANGlobal getKeyWindow].rootViewController.view subviews]){
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
    XCTAssertTrue([[request.URL absoluteString] isEqualToString:@"https://ib.adnxs-simple.com/ut/v3"], @"Expected Cookieless ib.adnxs-simple.com domain when GDPR set to true");
    
    
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
                       XCTAssertEqual(gdpr_consent.count, 3);
                       XCTAssertNotNil(gdpr_consent[@"consent_required"]);
                       XCTAssertTrue(gdpr_consent[@"consent_required"]);
                       XCTAssertNotNil(gdpr_consent[@"consent_string"]);
                       XCTAssertNotNil(gdpr_consent[@"addtl_consent"]);
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
                       XCTAssertEqual(gdpr_consent.count, 3);
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
    XCTAssertTrue([[request.URL absoluteString] isEqualToString:@"https://mediation.adnxs.com/ut/v3"], @"Expected mediation.adnxs.com domain when GDPR does not apply");
    
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
                       XCTAssertEqual(gdpr_consent.count, 3);
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
                       XCTAssertEqual(gdpr_consent.count, 3);
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
                       XCTAssertEqual(gdpr_consent.count, 3);
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
                       XCTAssertEqual(gdpr_consent.count, 3);
                       XCTAssertNotNil(gdpr_consent[@"consent_required"]);
                       XCTAssertTrue([gdpr_consent[@"consent_required"] isEqualToNumber:[NSNumber numberWithBool:NO]]);
                       XCTAssertNotNil(gdpr_consent[@"consent_string"]);
                       [expectation fulfill];
                   });
    
    [self waitForExpectationsWithTimeout:UTMODULETESTS_TIMEOUT handler:nil];
}

/**
* Test addtl_consent in /ut request body
 */
- (void)testGoogleACMConsentString
{
     [ANGDPRSettings  reset];
    [[NSUserDefaults standardUserDefaults] setObject:@"1~7.12.35.62.66.70.89.93.108" forKey:@"IABTCF_AddtlConsent"];
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
                       XCTAssertEqual(gdpr_consent.count, 3);
                       XCTAssertNotNil(gdpr_consent[@"consent_required"]);
                       XCTAssertTrue([gdpr_consent[@"consent_required"] isEqualToNumber:[NSNumber numberWithBool:NO]]);
                       XCTAssertNotNil(gdpr_consent[@"consent_string"]);
                       XCTAssertNotNil(gdpr_consent[@"addtl_consent"]);
                       NSArray *array = @[@7,@12,@35,@62,@66,@70,@89,@93,@108];
                       XCTAssertTrue([gdpr_consent[@"addtl_consent"] isEqualToArray:array]);
                       [expectation fulfill];
                   });
    
    [self waitForExpectationsWithTimeout:UTMODULETESTS_TIMEOUT handler:nil];
}


/**
* Test invalid addtl_consent in /ut request body
 */
- (void)testInvalidGoogleACMConsentString
{
     [ANGDPRSettings  reset];
    [[NSUserDefaults standardUserDefaults] setObject:@"12367" forKey:@"IABTCF_AddtlConsent"]; // Invalid Additional consent string
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
                       XCTAssertEqual(gdpr_consent.count, 3);
                       XCTAssertNotNil(gdpr_consent[@"consent_required"]);
                       XCTAssertTrue([gdpr_consent[@"consent_required"] isEqualToNumber:[NSNumber numberWithBool:NO]]);
                       XCTAssertNotNil(gdpr_consent[@"consent_string"]);
                       XCTAssertNotNil(gdpr_consent[@"addtl_consent"]);
                       NSArray *array = @[];
                       XCTAssertTrue([gdpr_consent[@"addtl_consent"] isEqualToArray:array]);
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

//1 If Valid GPP string and Gpp SID is set in NSUserDefault keys AN_IABGPP_HDR_GppString and AN_IABGPP_GppSID then it should go in request

- (void)testUTRequestGppString
{
    [[NSUserDefaults standardUserDefaults] setObject:@"DBACNYA~CPXxRfAPXxRfAAfKABENB-CgAAAAAAAAAAYgAAAAAAAA~1YNN" forKey:@"IABGPP_HDR_GppString"];
    [[NSUserDefaults standardUserDefaults] setObject:@"2_6" forKey:@"IABGPP_GppSID"];

  
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
                      
                       NSDictionary *gpp_privacy = jsonDict[@"privacy"];
                       XCTAssertNotNil(gpp_privacy);
                       XCTAssertEqual(gpp_privacy.count, 2);
                       XCTAssertNotNil(gpp_privacy[@"gpp_sid"]);
                       NSArray *gppSideArray = @[@2, @6];
                       XCTAssertTrue([gpp_privacy[@"gpp_sid"] isEqualToArray:gppSideArray]);
        
                       XCTAssertNotNil(gpp_privacy[@"gpp"]);
                       XCTAssertTrue([gpp_privacy[@"gpp"] isEqualToString:@"DBACNYA~CPXxRfAPXxRfAAfKABENB-CgAAAAAAAAAAYgAAAAAAAA~1YNN"]);
        
                       [expectation fulfill];
                   });
    
    [self waitForExpectationsWithTimeout:UTMODULETESTS_TIMEOUT handler:nil];
}

//2 If No GPP string/ GppSID is present in NSUserDefault keys AN_IABGPP_HDR_GppString and AN_IABGPP_GppSID then it should not go in request
- (void)testUTRequestGppPrivacyObjectNotPresent
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"IABGPP_HDR_GppString"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"IABGPP_GppSID"];

  
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
                       XCTAssertNil(jsonDict[@"privacy"]);
        
                       [expectation fulfill];
                   });
    
    [self waitForExpectationsWithTimeout:UTMODULETESTS_TIMEOUT handler:nil];
}


- (void)testUTRequestForAuctionTimeoutNonZero
{
    [[ANSDKSettings sharedInstance] setAuctionTimeout:200];
    
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

- (void)testUTRequestForZipCodeAndCountryCode
{
    ANSDKSettings.sharedInstance.geoOverrideCountryCode = @"US";
    ANSDKSettings.sharedInstance.geoOverrideZipCode = @"226006";
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
        NSDictionary *geoOverrideDict = jsonDict[@"geoOverride"];
        XCTAssertNotNil(geoOverrideDict);
        NSString *countryCode = geoOverrideDict[@"countryCode"];
        NSString *zipCode = geoOverrideDict[@"zip"];
        XCTAssertTrue([countryCode isEqualToString:ANSDKSettings.sharedInstance.geoOverrideCountryCode]);
        XCTAssertTrue([zipCode isEqualToString:ANSDKSettings.sharedInstance.geoOverrideZipCode]);
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:UTMODULETESTS_TIMEOUT handler:nil];
}

- (void)testUTRequestForValidZipCodeAndEmptyCountryCode
{
    ANSDKSettings.sharedInstance.geoOverrideCountryCode = @"";
    ANSDKSettings.sharedInstance.geoOverrideZipCode = @"226006";
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
        NSDictionary *geoOverrideDict = jsonDict[@"geoOverride"];
        XCTAssertNotNil(geoOverrideDict);
        XCTAssertNil(geoOverrideDict[@"countryCode"]);
        NSString *zipCode = geoOverrideDict[@"zip"];
        XCTAssertTrue([zipCode isEqualToString:ANSDKSettings.sharedInstance.geoOverrideZipCode]);
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:UTMODULETESTS_TIMEOUT handler:nil];
}

- (void)testUTRequestForEmptyZipCodeAndValidCountryCode
{
    ANSDKSettings.sharedInstance.geoOverrideCountryCode = @"US";
    ANSDKSettings.sharedInstance.geoOverrideZipCode = @"";
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
        NSDictionary *geoOverrideDict = jsonDict[@"geoOverride"];
        XCTAssertNotNil(geoOverrideDict);
        XCTAssertNil(geoOverrideDict[@"zip"]);
        NSString *countryCode = geoOverrideDict[@"countryCode"];
        XCTAssertTrue([countryCode isEqualToString:ANSDKSettings.sharedInstance.geoOverrideCountryCode]);
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:UTMODULETESTS_TIMEOUT handler:nil];
}

- (void)testUTRequestForEmptyZipCodeAndEmptyCountryCode
{
    ANSDKSettings.sharedInstance.geoOverrideCountryCode = @"";
    ANSDKSettings.sharedInstance.geoOverrideZipCode = @"";
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
        NSDictionary *geoOverrideDict = jsonDict[@"geoOverride"];
        XCTAssertNil(geoOverrideDict);
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:UTMODULETESTS_TIMEOUT handler:nil];
}

- (void)testUTRequestForContentLanguage
{
    ANSDKSettings.sharedInstance.contentLanguage = @"EN";
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
        NSDictionary *requestContentLanguageDict = jsonDict[@"request_content"];
        XCTAssertNotNil(requestContentLanguageDict);
        NSString *contentLanguage = requestContentLanguageDict[@"language"];
        XCTAssertTrue([contentLanguage isEqualToString:ANSDKSettings.sharedInstance.contentLanguage]);
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:UTMODULETESTS_TIMEOUT handler:nil];
}

- (void)testUTRequestForEmptyContentLanguage
{
    ANSDKSettings.sharedInstance.contentLanguage = @"";
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
        NSDictionary *requestContentLanguageDict = jsonDict[@"request_content"];
        XCTAssertNil(requestContentLanguageDict);
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



- (void)testUTRequestPublisherUserIDS
{
    
    ANSDKSettings.sharedInstance.publisherUserId = @"foobar-publisherfirstpartyid"; // This value should be seen in UT Request body
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
        NSDictionary *userDict = jsonDict[@"user"];
        XCTAssertNotNil(userDict);
        
        NSString *puhlisherUserId = userDict[@"external_uid"];
        XCTAssertNotNil(puhlisherUserId);
        XCTAssertEqualObjects(puhlisherUserId, @"foobar-publisherfirstpartyid");
        
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:UTMODULETESTS_TIMEOUT handler:nil];
    
}




- (void)testUTRequestUserIds
{
    
    NSMutableArray<ANUserId *>  *tempUserIdArray  = [[NSMutableArray<ANUserId *> alloc] init];
    [tempUserIdArray addObject:[[ANUserId alloc] initWithANUserIdSource:ANUserIdSourceNetId userId:@"999888777" ]];
    [tempUserIdArray addObject:[[ANUserId alloc] initWithANUserIdSource:ANUserIdSourceTheTradeDesk userId:@"00000111-91b1-49b2-ae37-17a8173dc36f" ]];
    [tempUserIdArray addObject:[[ANUserId alloc] initWithANUserIdSource:ANUserIdSourceUID2 userId:@"uid2_3948249329482ok" ]];
    [tempUserIdArray addObject:[[ANUserId alloc] initWithANUserIdSource:ANUserIdSourceCriteo userId:@"_fl7bV96WjZsbiUyQnJlQ3g4ckh5a1N"]];
    [tempUserIdArray addObject:[[ANUserId alloc] initWithANUserIdSource:ANUserIdSourceLiveRamp userId:@"AjfowMv4ZHZQJFM8TpiUnYEyA81Vdgg" ]];
    [tempUserIdArray addObject:[[ANUserId alloc] initWithStringSource:@"string-source-foo-bar-27" userId:@"temp_user_id-foo-bar-27" isFirstParytId:true]];

    ANSDKSettings.sharedInstance.userIdArray = tempUserIdArray;
    
    
    TestANUniversalFetcher  *adFetcher      = [[TestANUniversalFetcher alloc] initWithPlacementId:placementID];
    NSURLRequest            *request        = [ANUniversalTagRequestBuilder buildRequestWithAdFetcherDelegate:adFetcher.delegate];
   
    XCTestExpectation       *netIDExpectation    = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    XCTestExpectation       *liveRampExpectation    = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    XCTestExpectation       *tradeDeskExpectation    = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    XCTestExpectation       *criteoExpectation    = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    XCTestExpectation       *uid2Expectation    = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    XCTestExpectation       *customSourceExpectation    = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    
    
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
        NSArray *eidsArray = jsonDict[@"eids"];
        NSDictionary *eidDictionary = jsonDict[@"eids"];
        
        if (@available(iOS 14, *)) {
            // External UIDs should be sent in /ut/v3 request only when  ATT Tracking status is authorized
        #if __has_include(<AppTrackingTransparency/AppTrackingTransparency.h>)
                if ([ATTrackingManager trackingAuthorizationStatus] == ATTrackingManagerAuthorizationStatusAuthorized){
                    XCTAssertEqual(eidDictionary.count, 6 );
                    
                    NSUInteger count = [eidsArray count];
                    for (NSUInteger index = 0; index < count ; index++) {
                        TESTTRACEM(@"source==============%@", eidsArray[index][@"source"]);
                        if([eidsArray[index][@"source"] isEqualToString: @"criteo.com"]){
                            XCTAssertEqualObjects(eidsArray[index][@"source"], @"criteo.com");
                            XCTAssertEqualObjects(eidsArray[index][@"id"], @"_fl7bV96WjZsbiUyQnJlQ3g4ckh5a1N");
                            [criteoExpectation fulfill];
                        }
                        
                        if([eidsArray[index][@"source"] isEqualToString: @"netid.de"]){
                            XCTAssertEqualObjects(eidsArray[index][@"source"], @"netid.de");
                            XCTAssertEqualObjects(eidsArray[index][@"id"], @"999888777");
                            [netIDExpectation fulfill];
                        }
                        
                        if([eidsArray[index][@"source"] isEqualToString: @"liveramp.com"]){
                            XCTAssertEqualObjects(eidsArray[index][@"source"], @"liveramp.com");
                            XCTAssertEqualObjects(eidsArray[index][@"id"], @"AjfowMv4ZHZQJFM8TpiUnYEyA81Vdgg");
                            [liveRampExpectation fulfill];
                        }
                        
                        if([eidsArray[index][@"source"] isEqualToString: @"adserver.org"]){
                            XCTAssertEqualObjects(eidsArray[index][@"source"], @"adserver.org");
                            XCTAssertEqualObjects(eidsArray[index][@"id"], @"00000111-91b1-49b2-ae37-17a8173dc36f");
                            XCTAssertEqualObjects(eidsArray[index][@"rti_partner"], @"TDID");
                            [tradeDeskExpectation fulfill];
                        }
                        if([eidsArray[index][@"source"] isEqualToString: @"uidapi.com"]){
                            XCTAssertEqualObjects(eidsArray[index][@"source"], @"uidapi.com");
                            XCTAssertEqualObjects(eidsArray[index][@"id"], @"uid2_3948249329482ok");
                            XCTAssertEqualObjects(eidsArray[index][@"rti_partner"], @"UID2");
                            [uid2Expectation fulfill];
                        }
                        if([eidsArray[index][@"source"] isEqualToString: @"string-source-foo-bar-27"]){
                            XCTAssertEqualObjects(eidsArray[index][@"source"], @"string-source-foo-bar-27");
                            XCTAssertEqualObjects(eidsArray[index][@"id"], @"temp_user_id-foo-bar-27");
                            [customSourceExpectation fulfill];
                        }
                    }
                }else {
                    
                    
                    XCTAssertNil(eidDictionary);
                 
                    [tradeDeskExpectation fulfill];
                    [criteoExpectation fulfill];
                    [netIDExpectation fulfill];
                    [liveRampExpectation fulfill];
                    [uid2Expectation fulfill];
                    [customSourceExpectation fulfill];

                    }
        #endif
            }else{
                XCTAssertEqual(eidDictionary.count, 6 );
                
                NSUInteger count = [eidsArray count];
                for (NSUInteger index = 0; index < count ; index++) {
                    TESTTRACEM(@"source==============%@", eidsArray[index][@"source"]);
                    if([eidsArray[index][@"source"] isEqualToString: @"criteo.com"]){
                        XCTAssertEqualObjects(eidsArray[index][@"source"], @"criteo.com");
                        XCTAssertEqualObjects(eidsArray[index][@"id"], @"_fl7bV96WjZsbiUyQnJlQ3g4ckh5a1N");
                        [criteoExpectation fulfill];
                    }
                    
                    if([eidsArray[index][@"source"] isEqualToString: @"netid.de"]){
                        XCTAssertEqualObjects(eidsArray[index][@"source"], @"netid.de");
                        XCTAssertEqualObjects(eidsArray[index][@"id"], @"999888777");
                        [netIDExpectation fulfill];
                    }
                    
                    if([eidsArray[index][@"source"] isEqualToString: @"liveramp.com"]){
                        XCTAssertEqualObjects(eidsArray[index][@"source"], @"liveramp.com");
                        XCTAssertEqualObjects(eidsArray[index][@"id"], @"AjfowMv4ZHZQJFM8TpiUnYEyA81Vdgg");
                        [liveRampExpectation fulfill];
                    }
                    
                    if([eidsArray[index][@"source"] isEqualToString: @"adserver.org"]){
                        XCTAssertEqualObjects(eidsArray[index][@"source"], @"adserver.org");
                        XCTAssertEqualObjects(eidsArray[index][@"id"], @"00000111-91b1-49b2-ae37-17a8173dc36f");
                        XCTAssertEqualObjects(eidsArray[index][@"rti_partner"], @"TDID");
                        [tradeDeskExpectation fulfill];
                    }
                    
                    if([eidsArray[index][@"source"] isEqualToString: @"uidapi.com"]){
                        XCTAssertEqualObjects(eidsArray[index][@"source"], @"uidapi.com");
                        XCTAssertEqualObjects(eidsArray[index][@"id"], @"uid2_3948249329482ok");
                        XCTAssertEqualObjects(eidsArray[index][@"rti_partner"], @"UID2");
                        [uid2Expectation fulfill];
                    }
                    if([eidsArray[index][@"source"] isEqualToString: @"string-source-foo-bar-27"]){
                        XCTAssertEqualObjects(eidsArray[index][@"source"], @"string-source-foo-bar-27");
                        XCTAssertEqualObjects(eidsArray[index][@"id"], @"temp_user_id-foo-bar-27");
                        [customSourceExpectation fulfill];
                    }
                }
    }
        

    });
    
    [self waitForExpectationsWithTimeout:UTMODULETESTS_TIMEOUT handler:nil];
    
}



- (void)testUTRequestEidsFirst
{
    
    NSMutableArray<ANUserId *>  *tempUserIdArray  = [[NSMutableArray<ANUserId *> alloc] init];
    [tempUserIdArray addObject:[[ANUserId alloc] initWithANUserIdSource:ANUserIdSourceNetId userId:@"999888777" ]];
    [tempUserIdArray addObject:[[ANUserId alloc] initWithANUserIdSource:ANUserIdSourceTheTradeDesk userId:@"00000111-91b1-49b2-ae37-17a8173dc36f" ]];
    [tempUserIdArray addObject:[[ANUserId alloc] initWithANUserIdSource:ANUserIdSourceUID2 userId:@"uid2_3948249329482ok" ]];
    [tempUserIdArray addObject:[[ANUserId alloc] initWithANUserIdSource:ANUserIdSourceCriteo userId:@"_fl7bV96WjZsbiUyQnJlQ3g4ckh5a1N"]];
    [tempUserIdArray addObject:[[ANUserId alloc] initWithANUserIdSource:ANUserIdSourceLiveRamp userId:@"AjfowMv4ZHZQJFM8TpiUnYEyA81Vdgg" ]];
    [tempUserIdArray addObject:[[ANUserId alloc] initWithStringSource:@"string-source-foo-bar-2" userId:@"temp_user_id-foo-bar-2" isFirstParytId:true]];

    ANSDKSettings.sharedInstance.userIdArray = tempUserIdArray;
    
    
    TestANUniversalFetcher  *adFetcher      = [[TestANUniversalFetcher alloc] initWithPlacementId:placementID];
    NSURLRequest            *request        = [ANUniversalTagRequestBuilder buildRequestWithAdFetcherDelegate:adFetcher.delegate];
   
    XCTestExpectation       *netIDExpectation    = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    XCTestExpectation       *liveRampExpectation    = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    XCTestExpectation       *tradeDeskExpectation    = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    XCTestExpectation       *criteoExpectation    = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    XCTestExpectation       *uid2Expectation    = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    XCTestExpectation       *customSourceExpectation    = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    
    
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
        NSArray *eidsArray = jsonDict[@"eids"];
        NSDictionary *eidDictionary = jsonDict[@"eids"];
        
        if (@available(iOS 14, *)) {
            // External UIDs should be sent in /ut/v3 request only when  ATT Tracking status is authorized
        #if __has_include(<AppTrackingTransparency/AppTrackingTransparency.h>)
                if ([ATTrackingManager trackingAuthorizationStatus] == ATTrackingManagerAuthorizationStatusAuthorized){
                    XCTAssertEqual(eidDictionary.count, 6 );
                    
                    NSUInteger count = [eidsArray count];
                    for (NSUInteger index = 0; index < count ; index++) {
                        TESTTRACEM(@"source==============%@", eidsArray[index][@"source"]);
                        if([eidsArray[index][@"source"] isEqualToString: @"criteo.com"]){
                            XCTAssertEqualObjects(eidsArray[index][@"source"], @"criteo.com");
                            XCTAssertEqualObjects(eidsArray[index][@"id"], @"_fl7bV96WjZsbiUyQnJlQ3g4ckh5a1N");
                            [criteoExpectation fulfill];
                        }
                        
                        if([eidsArray[index][@"source"] isEqualToString: @"netid.de"]){
                            XCTAssertEqualObjects(eidsArray[index][@"source"], @"netid.de");
                            XCTAssertEqualObjects(eidsArray[index][@"id"], @"999888777");
                            [netIDExpectation fulfill];
                        }
                        
                        if([eidsArray[index][@"source"] isEqualToString: @"liveramp.com"]){
                            XCTAssertEqualObjects(eidsArray[index][@"source"], @"liveramp.com");
                            XCTAssertEqualObjects(eidsArray[index][@"id"], @"AjfowMv4ZHZQJFM8TpiUnYEyA81Vdgg");
                            [liveRampExpectation fulfill];
                        }
                        
                        if([eidsArray[index][@"source"] isEqualToString: @"adserver.org"]){
                            XCTAssertEqualObjects(eidsArray[index][@"source"], @"adserver.org");
                            XCTAssertEqualObjects(eidsArray[index][@"id"], @"00000111-91b1-49b2-ae37-17a8173dc36f");
                            XCTAssertEqualObjects(eidsArray[index][@"rti_partner"], @"TDID");
                            [tradeDeskExpectation fulfill];
                        }
                        if([eidsArray[index][@"source"] isEqualToString: @"uidapi.com"]){
                            XCTAssertEqualObjects(eidsArray[index][@"source"], @"uidapi.com");
                            XCTAssertEqualObjects(eidsArray[index][@"id"], @"uid2_3948249329482ok");
                            XCTAssertEqualObjects(eidsArray[index][@"rti_partner"], @"UID2");
                            [uid2Expectation fulfill];
                        }
                        if([eidsArray[index][@"source"] isEqualToString: @"string-source-foo-bar-2"]){
                            XCTAssertEqualObjects(eidsArray[index][@"source"], @"string-source-foo-bar-2");
                            XCTAssertEqualObjects(eidsArray[index][@"id"], @"temp_user_id-foo-bar-2");
                            [customSourceExpectation fulfill];
                        }
                    }
                }else {
                    
                    
                    XCTAssertNotNil(eidDictionary);
                    XCTAssertEqual(eidDictionary.count, 1);
                    
                    if([eidsArray[0][@"source"] isEqualToString: @"string-source-foo-bar-2"]){
                        XCTAssertEqualObjects(eidsArray[0][@"source"], @"string-source-foo-bar-2");
                        XCTAssertEqualObjects(eidsArray[0][@"id"], @"temp_user_id-foo-bar-2");
                    }
                    
                    [tradeDeskExpectation fulfill];
                    [criteoExpectation fulfill];
                    [netIDExpectation fulfill];
                    [liveRampExpectation fulfill];
                    [uid2Expectation fulfill];
                    [customSourceExpectation fulfill];

                    }
        #endif
            }else{
                XCTAssertEqual(eidDictionary.count, 6 );
                
                NSUInteger count = [eidsArray count];
                for (NSUInteger index = 0; index < count ; index++) {
                    TESTTRACEM(@"source==============%@", eidsArray[index][@"source"]);
                    if([eidsArray[index][@"source"] isEqualToString: @"criteo.com"]){
                        XCTAssertEqualObjects(eidsArray[index][@"source"], @"criteo.com");
                        XCTAssertEqualObjects(eidsArray[index][@"id"], @"_fl7bV96WjZsbiUyQnJlQ3g4ckh5a1N");
                        [criteoExpectation fulfill];
                    }
                    
                    if([eidsArray[index][@"source"] isEqualToString: @"netid.de"]){
                        XCTAssertEqualObjects(eidsArray[index][@"source"], @"netid.de");
                        XCTAssertEqualObjects(eidsArray[index][@"id"], @"999888777");
                        [netIDExpectation fulfill];
                    }
                    
                    if([eidsArray[index][@"source"] isEqualToString: @"liveramp.com"]){
                        XCTAssertEqualObjects(eidsArray[index][@"source"], @"liveramp.com");
                        XCTAssertEqualObjects(eidsArray[index][@"id"], @"AjfowMv4ZHZQJFM8TpiUnYEyA81Vdgg");
                        [liveRampExpectation fulfill];
                    }
                    
                    if([eidsArray[index][@"source"] isEqualToString: @"adserver.org"]){
                        XCTAssertEqualObjects(eidsArray[index][@"source"], @"adserver.org");
                        XCTAssertEqualObjects(eidsArray[index][@"id"], @"00000111-91b1-49b2-ae37-17a8173dc36f");
                        XCTAssertEqualObjects(eidsArray[index][@"rti_partner"], @"TDID");
                        [tradeDeskExpectation fulfill];
                    }
                    
                    if([eidsArray[index][@"source"] isEqualToString: @"uidapi.com"]){
                        XCTAssertEqualObjects(eidsArray[index][@"source"], @"uidapi.com");
                        XCTAssertEqualObjects(eidsArray[index][@"id"], @"uid2_3948249329482ok");
                        XCTAssertEqualObjects(eidsArray[index][@"rti_partner"], @"UID2");
                        [uid2Expectation fulfill];
                    }
                    if([eidsArray[index][@"source"] isEqualToString: @"string-source-foo-bar-2"]){
                        XCTAssertEqualObjects(eidsArray[index][@"source"], @"string-source-foo-bar-2");
                        XCTAssertEqualObjects(eidsArray[index][@"id"], @"temp_user_id-foo-bar-2");
                        [customSourceExpectation fulfill];
                    }
                }
    }
        

    });
    
    [self waitForExpectationsWithTimeout:UTMODULETESTS_TIMEOUT handler:nil];
    
}




- (void)testUTRequestDoNotTrackYES
{
    
    ANSDKSettings.sharedInstance.doNotTrack = YES; // This value should be seen as true in UT Request body
    TestANUniversalFetcher  *adFetcher      = [[TestANUniversalFetcher alloc] initWithPlacementId:placementID];
    
    
    NSURLRequest            *request        = [ANUniversalTagRequestBuilder buildRequestWithAdFetcherDelegate:adFetcher.delegate];
    XCTestExpectation       *expectation    = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    XCTAssertTrue([[request.URL absoluteString] isEqualToString:@"https://ib.adnxs-simple.com/ut/v3"], @"Expected Cookieless ib.adnxs-simple.com domain when doNotTrack set to true");
    
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
        NSDictionary *userDict = jsonDict[@"user"];
        XCTAssertNotNil(userDict);
        
        BOOL dntValue = userDict[@"dnt"];
        XCTAssertTrue(dntValue);
        
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:UTMODULETESTS_TIMEOUT handler:nil];
    
}

- (void)testUTRequestDoNotTrackNO
{
    
    ANSDKSettings.sharedInstance.doNotTrack = NO; // When set to NO, dnt param should not be sent in ad request
    TestANUniversalFetcher  *adFetcher      = [[TestANUniversalFetcher alloc] initWithPlacementId:placementID];
    
    
    NSURLRequest            *request        = [ANUniversalTagRequestBuilder buildRequestWithAdFetcherDelegate:adFetcher.delegate];
    XCTestExpectation       *expectation    = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    XCTAssertTrue([[request.URL absoluteString] isEqualToString:@"https://mediation.adnxs.com/ut/v3"], @"Expected mediation.adnxs.com domain when doNotTrack is NO");
    
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
        NSDictionary *userDict = jsonDict[@"user"];
        XCTAssertNotNil(userDict);
        
        XCTAssertFalse([userDict objectForKey:@"dnt"]);
        
        
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:UTMODULETESTS_TIMEOUT handler:nil];
    
}

/**
 Tests  DSA Params
 */
- (void)testUTRequestForDSA
{
    [ANDSASettings.sharedInstance setDsaRequired: 1];
    [ANDSASettings.sharedInstance setPubRender: 0];
    [ANDSASettings.sharedInstance setDataToPub: 1];
    NSMutableArray<ANDSATransparencyInfo *> *transparencyList = [NSMutableArray array];
    [transparencyList addObject:[[ANDSATransparencyInfo alloc] initWithDomain:@"example.com" andDSAParams:@[@1, @2, @3]]];
    [transparencyList addObject:[[ANDSATransparencyInfo alloc] initWithDomain:@"example.net" andDSAParams:@[@4, @5, @6]]];
    [ANDSASettings.sharedInstance setTransparencyList: transparencyList];
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
        NSDictionary *requestDSADict = jsonDict[@"dsa"];
        XCTAssertNotNil(requestDSADict);
        XCTAssertEqual([requestDSADict[@"dsarequired"] intValue], 1);
        XCTAssertEqual([requestDSADict[@"pubrender"] intValue], 0);
        XCTAssertEqual([requestDSADict[@"datatopub"] intValue], 1);
        NSArray *transparencyArray = requestDSADict[@"transparency"];
        NSMutableArray *expectedList = [NSMutableArray array];
        for (NSUInteger i = 0; i < transparencyList.count; i++) {
            ANDSATransparencyInfo *transparencyInfo = transparencyList[i];
            NSDictionary *jsonObject = @{@"domain": transparencyInfo.domain, @"dsaparams": transparencyInfo.dsaparams};
            [expectedList addObject:jsonObject];
        }
        XCTAssertEqualObjects(expectedList, transparencyArray);

        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:UTMODULETESTS_TIMEOUT handler:nil];
}


@end
