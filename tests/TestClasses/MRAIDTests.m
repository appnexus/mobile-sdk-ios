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
#define MRAID_TESTS_DEFAULT_DELAY 2.5

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
    [self addBannerAsSubview];
    
    [self clearTest];
}

- (void)testBasicExpandability {
    [self loadBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    [self addBannerAsSubview];
    
    [self expand];
    [self assertState:@"expanded"];
    
    [self close];
    [self assertState:@"default"];
    
    [self clearTest];
}

- (void)testBasicViewability { // MS-453
    [self loadBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    STAssertFalse([[self isViewable] boolValue], @"Expected ANWebView not to be visible");
    
    [self addBannerAsSubview];
    STAssertTrue([[self isViewable] boolValue], @"Expected ANWebView to be visible");
    
    [self bannerRemoveFromSuperview];
    STAssertFalse([[self isViewable] boolValue], @"Expected ANWebView not to be visible");
    
    [self clearTest];
}

- (void)testForceOrientationLandscapeFromPortrait { // MS-481
    [self loadBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    [self addBannerAsSubview];
    
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
    [self addBannerAsSubview];
    [self setOrientationPropertiesWithAllowOrientationChange:NO forceOrientation:@"portrait"];
    [self expand];
    STAssertTrue([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait, @"Expected portrait orientation");
    
    [self close];
    STAssertTrue([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight, @"Expected landscape right orientation");
    
    [self clearTest];
}

- (void)testForceOrientationLandscapeFromLandscapeRight { // MS-481
    [self rotateDeviceToOrientation:UIInterfaceOrientationLandscapeRight];
    [self loadBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    [self addBannerAsSubview];
    [self setOrientationPropertiesWithAllowOrientationChange:NO forceOrientation:@"landscape"];
    [self expand];
    STAssertTrue([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight, @"Expected landscape right orientation");

    [self close];
    STAssertTrue([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight, @"Expected landscape right orientation");

    [self clearTest];
}

- (void)testExpandFromPortraitUpsideDown { // MS-510
    [self rotateDeviceToOrientation:UIInterfaceOrientationPortraitUpsideDown];
    [self loadBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    [self addBannerAsSubview];
    [self expand];
    STAssertFalse([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait, @"Did not expect portrait right side up orientation");
    STAssertTrue([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown, @"Expected portrait upside down orientation");
    
    [self close];
    STAssertTrue([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown, @"Expected portrait upside down orientation");

    [self clearTest];
}

- (void)testScreenSizePortraitOnLoad {
    [self loadBasicMRAIDBanner];
    CGPoint screenSize = [self getScreenSize];
    CGFloat width = screenSize.x;
    CGFloat height = screenSize.y;
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat expectedWidth = screenBounds.size.width;
    CGFloat expectedHeight = screenBounds.size.height;
    STAssertTrue(expectedWidth == width && expectedHeight == height, [NSString stringWithFormat:@"Expected portrait screen bounds %f x %f, received screen bounds %f x %f", expectedWidth, expectedHeight, width, height]);
    [self clearTest];
}

- (void)testScreenSizeLandscapeOnLoad {
    [self rotateDeviceToOrientation:UIInterfaceOrientationLandscapeLeft];
    [self loadBasicMRAIDBanner];
    CGPoint screenSize = [self getScreenSize];
    CGFloat width = screenSize.x;
    CGFloat height = screenSize.y;
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat expectedWidth = screenBounds.size.height;
    CGFloat expectedHeight = screenBounds.size.width;
    STAssertTrue(expectedWidth == width && expectedHeight == height, [NSString stringWithFormat:@"Expected landscape screen bounds %f x %f, received screen bounds %f x %f", expectedWidth, expectedHeight, width, height]);
    [self clearTest];
}

// WILL FAIL: We don't update screen size on rotation
/*- (void)testScreenSizeLandscapeOnRotate {
    [self loadBasicMRAIDBanner];
    [self rotateDeviceToOrientation:UIInterfaceOrientationLandscapeLeft];
    CGPoint screenSize = [self getScreenSize];
    CGFloat width = screenSize.x;
    CGFloat height = screenSize.y;
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat expectedWidth = screenBounds.size.height;
    CGFloat expectedHeight = screenBounds.size.width;
    STAssertTrue(expectedWidth == width && expectedHeight == height, [NSString stringWithFormat:@"Expected landscape screen bounds %f x %f, received screen bounds %f x %f", expectedWidth, expectedHeight, width, height]);
    [self clearTest];
}*/

- (void)testMaxSizePortraitOnLoad {
    [self loadBasicMRAIDBanner];
    CGPoint maxSize = [self getMaxSize];
    CGFloat width = maxSize.x;
    CGFloat height = maxSize.y;
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat expectedWidth = screenBounds.size.width;
    CGFloat expectedHeight = screenBounds.size.height;
    
    if (![UIApplication sharedApplication].statusBarHidden) {
        expectedHeight -= [UIApplication sharedApplication].statusBarFrame.size.height;
    }
    STAssertTrue(expectedWidth == width && expectedHeight == height, [NSString stringWithFormat:@"Expected portrait max size %f x %f, received %f x %f", expectedWidth, expectedHeight, width, height]);

    [self clearTest];
}

- (void)testMaxSizeLandscapeOnLoad {
    [self rotateDeviceToOrientation:UIInterfaceOrientationLandscapeRight];
    [self loadBasicMRAIDBanner];
    
    CGPoint maxSize = [self getMaxSize];
    CGFloat width = maxSize.x;
    CGFloat height = maxSize.y;
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat expectedWidth = screenBounds.size.height;
    CGFloat expectedHeight = screenBounds.size.width;

    if (![UIApplication sharedApplication].statusBarHidden) {
        expectedHeight -= [UIApplication sharedApplication].statusBarFrame.size.width;
    }
    STAssertTrue(expectedWidth == width && expectedHeight == height, [NSString stringWithFormat:@"Expected landscape max size %f x %f, received %f x %f", expectedWidth, expectedHeight, width, height]);

    [self clearTest];
}

// WILL FAIL: We don't update max size on rotation
/*- (void)testMaxSizeLandscapeOnRotate {
    [self loadBasicMRAIDBanner];
    STAssertTrue(UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation), @"Expected to start in portrait orientation");
    [self rotateDeviceToOrientation:UIInterfaceOrientationLandscapeRight];
    
    CGPoint maxSize = [self getMaxSize];
    CGFloat width = maxSize.x;
    CGFloat height = maxSize.y;
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat expectedWidth = screenBounds.size.height;
    CGFloat expectedHeight = screenBounds.size.width;
    
    if (![UIApplication sharedApplication].statusBarHidden) {
        expectedHeight -= [UIApplication sharedApplication].statusBarFrame.size.width;
    }
    STAssertTrue(expectedWidth == width && expectedHeight == height, [NSString stringWithFormat:@"Expected landscape max size %f x %f, received %f x %f", expectedWidth, expectedHeight, width, height]);
    
    [self clearTest];
}*/

- (void)testCurrentPositionPortraitSizeOnLoad {
    [self loadBasicMRAIDBanner];
    CGRect currentPosition = [self getCurrentPosition];
    CGFloat width = currentPosition.size.width;
    CGFloat height = currentPosition.size.height;
    CGFloat expectedWidth = self.banner.adSize.width;
    CGFloat expectedHeight = self.banner.adSize.height;
    
    STAssertTrue(expectedWidth == width && expectedHeight == height, @"Expected portrait size %f x %f, received %f x %f", expectedWidth, expectedHeight, width, height);
    
    [self clearTest];
}

// Works because size_event_width and size_event_height in mraid.js are reset with expanded dimensions
- (void)testCurrentPositionPortraitSizeOnExpand {
    [self loadBasicMRAIDBanner];
    [self addBannerAsSubview];
    [self expand];
    CGRect currentPosition = [self getCurrentPosition];
    CGFloat width = currentPosition.size.width;
    CGFloat height = currentPosition.size.height;

    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat expectedWidth = screenBounds.size.width;
    CGFloat expectedHeight = screenBounds.size.height;

    STAssertTrue(expectedWidth == width && expectedHeight == height, @"Expected portrait size %f x %f, received %f x %f", expectedWidth, expectedHeight, width, height);
    
    [self close];
    [self clearTest];
}

- (void)testDefaultPositionPortraitSizeOnExpand {
    [self loadBasicMRAIDBanner];
    [self addBannerAsSubview];
    [self expand];
    CGRect defaultPosition = [self getDefaultPosition];
    CGFloat width = defaultPosition.size.width;
    CGFloat height = defaultPosition.size.height;
    CGFloat expectedWidth = self.banner.adSize.width;
    CGFloat expectedHeight = self.banner.adSize.height;
    
    STAssertTrue(expectedWidth == width && expectedHeight == height, @"Expected portrait size %f x %f, received %f x %f", expectedWidth, expectedHeight, width, height);
    
    [self close];
    [self clearTest];
}

// WILL FAIL: Origin is always (0,0)?
/*- (void)testDefaultPositionPortraitOriginOnLoad {
    CGFloat expectedOriginX = 0.0f;
    CGFloat expectedOriginY = 50.0f;
    [self loadBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd) atOrigin:CGPointMake(expectedOriginX, expectedOriginY) withSize:CGSizeMake(320.0f, 50.0f)];
    [self addBannerAsSubview];
    CGRect defaultPosition = [self getDefaultPosition];
    CGFloat originX = defaultPosition.origin.x;
    CGFloat originY = defaultPosition.origin.y;
 
    STAssertTrue(expectedOriginX == originX && expectedOriginY == originY, @"Expected origin %f x %f, received %f x %f", expectedOriginX, expectedOriginY, originX, originY);
 
    [self clearTest];
}*/


// WILL FAIL: Current position origin (x,y) is equal to default position origin (x,y), set on initial load.
/*- (void)testCurrentPositionPortraitOriginOnLoad {
    CGFloat expectedOriginX = 0.0f;
    CGFloat expectedOriginY = 50.0f;
    [self loadBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd) atOrigin:CGPointMake(expectedOriginX, expectedOriginY) withSize:CGSizeMake(320.0f, 50.0f)];
    CGRect currentPosition = [self getCurrentPosition];
    CGFloat originX = currentPosition.origin.x;
    CGFloat originY = currentPosition.origin.y;
    
    STAssertTrue(expectedOriginX == originX && expectedOriginY == originY, @"Expected origin %f x %f, received %f x %f", expectedOriginX, expectedOriginY, originX, originY);
 
    [self clearTest];
}*/

#pragma mark MRAID Helper Functions

- (void)clearTest {
    self.webView = nil;
    [self bannerRemoveFromSuperview];
    if ([[UIApplication sharedApplication] statusBarOrientation] != UIInterfaceOrientationPortrait) {
        [self rotateDeviceToOrientation:UIInterfaceOrientationPortrait];
    }
    [super clearTest];
}

- (void)loadBasicMRAIDBanner {
    [self loadBasicMRAIDBannerWithSelectorName:@"Test Ad"];
}

- (void)loadBasicMRAIDBannerWithSelectorName:(NSString *)selector {
    [self loadBasicMRAIDBannerWithSelectorName:selector atOrigin:CGPointMake(0.0f, 0.0f) withSize:CGSizeMake(320.0f, 50.0f)];
}

- (void)loadBasicMRAIDBannerAtOrigin:(CGPoint)origin withSize:(CGSize)size {
    [self loadBasicMRAIDBannerWithSelectorName:@"Test Ad" atOrigin:origin withSize:size];
}

- (void)loadBasicMRAIDBannerWithSelectorName:(NSString *)selector atOrigin:(CGPoint)origin withSize:(CGSize)size {
    [self stubWithBody:[ANMRAIDTestResponses basicMRAIDBannerWithSelectorName:selector]];
    [self loadBannerAdAtOrigin:CGPointMake(origin.x, origin.y) withSize:CGSizeMake(size.width, size.height)];
    STAssertTrue([self waitForCompletion:MRAID_TESTS_TIMEOUT], @"Ad load timed out");
    STAssertTrue(self.adDidLoadCalled, @"Success callback should be called");
    STAssertFalse(self.adFailedToLoadCalled, @"Failure callback should not be called");
    id wv = [[self.banner subviews] firstObject];
    STAssertTrue([wv isKindOfClass:[ANWebView class]], @"Expected ANWebView as subview of BannerAdView");
    self.webView = (ANWebView *)wv;
}

- (void)addBannerAsSubview {
    if (self.banner) {
        [self.banner removeFromSuperview];
        [self.banner.rootViewController.view addSubview:self.banner];
        [self delay:MRAID_TESTS_DEFAULT_DELAY];
    }
}

- (void)moveBannerSubviewToOrigin:(CGPoint)origin {
    if (self.banner) {
        [self.banner removeFromSuperview];
        [self.banner setFrame:CGRectMake(origin.x, origin.y, self.banner.adSize.width, self.banner.adSize.height)];
        [self.banner.rootViewController.view addSubview:self.banner];
        [self delay:MRAID_TESTS_DEFAULT_DELAY];
    }
}

- (void)loadBannerAdAtOrigin:(CGPoint)origin withSize:(CGSize)size {
    self.banner = [[ANBannerAdView alloc]
                   initWithFrame:CGRectMake(origin.x, origin.y, size.width, size.height)
                   placementId:@"1"
                   adSize:CGSizeMake(320, 50)];
    self.banner.rootViewController = [[UIApplication sharedApplication].delegate window].rootViewController;
    self.banner.autoRefreshInterval = 0.0;
    self.banner.delegate = self;
    [self.banner loadAd];
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
    [self delay:MRAID_TESTS_DEFAULT_DELAY];
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

- (CGPoint)getScreenSize {
    return CGPointMake([[self mraidNativeCall:@"getScreenSize()[\"width\"]" withDelay:0] floatValue], [[self mraidNativeCall:@"getScreenSize()[\"height\"]" withDelay:0] floatValue]);
}

- (CGPoint)getMaxSize {
    return CGPointMake([[self mraidNativeCall:@"getMaxSize()[\"width\"]" withDelay:0] floatValue], [[self mraidNativeCall:@"getMaxSize()[\"height\"]" withDelay:0] floatValue]);
}

- (CGRect)getCurrentPosition {
    return CGRectMake([[self mraidNativeCall:@"getCurrentPosition()[\"x\"]" withDelay:0] floatValue],
                      [[self mraidNativeCall:@"getCurrentPosition()[\"y\"]" withDelay:0] floatValue],
                      [[self mraidNativeCall:@"getCurrentPosition()[\"width\"]" withDelay:0] floatValue],
                      [[self mraidNativeCall:@"getCurrentPosition()[\"height\"]" withDelay:0] floatValue]);
}

- (CGRect)getDefaultPosition {
    return CGRectMake([[self mraidNativeCall:@"getDefaultPosition()[\"x\"]" withDelay:0] floatValue],
                      [[self mraidNativeCall:@"getDefaultPosition()[\"y\"]" withDelay:0] floatValue],
                      [[self mraidNativeCall:@"getDefaultPosition()[\"width\"]" withDelay:0] floatValue],
                      [[self mraidNativeCall:@"getDefaultPosition()[\"height\"]" withDelay:0] floatValue]);
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