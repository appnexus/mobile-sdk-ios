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
#import "XandrAd.h"




static NSString *const kTestUUID = @"0000-000-000-00";




@interface ANUniversalAdFetcherTests : XCTestCase<  ANAdFetcherFoundationDelegate,
                                                    ANAdProtocolBrowser, ANAdProtocolPublicServiceAnnouncement
                                                 >

    @property (nonatomic, strong) ANAdFetcher *universalAdFetcher;
    @property (nonatomic) BOOL callbackInvoked;
    @property (nonatomic, readwrite, strong, nonnull)   NSString  *utRequestUUIDString;

@end




@implementation ANUniversalAdFetcherTests

@synthesize age;
@synthesize location;
@synthesize inventoryCode;
@synthesize reserve;
@synthesize placementId;
@synthesize gender;
@synthesize shouldServePublicServiceAnnouncements;
@synthesize landingPageLoadsInBackground;
@synthesize memberId;
@synthesize customKeywords;
@synthesize publisherId;
@synthesize extInvCode;
@synthesize trafficSourceCode;



#pragma mark - Test lifecycle.

- (void)setUp {
    [super setUp];
    self.placementId = @"1281482";
    self.universalAdFetcher = [[ANAdFetcher alloc] initWithDelegate:self];
    self.callbackInvoked = NO;
    // Init here if not the tests will crash
      [[XandrAd sharedInstance] initWithMemberID:1 preCacheRequestObjects:true completionHandler:nil];

   
    
}

- (void)tearDown {
    [super tearDown];
}



#pragma mark - Test methods.

- (void)testRequestAd {
    
    [self.universalAdFetcher requestAd];
    
    XCTAssert([self waitForCompletion:10.0], @"Testing to see what happens here...");

}

- (BOOL)waitForCompletion:(NSTimeInterval)timeoutSecs {
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeoutSecs];
    
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
        if([timeoutDate timeIntervalSinceNow] < 0.0)
            break;
    } while (!self.callbackInvoked);
    
    return self.callbackInvoked;
}


- (nonnull NSString *)internalGetUTRequestUUIDString
{
    return  self.utRequestUUIDString;
}

- (void)internalUTRequestUUIDStringReset
{
     self.utRequestUUIDString = ANUUID();
}


#pragma mark - For ANUniversalRequestTagBuilderDelegate.

- (void)addCustomKeywordWithKey:(NSString *)key value:(NSString *)value {
    
}

- (void)clearCustomKeywords {
    
}

- (void)removeCustomKeywordWithKey:(NSString *)key {
    
}

- (void)setInventoryCode:(NSString *)inventoryCode memberId:(NSInteger)memberID {
    
}

- (void)setLocationWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude timestamp:(NSDate *)timestamp horizontalAccuracy:(CGFloat)horizontalAccuracy {
    
}

- (void)setLocationWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude timestamp:(NSDate *)timestamp horizontalAccuracy:(CGFloat)horizontalAccuracy precision:(NSInteger)precision {
    
}

- (NSArray<NSValue *> *)adAllowedMediaTypes {
    return nil;
}

- (NSDictionary *)internalDelegateUniversalTagSizeParameters {
    return nil;
}

- (void)adFetcher:(ANAdFetcherBase *)fetcher didFinishRequestWithResponse:(ANAdFetcherResponse *)response{
    self.callbackInvoked = YES;
}

- (void)adDidClose {
    
}

- (void)adDidPresent {
    
}

- (void)adDidReceiveAd {
    
}

- (void)adDidReceiveAppEvent:(NSString *)name withData:(NSString *)data {
    
}

- (void)adInteractionDidBegin {
    
}

- (void)adInteractionDidEnd {
    
}

- (void)adRequestFailedWithError:(NSError *)error
{

}

- (NSString *)adTypeForMRAID {
    return @"";
}

- (void)adWasClicked {
    
}

- (void)adWillClose {
    
}

- (void)adWillLeaveApplication {
    
}

- (void)adWillPresent {
    
}

- (UIViewController *)displayController {
    return nil;
}

- (BOOL)landingPageLoadsInBackground {
    return YES;
}

- (CGSize)requestedSizeForAdFetcher:(ANAdFetcher *)fetcher {
    return CGSizeMake(320, 50);
}


@end
