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




//static NSString *const kANMockMediationAdapterSuccessfulBanner   = @"ANMockMediationAdapterSuccessfulBanner";
static NSString *const kANAdAdapterBannerDummy                   = @"ANMockMediationAdapterBannerDummy";
static NSString *const kANAdAdapterBannerNoAds                   = @"ANAdAdapterBannerNoAds";
//static NSString *const kANAdAdapterBannerRequestFail             = @"ANMockMediationAdapterBannerRequestFail";
//static NSString *const kANAdAdapterErrorCode                     = @"ANMockMediationAdapterErrorCode";
static NSString *const kANMockMediationAdapterBannerNeverCalled  = @"ANMockMediationAdapterBannerNeverCalled";


float const  MEDIATION_TESTS_TIMEOUT  = 15.0;



#pragma mark - ANUniversalAdFetcher local interface.
                //FIX -- verify all methods necesary, and those missing
                //FIX -- aso wowith all other delegatesb elow.

@interface ANUniversalAdFetcher ()

//- (void)processResponseData:(NSData *)data;
- (void) processV2ResponseData:(NSData *)data;
            //FIX -- need this?

- (ANMediationAdViewController *)mediationController;

- (ANMRAIDContainerView *)standardAdView;

        /* FIX -- toss -- no longer exists
//- (NSMutableURLRequest *)successResultRequest;
- (NSMutableURLRequest *)request;
                 */

@end




#pragma mark - ANMediationAdViewController local interface.

@interface ANMediationAdViewController ()

- (id)currentAdapter;

- (ANMediatedAd *)mediatedAd;

@end




#pragma mark - ANBannerAdViewExtended

@interface ANBannerAdViewExtended : ANBannerAdView

@property (nonatomic, assign)  BOOL                      testComplete;
@property (nonatomic, strong)  ANUniversalAdFetcher     *fetcher;
@property (nonatomic, strong)  id                        adapter;
@property (nonatomic, strong)  NSError                  *anError;
@property (nonatomic, strong)  ANMRAIDContainerView     *standardAdView;

//@property (nonatomic, strong)  NSMutableURLRequest      *successResultRequest;
@property (nonatomic, strong)  NSMutableURLRequest      *request;

- (id)runTestForAdapter:(int)testNumber
                   time:(NSTimeInterval)time;
@end


@interface ANBannerAdViewExtended () <ANUniversalAdFetcherDelegate>
{
    NSUInteger __testNumber;
}
@end


@implementation ANBannerAdViewExtended
                    //FIX -- remove warnings?

@synthesize  testComplete        = __testComplete;
@synthesize  fetcher             = __fetcher;
@synthesize  adapter             = __adapter;
@synthesize  standardAdView      = __standardAdView;
@synthesize  anError             = __anError;

        /* FIX toss
//@synthesize  successResultRequest = __successResultRequest;
@synthesize  request             = __request;
        //FIX -- really need these?
                     */


- (id)runTestForAdapter: (int)testNumber
                   time: (NSTimeInterval)time
{
    [self runBasicTest:testNumber];

    [self waitForCompletion:time];
    return __adapter;
}

- (void)runBasicTest:(int)testNumber
{
    __testNumber    = testNumber;
    __testComplete  = NO;

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
    } while (!__testComplete);

    return __testComplete;
}




#pragma mark - ANUniversalAdFetcherDelegate (for ANBannerAdViewExtended)

- (void)universalAdFetcher:(ANUniversalAdFetcher *)fetcher didFinishRequestWithResponse:(ANAdFetcherResponse *)response
{
TESTTRACEM(@"__testNumber=%@", @(__testNumber));
    if (!__testComplete)
    {
        //        __successResultRequest = [__fetcher successResultRequest];
//        __request = [__fetcher requestAd];
                        //FIX -- what is this, toss? please?
//        [__fetcher requestAd];
                        //FIX - why ever would we requestAd after receiving an ad?

        switch (__testNumber)
        {
            case 7:
            {
                self.adapter = [[fetcher mediationController] currentAdapter];

//                [fetcher requestAdWithURL:[NSURL URLWithString:[[[fetcher mediationController] mediatedAd] resultCB]]];
                                        //FIX -- repair per intent -- doesn't matter?
                TESTTRACEM(@"FIX ERROR HERE?  WAS...  [fetcher requestAdWithURL:[NSURL URLWithString:[[[fetcher mediationController] mediatedAd] resultCB]]]");
                break;
            }

            case 70:
            {
                // don't set adapter here, because we want to retain the adapter from case 7
                self.standardAdView = [fetcher standardAdView];
                break;
            }

            case 13:
            {
                self.adapter = [[fetcher mediationController] currentAdapter];
                self.standardAdView = [fetcher standardAdView];
                break;
            }

            case 15:
            {
                self.anError = [response error];
                break;
            }

            default:
            {
                self.adapter = [[fetcher mediationController] currentAdapter];
                break;
            }
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




#pragma mark - ANBrowserViewControllerDelegate (for ANBannerAdViewExtended)

- (void)browserViewControllerShouldDismiss:(ANBrowserViewController *)controller  {};
- (void)browserViewControllerShouldPresent:(ANBrowserViewController *)controller  {};
- (void)browserViewControllerWillLaunchExternalApplication  {};
- (void)browserViewControllerWillNotPresent:(ANBrowserViewController *)controller  {};




#pragma mark - ANAdViewInternalDelegate (for ANBannerAdViewExtended)

- (void)adWasClicked  {};
- (void)adWillPresent  {};
- (void)adDidPresent  {};
- (void)adWillClose  {};
- (void)adDidClose  {};
- (void)adWillLeaveApplication  {};
- (void)adFailedToDisplay  {};
- (void)adDidReceiveAppEvent:(NSString *)name withData:(NSString *)data  {};
- (void)adDidReceiveAd  {};
- (void)adRequestFailedWithError:(NSError *)error  {};
- (void)adInteractionDidBegin  {};
- (void)adInteractionDidEnd  {};




#pragma mark - ANMRAIDAdViewDelegate (for ANBannerAdViewExtended)

- (NSString *)adType
{
    return nil;
};

- (UIViewController *)displayController
{
    return nil;
};

- (void)adShouldResetToDefault
{
    //EMPTY
};

- (void)adShouldExpandToFrame:(CGRect)frame closeButton:(UIButton *)closeButton
{
    //EMPTY
};

- (void)adShouldResizeToFrame:(CGRect)frame allowOffscreen:(BOOL)allowOffscreen
                  closeButton:(UIButton *)closeButton
                closePosition:(ANMRAIDCustomClosePosition)closePosition
{
    //EMPTY
};

- (void)allowOrientationChange:(BOOL)allowOrientationChange
         withForcedOrientation:(ANMRAIDOrientation)orientation
{
    //EMPTY
};




# pragma mark - ANAppEventDelegate (for ANBannerAdViewExtended)

- (void)            ad: (id<ANAdProtocol>)ad
    didReceiveAppEvent: (NSString *)name
              withData: (NSString *)data
{
    //EMPTY
};


@end




#pragma mark - MediationTests

@interface MediationTests : ANBaseTestCase

@property (nonatomic, strong) ANBannerAdViewExtended *bannerAdViewExtended;

@end



@implementation MediationTests

@synthesize bannerAdViewExtended = __bannerAdViewExtended;
                    //FIX -- need this?


#pragma mark - Test lifecycle.

- (void)setUp
{
    [super setUp];

    self.bannerAdViewExtended = [ANBannerAdViewExtended new];
    [self.bannerAdViewExtended setAdSize:CGSizeMake(320, 50)];
}



#pragma mark - Basic Mediation Tests

- (void)test1ResponseWhereClassExists
{
    [self stubWithInitialMockResponse:[ANTestResponses mediationWaterfallWithMockClassNames:@[ @"ANMockMediationAdapterSuccessfulBanner" ]]];
    [self runBasicTest:1];
}

//
//FIX -- WRONG : /Users/dreeder/appnexus/project/code/MOBILE-SDK/app_mobile-sdk/apps/iOS/mobile-sdk-ios/tests/OriginalUnitTestAppTests/MediationTests.m:479: error: -[MediationTests test3ResponseWhereClassCannotInstantiate] : ((result) is true) failed - Expected an adapter of class ANMockMediationAdapterErrorCode
//

- (void)test2ResponseWhereMediationAdapterClassDoesNotExist
{
    [self stubWithInitialMockResponse:[ANTestResponses mediationWaterfallWithMockClassNames:@[ kMediationAdapterClassDoesNotExist ]]];
    [self runBasicTest:2];
}

- (void)test3ResponseWhereClassCannotInstantiate
{
            /* FIX -- toss
    [self stubWithInitialMockResponse:[ANTestResponses createMediatedBanner:kANAdAdapterBannerDummy]];
    [self stubResultCBForErrorCode];
                     */

    [self stubWithInitialMockResponse:[ANTestResponses mediationWaterfallWithMockClassNames:@[ @"ANMockMediationAdapterBannerDummy" ]]];
    [self runBasicTest:3];
}

- (void)test4ResponseWhereClassInstantiatesAndDoesNotRequestAd
{
                    /* FIX -- toss
    [self stubWithInitialMockResponse:[ANTestResponses createMediatedBanner:kANAdAdapterBannerRequestFail]];
    [self stubResultCBForErrorCode];
                             */

    [self stubWithInitialMockResponse:[ANTestResponses mediationWaterfallWithMockClassNames:@[ @"ANMockMediationAdapterBannerRequestFail" ]]];
    [self runBasicTest:4];
}

- (void)test6AdWithNoFill
{
    [self stubWithInitialMockResponse:[ANTestResponses createMediatedBanner:kANAdAdapterBannerNoAds]];
    [self stubResultCBForErrorCode];
    [self runBasicTest:6];
}

- (void)test7TwoSuccessfulResponses
{
    [self stubWithInitialMockResponse:[ANTestResponses createMediatedBanner:@"ANMockMediationAdapterSuccessfulBanner"]];
    [self stubResultCBResponses:[ANTestResponses successfulBanner]];
    [self runBasicTest:7];
}



#pragma mark - MediationWaterfall tests

- (void)test11FirstSuccessfulSkipSecond
{
    [self stubWithInitialMockResponse:[ANTestResponses mediationWaterfallBanners:@"ANMockMediationAdapterSuccessfulBanner"
                                                      secondClass:kANMockMediationAdapterBannerNeverCalled]];
    [self stubResultCBResponses:@""];
    [self runBasicTest:11];
}

- (void)test12SkipFirstSuccessfulSecond
{
    [self stubWithInitialMockResponse:[ANTestResponses mediationWaterfallBanners:kMediationAdapterClassDoesNotExist
                                                      secondClass:@"ANMockMediationAdapterSuccessfulBanner"]];
    [self stubResultCBResponses:@""];
    [self runBasicTest:12];
}

// no longer applicable
//- (void)test13FirstFailsIntoOverrideStd
//{
//    [self stubWithInitialMockResponse:[ANTestResponses mediationWaterfallBanners:kMediationAdapterClassDoesNotExist
//                                                      secondClass:kANMockMediationAdapterBannerNeverCalled]];
//    [self stubResultCBResponses:[ANTestResponses successfulBanner]];
//    [self runBasicTest:13];
//}

// no longer applicable
//- (void)test14FirstFailsIntoOverrideMediated
//{
//    [self stubWithInitialMockResponse:[ANTestResponses mediationWaterfallBanners:kMediationAdapterClassDoesNotExist
//                                                      secondClass:kANMockMediationAdapterBannerNeverCalled]];
//    [self stubResultCBResponses:[ANTestResponses mediationSuccessfulBanner]];
//    [self runBasicTest:14];
//}

- (void)test15TestNoFill
{
    [self stubWithInitialMockResponse:[ANTestResponses createMediatedBanner:kMediationAdapterClassDoesNotExist]];
    [self stubResultCBResponses:[ANTestResponses createMediatedBanner:kMediationAdapterClassDoesNotExist withID:@"" withResultCB:@""]];
    [self runBasicTest:15];
}

- (void)test16NoResultCB
{
    NSString *response = [ANTestResponses mediationWaterfallBanners:kMediationAdapterClassDoesNotExist firstResult:@""
                                   secondClass:kMediationAdapterClassDoesNotExist secondResult:nil
                                    thirdClass:@"ANMockMediationAdapterSuccessfulBanner" thirdResult:@""];
    [self stubWithInitialMockResponse:response];
    [self stubResultCBResponses:@""];
    
    [self runBasicTest:16];
}




#pragma mark - Helper methods.

- (void)clearTest {
    [super clearTest];
    [ANMockMediationAdapterBannerNeverCalled setCalled:NO];
}

- (void)runBasicTest:(int)testNumber
{
    id adapter = [self.bannerAdViewExtended runTestForAdapter:testNumber time:MEDIATION_TESTS_TIMEOUT];

    XCTAssertTrue([self.bannerAdViewExtended testComplete], @"Test timed out");
    [self runChecks:testNumber adapter:adapter];
                                //FIX -- is 2ppart test run fom here?  else where>...?

    [self clearTest];
}

- (void)checkErrorCode:(id)adapter expectedError:(ANAdResponseCode)error
{
    [self checkClass:@"ANMockMediationAdapterErrorCode" adapter:adapter];
//    [self checkLastRequest:error];   //FIX -- toss
}

- (void)checkClass:(NSString *)className adapter:(id)adapter
{
TESTTRACE();
    BOOL   result;
    Class  adClass  = NSClassFromString(className);

    if (!adClass) {
        result = NO;
    } else {
        result = [adapter isMemberOfClass:adClass];
    }

    XCTAssertTrue(result, @"Expected an adapter of class %@", className);
}

//- (void)checkSuccessResultCB:(int)code {
//    NSString *resultCBString =[[self.bannerAdViewExtended successResultRequest].URL absoluteString];
//    NSString *resultCBPrefix = [NSString stringWithFormat:@"%@?reason=%i", OK_RESULT_CB_URL, code];
//    STAssertTrue([resultCBString hasPrefix:resultCBPrefix], @"ResultCB should match");
//}
            //FIX -- toss?

                            /* FIX -- toss olds choll
- (void)checkLastRequest:(int)code
                    //FIX -- final proof of need for OK_RESULT_CB_URL?  else toss.
{
TESTTRACE();
    NSString  *resultCBString  = [[self.bannerAdViewExtended request].URL absoluteString];
    NSString  *resultCBPrefix  = [NSString stringWithFormat:@"%@?reason=%i", OK_RESULT_CB_URL, code];

TESTTRACEM(@"FIX ERROR is this still defined?  resultCBString=%@", resultCBString);
    XCTAssertTrue([resultCBString hasPrefix:resultCBPrefix], @"ResultCB should match");
}
                                         */

- (void)checkSuccessfulBannerNeverCalled {
    XCTAssertFalse([ANMockMediationAdapterBannerNeverCalled getCalled], @"Should never be called");
}

- (void)runChecks: (int)testNumber
          adapter: (id)adapter
{
TESTTRACEM(@"testNumber=%@", @(testNumber));

    switch (testNumber)
                                //FIX -- enumerated types for testNumber's...
    {
        case 1:
        {
            [self checkClass:@"ANMockMediationAdapterSuccessfulBanner" adapter:adapter];
            //            [self checkSuccessResultCB:ANAdResponseSuccessful];
            break;
        }

        case 2:
        {
            XCTAssertNil(adapter, @"Expected an adapter to be nil.");

//            [self checkErrorCode:adapter expectedError:ANAdResponseMediatedSDKUnavailable];
            break;
        }

        case 3:
        {
            [self checkErrorCode:adapter expectedError:ANAdResponseMediatedSDKUnavailable];
            break;
        }

        case 4:
        {
            [self checkErrorCode:adapter expectedError:ANAdResponseNetworkError];
            break;
        }

        case 6:
        {
            [self checkErrorCode:adapter expectedError:ANAdResponseUnableToFill];
            break;
        }

        case 7:
        {
            [self checkClass:@"ANMockMediationAdapterSuccessfulBanner" adapter:adapter];
            XCTAssertNotNil(self.bannerAdViewExtended.standardAdView, @"Expected webView to be non-nil");
            break;
        }

        case 11:
        {
            [self checkClass:@"ANMockMediationAdapterSuccessfulBanner" adapter:adapter];
            break;
        }

        case 12:
        {
            [self checkClass:@"ANMockMediationAdapterSuccessfulBanner" adapter:adapter];
            break;
        }

        case 13:
        {
            XCTAssertNil(adapter, @"Expected nil adapter");
            XCTAssertNotNil(self.bannerAdViewExtended.standardAdView, @"Expected webView to be non-nil");
            break;
        }

        case 14:
        {
            [self checkClass:@"ANMockMediationAdapterSuccessfulBanner" adapter:adapter];
            break;
        }

        case 15:
        {
            XCTAssertTrue([[self.bannerAdViewExtended anError] code] == ANAdResponseUnableToFill, @"Expected ANAdResponseUnableToFill error.");
            break;
        }

        case 16:
        {
            [self checkClass:@"ANMockMediationAdapterSuccessfulBanner" adapter:adapter];
            break;
        }

        default:
            break;
    }

    [self checkSuccessfulBannerNeverCalled];
}


@end
