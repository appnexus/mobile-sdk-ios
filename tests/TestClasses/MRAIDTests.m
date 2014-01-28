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
#define MRAID_TESTS_DEFAULT_DELAY 2.0


@interface UIDevice (HackyWayToRotateTheDeviceForTestingPurposesBecauseAppleDeclaredSuchAMethodInTheirPrivateImplementationOfTheUIDeviceClass)
-(void)setOrientation:(UIInterfaceOrientation)orientation animated:(BOOL)animated;
-(void)setOrientation:(UIInterfaceOrientation)orientation;
@end

@interface MRAIDTests : ANBaseTestCase
@property (strong, nonatomic) ANWebView *webView;
@end

@implementation MRAIDTests

#pragma mark MRAID Tests

- (void)testSuccessfulBannerDidLoad {
    [self loadBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    [self bannerAddSubview];
    
    [self clearTest];
}

- (void)testBasicExpandability {
    [self loadBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    [self bannerAddSubview];
    
    [self expand];
    [self assertState:@"expanded"];
    
    [self close];
    [self assertState:@"default"];
    
    [self clearTest];
}

- (void)testBasicViewability { // MS-453
    [self loadBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    STAssertFalse([[self isViewable] boolValue], @"Expected ANWebView not to be visible");
    
    [self bannerAddSubview];
    STAssertTrue([[self isViewable] boolValue], @"Expected ANWebView to be visible");
    
    [self bannerRemoveFromSuperview];
    STAssertFalse([[self isViewable] boolValue], @"Expected ANWebView not to be visible");
    
    [self clearTest];
}

- (void)testForceOrientationLandscapeFromPortrait { // MS-481
    [self loadBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    [self bannerAddSubview];
    
    [self setOrientationPropertiesWithAllowOrientationChange:NO forceOrientation:@"landscape"];
    [self expand];
    STAssertTrue([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft, @"Expected landscape left orientation");
    
    [self close];
    STAssertTrue([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait, @"Expected portrait orientation");
    
    [self clearTest];
}

- (void)testForceOrientationPortraitFromLandscape { // MS-481
    [self rotateDeviceToOrientation:UIInterfaceOrientationLandscapeRight];
    [self loadBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    [self bannerAddSubview];
    [self setOrientationPropertiesWithAllowOrientationChange:NO forceOrientation:@"portrait"];
    [self expand];
    STAssertTrue([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait, @"Expected portrait orientation");
    
    [self close];
    STAssertTrue([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight, @"Expected landscape right orientation");
    
    [self rotateDeviceToOrientation:UIInterfaceOrientationPortrait];
    [self clearTest];
}

- (void)testForceOrientationLandscapeFromLandscapeRight { // MS-481
    [self rotateDeviceToOrientation:UIInterfaceOrientationLandscapeRight];
    [self loadBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    [self bannerAddSubview];
    [self setOrientationPropertiesWithAllowOrientationChange:NO forceOrientation:@"landscape"];
    [self expand];
    STAssertTrue([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight, @"Expected landscape right orientation");

    [self close];
    STAssertTrue([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight, @"Expected landscape right orientation");

    [self rotateDeviceToOrientation:UIInterfaceOrientationPortrait];
    [self clearTest];
}

- (void)testExpandFromPortraitUpsideDown { // MS-510
    [self rotateDeviceToOrientation:UIInterfaceOrientationPortraitUpsideDown];
    [self loadBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    [self bannerAddSubview];
    [self expand];
    STAssertTrue([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown, @"Expected portrait upside down orientation"); // Will pass after release for flipped orientation support
    
    [self rotateDeviceToOrientation:UIInterfaceOrientationPortrait];
    [self clearTest];
}

#pragma mark MRAID Helper Functions

- (void)clearTest {
    self.webView = nil;
    [self bannerRemoveFromSuperview];
    [super clearTest];
}

- (void)loadBasicMRAIDBanner {
    [self loadBasicMRAIDBannerWithSelectorName:@"Test Ad"];
}

- (void)loadBasicMRAIDBannerWithSelectorName:(NSString *)selector {
    [self stubWithBody:[ANMRAIDTestResponses basicMRAIDBannerWithSelectorName:selector]];
    [self loadBannerAd];
    STAssertTrue([self waitForCompletion:MRAID_TESTS_TIMEOUT], @"Ad load timed out");
    STAssertTrue(self.adDidLoadCalled, @"Success callback should be called");
    STAssertFalse(self.adFailedToLoadCalled, @"Failure callback should not be called");
    id wv = [[self.banner subviews] firstObject];
    STAssertTrue([wv isKindOfClass:[ANWebView class]], @"Expected ANWebView as subview of BannerAdView");
    self.webView = (ANWebView *)wv;
}

- (void)bannerAddSubview {
    if (self.banner) {
        [self.banner.rootViewController.view addSubview:self.banner];
        [self delay:MRAID_TESTS_DEFAULT_DELAY];
    }
}

- (void)bannerRemoveFromSuperview {
    if (self.banner) {
        [self.banner removeFromSuperview];
        [self delay:MRAID_TESTS_DEFAULT_DELAY];
    }
}

- (void)assertState:(NSString *)expectedState {
    STAssertTrue([[self getState] isEqualToString:expectedState], [NSString stringWithFormat:@"Expected state '%@', instead in state '%@'", expectedState, [self getState]]);
}

- (void)rotateDeviceToOrientation:(UIInterfaceOrientation)orientation {
    [[UIDevice currentDevice] setOrientation:orientation animated:YES];
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