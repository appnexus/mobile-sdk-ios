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
#import "ANSuccessfulBannerNeverCalled.h"

static NSString *const kANSuccessfulBanner = @"ANSuccessfulBanner";
static NSString *const kANAdAdapterBannerDummy = @"ANAdAdapterBannerDummy";
static NSString *const kANAdAdapterBannerNoAds = @"ANAdAdapterBannerNoAds";
static NSString *const kANAdAdapterBannerRequestFail = @"ANAdAdapterBannerRequestFail";
static NSString *const kANAdAdapterErrorCode = @"ANAdAdapterErrorCode";
static NSString *const kClassDoesNotExist = @"ClassDoesNotExist";
static NSString *const kANSuccessfulBannerNeverCalled = @"ANSuccessfulBannerNeverCalled";

@interface FetcherHelper : ANBannerAdView
@property (nonatomic, assign) BOOL testComplete;
@property (nonatomic, strong) ANAdFetcher *fetcher;
@property (nonatomic, strong) id adapter;
@property (nonatomic, strong) ANMRAIDAdWebViewController *webViewController;
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
- (ANMRAIDAdWebViewController *)webViewController;
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

- (void)clearTest {
    [super clearTest];
    [ANSuccessfulBannerNeverCalled setCalled:NO];
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

- (void)checkSuccessfulBannerNeverCalled {
    STAssertFalse([ANSuccessfulBannerNeverCalled getCalled], @"Should never be called");
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
            [self checkClass:kANSuccessfulBanner adapter:adapter];
        }
            break;
        case 12:
        {
            [self checkClass:kANSuccessfulBanner adapter:adapter];
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
            [self checkClass:kANSuccessfulBanner adapter:adapter];
        }
            break;
        case 15:
        {
            STAssertTrue([[self.helper ANError] code] == ANAdResponseUnableToFill, @"Expected ANAdResponseUnableToFill error.");
        }
            break;
        case 16:
        {
            [self checkClass:kANSuccessfulBanner adapter:adapter];
        }
            break;
        default:
            break;
    }
    [self checkSuccessfulBannerNeverCalled];
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
    [self stubWithBody:[ANTestResponses createMediatedBanner:kClassDoesNotExist]];
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
    [self stubWithBody:[ANTestResponses mediationWaterfallBanners:kANSuccessfulBanner
                                                      secondClass:kANSuccessfulBannerNeverCalled]];
    [self stubResultCBResponses:@""];
    [self runBasicTest:11];
}

- (void)test12SkipFirstSuccessfulSecond
{
    [self stubWithBody:[ANTestResponses mediationWaterfallBanners:kClassDoesNotExist
                                                      secondClass:kANSuccessfulBanner]];
    [self stubResultCBResponses:@""];
    [self runBasicTest:12];
}

- (void)test13FirstFailsIntoOverrideStd
{
    [self stubWithBody:[ANTestResponses mediationWaterfallBanners:kClassDoesNotExist
                                                      secondClass:kANSuccessfulBannerNeverCalled]];
    [self stubResultCBResponses:[ANTestResponses successfulBanner]];
    [self runBasicTest:13];
}

- (void)test14FirstFailsIntoOverrideMediated
{
    [self stubWithBody:[ANTestResponses mediationWaterfallBanners:kClassDoesNotExist
                                                      secondClass:kANSuccessfulBannerNeverCalled]];
    [self stubResultCBResponses:[ANTestResponses mediationSuccessfulBanner]];
    [self runBasicTest:14];
}

- (void)test15TestNoFill
{
    [self stubWithBody:[ANTestResponses createMediatedBanner:kClassDoesNotExist]];
    [self stubResultCBResponses:[ANTestResponses createMediatedBanner:kClassDoesNotExist withID:@"" withResultCB:@""]];
    [self runBasicTest:15];
}

- (void)test16NoResultCB
{
    NSString *response = [ANTestResponses mediationWaterfallBanners:kClassDoesNotExist firstResult:@""
                                   secondClass:kClassDoesNotExist secondResult:nil
                                    thirdClass:kANSuccessfulBanner thirdResult:@""];
    [self stubWithBody:response];
    [self stubResultCBResponses:@""];
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
        __successResultRequest = [__fetcher successResultRequest];
        __request = [__fetcher request];
        
		switch (__testNumber)
		{
			case 7:
			{
				self.adapter = [[fetcher mediationController] currentAdapter];
				[fetcher requestAdWithURL:
                 [NSURL URLWithString:[[fetcher mediationController] resultCBString]]];
			}
				break;
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

        // test case 7 is a special two-part test, so we handle it specially
        if (__testNumber != 7) {
            NSLog(@"test complete");
            __testComplete = YES;
        } else {
            // Change the test number to 70 to denote the "part 2" of this 2-step unit test
            __testNumber = 70;
        }
	}
}

- (NSTimeInterval)autoRefreshIntervalForAdFetcher:(ANAdFetcher *)fetcher {
	return 0.0;
}

- (CGSize)requestedSizeForAdFetcher:(ANAdFetcher *)fetcher {
    return CGSizeMake(320, 50);
}

- (void)adFetcher:(ANAdFetcher *)fetcher adShouldOpenInBrowserWithURL:(NSURL *)URL {};

#pragma mark ANBrowserViewControllerDelegate

- (void)browserViewControllerShouldDismiss:(ANBrowserViewController *)controller{};
- (void)browserViewControllerShouldPresent:(ANBrowserViewController *)controller{};
- (void)browserViewControllerWillLaunchExternalApplication{};
- (void)browserViewControllerWillNotPresent:(ANBrowserViewController *)controller{};

#pragma mark ANAdViewDelegate

- (void)adWasClicked{};
- (void)adWillPresent{};
- (void)adDidPresent{};
- (void)adWillClose{};
- (void)adDidClose{};
- (void)adWillLeaveApplication{};
- (void)adFailedToDisplay{};
- (void)adDidReceiveAppEvent:(NSString *)name withData:(NSString *)data{};

#pragma mark ANMRAIDAdViewDelegate

- (NSString *)adType{
    return nil;
};

- (UIViewController *)displayController{
    return nil;
};

- (void)adShouldResetToDefault{};
- (void)adShouldExpandToFrame:(CGRect)frame closeButton:(UIButton *)closeButton{};
- (void)adShouldResizeToFrame:(CGRect)frame allowOffscreen:(BOOL)allowOffscreen
                  closeButton:(UIButton *)closeButton
                closePosition:(ANMRAIDCustomClosePosition)closePosition{};
- (void)allowOrientationChange:(BOOL)allowOrientationChange
         withForcedOrientation:(ANMRAIDOrientation)orientation{};

# pragma mark ANAppEventDelegate

- (void)ad:(id<ANAdProtocol>)ad
didReceiveAppEvent:(NSString *)name withData:(NSString *)data{};

@end
