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

#import "ANBaseTestCase.h"
#import "ANAdFetcher.h"
#import "ANAdWebViewController.h"
#import "ANMediationAdViewController.h"

#define iAdBannerClassName @"ANAdAdapterBanneriAd"
#define AdMobBannerClassName @"ANAdAdapterBannerAdMob"
#define MMBannerClassName @"ANAdAdapterBannerMillennialMedia"

static NSString *const kANSuccessfulBanner = @"ANSuccessfulBanner";
static NSString *const kANAdAdapterBannerDummy = @"ANAdAdapterBannerDummy";
static NSString *const kANAdAdapterBannerNoAds = @"ANAdAdapterBannerNoAds";
static NSString *const kANAdAdapterBannerRequestFail = @"ANAdAdapterBannerRequestFail";
static NSString *const kANAdAdapterErrorCode = @"ANAdAdapterErrorCode";

@interface FetcherHelper : ANBannerAdView
@property (nonatomic, assign) BOOL testComplete;
@property (nonatomic, strong) ANAdFetcher *fetcher;
@property (nonatomic, strong) id adapter;
@property (nonatomic, strong) ANAdWebViewController *webViewController;
@property (nonatomic, strong) NSError *ANError;
@property (nonatomic, strong) NSMutableURLRequest *successResultRequest;
@property (nonatomic, strong) NSMutableURLRequest *request;

- (id)runTestForAdapter:(int)testNumber
                   time:(NSTimeInterval)time;
@end

@interface FetcherHelper () <ANAdFetcherDelegate>
{
    NSUInteger __testNumber;
}
@end

@interface ANAdFetcher ()
- (void)processResponseData:(NSData *)data;
- (ANMediationAdViewController *)mediationController;
- (ANAdWebViewController *)webViewController;
- (NSMutableURLRequest *)successResultRequest;
- (NSMutableURLRequest *)request;
@end

@interface ANMediationAdViewController ()
- (id)currentAdapter;
- (NSString *)resultCBString;
@end

#pragma mark MediationTests

@interface MediationTests : ANBaseTestCase
@property (nonatomic, strong) FetcherHelper *helper;
@end

@implementation MediationTests
@synthesize helper = __helper;

- (void)setUp
{
    [super setUp];
    self.helper = [FetcherHelper new];
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)runBasicTest:(int)testNumber {
    id adapter = [self.helper runTestForAdapter:testNumber time:15.0];
    
    STAssertTrue([self.helper testComplete], @"Test timed out");
    [self runChecks:testNumber adapter:adapter];
    
    [self clearTest];
}

- (void)checkErrorCode:(id)adapter expectedError:(ANAdResponseCode)error{
    [self checkClass:kANAdAdapterErrorCode adapter:adapter];
    [self checkLastRequest:error];
}

- (void)checkClass:(NSString *)className adapter:(id)adapter{
    BOOL result;
    Class adClass = NSClassFromString(className);
    if (!adClass) {
        result = NO;
    }
    else {
        result = [adapter isMemberOfClass:adClass];
    }
    
    STAssertTrue(result, [NSString stringWithFormat:@"Expected an adapter of class %@.", className]);
}

- (void)checkSuccessResultCB:(int)code {
    NSString *resultCBString =[[self.helper successResultRequest].URL absoluteString];
    NSString *resultCBPrefix = [NSString stringWithFormat:@"%@?reason=%i", OK_RESULT_CB_URL, code];
    STAssertTrue([resultCBString hasPrefix:resultCBPrefix], @"ResultCB should match");
}

- (void)checkLastRequest:(int)code {
    NSString *resultCBString =[[self.helper request].URL absoluteString];
    NSString *resultCBPrefix = [NSString stringWithFormat:@"%@?reason=%i", OK_RESULT_CB_URL, code];
    STAssertTrue([resultCBString hasPrefix:resultCBPrefix], @"ResultCB should match");
}

- (void)runChecks:(int)testNumber adapter:(id)adapter {
    switch (testNumber)
    {
        case 1:
        {
            [self checkClass:kANSuccessfulBanner adapter:adapter];
            [self checkSuccessResultCB:ANAdResponseSuccessful];
        }
            break;
            
        case 2:
        {
            [self checkErrorCode:adapter expectedError:ANAdResponseMediatedSDKUnavailable];
        }
            break;
        case 3:
        {
            [self checkErrorCode:adapter expectedError:ANAdResponseMediatedSDKUnavailable];
        }
            break;
        case 4:
        {
            [self checkErrorCode:adapter expectedError:ANAdResponseNetworkError];
        }
            break;
        case 6:
        {
            [self checkErrorCode:adapter expectedError:ANAdResponseUnableToFill];
        }
            break;
        case 7:
        {
            [self checkClass:kANSuccessfulBanner adapter:adapter];
            STAssertNotNil([self.helper webViewController], @"Expected webViewController to be non-nil");
        }
            break;
        case 11:
        {
            [self checkClass:MMBannerClassName adapter:adapter];
        }
            break;
        case 12:
        {
            [self checkClass:MMBannerClassName adapter:adapter];
        }
            break;
        case 13:
        {
            STAssertNil(adapter, @"Expected nil adapter");
            STAssertNotNil([self.helper webViewController], @"Expected webViewController to be non-nil");
        }
            break;
        case 14:
        {
            [self checkClass:MMBannerClassName adapter:adapter];
        }
            break;
        case 15:
        {
            STAssertTrue([[self.helper ANError] code] == ANAdResponseUnableToFill, @"Expected ANAdResponseUnableToFill error.");
        }
            break;
        case 16:
        {
            [self checkClass:iAdBannerClassName adapter:adapter];
        }
            break;
        default:
            break;
    }
}

#pragma mark Basic Mediation Tests

- (void)test1ResponseWhereClassExists
{
    [self stubWithBody:[ANTestResponses createMediatedBanner:kANSuccessfulBanner]];
    [self stubResultCBForErrorCode];
    [self runBasicTest:1];
}

- (void)test2ResponseWhereClassDoesNotExist
{
    [self stubWithBody:[ANTestResponses createMediatedBanner:@"ClassThatDoesNotExist"]];
    [self stubResultCBForErrorCode];
    [self runBasicTest:2];
}

- (void)test3ResponseWhereClassCannotInstantiate
{
    [self stubWithBody:[ANTestResponses createMediatedBanner:kANAdAdapterBannerDummy]];
    [self stubResultCBForErrorCode];
    [self runBasicTest:3];
}

- (void)test4ResponseWhereClassInstantiatesAndDoesNotRequestAd
{
    [self stubWithBody:[ANTestResponses createMediatedBanner:kANAdAdapterBannerRequestFail]];
    [self stubResultCBForErrorCode];
    [self runBasicTest:4];
}

- (void)test6AdWithNoFill
{
    [self stubWithBody:[ANTestResponses createMediatedBanner:kANAdAdapterBannerNoAds]];
    [self stubResultCBForErrorCode];
    [self runBasicTest:6];
}

- (void)test7TwoSuccessfulResponses
{
    [self stubWithBody:[ANTestResponses createMediatedBanner:kANSuccessfulBanner]];
    [self stubResultCBResponses:[ANTestResponses successfulBanner]];
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

@end

#pragma mark FetcherHelper

@implementation FetcherHelper
@synthesize testComplete = __testComplete;
@synthesize fetcher = __fetcher;
@synthesize adapter = __adapter;
@synthesize webViewController = __webViewController;
@synthesize ANError = __ANError;
@synthesize successResultRequest = __successResultRequest;
@synthesize request = __request;

- (id)runTestForAdapter:(int)testNumber
                   time:(NSTimeInterval)time {
    [self runBasicTest:testNumber];
    [self waitForCompletion:time];
    return __adapter;
}

- (void)runBasicTest:(int)testNumber
{
    __testNumber = testNumber;
    __testComplete = NO;
    
    __fetcher = [ANAdFetcher new];
    __fetcher.delegate = self;
    [__fetcher requestAdWithURL:[NSURL URLWithString:TEST_URL]];
}

- (BOOL)waitForCompletion:(NSTimeInterval)timeoutSecs
{
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeoutSecs];
    
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
        if ([timeoutDate timeIntervalSinceNow] < 0.0) {
            break;
        }
    }
    while (!__testComplete);
    return __testComplete;
}

#pragma mark ANAdFetcherDelegate
- (void)adFetcher:(ANAdFetcher *)fetcher didFinishRequestWithResponse:(ANAdResponse *)response
{
	if (!__testComplete)
	{
        if (__testNumber != 7) {
            NSLog(@"test complete");
            __testComplete = YES;
        }
        
        __successResultRequest = [__fetcher successResultRequest];
        __request = [__fetcher request];
        
		switch (__testNumber)
		{
			case 7:
			{
				// Change the test number to 70 to denote the "part 2" of this 2-step unit test
				__testNumber = 70;
				
				self.adapter = [[fetcher mediationController] currentAdapter];
				[fetcher requestAdWithURL:
                 [NSURL URLWithString:[[fetcher mediationController] resultCBString]]];
			}
				break;
                //this second part test should be for a non-mediated ad..
			case 70:
			{
                // don't set adapter here, because we want to retain the adapter from case 7
                self.webViewController = [fetcher webViewController];
			}
				break;
			case 13:
			{
				self.adapter = [[fetcher mediationController] currentAdapter];
                self.webViewController = [fetcher webViewController];
			}
				break;
			case 15:
			{
                self.ANError = [response error];
			}
				break;

			default:
            {
				self.adapter = [[fetcher mediationController] currentAdapter];
            }
				break;
		}
	}
}

- (NSTimeInterval)autoRefreshIntervalForAdFetcher:(ANAdFetcher *)fetcher
{
	return 0.0;
}

- (CGSize)requestedSizeForAdFetcher:(ANAdFetcher *)fetcher {
    return CGSizeMake(320, 50);
}

@end
