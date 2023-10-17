/*   Copyright 2019 APPNEXUS INC
 
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

#import "TestGlobal.h"

#import "ANUniversalTagAdServerResponse.h"
#import "XCTestCase+ANCategory.h"
#import "ANNativeStandardAdResponse.h"
#import "ANMediatedAd.h"
#import "ANNativeAdResponse+PrivateMethods.h"

@interface ANVerificationScriptResourceTestCase : XCTestCase

@end

@implementation ANVerificationScriptResourceTestCase

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testRTBNativeResponseForViewabilityObject
{
    NSMutableArray<id>  *adsArray  = [TestGlobal adsArrayFromFirstTagInReponseData:[self dataWithJSONResource:@"OMID_Native_RTBResponse"]];
    XCTAssertTrue([adsArray count] > 0);
    
    ANNativeStandardAdResponse  *nativeAd  = (ANNativeStandardAdResponse *)adsArray[0];
    XCTAssertNotNil(nativeAd);
    XCTAssertNotNil(nativeAd.verificationScriptResource);
    XCTAssertNotNil(nativeAd.verificationScriptResource.url);
    XCTAssertNotNil(nativeAd.verificationScriptResource.params);
    XCTAssertNotNil(nativeAd.verificationScriptResource.vendorKey);
    XCTAssertEqualObjects(nativeAd.verificationScriptResource.url, @"https://cdn.adnxs.com/v/s/160/trk.js");
    XCTAssertEqualObjects(nativeAd.verificationScriptResource.vendorKey, @"appnexus.com-omid");
    XCTAssertEqualObjects(nativeAd.verificationScriptResource.params, @"v;vk=appnexus.com-omid;tv=native1-18h;dom_id=%native_dom_id%;st=2;d=1x1;vc=iab;vid_ccr=1;ab=10;cid=1;tag_id=13255429;cb=http%3A%2F%2Fsin1-mobile.adnxs.com%2Fvevent%3Freferrer%3Ditunes.apple.com%252Fus%252Fapp%252Fappnexus-sdk-app%252Fid736869833%26e%3DwqT_3QLTCKBTBAAAAwDWAAUBCI79reQFEPOdyJjM7L-pHBiK9rXIxs6lnlIqNgkAAAECCBRAEQEHNAAAFEAZAAAA4HoUFEAhERIAKREJADERG6AwhYapBji-B0C-B0gCUMDY7C5Yy7tOYABokUB4qf0EgAEBigEDVVNEkgUG8GaYAQGgAQGoAQGwAQC4AQHAAQTIAQLQAQDYAQDgAQDwAQD6ARJ1bml2ZXJzYWxQbGFjZW1lbnSKAjt1ZignYScsIDE3OTc4NjUsIDE1NTI2NDU3NzQpO3VmKCdyJywgOTgyNDk3OTIsMh4A8JCSAvkBIVNqbTNJd2o5Njk0TEVNRFk3QzRZQUNETHUwNHdBRGdBUUFSSXZnZFFoWWFwQmxnQVlPSUhhQUJ3TW5pc3JnR0FBVEtJQWF5dUFaQUJBWmdCQWFBQkFhZ0JBN0FCQUxrQjg2MXFwQUFBRkVEQkFmT3RhcVFBQUJSQXlRRWFQY1U4QVpIeFA5a0JBQUFBAQMkOERfZ0FRRDFBUQEOQENZQWdDZ0F2X19fXzhQdFFJARUEQXYNCHx3QUlBeUFJQTRBSUE2QUlBLUFJQWdBTUJtQU1CcUFQOQHUgHVnTUpVMGxPTVRvek5UZzA0QVBXQ0EuLpoCYSFCUTVybDr8ACh5N3RPSUFRb0FERQVsGEFBQVVRRG8yRAAQUU5ZSVMFoBhBQUFQQV9VEQwMQUFBVx0MiNgC6AfgAsfTAeoCNGl0dW5lcy5hcHBsZS5jb20vdXMvYXBwAQQkbmV4dXMtc2RrLQERXGlkNzM2ODY5ODMz8gIRCgZBRFZfSUQSBy3hBRQIQ1BHBRQYNjU0NTc0OQEUCAVDUAETZAgyNDYyMjU4OfICEwoPQ1VTVE9NX01PREVMAR4UAPICGgoWMhYAIExFQUZfTkFNRQEdCB4KGjYdAAhBU1QBPvC0SUZJRUQSAIADAYgDAZADAJgDF6ADAaoDAMAD4KgByAMA0gMoCAASJDJhYjBkNmIwLWY1NTYtNGY1NC1iMzY3LWU0YzE5MDZlMzgxZtgD-aN64AMA6AMC-AMAgAQAkgQGL3V0L3YzmAQAogQLMTAuMTQuMTIuMTWoBI7sAbIEDAgAEAEYACAAMAA4ArgEAMAEAMgEANIEDTk1OCNTSU4xOjM1ODTaBAIIAeAEAfAEwNjsLoIFCTVHIIgFAZgFAKAF_xEBFAHABQDJBWmyFPA_0gUJCQkMcAAA2AUB4AUB8AUB-gUECAAQAJAGAZgGALgGAMEGCSMk8D_IBgDaBhYKEAkQGQEYEAAYAOAGDA..%26s%3D7ce10a2c54e33c67be60fe5ccbaabed1a37c6b4d;ts=1552645774;cet=0;cecb=");
}

- (void)testCSMNativeResponseForViewabilityObject
{
    NSMutableArray<id>  *adsArray  = [TestGlobal adsArrayFromFirstTagInReponseData:[self dataWithJSONResource:@"OMID_Native_CSMResponse"]];
    XCTAssertTrue([adsArray count] > 0);
    
    ANMediatedAd *mediatedAd = [adsArray objectAtIndex:0];
    XCTAssertNotNil(mediatedAd);
    XCTAssertNotNil(mediatedAd.verificationScriptResource);
    XCTAssertNotNil(mediatedAd.verificationScriptResource.url);
    XCTAssertNotNil(mediatedAd.verificationScriptResource.params);
    XCTAssertNotNil(mediatedAd.verificationScriptResource.vendorKey);
    XCTAssertEqualObjects(mediatedAd.verificationScriptResource.url, @"https://cdn.adnxs.com/v/s/160/trk.js");
    XCTAssertEqualObjects(mediatedAd.verificationScriptResource.vendorKey, @"appnexus.com-omid");
    XCTAssertEqualObjects(mediatedAd.verificationScriptResource.params, @"v;vk=appnexus.com-omid;tv=native1-18h;dom_id=%native_dom_id%;st=2;d=1x1;vc=iab;vid_ccr=1;ab=10;cid=1;tag_id=15378891;cb=http%3A%2F%2Fsin1-mobile.adnxs.com%2Fvevent%3Freferrer%3Ditunes.apple.com%252Fus%252Fapp%252Fappnexus-sdk-app%252Fid736869833%26e%3DwqT_3QK9COg9BAAAAwDWAAUBCKLyreQFEOz37tjJhdrAQRiK9rXIxs6lnlIqNgn5wmSqYFSSPxH5wmSqYFSSPxkAAAkCACERGwApEQkAMQkZqAAAMMvTqgc4vgdAvgdIAlDuhJFHWKfIYGAAaJFAeOGjBYABAYoBA1VTRJIFBvA-mAEBoAEBqAEGsAEAuAEAwAEEyAEC0AEA2AEA4AEA8AEAigI7dWYoJ2EnLCA0NzQxODQsIDE1NTI2NDQzODYpBRw0cicsIDE0OTE3Njk0MiwyHwDwjZIC9QEhQmo3Q1pBajR3NmtORU82RWtVY1lBQ0NueUdBd0FEZ0FRQU5JdmdkUXk5T3FCMWdBWU9JSGFBQndJbmpvRjRBQkpvZ0I2QmVRQVFHWUFRR2dBUUdvQVFPd0FRQzVBY3U1TUxKVFZKSV93UUhMdVRDeVUxU1NQOGtCRlBiNjJzR2pfRF9aQVFBQUEBA1hQQV80QUVBOVFHWm9wSThtQUlBb0FMXwEBDEQ3VUMBIwhBTDAJCPBETUFDQU1nQ0FPQUNBT2dDQVBnQ0FJQURBWmdEQWFnRC1NT3BEYm9EQ1ZOSlRqRTZNelU0T2VBRDFnZy6aAmEhaWhDb19BNvgAqHA4aGdJQU1vQURGN0ZLNUg0WHFFUHpvSlUwbE9NVG96TlRnNVFOWUlTUUEFiwGwAFURDAxBQUFXHQyI2ALoB-ACx9MB6gI0aXR1bmVzLmFwcGxlLmNvbS91cy9hcHABBCRuZXh1cy1zZGstARFgaWQ3MzY4Njk4MzPyAhAKBkFEVl9JRBIGNCXdHPICEQoGQ1BHARM4Bzc1NDUxNzbyAhEKBUNQARNkCDI3OTQzNDE28gITCg9DVVNUT01fTU9ERUwBHhQA8gIaChYyFgAgTEVBRl9OQU1FAR0IHgoaNh0ACEFTVAE-8LdJRklFRBIAgAMBiAMBkAMAmAMXoAMBqgMAwAPgqAHIAwHSAygIABIkMmFiMGQ2YjAtZjU1Ni00ZjU0LWIzNjctZTRjMTkwNmUzODFm2AP5o3rgAwDoAwL4AwCABACSBAYvdXQvdjOYBACiBAsxMC4xNC4xMi4xNagE9-sBsgQOCAAQARgAIAAoADAAOAK4BADABADIBADSBA05NTgjU0lOMTozNTg52gQCCAHgBADwBO6EkUeCBQk3MUggiAUBmAUAoAX_EQEUAcAFAMkFaZEU8D_SBQkJCQx4AADYBQHgBQHwBdyKBfoFBAgAEACQBgGYBgC4BgDBBgklJPA_yAYA2gYWChAJEBkBGBAAGADgBgw.%26s%3D1441abda1cd0730bbd68495c6c276653804e2f28;ts=1552644386;cet=0;cecb=");
}

@end
