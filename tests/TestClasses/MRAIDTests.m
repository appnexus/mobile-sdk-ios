//
//  ANMRAIDTests.m
//  Tests
//
//  Created by Jose Cabal-Ugaz on 1/27/14.
//
//

#import "ANWebView.h"
#import "ANBaseTestCase.h"
#import "ANMRAIDTestResponses.h"
#import "ANLogging.h"

#define MRAID_TESTS_TIMEOUT 10.0
#define MRAID_TESTS_DEFAULT_DELAY 3.0

@interface MRAIDTests : ANBaseTestCase

@property (strong, nonatomic) ANWebView *webView;

@end

@implementation MRAIDTests

#pragma mark MRAID Tests

- (void)testSuccessfulBannerDidLoad {
    [self loadBasicMRAIDBanner];
    [self clearTest];
}

- (void)testBannerExpand {
    [self loadBasicMRAIDBanner];
    
    [self expand];
    [self assertState:@"expanded"];
    
    [self close];
    [self assertState:@"default"];
    
    [self clearTest];
}

- (void)testBasicViewability {
    [self loadBasicMRAIDBanner];
    STAssertFalse([[self isViewable] boolValue], @"Expected ANWebView not to be visible");
    
    [self.banner.rootViewController.view addSubview:self.banner];
    [self delay:MRAID_TESTS_DEFAULT_DELAY];
    STAssertTrue([[self isViewable] boolValue], @"Expected ANWebView to be visible");
    
    [self.banner removeFromSuperview];
    [self delay:MRAID_TESTS_DEFAULT_DELAY];
    STAssertFalse([[self isViewable] boolValue], @"Expected ANWebView not to be visible");
    
    [self clearTest];
}

- (void)testForceOrientation {
    [self loadBasicMRAIDBanner];
    [self setOrientationPropertiesWithAllowOrientationChange:NO forceOrientation:@"landscape"];
    [self expand];
    STAssertTrue(UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]), @"Expected landscape mode");
    [self close];
    STAssertTrue([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationPortrait, @"Expected portrait right-side up mode");
    [self clearTest];
}

#pragma mark MRAID Helper Functions

- (void)clearTest {
    [super clearTest];
    self.webView = nil;
}

- (void)loadBasicMRAIDBanner {
    [self stubWithBody:[ANMRAIDTestResponses basicMRAIDBanner]];
    [self loadBannerAd];
    STAssertTrue([self waitForCompletion:MRAID_TESTS_TIMEOUT], @"Ad load timed out");
    STAssertTrue(self.adDidLoadCalled, @"Success callback should be called");
    STAssertFalse(self.adFailedToLoadCalled, @"Failure callback should not be called");
    id wv = [[self.banner subviews] firstObject];
    STAssertTrue([wv isKindOfClass:[ANWebView class]], @"Expected ANWebView as subview of BannerAdView");
    self.webView = (ANWebView *)wv;
}

- (void)assertState:(NSString *)expectedState {
    STAssertTrue([[self getState] isEqualToString:expectedState], [NSString stringWithFormat:@"Expected state '%@', instead in state '%@'", expectedState, [self getState]]);
}

# pragma mark MRAID Accessor Functions

- (void)expand {
    [self mraidNativeCall:@"expand()" withDelay:MRAID_TESTS_DEFAULT_DELAY];
}

- (void)close {
    [self mraidNativeCall:@"close()" withDelay:MRAID_TESTS_DEFAULT_DELAY];
}

- (NSString *)getState {
    return [self mraidNativeCall:@"getState()" withDelay:0];
}

- (NSString *)isViewable {
    return [self mraidNativeCall:@"isViewable()" withDelay:0];
}

- (void)setOrientationPropertiesWithAllowOrientationChange:(BOOL)changeAllowed forceOrientation:(NSString *)orientation {
    NSString *allowOrientationChange = changeAllowed ? @"true":@"false";
    [self mraidNativeCall:[NSString stringWithFormat:@"setOrientationProperties({allowOrientationChange:%@, forceOrientation:\"%@\"});", allowOrientationChange, orientation] withDelay:MRAID_TESTS_DEFAULT_DELAY];
}

- (NSString *)mraidNativeCall:(NSString *)script withDelay:(NSTimeInterval)delay {
    NSString *response = [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"mraid.%@",script]];
    if (delay) {
        [self delay:delay];
    }
    return response;
}

@end
