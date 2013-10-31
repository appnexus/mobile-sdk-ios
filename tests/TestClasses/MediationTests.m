/*   Copyright 2013 APPNEXUS INC
 
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

#import "MediationTests.h"
#import "ANAdFetcher.h"
#import "ANAdResponse.h"
#import "ANAdAdapterErrorCode.h"
#import <iAd/iAd.h>
#import "ANAdWebViewController.h"
#import "ANMediationAdViewController.h"

// These URLs will be deprecrated
#define APPNEXUS_TEST_HOST @"http://rlissack.adnxs.net:8080/"
#define APPNEXUS_TEST_MOBCALL_WITH_ID(x) [APPNEXUS_TEST_HOST stringByAppendingPathComponent:[NSString stringWithFormat:@"/mobile/utest?id=%@", x]]

#define iAdBannerClassName @"ANAdAdapterBanneriAd"
#define AdMobBannerClassName @"ANAdAdapterBannerAdMob"
#define MMBannerClassName @"ANAdAdapterBannerMillennialMedia"


@interface ANAdFetcher ()
- (void)processResponseData:(NSData *)data;
- (ANMediationAdViewController *)mediationController;
- (ANAdWebViewController *)webViewController;
@end

@interface ANMediationAdViewController ()
- (id)currentAdapter;
@end

@interface MediationTests () <ANAdFetcherDelegate>
{
    BOOL __testComplete;
    NSUInteger __testNumber;
}

@end

@implementation MediationTests
@synthesize placementId = __placementId;
@synthesize shouldServePublicServiceAnnouncements = __shouldServePublicServiceAnnouncements;
@synthesize location = __location;
@synthesize reserve = __reserve;
@synthesize age = __age;
@synthesize gender = __gender;
@synthesize customKeywords = __customKeywords;

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)runBasicTest:(int)testNumber
{
    __testNumber = testNumber;
    __testComplete = NO;
    
    ANAdFetcher *fetcher = [ANAdFetcher new];
    fetcher.delegate = self;
    [fetcher requestAdWithURL:[NSURL URLWithString:APPNEXUS_TEST_MOBCALL_WITH_ID([@(testNumber) stringValue])]];
	
    STAssertTrue([self waitForCompletion:10.0], @"Failed to receive response from server. Test failing.");
}

- (void)test1ResponseWhereClassExists
{
    [self runBasicTest:1];
}

- (void)test2ResponseWhereClassDoesNotExist
{
    [self runBasicTest:2];
}

- (void)test3ResponseWhereClassCannotInstantiate
{
    [self runBasicTest:3];
}

- (void)test4ResponseWhereClassInstantiatesAndDoesNotRequestAd
{
    [self runBasicTest:4];
}

- (void)test6AdWithNoFill
{
    [self runBasicTest:6];
}

- (void)test7TwoSuccessfulResponses
{
    [self runBasicTest:7];
}

#pragma mark MediationWaterfall tests

- (void)test11FirstSuccessfulSkipSecond
{
    [self runBasicTest:11];
}

- (void)test12SkipFirstSuccessfulSecond
{
    [self runBasicTest:12];
}

- (void)test13FirstFailsIntoOverrideStd
{
    [self runBasicTest:13];
}

- (void)test14FirstFailsIntoOverrideMediated
{
    [self runBasicTest:14];
}

- (void)test15TestNoFill
{
    [self runBasicTest:15];
}

- (void)test16NoResultCB
{
    [self runBasicTest:16];
}


- (BOOL)waitForCompletion:(NSTimeInterval)timeoutSecs
{
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeoutSecs];
    
    do
    {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
        if ([timeoutDate timeIntervalSinceNow] < 0.0)
        {
            break;
        }
    }
	
    while (!__testComplete);
    
    return __testComplete;
}

- (void)checkErrorCode:(ANAdFetcher *)fetcher expectedError:(ANAdResponseCode)error{
    id adapter = [[fetcher mediationController] currentAdapter];
    STAssertTrue([adapter isKindOfClass:[ANAdAdapterErrorCode class]],
                 @"Expected an adapter of type ANAdAdapterErrorCode.");
    
    ANAdAdapterErrorCode *bannerAdapter = (ANAdAdapterErrorCode *)adapter;
    int codeNumber = [[bannerAdapter errorId] intValue];
    
    STAssertTrue(codeNumber == error,
                 [NSString stringWithFormat:@"Expected error value %d.", error]);
}

- (void)checkClass:(NSString *)className adapter:(id)adapter{
    BOOL result;
    Class adClass = NSClassFromString(className);
    if (!adClass) {
        result = NO;
    }
    else {
        result = [adapter isKindOfClass:adClass];
    }
    
    STAssertTrue(result, [NSString stringWithFormat:@"Expected an adapter of class %@.", className]);
}

#pragma mark ANAdFetcherDelegate
- (void)adFetcher:(ANAdFetcher *)fetcher didFinishRequestWithResponse:(ANAdResponse *)response
{
	if (!__testComplete)
	{
		switch (__testNumber)
		{
			case 1:
			{
				__testComplete = YES;
                
				id adapter = [[fetcher mediationController] currentAdapter];
                [self checkClass:iAdBannerClassName adapter:adapter];
			}
				break;
                
			case 2:
			{
				__testComplete = YES;
                [self checkErrorCode:fetcher expectedError:ANAdResponseMediatedSDKUnavailable];
			}
				break;
			case 3:
			{
				__testComplete = YES;
                [self checkErrorCode:fetcher expectedError:ANAdResponseMediatedSDKUnavailable];
			}
				break;
			case 4:
			{
				__testComplete = YES;
                [self checkErrorCode:fetcher expectedError:ANAdResponseNetworkError];
			}
				break;
			case 6:
			{
				__testComplete = YES;
                [self checkErrorCode:fetcher expectedError:ANAdResponseUnableToFill];
			}
				break;
			case 7:
			{
				// Change the test number to 70 to denote the "part 2" of this 2-step unit test
				__testNumber = 70;
				
				id adapter = [[fetcher mediationController] currentAdapter];
                
                [self checkClass:MMBannerClassName adapter:adapter];
				
				[fetcher requestAdWithURL:[NSURL URLWithString:[adapter responseURLString]]];
			}
				break;
                //this second part test should be for a non-mediated ad..
			case 70:
			{
				__testComplete = YES;
				
				id adapter = [[fetcher mediationController] currentAdapter];
                STAssertNil(adapter, @"Expected nil adapter");
                
                id viewController = [fetcher webViewController];
                STAssertNotNil(viewController, @"Expected webViewController to be non-nil");
			}
				break;
			case 11:
			{
				__testComplete = YES;
                
				id adapter = [[fetcher mediationController] currentAdapter];
                [self checkClass:MMBannerClassName adapter:adapter];
			}
				break;
			case 12:
			{
				__testComplete = YES;
                
				id adapter = [[fetcher mediationController] currentAdapter];
                [self checkClass:MMBannerClassName adapter:adapter];
			}
				break;
			case 13:
			{
                __testComplete = YES;
                
				id adapter = [[fetcher mediationController] currentAdapter];
                STAssertNil(adapter, @"Expected nil adapter");
                
                id viewController = [fetcher webViewController];
                STAssertNotNil(viewController, @"Expected webViewController to be non-nil");
			}
				break;
			case 14:
			{
				__testComplete = YES;
                
				id adapter = [[fetcher mediationController] currentAdapter];
                [self checkClass:MMBannerClassName adapter:adapter];
			}
				break;
			case 15:
			{
				__testComplete = YES;
                
				NSError *error = [response error];
				STAssertTrue([error code] == ANAdResponseUnableToFill, @"Expected ANAdResponseUnableToFill error.");
			}
				break;
			case 16:
			{
				__testComplete = YES;
                
				id adapter = [[fetcher mediationController] currentAdapter];
                [self checkClass:iAdBannerClassName adapter:adapter];
			}
				break;
			default:
				break;
		}
	}
}

- (NSTimeInterval)autorefreshIntervalForAdFetcher:(ANAdFetcher *)fetcher
{
	return 0.0;
}

- (CGSize)requestedSizeForAdFetcher:(ANAdFetcher *)fetcher {
    return CGSizeMake(320, 50);
}

- (ANLocation *)location {
    return nil;
}

- (void) adWillPresent {};
- (void) adWillClose {}
- (void) adDidClose {};
- (void) adWillLeaveApplication {}

@end
