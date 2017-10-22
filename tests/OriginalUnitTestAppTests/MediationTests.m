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
#import "ANUniversalAdFetcher.h"
#import "ANMediatedAd.h"
#import "ANMRAIDContainerView.h"
#import "ANMediationAdViewController.h"
#import "ANMockMediationAdapterBannerNeverCalled.h"
#import "ANBrowserViewController.h"




static NSString *const kANMockMediationAdapterSuccessfulBanner   = @"ANMockMediationAdapterSuccessfulBanner";
static NSString *const kANAdAdapterBannerDummy                   = @"ANAdAdapterBannerDummy";
static NSString *const kANAdAdapterBannerNoAds                   = @"ANAdAdapterBannerNoAds";
static NSString *const kANAdAdapterBannerRequestFail             = @"ANAdAdapterBannerRequestFail";
static NSString *const kANAdAdapterErrorCode                     = @"ANAdAdapterErrorCode";
static NSString *const kMediationAdapterClassDoesNotExist                        = @"MediationAdapterClassDoesNotExist";
static NSString *const kANMockMediationAdapterBannerNeverCalled  = @"ANMockMediationAdapterBannerNeverCalled";




@interface FetcherHelper : ANBannerAdView

@property (nonatomic, assign) BOOL testComplete;
@property (nonatomic, strong) ANUniversalAdFetcher *fetcher;
@property (nonatomic, strong) id adapter;
@property (nonatomic, strong) NSError *ANError;
@property (nonatomic, strong) ANMRAIDContainerView *standardAdView;
//@property (nonatomic, strong) NSMutableURLRequest *successResultRequest;
@property (nonatomic, strong) NSMutableURLRequest *request;

- (id)runTestForAdapter:(int)testNumber
                   time:(NSTimeInterval)time;
@end

@interface FetcherHelper () <ANUniversalAdFetcherDelegate>
{
    NSUInteger __testNumber;
}
@end

@interface ANUniversalAdFetcher ()
- (void)processResponseData:(NSData *)data;
- (ANMediationAdViewController *)mediationController;
- (ANMRAIDContainerView *)standardAdView;
//- (NSMutableURLRequest *)successResultRequest;
- (NSMutableURLRequest *)request;
@end

@interface ANMediationAdViewController ()
- (id)currentAdapter;
- (ANMediatedAd *)mediatedAd;
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
    [ANMockMediationAdapterBannerNeverCalled setCalled:NO];
}

- (void)runBasicTest:(int)testNumber {
    id adapter = [self.helper runTestForAdapter:testNumber time:15.0];
    
    XCTAssertTrue([self.helper testComplete], @"Test timed out");
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
    
    XCTAssertTrue(result, @"Expected an adapter of class %@", className);
}

//- (void)checkSuccessResultCB:(int)code {
//    NSString *resultCBString =[[self.helper successResultRequest].URL absoluteString];
//    NSString *resultCBPrefix = [NSString stringWithFormat:@"%@?reason=%i", OK_RESULT_CB_URL, code];
//    STAssertTrue([resultCBString hasPrefix:resultCBPrefix], @"ResultCB should match");
//}

- (void)checkLastRequest:(int)code {
    NSString *resultCBString =[[self.helper request].URL absoluteString];
    NSString *resultCBPrefix = [NSString stringWithFormat:@"%@?reason=%i", OK_RESULT_CB_URL, code];
    XCTAssertTrue([resultCBString hasPrefix:resultCBPrefix], @"ResultCB should match");
}

- (void)checkSuccessfulBannerNeverCalled {
    XCTAssertFalse([ANMockMediationAdapterBannerNeverCalled getCalled], @"Should never be called");
}

- (void)runChecks:(int)testNumber adapter:(id)adapter
{
LOGMARKM(@"testNumber=%@", @(testNumber));
    switch (testNumber)
    {
        case 1:
        {
            [self checkClass:kANMockMediationAdapterSuccessfulBanner adapter:adapter];
//            [self checkSuccessResultCB:ANAdResponseSuccessful];
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
            [self checkClass:kANMockMediationAdapterSuccessfulBanner adapter:adapter];
            XCTAssertNotNil(self.helper.standardAdView, @"Expected webView to be non-nil");
        }
            break;
        case 11:
        {
            [self checkClass:kANMockMediationAdapterSuccessfulBanner adapter:adapter];
        }
            break;
        case 12:
        {
            [self checkClass:kANMockMediationAdapterSuccessfulBanner adapter:adapter];
        }
            break;
        case 13:
        {
            XCTAssertNil(adapter, @"Expected nil adapter");
            XCTAssertNotNil(self.helper.standardAdView, @"Expected webView to be non-nil");
        }
            break;
        case 14:
        {
            [self checkClass:kANMockMediationAdapterSuccessfulBanner adapter:adapter];
        }
            break;
        case 15:
        {
            XCTAssertTrue([[self.helper ANError] code] == ANAdResponseUnableToFill, @"Expected ANAdResponseUnableToFill error.");
        }
            break;
        case 16:
        {
            [self checkClass:kANMockMediationAdapterSuccessfulBanner adapter:adapter];
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
    [self stubWithBody:[ANTestResponses createMediatedBanner:kANMockMediationAdapterSuccessfulBanner]];
    [self stubResultCBForErrorCode];
    [self runBasicTest:1];
}

- (void)test2ResponseWhereMediationAdapterClassDoesNotExist
{
    [self stubWithBody:[ANTestResponses createMediatedBanner:kMediationAdapterClassDoesNotExist]];
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
    [self stubWithBody:[ANTestResponses createMediatedBanner:kANMockMediationAdapterSuccessfulBanner]];
    [self stubResultCBResponses:[ANTestResponses successfulBanner]];
    [self runBasicTest:7];
}

#pragma mark MediationWaterfall tests

- (void)test11FirstSuccessfulSkipSecond
{
    [self stubWithBody:[ANTestResponses mediationWaterfallBanners:kANMockMediationAdapterSuccessfulBanner
                                                      secondClass:kANMockMediationAdapterBannerNeverCalled]];
    [self stubResultCBResponses:@""];
    [self runBasicTest:11];
}

- (void)test12SkipFirstSuccessfulSecond
{
    [self stubWithBody:[ANTestResponses mediationWaterfallBanners:kMediationAdapterClassDoesNotExist
                                                      secondClass:kANMockMediationAdapterSuccessfulBanner]];
    [self stubResultCBResponses:@""];
    [self runBasicTest:12];
}

// no longer applicable
//- (void)test13FirstFailsIntoOverrideStd
//{
//    [self stubWithBody:[ANTestResponses mediationWaterfallBanners:kMediationAdapterClassDoesNotExist
//                                                      secondClass:kANMockMediationAdapterBannerNeverCalled]];
//    [self stubResultCBResponses:[ANTestResponses successfulBanner]];
//    [self runBasicTest:13];
//}

// no longer applicable
//- (void)test14FirstFailsIntoOverrideMediated
//{
//    [self stubWithBody:[ANTestResponses mediationWaterfallBanners:kMediationAdapterClassDoesNotExist
//                                                      secondClass:kANMockMediationAdapterBannerNeverCalled]];
//    [self stubResultCBResponses:[ANTestResponses mediationSuccessfulBanner]];
//    [self runBasicTest:14];
//}

- (void)test15TestNoFill
{
    [self stubWithBody:[ANTestResponses createMediatedBanner:kMediationAdapterClassDoesNotExist]];
    [self stubResultCBResponses:[ANTestResponses createMediatedBanner:kMediationAdapterClassDoesNotExist withID:@"" withResultCB:@""]];
    [self runBasicTest:15];
}

- (void)test16NoResultCB
{
    NSString *response = [ANTestResponses mediationWaterfallBanners:kMediationAdapterClassDoesNotExist firstResult:@""
                                   secondClass:kMediationAdapterClassDoesNotExist secondResult:nil
                                    thirdClass:kANMockMediationAdapterSuccessfulBanner thirdResult:@""];
    [self stubWithBody:response];
    [self stubResultCBResponses:@""];
    
    [self runBasicTest:16];
}

@end

#pragma mark FetcherHelper

@implementation FetcherHelper
                    //FIX -- remove warnings?

@synthesize testComplete = __testComplete;
@synthesize fetcher = __fetcher;
@synthesize adapter = __adapter;
@synthesize standardAdView = __standardAdView;
@synthesize ANError = __ANError;
//@synthesize successResultRequest = __successResultRequest;
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
    
    __fetcher = [[ANUniversalAdFetcher alloc] initWithDelegate:self];
    [__fetcher requestAd];
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




#pragma mark - ANAdFetcherDelegate

- (void)adFetcher:(ANUniversalAdFetcher *)fetcher didFinishRequestWithResponse:(ANAdFetcherResponse *)response
{
	if (!__testComplete)
	{
//        __successResultRequest = [__fetcher successResultRequest];
        __request = [__fetcher request];
        
		switch (__testNumber)
		{
			case 7:
			{
				self.adapter = [[fetcher mediationController] currentAdapter];
                                //[fetcher requestAdWithURL:[NSURL URLWithString:[[[fetcher mediationController] mediatedAd] resultCB]]];
                                        //FIX -- repair per intent
                        }
				break;
			case 70:
			{
                                // don't set adapter here, because we want to retain the adapter from case 7
                                self.standardAdView = [fetcher standardAdView];
			}
				break;
			case 13:
			{
				self.adapter = [[fetcher mediationController] currentAdapter];
                                self.standardAdView = [fetcher standardAdView];
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

- (NSTimeInterval)autoRefreshIntervalForAdFetcher:(ANUniversalAdFetcher *)fetcher {
	return 0.0;
}

- (CGSize)requestedSizeForAdFetcher:(ANUniversalAdFetcher *)fetcher {
    return CGSizeMake(320, 50);
}

- (void)adFetcher:(ANUniversalAdFetcher *)fetcher adShouldOpenInBrowserWithURL:(NSURL *)URL {};




#pragma mark - ANBrowserViewControllerDelegate

- (void)browserViewControllerShouldDismiss:(ANBrowserViewController *)controller{};
- (void)browserViewControllerShouldPresent:(ANBrowserViewController *)controller{};
- (void)browserViewControllerWillLaunchExternalApplication{};
- (void)browserViewControllerWillNotPresent:(ANBrowserViewController *)controller{};




#pragma mark - ANAdViewInternalDelegate

- (void)adWasClicked{};
- (void)adWillPresent{};
- (void)adDidPresent{};
- (void)adWillClose{};
- (void)adDidClose{};
- (void)adWillLeaveApplication{};
- (void)adFailedToDisplay{};
- (void)adDidReceiveAppEvent:(NSString *)name withData:(NSString *)data{};
- (void)adDidReceiveAd{};
- (void)adRequestFailedWithError:(NSError *)error{};
- (void)adInteractionDidBegin{};
- (void)adInteractionDidEnd{};




#pragma mark - ANMRAIDAdViewDelegate

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
