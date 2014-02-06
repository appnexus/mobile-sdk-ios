/*   Copyright 2014 APPNEXUS INC
 
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

#import "ANWebView.h"
#import "ANBaseTestCase.h"
#import "ANMRAIDTestResponses.h"
#import "ANLogging.h"
#import "ANLogManager.h"

#define MRAID_TESTS_TIMEOUT 10.0
#define MRAID_TESTS_DEFAULT_DELAY 1.5

@interface UIDevice (HackyWayToRotateTheDeviceForTestingPurposesBecauseAppleDeclaredSuchAMethodInTheirPrivateImplementationOfTheUIDeviceClass)
-(void)setOrientation:(UIInterfaceOrientation)orientation animated:(BOOL)animated;
-(void)setOrientation:(UIInterfaceOrientation)orientation;
@end

@interface MRAIDTests : ANBaseTestCase
@property (strong, nonatomic) ANWebView *webView;
@end

@implementation MRAIDTests

#pragma mark Basic MRAID Banner Test

- (void)testSuccessfulBannerDidLoad {
    [self loadBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    [self addBannerAsSubview];
    
    [self clearTest];
}

#pragma mark mraid.isViewable()

- (void)testBasicViewability { // MS-453
    [self loadBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    STAssertFalse([[self isViewable] boolValue], @"Expected ANWebView not to be visible");
    
    [self addBannerAsSubview];
    STAssertTrue([[self isViewable] boolValue], @"Expected ANWebView to be visible");
    
    [self bannerRemoveFromSuperview];
    STAssertFalse([[self isViewable] boolValue], @"Expected ANWebView not to be visible");
    
    [self clearTest];
}

#pragma mark mraid.setOrientationProperties()

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

#pragma mark mraid.expand()

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

#pragma mark mraid.getScreenSize()

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

- (void)testScreenSizeLandscapeOnRotate {
    [self loadBasicMRAIDBanner];
    [self rotateDeviceToOrientation:UIInterfaceOrientationLandscapeLeft];
    CGPoint screenSize = [self getScreenSize];
    CGFloat width = screenSize.x;
    CGFloat height = screenSize.y;
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat expectedWidth = screenBounds.size.height;
    CGFloat expectedHeight = screenBounds.size.width;
    STAssertTrue(expectedWidth == width && expectedHeight == height, [NSString stringWithFormat:@"Expected landscape screen bounds %f x %f, received screen bounds %f x %f", expectedWidth, expectedHeight, width, height]);
    
    [self rotateDeviceToOrientation:UIInterfaceOrientationPortrait];
    screenSize = [self getScreenSize];
    width = screenSize.x;
    height = screenSize.y;
    expectedWidth = screenBounds.size.width;
    expectedHeight = screenBounds.size.height;
    STAssertTrue(expectedWidth == width && expectedHeight == height, [NSString stringWithFormat:@"Expected portrait screen bounds %f x %f, received screen bounds %f x %f", expectedWidth, expectedHeight, width, height]);
    
    [self clearTest];
}

#pragma mark mraid.getMaxSize()

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

- (void)testMaxSizeLandscapeOnRotate {
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
    
    [self rotateDeviceToOrientation:UIInterfaceOrientationPortraitUpsideDown];
    maxSize = [self getMaxSize];
    width = maxSize.x;
    height = maxSize.y;
    expectedWidth = screenBounds.size.width;
    expectedHeight = screenBounds.size.height;
    if (![UIApplication sharedApplication].statusBarHidden) {
        expectedHeight -= [UIApplication sharedApplication].statusBarFrame.size.height;
    }
    STAssertTrue(expectedWidth == width && expectedHeight == height, [NSString stringWithFormat:@"Expected portrait max size %f x %f, received %f x %f", expectedWidth, expectedHeight, width, height]);
    
    [self clearTest];
}

#pragma mark mraid.getCurrentPosition()

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

#pragma mark mraid.getDefaultPosition()

- (void)testDefaultPositionPortraitSizeOnLoad {
    [self loadBasicMRAIDBanner];
    [self addBannerAsSubview];
    
    CGRect defaultPosition = [self getDefaultPosition];
    CGFloat width = defaultPosition.size.width;
    CGFloat height = defaultPosition.size.height;
    CGFloat expectedWidth = self.banner.adSize.width;
    CGFloat expectedHeight = self.banner.adSize.height;

    STAssertTrue(expectedWidth == width && expectedHeight == height, @"Expected portrait size %f x %f, received %f x %f", expectedWidth, expectedHeight, width, height);
    
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

#pragma mark mraid.getState()

- (void)testBasicStateChange {
    [self loadBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    [self addBannerAsSubview];
    
    [self expand];
    [self assertState:@"expanded"];
    
    [self close];
    [self assertState:@"default"];
    
    [self clearTest];
}


- (void)testResizeWhileExpandedStateChange {
    [self loadBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    [self addBannerAsSubview];
    [self expand];
    [self assertState:@"expanded"];
    [self setResizePropertiesResizeToSize:CGSizeMake(320.0f, 200.0f)
                               withOffset:CGPointZero
                  withCustomClosePosition:@"bottom-center"
                           allowOffscreen:YES];
    [self resize];
    [self assertState:@"expanded"];
    [self close];
    [self clearTest];
}

- (void)testResizeToExpandStateChange {
    [self loadBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    [self addBannerAsSubview];
    [self setResizePropertiesResizeToSize:CGSizeMake(320.0f, 200.0f)
                               withOffset:CGPointZero
                  withCustomClosePosition:@"bottom-center"
                           allowOffscreen:YES];
    [self resize];
    [self assertState:@"resized"];
    [self expand];
    [self assertState:@"expanded"];
    [self close];
    [self clearTest];
}

- (void)testDefaultToHiddenStateChange {
    [self loadBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    [self addBannerAsSubview];
    [self assertState:@"default"];
    [self close];
    [self assertState:@"hidden"];
    [self clearTest];
}

- (void)testExpandedToHiddenStateChange {
    [self loadBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    [self addBannerAsSubview];
    [self assertState:@"default"];
    [self expand];
    [self assertState:@"expanded"];
    [self close];
    [self assertState:@"default"];
    [self close];
    [self assertState:@"hidden"];
    [self clearTest];
}
    
- (void)testHiddenDoesNotRevertToAnyOtheState {
    [self loadBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    [self addBannerAsSubview];
    [self assertState:@"default"];
    [self close];
    [self assertState:@"hidden"];
    [self expand];
    [self assertState:@"hidden"];
    [self setResizePropertiesResizeToSize:CGSizeMake(320.0f, 200.0f) withOffset:CGPointZero];
    [self resize];
    [self assertState:@"hidden"];
    [self clearTest];
}

#pragma mark mraid.resizeProperties

- (void)testBasicSetResizeProperties { // MS-525
    [self loadBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    [self addBannerAsSubview];
    CGFloat resizeWidth = 320.0f;
    CGFloat resizeHeight = 200.0f;
    [self setResizePropertiesResizeToSize:CGSizeMake(resizeWidth, resizeHeight)
                               withOffset:CGPointZero
                  withCustomClosePosition:@"bottom-center"
                           allowOffscreen:YES];
    NSString *width = [self getResizePropertiesWidth];
    NSString *height = [self getResizePropertiesHeight];
    NSString *offsetX = [self getResizePropertiesOffsetX];
    NSString *offsetY = [self getResizePropertiesOffsetY];
    STAssertTrue([width length] > 0, @"Expected width to be defined");
    STAssertTrue([height length] > 0, @"Expected height to be defined");
    STAssertTrue([offsetX length] > 0, @"Expected offsetX to be defined");
    STAssertTrue([offsetY length] > 0, @"Expected offsetY to be defined");
    STAssertTrue([width isEqualToString:([NSString stringWithFormat:@"%d", (int)resizeWidth])], @"Expected different width");
    STAssertTrue([height isEqualToString:([NSString stringWithFormat:@"%d", (int)resizeHeight])], @"Expected different height");
    STAssertTrue([offsetX isEqualToString:@"0"], @"Expected offsetX to be 0");
    STAssertTrue([offsetY isEqualToString:@"0"], @"Expected offsetY to be 0");

    [self resize];
    [self assertState:@"resized"];
    STAssertTrue(self.banner.frame.size.width == resizeWidth, @"Expected new width of banner frame to be resized width");
    STAssertTrue(self.banner.frame.size.height == resizeHeight, @"Expected new height of banner frame to be resized height");
    [self clearTest];
}

- (void)testSetResizePropertiesOnlySizeAndOffset { // MS-525
    [self loadBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    [self addBannerAsSubview];
    CGFloat resizeHeight = 200.0f;
    [self setResizePropertiesResizeToSize:CGSizeMake(320.0f, resizeHeight) withOffset:CGPointZero];
    [self resize];
    STAssertTrue(self.banner.frame.size.height == resizeHeight , @"Expected new height of banner frame to be resized height");
    [self clearTest];
}

- (void)testGetCustomCloseAndAllowOffscreenAfterSettingSizeAndOffset { // MS-525
    [self loadBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    [self addBannerAsSubview];
    CGFloat resizeHeight = 200.0f;
    [self setResizePropertiesResizeToSize:CGSizeMake(320.0f, resizeHeight) withOffset:CGPointZero];
    NSString *customClosePosition = [self getResizePropertiesCustomClosePosition];
    NSString *allowOffscreen = [self getResizePropertiesAllowOffscreen];
    STAssertTrue([customClosePosition length] > 0, @"Expected custom close position to be defined");
    STAssertTrue([allowOffscreen length] > 0, @"Expected allow offscreen to be defined");
    [self clearTest];
}
    
- (void)testSetResizePropertiesMultipleTimes { // MS-525
    [self loadBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    [self addBannerAsSubview];
    CGSize size1 = CGSizeMake(320.0f, 250.0f);
    [self setResizePropertiesResizeToSize:size1 withOffset:CGPointMake(-50.0f, 240.0f) withCustomClosePosition:@"top-left" allowOffscreen:NO];
    NSString *customClosePosition = [self getResizePropertiesCustomClosePosition];
    NSString *allowOffscreen = [self getResizePropertiesAllowOffscreen];
    STAssertTrue([customClosePosition isEqualToString:@"top-left"], @"Expected close position to be top left");
    STAssertTrue([allowOffscreen isEqualToString:@"false"], @"Expected allow offscreen to be false");
    CGSize size2 = CGSizeMake(500.0f, 300.0f);
    [self setResizePropertiesResizeToSize:size2 withOffset:CGPointMake(100.0f, 270.0f)];
    NSString *width = [self getResizePropertiesWidth];
    NSString *height = [self getResizePropertiesHeight];
    STAssertTrue([width length] > 0, @"Expected width to be defined");
    STAssertTrue([height length] > 0, @"Expected height to be defined");
    STAssertTrue([width isEqualToString:@"500"], @"Expected different width");
    STAssertTrue([height isEqualToString:@"300"], @"Expected different height");
    NSString *offsetX = [self getResizePropertiesOffsetX];
    NSString *offsetY = [self getResizePropertiesOffsetY];
    STAssertTrue([offsetX isEqualToString:@"100"], @"Expected offsetX to be 100");
    STAssertTrue([offsetY isEqualToString:@"270"], @"Expected offsetY to be 270");
    customClosePosition = [self getResizePropertiesCustomClosePosition];
    allowOffscreen = [self getResizePropertiesAllowOffscreen];
    STAssertTrue([customClosePosition isEqualToString:@"top-right"], @"Expected close position to be top right (default)");
    STAssertTrue([allowOffscreen isEqualToString:@"true"], @"Expected allow offscreen to be true (default)");
    [self clearTest];
}
    
- (void)testResizeAfterSettingIncompleteResizeProperties { // MS-525
    [self loadBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    [self addBannerAsSubview];
    CGSize size = CGSizeMake(320.0f, 250.0f);
    [self setResizePropertiesResizeToSize:size];
    NSString *width = [self getResizePropertiesWidth];
    NSString *height = [self getResizePropertiesHeight];
    NSString *offsetX = [self getResizePropertiesOffsetX];
    NSString *offsetY = [self getResizePropertiesOffsetY];

    STAssertFalse([offsetX length], @"Expected offsetX to be undefined");
    STAssertFalse([offsetY length], @"Expected offsetY to be undefined");
    STAssertFalse([width length], @"Expected width to be undefined");
    STAssertFalse([height length], @"Expected height to be undefined");

    [self resize];
    [self assertState:@"default"]; // Should not have resized
    [self clearTest];
}

#pragma mark mraid.expandProperties

- (void)testSetExpandPropertiesOnlySize {
    [self loadBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    [self addBannerAsSubview];
    CGFloat expandHeight = 200.0f;
    [self setExpandPropertiesExpandToSize:CGSizeMake(320.0f, expandHeight)];
    NSString *useCustomClose = [self getExpandPropertiesUseCustomClose];
    STAssertTrue([useCustomClose isEqualToString:@"false"], @"Expected useCustomClose to be false");
    [self expand];
    STAssertTrue(self.banner.frame.size.height == expandHeight , @"Expected new height of banner frame to be expanded height");
    [self close];
    [self clearTest];
}

- (void)testSetExpandPropertiesEmptyObject { // MS-525
    [self loadBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    [self addBannerAsSubview];
    [self setExpandPropertiesEmpty];
    NSString *width = [self getExpandPropertiesWidth];
    NSString *height = [self getExpandPropertiesHeight];
    STAssertTrue([width length] > 0, @"Expected width to be defined");
    STAssertTrue([height length] > 0, @"Expected height to be defined");
    [self clearTest];
}

- (void)testExpandAfterSetExpandPropertiesEmptyObject { // MS-525
    [self loadBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    [self addBannerAsSubview];
    [self setExpandPropertiesEmpty];
    [self expand];
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGSize currentSize = [self getCurrentPosition].size;
    STAssertTrue(CGSizeEqualToSize(screenSize, currentSize), @"Expected expanded size to be screen size");
    [self close];
    [self clearTest];
}

- (void)testGetExpandPropertiesAfterSettingSize { // MS-525
    [self loadBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    [self addBannerAsSubview];
    CGFloat expandHeight = 200.0f;
    [self setExpandPropertiesExpandToSize:CGSizeMake(320.0f, expandHeight)];
    NSString *customClose = [self getExpandPropertiesUseCustomClose];
    STAssertTrue([customClose length], @"expected custom close value to not be undefined");
    STAssertTrue([customClose isEqualToString:@"false"], @"expected default value of custom close to be false");
    
    // isModal works because it is set on every call to setExpandProperties.
    NSString *isModal = [self getExpandPropertiesIsModal];
    STAssertTrue(![isModal isEqualToString:@""], @"expected isModal value to not be undefined");
    STAssertTrue([isModal isEqualToString:@"true"], @"expected default value of isModal to be true");
    [self clearTest];
}

- (void)testSetExpandPropertiesToSizeZero {
    [self loadBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    [self addBannerAsSubview];
    [self setExpandPropertiesExpandToSize:CGSizeZero];
    [self expand];
    [self assertState:@"default"];
    [self clearTest];
}
    
- (void)testSetExpandPropertiesToNegativeSize {
    [self loadBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    [self addBannerAsSubview];
    [self setExpandPropertiesExpandToSize:CGSizeMake(-10.0f, 250.0f)];
    [self expand];
    [self assertState:@"default"];
    [self clearTest];
}
    
- (void)testSetExpandPropertiesMultipleTimes {
    [self loadBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    [self addBannerAsSubview];
    CGSize size1 = CGSizeMake(320.0f, 250.0f);
    BOOL useCustomClose1 = YES;
    BOOL isModal1 = NO;
    [self setExpandPropertiesExpandToSize:size1 useCustomClose:useCustomClose1 setModal:isModal1];
    NSString *useCustomClose = [self getExpandPropertiesUseCustomClose];
    NSString *width = [self getExpandPropertiesWidth];
    NSString *height = [self getExpandPropertiesHeight];
    NSString *isModal = [self getExpandPropertiesIsModal];
    STAssertTrue([useCustomClose isEqualToString:@"true"], @"Expected useCustomClose to be true");
    STAssertTrue([width isEqualToString:@"320"], @"Expected width to be 320");
    STAssertTrue([height isEqualToString:@"250"], @"Expected height to be 250");
    STAssertTrue([isModal isEqualToString:@"true"], @"Expected isModal to be true");
    CGSize size2 = CGSizeMake(500.0f, 300.0f);
    [self setExpandPropertiesExpandToSize:size2];
    useCustomClose = [self getExpandPropertiesUseCustomClose];
    width = [self getExpandPropertiesWidth];
    height = [self getExpandPropertiesHeight];
    isModal = [self getExpandPropertiesIsModal];
    STAssertTrue([useCustomClose isEqualToString:@"false"], @"Expected useCustomClose to be false");
    STAssertTrue([width isEqualToString:@"500"], @"Expected width to be 320");
    STAssertTrue([height isEqualToString:@"300"], @"Expected height to be 250");
    STAssertTrue([isModal isEqualToString:@"true"], @"Expected isModal to be true");
    [self clearTest];
}

    
// WILL FAIL: Initial getExpandProperties returns -1 as width and height
/*- (void)testGetExpandPropertiesInitialSize {
    [self loadBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    [self addBannerAsSubview];
    CGSize initSize = [self getExpandPropertiesSize];
    CGRect actualBounds = [[UIScreen mainScreen] bounds];
    STAssertTrue(actualBounds.size.width == initSize.width && actualBounds.size.height == initSize.height, @"Expected default expand properties to reflect actual screen values");
    [self clearTest];
}*/

#pragma mark mraid.supports()

- (void)testSupportSMS {
    [self loadBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    BOOL isSupported = [self supports:@"sms"];
    #if TARGET_IPHONE_SIMULATOR
    STAssertFalse(isSupported, @"Expected iphone simulator to not support SMS");
    #else
    STAssertTrue(isSupported, @"Expected iPhone device to support SMS");
    #endif
    [self clearTest];
}

- (void)testSupportTel {
    [self loadBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    BOOL isSupported = [self supports:@"tel"];
    #if TARGET_IPHONE_SIMULATOR
    STAssertFalse(isSupported, @"Expected iphone simulator to not support Tel");
    #else
    STAssertTrue(isSupported, @"Expected iPhone device to support Tel");
    #endif
    [self clearTest];
}

- (void)testSupportCal {
    [self loadBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    BOOL isSupported = [self supports:@"calendar"];
    STAssertTrue(isSupported, @"Expected calendar support");
    [self clearTest];
}

- (void)testSupportInlineVideo {
    [self loadBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    BOOL isSupported = [self supports:@"inlineVideo"];
    STAssertTrue(isSupported, @"Expected inline video support");
    [self clearTest];
}

- (void)testSupportStorePicture {
    [self loadBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    BOOL isSupported = [self supports:@"storePicture"];
    STAssertTrue(isSupported, @"Expected store picture support");
    [self clearTest];
}

#pragma mark Helper Functions

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
    self.banner = [[ANBannerAdView alloc] initWithFrame:CGRectMake(origin.x, origin.y, size.width, size.height)
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

- (void)resize {
    [self mraidNativeCall:@"resize()" withDelay:MRAID_TESTS_DEFAULT_DELAY];
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

- (CGSize)getExpandPropertiesSize {
    return CGSizeMake([[self mraidNativeCall:@"getExpandProperties()[\"width\"]" withDelay:0] floatValue], [[self mraidNativeCall:@"getExpandProperties()[\"height\"]" withDelay:0] floatValue]);
}

- (NSString *)getExpandPropertiesUseCustomClose { // want to test actual response against being "undefined"
    return [self mraidNativeCall:@"getExpandProperties()[\"useCustomClose\"]" withDelay:0];
}

- (NSString *)getExpandPropertiesIsModal { // want to validate actual response against being "undefined"
    return [self mraidNativeCall:@"getExpandProperties()[\"isModal\"]" withDelay:0];
}

- (NSString *)getExpandPropertiesWidth {
    return [self mraidNativeCall:@"getExpandProperties()[\"width\"]" withDelay:0];
}

- (NSString *)getExpandPropertiesHeight {
    return [self mraidNativeCall:@"getExpandProperties()[\"height\"]" withDelay:0];
}

- (void)setExpandPropertiesExpandToSize:(CGSize)size useCustomClose:(BOOL)useCustomClose setModal:(BOOL)isModal {
    [self mraidNativeCall:[NSString stringWithFormat:@"setExpandProperties({width:%f, height: %f, useCustomClose: %@, isModal: %@});", size.width, size.height,
                           useCustomClose ? @"true":@"false", isModal ? @"true":@"false"] withDelay:0];
}
    
- (void)setExpandPropertiesExpandToSize:(CGSize)size {
    [self mraidNativeCall:[NSString stringWithFormat:@"setExpandProperties({width:%f, height: %f});", size.width, size.height] withDelay:0];
}

- (void)setExpandPropertiesEmpty {
    [self mraidNativeCall:[NSString stringWithFormat:@"setExpandProperties({});"] withDelay:0];
}

- (void)setResizePropertiesEmpty {
    [self mraidNativeCall:[NSString stringWithFormat:@"setResizeProperties({});"] withDelay:0];
}

- (void)setResizePropertiesResizeToSize:(CGSize)size
                             withOffset:(CGPoint)offset
                withCustomClosePosition:(NSString *)position
                         allowOffscreen:(BOOL)allowOffscreen {
    NSString *offscreen = allowOffscreen ? @"true" : @"false";
    [self mraidNativeCall:[NSString stringWithFormat:@"setResizeProperties({width:%f, height: %f, offsetX: %f, offsetY: %f, customClosePosition: '%@', allowOffscreen: %@});",
                           size.width, size.height, offset.x, offset.y, position, offscreen] withDelay:0];
    
}

- (void)setResizePropertiesResizeToSize:(CGSize)size withOffset:(CGPoint)offset {
    [self mraidNativeCall:[NSString stringWithFormat:@"setResizeProperties({width:%f, height: %f, offsetX: %f, offsetY: %f});", size.width, size.height, offset.x, offset.y] withDelay:0];
}

- (void)setResizePropertiesResizeToSize:(CGSize)size {
    [self mraidNativeCall:[NSString stringWithFormat:@"setResizeProperties({width:%f, height: %f});", size.width, size.height] withDelay:0];
}

- (NSString *)getResizePropertiesWidth {
    return [self mraidNativeCall:@"getResizeProperties()[\"width\"]" withDelay:0];
}

- (NSString *)getResizePropertiesHeight {
    return [self mraidNativeCall:@"getResizeProperties()[\"height\"]" withDelay:0];
}

- (NSString *)getResizePropertiesOffsetX {
    return [self mraidNativeCall:@"getResizeProperties()[\"offsetX\"]" withDelay:0];
}

- (NSString *)getResizePropertiesOffsetY {
    return [self mraidNativeCall:@"getResizeProperties()[\"offsetY\"]" withDelay:0];
}

- (NSString *)getResizePropertiesCustomClosePosition {
    return [self mraidNativeCall:@"getResizeProperties()[\"customClosePosition\"]" withDelay:0];
}

- (NSString *)getResizePropertiesAllowOffscreen {
    return [self mraidNativeCall:@"getResizeProperties()[\"allowOffscreen\"]" withDelay:0];
}

- (BOOL)supports:(NSString *)feature {
    return [[self mraidNativeCall:[NSString stringWithFormat:@"supports('%@')", feature] withDelay:0] boolValue];
}

- (NSString *)mraidNativeCall:(NSString *)script withDelay:(NSTimeInterval)delay {
    NSString *response = [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"mraid.%@",script]];
    if (delay) {
        [self delay:delay];
    }
    return response;
}

@end