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
#import "ANMediatedAd.h"
#import "ANMRAIDContainerView.h"
#import "ANMediationAdViewController.h"
#import "ANMockMediationAdapterBannerNeverCalled.h"
#import "ANBrowserViewController.h"
#import "XandrAd.h"




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

@interface ANAdFetcherBase ()

- (ANMediationAdViewController *)mediationController;

- (ANMRAIDContainerView *)adView;

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
@property (nonatomic, strong)  ANAdFetcher     *fetcher;
@property (nonatomic, strong)  id                        adapter;
@property (nonatomic, strong)  NSError                  *anError;
@property (nonatomic, strong)  ANMRAIDContainerView     *standardAdView;

- (id)runTestForAdapter:(int)testNumber
                   time:(NSTimeInterval)time;
@end


@interface ANBannerAdViewExtended () <ANAdFetcherDelegate>
{
    NSUInteger __testNumber;
}
@end


@implementation ANBannerAdViewExtended

@synthesize  testComplete        = __testComplete;
@synthesize  fetcher             = __fetcher;
@synthesize  adapter             = __adapter;
@synthesize  standardAdView      = __standardAdView;
@synthesize  anError             = __anError;



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

    __fetcher = [[ANAdFetcher alloc] initWithDelegate:self];
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

- (void)adFetcher:(ANAdFetcherBase *)fetcher didFinishRequestWithResponse:(ANAdFetcherResponse *)response
{
    TESTTRACEM(@"__testNumber=%@", @(__testNumber));

    if (__testComplete)  { return; }

    //
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
            self.standardAdView = [fetcher adView];
            break;
        }

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

- (NSTimeInterval)autoRefreshIntervalForAdFetcher:(ANAdFetcher *)fetcher {
    return 0.0;
}

- (CGSize)requestedSizeForAdFetcher:(ANAdFetcher *)fetcher {
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
    // Init here if not the tests will crash
    [[XandrAd sharedInstance] initWithMemberID:1 preCacheRequestObjects:true completionHandler:nil];

}




#pragma mark - Basic Mediation Tests

-(void)tearDown {
    [self clearTest];

}
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

- (void)test15NoFill
{
    [self stubWithInitialMockResponse:[ANTestResponses mediationWaterfallWithMockClassNames:@[ kFauxMediationAdapterClassDoesNotExist ]]];
    [self runBasicTest:ANMediationTestsNoFill];
}

- (void)test16TwoBadAdsThenOneGoodAd
{
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

        case ANMediationTestsNoFill:
        {
            XCTAssertNil(adapter, @"Expected an adapter to be nil.");
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

- (void)matchMediationAdapter: (id)adapter
                  toClassName: (NSString *)className
{
    BOOL   result;
    Class  adClass  = NSClassFromString(className);

    if (!adClass) {
        result = NO;
    } else {
        result = [adapter isMemberOfClass:adClass];
    }

    XCTAssertTrue(result, @"Expected an adapter of class %@", className);
}

- (void)checkSuccessfulBannerNeverCalled {
    XCTAssertFalse([ANMockMediationAdapterBannerNeverCalled getCalled], @"Should never be called");
}


@end
