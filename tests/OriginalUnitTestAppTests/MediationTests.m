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
//static NSString *const kANAdAdapterBannerDummy                   = @" ANMockMediationAdapterBannerDummy";
//static NSString *const kANAdAdapterBannerNoAds                   = @"ANMockMediationAdapterBannerNoAds";
//static NSString *const kANAdAdapterBannerRequestFail             = @"ANMockMediationAdapterBannerRequestFail";
//static NSString *const kANAdAdapterErrorCode                     = @"ANMockMediationAdapterErrorCode";
//static NSString *const kFauxMediationAdapterBannerNeverCalled  = @"ANMockMediationAdapterBannerNeverCalled";


float const  MEDIATION_TESTS_TIMEOUT  = 15.0;

typedef NS_ENUM(NSUInteger, ANMediationTestsType) {
    ANMediationTestsSuccessfulBanner,
    ANMediationTestsClassDoesNotExist,
    ANmediationTestsBannerDummy,
    ANMediationTestsBannerRequestFail,
    ANMediationTestsBannerNoAds,
    ANMediationTestsTwoSuccessfulResponses_Part1,
    ANMediationTestsTwoSuccessfulResponses_Part2,
    ANMediationTestsFirstSuccessfulSkipSecond,
    ANMediationTestsSkipFirstSuccessfulSecond,
    ANMediationTestsNoFill,
    ANMediationTestsTwoBadAdsThenOneGoodAd
};



#pragma mark - ANUniversalAdFetcher local interface.
                //FIX -- verify all methods necesary, and those missing
                //FIX -- aso wowith all other delegatesb elow.

@interface ANUniversalAdFetcher ()

//- (void)processResponseData:(NSData *)data;
//- (void) processV2ResponseData:(NSData *)data;
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

@class  MediationTests;

@interface ANBannerAdViewExtended : ANBannerAdView

@property (nonatomic, assign)  BOOL                      testComplete;
@property (nonatomic, strong)  ANUniversalAdFetcher     *fetcher;
@property (nonatomic, strong)  id                        adapter;
@property (nonatomic, strong)  NSError                  *anError;
@property (nonatomic, strong)  ANMRAIDContainerView     *standardAdView;

//@property (nonatomic, strong)  NSMutableURLRequest      *successResultRequest;
//@property (nonatomic, strong)  NSMutableURLRequest      *request;

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
                    /* FIX ------ ttoss
        //        __successResultRequest = [__fetcher successResultRequest];
//        __request = [__fetcher requestAd];
                        //FIX -- what is this, toss? please?
//        [__fetcher requestAd];
                        //FIX - why ever would we requestAd after receiving an ad?
                                 */


        switch (__testNumber)
        {
            case ANMediationTestsTwoSuccessfulResponses_Part1:
            {
                self.adapter = [[fetcher mediationController] currentAdapter];
                [fetcher requestAd];

                break;
            }

            case ANMediationTestsTwoSuccessfulResponses_Part2:
            {
                // don't set adapter here, because we want to retain the adapter from case 7
                self.standardAdView = [fetcher standardAdView];
                break;
            }

                            /* FIX -- tossed MS-709
            case 13:
            {
                self.adapter = [[fetcher mediationController] currentAdapter];
                self.standardAdView = [fetcher standardAdView];
                break;
            }
                                             */

            case ANMediationTestsNoFill:
            {
                self.anError = [response error];
                break;
            }

            default:
            {
                TESTTRACEM(@"UNMATCHED __testNumber.  (%@)", @(__testNumber));
                self.adapter = [[fetcher mediationController] currentAdapter];
                break;
            }
        }

        // test case ANMediationTestsTwoSuccessfulResponses is a special two-part test, so we handle it specially.
        //   Change the test number to ANMediationTestsTwoSuccessfulResponses_Part2 to denote the "part 2" of this 2-step unit test.
        //
        if (__testNumber != ANMediationTestsTwoSuccessfulResponses_Part1)
        {
            NSLog(@"test complete");
            __testComplete = YES;
        } else {
            __testNumber = ANMediationTestsTwoSuccessfulResponses_Part2;
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

@property (nonatomic, strong)  ANBannerAdViewExtended  *bannerAdViewExtended;

@end



@implementation MediationTests

#pragma mark - Test lifecycle.

- (void)setUp
{
    [super setUp];

    self.bannerAdViewExtended = [ANBannerAdViewExtended new];
    [self.bannerAdViewExtended setAdSize:CGSizeMake(320, 50)];
}



#pragma mark - Basic Mediation Tests
                            //TBDFIX -- are all these tests useful?  develop means to measure their nuances.

- (void)test1ResponseWhereClassExists
{
    [self stubWithInitialMockResponse:[ANTestResponses mediationWaterfallWithMockClassNames:@[ @"ANMockMediationAdapterSuccessfulBanner" ]]];
    [self runBasicTest:ANMediationTestsSuccessfulBanner];

}

- (void)test2ResponseWhereMediationAdapterClassDoesNotExist
{
    [self stubWithInitialMockResponse:[ANTestResponses mediationWaterfallWithMockClassNames:@[ kFauxMediationAdapterClassDoesNotExist ]]];
    [self runBasicTest:ANMediationTestsClassDoesNotExist];
}

- (void)test3ResponseWhereClassCannotInstantiate
{
    [self stubWithInitialMockResponse:[ANTestResponses mediationWaterfallWithMockClassNames:@[ @"ANMockMediationAdapterBannerDummy" ]]];
    [self runBasicTest:ANmediationTestsBannerDummy];
}

- (void)test4ResponseWhereClassInstantiatesAndDoesNotRequestAd
{
    [self stubWithInitialMockResponse:[ANTestResponses mediationWaterfallWithMockClassNames:@[ @"ANMockMediationAdapterBannerRequestFail" ]]];
    [self runBasicTest:ANMediationTestsBannerRequestFail];
}

- (void)test6AdWithNoFill
{
    [self stubWithInitialMockResponse:[ANTestResponses mediationWaterfallWithMockClassNames:@[ @"ANMockMediationAdapterBannerNoAds" ]]];
    [self runBasicTest:ANMediationTestsBannerNoAds];
}

- (void)test7TwoSuccessfulResponses
{
    [self stubWithInitialMockResponse:[ANTestResponses mediationWaterfallWithMockClassNames:@[ @"ANMockMediationAdapterSuccessfulBanner" ]]];
    [self runBasicTest:ANMediationTestsTwoSuccessfulResponses_Part1];
}



#pragma mark - MediationWaterfall tests

- (void)test11FirstSuccessfulSkipSecond
{
    [self stubWithInitialMockResponse:[ANTestResponses mediationWaterfallWithMockClassNames:@[ @"ANMockMediationAdapterSuccessfulBanner", @"ANMockMediationAdapterBannerNeverCalled" ]]];
    [self runBasicTest:ANMediationTestsFirstSuccessfulSkipSecond];
}

- (void)test12SkipFirstSuccessfulSecond
{
    [self stubWithInitialMockResponse:[ANTestResponses mediationWaterfallWithMockClassNames:@[ kFauxMediationAdapterClassDoesNotExist, @"ANMockMediationAdapterSuccessfulBanner" ]]];
    [self runBasicTest:ANMediationTestsSkipFirstSuccessfulSecond];
}


                /* FIX -- toss
// no longer applicable
//- (void)test13FirstFailsIntoOverrideStd
//{
//    [self stubWithInitialMockResponse:[ANTestResponses mediationWaterfallBanners:kFauxMediationAdapterClassDoesNotExist
//                                                      secondClass:kFauxMediationAdapterBannerNeverCalled]];
//    [self stubResultCBResponses:[ANTestResponses successfulBanner]];
//    [self runBasicTest:13];
//}

// no longer applicable
//- (void)test14FirstFailsIntoOverrideMediated
//{
//    [self stubWithInitialMockResponse:[ANTestResponses mediationWaterfallBanners:kFauxMediationAdapterClassDoesNotExist
//                                                      secondClass:kFauxMediationAdapterBannerNeverCalled]];
//    [self stubResultCBResponses:[ANTestResponses mediationSuccessfulBanner]];
//    [self runBasicTest:14];
//}
                             */

- (void)test15NoFill
{
    [self stubWithInitialMockResponse:[ANTestResponses mediationWaterfallWithMockClassNames:@[ kFauxMediationAdapterClassDoesNotExist ]]];
    [self runBasicTest:ANMediationTestsNoFill];
}

- (void)test16TwoBadAdsThenOneGoodAd
{
                /* FIX toss
    NSString *response = [ANTestResponses mediationWaterfallBanners:kFauxMediationAdapterClassDoesNotExist firstResult:@""
                                   secondClass:kFauxMediationAdapterClassDoesNotExist secondResult:nil
                                    thirdClass:@"ANMockMediationAdapterSuccessfulBanner" thirdResult:@""];
    [self stubWithInitialMockResponse:response];
    [self stubResultCBResponses:@""];
                    */

    [self stubWithInitialMockResponse:
             [ANTestResponses mediationWaterfallWithMockClassNames:
                  @[ kFauxMediationAdapterClassDoesNotExist, kFauxMediationAdapterClassDoesNotExist, @"ANMockMediationAdapterSuccessfulBanner" ]
              ]
     ];

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

- (void)runChecks: (int)testNumber
          adapter: (id)adapter
{
TESTTRACEM(@"testNumber=%@  adapter=%@", @(testNumber), adapter);

    switch (testNumber)
    {
        case ANMediationTestsSuccessfulBanner:
        {
            [self matchMediationAdapter:adapter toClassName:@"ANMockMediationAdapterSuccessfulBanner"];
            break;
        }

        case ANMediationTestsClassDoesNotExist:
        {
            XCTAssertNil(adapter, @"Expected an adapter to be nil.");
            break;
        }

        case ANmediationTestsBannerDummy:
        {
            XCTAssertNil(adapter, @"Expected an adapter to be nil.");
            break;
        }

        case ANMediationTestsBannerRequestFail:
        {
            XCTAssertNil(adapter, @"Expected an adapter to be nil.");
            break;
        }

        case ANMediationTestsBannerNoAds:
        {
            XCTAssertNil(adapter, @"Expected an adapter to be nil.");
            break;
        }

        case ANMediationTestsTwoSuccessfulResponses_Part1:
        {
            [self matchMediationAdapter:adapter toClassName:@"ANMockMediationAdapterSuccessfulBanner"];
            break;
        }

        case ANMediationTestsFirstSuccessfulSkipSecond:
        {
            [self matchMediationAdapter:adapter toClassName:@"ANMockMediationAdapterSuccessfulBanner"];
            break;
        }

        case ANMediationTestsSkipFirstSuccessfulSecond:
        {
            [self matchMediationAdapter:adapter toClassName:@"ANMockMediationAdapterSuccessfulBanner"];
            break;
        }


                        /* FIX -- not relevant!
        case 13:
        {
            XCTAssertNil(adapter, @"Expected nil adapter");
            XCTAssertNotNil(self.bannerAdViewExtended.standardAdView, @"Expected webView to be non-nil");
            break;
        }

        case 14:
        {
            [self matchMediationAdapter:adapter toClassName:@"ANMockMediationAdapterSuccessfulBanner"];
            break;
        }
                                     */

        case ANMediationTestsNoFill:
        {
            NSInteger  anErrorCode  = [[self.bannerAdViewExtended anError] code];
            TESTTRACEM(@"anErrorCode=%@", @(anErrorCode));

            XCTAssertTrue(anErrorCode == ANAdResponseUnableToFill, @"Expected ANAdResponseUnableToFill error.");
            break;
        }

        case ANMediationTestsTwoBadAdsThenOneGoodAd:
        {
            [self matchMediationAdapter:adapter toClassName:@"ANMockMediationAdapterSuccessfulBanner"];
            break;
        }

        default:
        {
            TESTTRACEM(@"UNMATCHED testNumber.  (%@)", @(testNumber));
            break;
        }
    }

    [self checkSuccessfulBannerNeverCalled];
}

        /* FIX -- toss, replace with sometihing?
- (void)checkErrorCode:(id)adapter expectedError:(ANAdResponseCode)error
{
TESTTRACEM(@"adapter=%@", adapter);
    [self matchMediationAdapter:adapter toClassName:@"ANMockMediationAdapterErrorCode"];
//    [self checkLastRequest:error];   //FIX -- toss
}
                     */

- (void)matchMediationAdapter: (id)adapter
                  toClassName: (NSString *)className
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

            /* FIX  no thanks.
+ (void) matchMediationAdapter: (id)adapter
                   toClassName: (NSString *)className
{
    [[[self alloc] init] matchMediationAdapter:adapter toClassName:className];
}
                     */

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


@end
