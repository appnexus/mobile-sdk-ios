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
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    [self clearTest];
}

#pragma mark mraid.isViewable()

- (void)testBasicViewability { // MS-453
    [self loadBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    XCTAssertFalse([[self isViewable] boolValue], @"Expected ANWebView not to be visible");
    
    [self addBannerAsSubview];
    XCTAssertTrue([[self isViewable] boolValue], @"Expected ANWebView to be visible");
    
    [self removeBannerFromSuperview];
    XCTAssertFalse([[self isViewable] boolValue], @"Expected ANWebView not to be visible");
    
    [self clearTest];
}

#pragma mark mraid.setOrientationProperties()

- (void)testForceOrientationLandscapeFromPortrait { // MS-481
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    
    [self setOrientationPropertiesWithAllowOrientationChange:NO forceOrientation:@"landscape"];
    [self expand];
    XCTAssertTrue([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft, @"Expected landscape left orientation");
    
    [self close];
    XCTAssertTrue([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait, @"Expected portrait orientation");
    
    [self clearTest];
}

- (void)testForceOrientationPortraitFromLandscape { // MS-481
    [self rotateDeviceToOrientation:UIInterfaceOrientationLandscapeRight];
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    [self setOrientationPropertiesWithAllowOrientationChange:NO forceOrientation:@"portrait"];
    [self expand];
    XCTAssertTrue([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait, @"Expected portrait orientation");
    
    [self close];
    XCTAssertTrue([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight, @"Expected landscape right orientation");
    
    [self clearTest];
}

- (void)testForceOrientationLandscapeFromLandscapeRight { // MS-481
    [self rotateDeviceToOrientation:UIInterfaceOrientationLandscapeRight];
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    [self setOrientationPropertiesWithAllowOrientationChange:NO forceOrientation:@"landscape"];
    [self expand];
    XCTAssertTrue([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight, @"Expected landscape right orientation");

    [self close];
    XCTAssertTrue([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight, @"Expected landscape right orientation");

    [self clearTest];
}

#pragma mark mraid.expand()

- (void)testExpandFromPortraitUpsideDown { // MS-510
    [self rotateDeviceToOrientation:UIInterfaceOrientationPortraitUpsideDown];
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    [self expand];
    XCTAssertFalse([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait, @"Did not expect portrait right side up orientation");
    XCTAssertTrue([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown, @"Expected portrait upside down orientation");
    
    [self close];
    XCTAssertTrue([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown, @"Expected portrait upside down orientation");

    [self clearTest];
}

#pragma mark mraid.getScreenSize()

- (void)testScreenSizePortraitOnLoad {
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    CGPoint screenSize = [self getScreenSize];
    CGFloat width = screenSize.x;
    CGFloat height = screenSize.y;
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat expectedWidth = screenBounds.size.width;
    CGFloat expectedHeight = screenBounds.size.height;
    XCTAssertTrue(expectedWidth == width && expectedHeight == height, @"Expected portrait screen bounds %f x %f, received screen bounds %f x %f", expectedWidth, expectedHeight, width, height);
    [self clearTest];
}

- (void)testScreenSizeLandscapeOnLoad {
    [self rotateDeviceToOrientation:UIInterfaceOrientationLandscapeLeft];
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    CGPoint screenSize = [self getScreenSize];
    CGFloat width = screenSize.x;
    CGFloat height = screenSize.y;
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat expectedWidth = screenBounds.size.height;
    CGFloat expectedHeight = screenBounds.size.width;
    XCTAssertTrue(expectedWidth == width && expectedHeight == height, @"Expected landscape screen bounds %f x %f, received screen bounds %f x %f", expectedWidth, expectedHeight, width, height);
    [self clearTest];
}

- (void)testScreenSizeLandscapeOnRotate {
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    [self rotateDeviceToOrientation:UIInterfaceOrientationLandscapeLeft];
    CGPoint screenSize = [self getScreenSize];
    CGFloat width = screenSize.x;
    CGFloat height = screenSize.y;
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat expectedWidth = screenBounds.size.height;
    CGFloat expectedHeight = screenBounds.size.width;
    XCTAssertTrue(expectedWidth == width && expectedHeight == height, @"Expected landscape screen bounds %f x %f, received screen bounds %f x %f", expectedWidth, expectedHeight, width, height);
    
    [self rotateDeviceToOrientation:UIInterfaceOrientationPortrait];
    screenSize = [self getScreenSize];
    width = screenSize.x;
    height = screenSize.y;
    expectedWidth = screenBounds.size.width;
    expectedHeight = screenBounds.size.height;
    XCTAssertTrue(expectedWidth == width && expectedHeight == height, @"Expected portrait screen bounds %f x %f, received screen bounds %f x %f", expectedWidth, expectedHeight, width, height);
    
    [self clearTest];
}

#pragma mark mraid.getMaxSize()

- (void)testMaxSizePortraitOnLoad {
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    CGPoint maxSize = [self getMaxSize];
    CGFloat width = maxSize.x;
    CGFloat height = maxSize.y;
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat expectedWidth = screenBounds.size.width;
    CGFloat expectedHeight = screenBounds.size.height;
    
    if (![UIApplication sharedApplication].statusBarHidden) {
        expectedHeight -= [UIApplication sharedApplication].statusBarFrame.size.height;
    }
    XCTAssertTrue(expectedWidth == width && expectedHeight == height, @"Expected portrait max size %f x %f, received %f x %f", expectedWidth, expectedHeight, width, height);

    [self clearTest];
}

- (void)testMaxSizeLandscapeOnLoad {
    [self rotateDeviceToOrientation:UIInterfaceOrientationLandscapeRight];
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    
    CGPoint maxSize = [self getMaxSize];
    CGFloat width = maxSize.x;
    CGFloat height = maxSize.y;
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat expectedWidth = screenBounds.size.height;
    CGFloat expectedHeight = screenBounds.size.width;

    if (![UIApplication sharedApplication].statusBarHidden) {
        expectedHeight -= [UIApplication sharedApplication].statusBarFrame.size.width;
    }
    XCTAssertTrue(expectedWidth == width && expectedHeight == height, @"Expected landscape max size %f x %f, received %f x %f", expectedWidth, expectedHeight, width, height);

    [self clearTest];
}

- (void)testMaxSizeLandscapeOnRotate {
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    XCTAssertTrue(UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation), @"Expected to start in portrait orientation");
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
    XCTAssertTrue(expectedWidth == width && expectedHeight == height, @"Expected landscape max size %f x %f, received %f x %f", expectedWidth, expectedHeight, width, height);
    
    [self rotateDeviceToOrientation:UIInterfaceOrientationPortraitUpsideDown];
    maxSize = [self getMaxSize];
    width = maxSize.x;
    height = maxSize.y;
    expectedWidth = screenBounds.size.width;
    expectedHeight = screenBounds.size.height;
    if (![UIApplication sharedApplication].statusBarHidden) {
        expectedHeight -= [UIApplication sharedApplication].statusBarFrame.size.height;
    }
    XCTAssertTrue(expectedWidth == width && expectedHeight == height, @"Expected portrait max size %f x %f, received %f x %f", expectedWidth, expectedHeight, width, height);
    
    [self clearTest];
}

#pragma mark mraid.getCurrentPosition()

- (void)testCurrentPositionPortraitSizeOnLoad {
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    CGRect currentPosition = [self getCurrentPosition];
    CGFloat width = currentPosition.size.width;
    CGFloat height = currentPosition.size.height;
    CGFloat expectedWidth = self.banner.adSize.width;
    CGFloat expectedHeight = self.banner.adSize.height;
    
    XCTAssertTrue(expectedWidth == width && expectedHeight == height, @"Expected portrait size %f x %f, received %f x %f", expectedWidth, expectedHeight, width, height);
    
    [self clearTest];
}

- (void)testCurrentPositionLandscapeSizeOnLoad {
    [self rotateDeviceToOrientation:UIInterfaceOrientationLandscapeRight];
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    CGRect currentPosition = [self getCurrentPosition];
    CGFloat width = currentPosition.size.width;
    CGFloat height = currentPosition.size.height;
    CGFloat expectedWidth = self.banner.adSize.width;
    CGFloat expectedHeight = self.banner.adSize.height;
    
    XCTAssertTrue(expectedWidth == width && expectedHeight == height, @"Expected landscape size %f x %f, received %f x %f", expectedWidth, expectedHeight, width, height);
    
    [self clearTest];
}

- (void)testCurrentPositionPortraitSizeOnExpand {
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    [self expand];
    CGRect currentPosition = [self getCurrentPosition];
    CGFloat width = currentPosition.size.width;
    CGFloat height = currentPosition.size.height;

    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat expectedWidth = screenBounds.size.width;
    CGFloat expectedHeight = screenBounds.size.height;

    XCTAssertTrue(expectedWidth == width && expectedHeight == height, @"Expected portrait size %f x %f, received %f x %f", expectedWidth, expectedHeight, width, height);
    
    [self close];
    [self clearTest];
}

- (void)testCurrentPositionPortraitOriginOnLoad {
     CGFloat expectedOriginX = 0.0f;
     CGFloat expectedOriginY = 50.0f;
     [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd) atOrigin:CGPointMake(expectedOriginX, expectedOriginY) withSize:CGSizeMake(320.0f, 50.0f)];
     CGRect currentPosition = [self getCurrentPosition];
     CGFloat originX = currentPosition.origin.x;
     CGFloat originY = currentPosition.origin.y;
     
     XCTAssertTrue(expectedOriginX == originX && expectedOriginY == originY, @"Expected origin %f x %f, received %f x %f", expectedOriginX, expectedOriginY, originX, originY);
     
     [self clearTest];
}

- (void)testCurrentPositionPortraitOriginOnExpand {
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd) atOrigin:CGPointMake(0.0f, 50.0f) withSize:CGSizeMake(320.0f, 50.0f)];
    [self expand];
    CGRect currentPosition = [self getCurrentPosition];
    CGFloat expectedOriginX = 0.0f;
    CGFloat expectedOriginY = 0.0f;

    CGFloat originX = currentPosition.origin.x;
    CGFloat originY = currentPosition.origin.y;
    
    XCTAssertTrue(expectedOriginX == originX && expectedOriginY == originY, @"Expected origin %f x %f, received %f x %f", expectedOriginX, expectedOriginY, originX, originY);
    
    [self close];
    [self clearTest];
}

- (void)testCurrentPositionPortraitOriginOnResize {
    CGFloat expectedOriginX = 100.0f;
    CGFloat expectedOriginY = 50.0f;

    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd) atOrigin:CGPointMake(expectedOriginX, expectedOriginY) withSize:CGSizeMake(320.0f, 50.0f)];
    [self setResizePropertiesResizeToSize:CGSizeMake(320.0f, 200.0f)
                               withOffset:CGPointZero
                  withCustomClosePosition:@"bottom-center"
                           allowOffscreen:YES];
    [self resize];
    CGRect currentPosition = [self getCurrentPosition];
    
    CGFloat originX = currentPosition.origin.x;
    CGFloat originY = currentPosition.origin.y;
    
    XCTAssertTrue(expectedOriginX == originX && expectedOriginY == originY, @"Expected origin %f x %f, received %f x %f", expectedOriginX, expectedOriginY, originX, originY);
    
    [self close];
    [self clearTest];
}

- (void)testCurrentPositionPortraitOriginOnResizeWithCustomOffset {
    CGFloat initialOriginX = 100.0f;
    CGFloat initialOriginY = 50.0f;
    CGPoint resizeOffset = CGPointMake(-10.0f, -10.0f);
    
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd) atOrigin:CGPointMake(initialOriginX, initialOriginY) withSize:CGSizeMake(320.0f, 50.0f)];
    [self setResizePropertiesResizeToSize:CGSizeMake(320.0f, 200.0f)
                               withOffset:resizeOffset
                  withCustomClosePosition:@"bottom-center"
                           allowOffscreen:YES];
    [self resize];
    
    CGRect currentPosition = [self getCurrentPosition];
    CGFloat expectedX = 90.0f;
    CGFloat expectedY = 40.0f;
    CGFloat originX = currentPosition.origin.x;
    CGFloat originY = currentPosition.origin.y;
    
    XCTAssertTrue(expectedX == originX && expectedY == originY, @"Expected origin %f x %f, received %f x %f", expectedX, expectedY, originX, originY);
    
    [self close];
    
    currentPosition = [self getCurrentPosition];
    originX = currentPosition.origin.x;
    originY = currentPosition.origin.y;
    expectedX = initialOriginX;
    expectedY = initialOriginY;
    
    XCTAssertTrue(expectedX == originX && expectedY == originY, @"Expected origin %f x %f, received %f x %f", expectedX, expectedY, originX, originY);
    
    [self clearTest];
}

- (void)testCurrentPositionPortraitOriginOnResizeWithCustomOffsetAndSetFrameCalled {
    CGFloat expectedOriginX = 100.0f;
    CGFloat expectedOriginY = 50.0f;
    CGPoint resizeOffset = CGPointMake(-10.0f, -10.0f);
    
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd) atOrigin:CGPointMake(expectedOriginX, expectedOriginY) withSize:CGSizeMake(320.0f, 50.0f)];
    [self setResizePropertiesResizeToSize:CGSizeMake(320.0f, 200.0f)
                               withOffset:resizeOffset
                  withCustomClosePosition:@"bottom-center"
                           allowOffscreen:YES];
    [self resize];
    
    CGRect currentPosition = [self getCurrentPosition];
    CGFloat expectedX = 90.0f;
    CGFloat expectedY = 40.0f;
    CGFloat originX = currentPosition.origin.x;
    CGFloat originY = currentPosition.origin.y;
    
    XCTAssertTrue(expectedX == originX && expectedY == originY, @"Expected origin %f x %f, received %f x %f", expectedX, expectedY, originX, originY);
    
    [self moveBannerSubviewToOrigin:CGPointMake(150.0f, 60.0f)];
    
    // maintain resize offset
    expectedX = 140.0f;
    expectedY = 50.0f;
    
    currentPosition = [self getCurrentPosition];
    originX = currentPosition.origin.x;
    originY = currentPosition.origin.y;
    
    XCTAssertTrue(expectedX == originX && expectedY == originY, @"Expected origin %f x %f, received %f x %f", expectedX, expectedY, originX, originY);
    
    [self close];
    
    // revert resize offset on default
    expectedX = 150.0f;
    expectedY = 60.0f;

    currentPosition = [self getCurrentPosition];
    originX = currentPosition.origin.x;
    originY = currentPosition.origin.y;

    XCTAssertTrue(expectedX == originX && expectedY == originY, @"Expected origin %f x %f, received %f x %f", expectedX, expectedY, originX, originY);
    
    [self clearTest];
}

#pragma mark mraid.getDefaultPosition()

- (void)testDefaultPositionPortraitSizeOnLoad {
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    
    CGRect defaultPosition = [self getDefaultPosition];
    CGFloat width = defaultPosition.size.width;
    CGFloat height = defaultPosition.size.height;
    CGFloat expectedWidth = self.banner.adSize.width;
    CGFloat expectedHeight = self.banner.adSize.height;

    XCTAssertTrue(expectedWidth == width && expectedHeight == height, @"Expected portrait size %f x %f, received %f x %f", expectedWidth, expectedHeight, width, height);
    
    [self clearTest];
}

- (void)testDefaultPositionLandscapeSizeOnLoad {
    [self rotateDeviceToOrientation:UIInterfaceOrientationLandscapeRight];
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    
    CGRect defaultPosition = [self getDefaultPosition];
    CGFloat width = defaultPosition.size.width;
    CGFloat height = defaultPosition.size.height;
    CGFloat expectedWidth = self.banner.adSize.width;
    CGFloat expectedHeight = self.banner.adSize.height;
    
    XCTAssertTrue(expectedWidth == width && expectedHeight == height, @"Expected landscape size %f x %f, received %f x %f", expectedWidth, expectedHeight, width, height);
    
    [self clearTest];
}

- (void)testDefaultPositionPortraitOriginOnLoad {
    CGFloat expectedOriginX = 0.0f;
    CGFloat expectedOriginY = 50.0f;
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd) atOrigin:CGPointMake(expectedOriginX, expectedOriginY) withSize:CGSizeMake(320.0f, 50.0f)];
    CGRect defaultPosition = [self getDefaultPosition];
    CGFloat originX = defaultPosition.origin.x;
    CGFloat originY = defaultPosition.origin.y;
 
    XCTAssertTrue(expectedOriginX == originX && expectedOriginY == originY, @"Expected origin %f x %f, received %f x %f", expectedOriginX, expectedOriginY, originX, originY);
 
    [self clearTest];
}

- (void)testDefaultPositionPortraitOriginOnMove {
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    CGFloat expectedOriginX = 100.0f;
    CGFloat expectedOriginY = 25.0f;
    [self moveBannerSubviewToOrigin:CGPointMake(expectedOriginX, expectedOriginY)];
    CGRect defaultPosition = [self getDefaultPosition];
    CGFloat originX = defaultPosition.origin.x;
    CGFloat originY = defaultPosition.origin.y;
    
    XCTAssertTrue(expectedOriginX == originX && expectedOriginY == originY, @"Expected portrait origin %f x %f, received %f x %f", expectedOriginX, expectedOriginY, originX, originY);
    
    [self close];
    [self clearTest];
}

- (void)testDefaultPositionPortraitSizeOnExpand {
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    [self expand];
    
    CGRect defaultPosition = [self getDefaultPosition];
    CGFloat width = defaultPosition.size.width;
    CGFloat height = defaultPosition.size.height;
    CGFloat expectedWidth = self.banner.adSize.width;
    CGFloat expectedHeight = self.banner.adSize.height;
    
    XCTAssertTrue(expectedWidth == width && expectedHeight == height, @"Expected portrait size %f x %f, received %f x %f", expectedWidth, expectedHeight, width, height);
    
    [self close];
    [self clearTest];
}

- (void)testDefaultPositionLandscapeSizeOnExpand {
    [self rotateDeviceToOrientation:UIInterfaceOrientationLandscapeLeft];
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    [self expand];
    
    CGRect defaultPosition = [self getDefaultPosition];
    CGFloat width = defaultPosition.size.width;
    CGFloat height = defaultPosition.size.height;
    CGFloat expectedWidth = self.banner.adSize.width;
    CGFloat expectedHeight = self.banner.adSize.height;
    
    XCTAssertTrue(expectedWidth == width && expectedHeight == height, @"Expected portrait size %f x %f, received %f x %f", expectedWidth, expectedHeight, width, height);
    
    [self close];
    [self clearTest];
}

- (void)testDefaultPositionPortraitOriginOnExpand {
    CGFloat expectedOriginX = 100.0f;
    CGFloat expectedOriginY = 25.0f;
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd) atOrigin:CGPointMake(expectedOriginX, expectedOriginY) withSize:CGSizeMake(320.0f, 50.0f)];
    [self expand];
    
    CGRect defaultPosition = [self getDefaultPosition];
    CGFloat originX = defaultPosition.origin.x;
    CGFloat originY = defaultPosition.origin.y;
    
    XCTAssertTrue(expectedOriginX == originX && expectedOriginY == originY, @"Expected portrait origin %f x %f, received %f x %f", expectedOriginX, expectedOriginY, originX, originY);
    
    [self close];
    [self clearTest];
}

- (void)testDefaultPositionPortraitOriginOnRotateAndExpand {
    CGFloat expectedOriginX = 100.0f;
    CGFloat expectedOriginY = 25.0f;
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd) atOrigin:CGPointMake(expectedOriginX, expectedOriginY) withSize:CGSizeMake(320.0f, 50.0f)];
    [self rotateDeviceToOrientation:UIInterfaceOrientationLandscapeLeft];

    [self expand];
    
    CGRect defaultPosition = [self getDefaultPosition];
    CGFloat originX = defaultPosition.origin.x;
    CGFloat originY = defaultPosition.origin.y;
    
    XCTAssertTrue(expectedOriginX == originX && expectedOriginY == originY, @"Expected landscape origin %f x %f, received %f x %f", expectedOriginX, expectedOriginY, originX, originY);
    
    [self close];
    [self clearTest];
}

- (void)testDefaultPositionPortraitOnResizeMoveAndRotate {
    CGFloat originalOriginX = 100.0f;
    CGFloat originalOriginY = 25.0f;
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd) atOrigin:CGPointMake(originalOriginX, originalOriginY) withSize:CGSizeMake(320.0f, 50.0f)];
    [self setResizePropertiesResizeToSize:CGSizeMake(320.0f, 200.0f)
                               withOffset:CGPointZero
                  withCustomClosePosition:@"bottom-center"
                           allowOffscreen:YES];
    [self resize];
    [self rotateDeviceToOrientation:UIInterfaceOrientationLandscapeRight];
    CGFloat expectedOriginX = 200.0f;
    CGFloat expectedOriginY = 10.0f;
    [self moveBannerSubviewToOrigin:CGPointMake(expectedOriginX, expectedOriginY)];
    CGRect defaultPosition = [self getDefaultPosition];
    CGFloat originX = defaultPosition.origin.x;
    CGFloat originY = defaultPosition.origin.y;
    
    XCTAssertTrue(expectedOriginX == originX && expectedOriginY == originY, @"Expected portrait origin %f x %f, received %f x %f", expectedOriginX, expectedOriginY, originX, originY);
    XCTAssertFalse(originalOriginX == originX && originalOriginY == originY, @"Expected default position to be modified postion");
    
    [self close];
    [self clearTest];
}

- (void)testDefaultPositionPortraitOriginOnResizeWithCustomOffsetAndSetFrameCalled {
    CGFloat expectedOriginX = 100.0f;
    CGFloat expectedOriginY = 50.0f;
    CGPoint resizeOffset = CGPointMake(-10.0f, -10.0f);
    
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd) atOrigin:CGPointMake(expectedOriginX, expectedOriginY) withSize:CGSizeMake(320.0f, 50.0f)];
    [self setResizePropertiesResizeToSize:CGSizeMake(320.0f, 200.0f)
                               withOffset:resizeOffset
                  withCustomClosePosition:@"bottom-center"
                           allowOffscreen:YES];
    [self resize];
    
    CGRect defaultPosition = [self getDefaultPosition];
    CGFloat expectedX = 100.0f;
    CGFloat expectedY = 50.0f;
    CGFloat originX = defaultPosition.origin.x;
    CGFloat originY = defaultPosition.origin.y;
    
    XCTAssertTrue(expectedX == originX && expectedY == originY, @"Expected origin %f x %f, received %f x %f", expectedX, expectedY, originX, originY);
    
    expectedX = 150.0f;
    expectedY = 60.0f;
    
    [self moveBannerSubviewToOrigin:CGPointMake(expectedX, expectedY)];
    
    defaultPosition = [self getDefaultPosition];
    originX = defaultPosition.origin.x;
    originY = defaultPosition.origin.y;
    
    XCTAssertTrue(expectedX == originX && expectedY == originY, @"Expected origin %f x %f, received %f x %f", expectedX, expectedY, originX, originY);
    
    [self close];
    
    defaultPosition = [self getDefaultPosition];
    originX = defaultPosition.origin.x;
    originY = defaultPosition.origin.y;
    
    XCTAssertTrue(expectedX == originX && expectedY == originY, @"Expected origin %f x %f, received %f x %f", expectedX, expectedY, originX, originY);
    
    [self clearTest];
}

- (void)testDefaultPositionPortraitOriginResizeHuggingBottomOfScreen {
    CGFloat expectedOriginX = 0.0f;
    CGFloat expectedOriginY = 518.0f;
    CGPoint resizeOffset = CGPointMake(0.0f, -150.0f);
    
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd) atOrigin:CGPointMake(expectedOriginX, expectedOriginY) withSize:CGSizeMake(320.0f, 50.0f)];
    [self setResizePropertiesResizeToSize:CGSizeMake(320.0f, 200.0f)
                               withOffset:resizeOffset
                  withCustomClosePosition:@"bottom-center"
                           allowOffscreen:YES];
    [self resize];
    
    CGRect defaultPosition = [self getDefaultPosition];
    CGFloat originX = defaultPosition.origin.x;
    CGFloat originY = defaultPosition.origin.y;
    
    XCTAssertTrue(expectedOriginX == originX && expectedOriginY == originY, @"Expected origin %f x %f, received %f x %f", expectedOriginX, expectedOriginY, originX, originY);
    
    [self close];
    [self clearTest];
}

- (void)testDefaultPositionPortraitOriginResizeHuggingBottomOfScreenOnRotate {
    CGFloat expectedOriginX = 0.0f;
    CGFloat expectedOriginY = 518.0f;
    CGPoint resizeOffset = CGPointMake(0.0f, -150.0f);
    
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd) atOrigin:CGPointMake(expectedOriginX, expectedOriginY) withSize:CGSizeMake(320.0f, 50.0f)];
    [self setResizePropertiesResizeToSize:CGSizeMake(320.0f, 200.0f)
                               withOffset:resizeOffset
                  withCustomClosePosition:@"bottom-center"
                           allowOffscreen:YES];
    [self resize];
    
    expectedOriginX = 124.0f;
    expectedOriginY = 270.0f;
    [self.banner setFrame:CGRectMake(expectedOriginX, expectedOriginY, self.banner.frame.size.width, self.banner.frame.size.height)];

    [self rotateDeviceToOrientation:UIInterfaceOrientationLandscapeRight];
    
    CGRect defaultPosition = [self getDefaultPosition];
    CGFloat originX = defaultPosition.origin.x;
    CGFloat originY = defaultPosition.origin.y;
    
    XCTAssertTrue(expectedOriginX == originX && expectedOriginY == originY, @"Expected origin %f x %f, received %f x %f", expectedOriginX, expectedOriginY, originX, originY);
    
    [self close];
    [self clearTest];
}

- (void)testDefaultPositionMultipleResize {
    CGFloat initialOriginX = 0.0f;
    CGFloat initialOriginY = 518.0f;
    CGPoint resizeOffset = CGPointMake(0.0f, -150.0f);
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd) atOrigin:CGPointMake(initialOriginX, initialOriginY) withSize:CGSizeMake(320.0f, 50.0f)];
    [self setResizePropertiesResizeToSize:CGSizeMake(320.0f, 200.0f)
                               withOffset:resizeOffset
                  withCustomClosePosition:@"bottom-center"
                           allowOffscreen:YES];
    [self resize];
    
    CGRect defaultPosition = [self getDefaultPosition];
    CGFloat originX = defaultPosition.origin.x;
    CGFloat originY = defaultPosition.origin.y;
    XCTAssertTrue(initialOriginX == originX && initialOriginY == originY, @"Expected origin %f x %f, received %f x %f", initialOriginX, initialOriginY, originX, originY);
    
    resizeOffset = CGPointMake(0.0f, -50.0f);

    [self setResizePropertiesResizeToSize:CGSizeMake(320.0f, 250.0f)
                               withOffset:resizeOffset
                  withCustomClosePosition:@"bottom-center"
                           allowOffscreen:YES];
    [self resize];
    
    defaultPosition = [self getDefaultPosition];
    originX = defaultPosition.origin.x;
    originY = defaultPosition.origin.y;
    XCTAssertTrue(initialOriginX == originX && initialOriginY == originY, @"Expected origin %f x %f, received %f x %f", initialOriginX, initialOriginY, originX, originY);

    [self close];
    [self clearTest];
}

- (void)testDefaultPositionMultipleResizeAndExpand {
    CGFloat initialOriginX = 0.0f;
    CGFloat initialOriginY = 518.0f;
    CGPoint resizeOffset = CGPointMake(0.0f, -150.0f);
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd) atOrigin:CGPointMake(initialOriginX, initialOriginY) withSize:CGSizeMake(320.0f, 50.0f)];
    [self setResizePropertiesResizeToSize:CGSizeMake(320.0f, 200.0f)
                               withOffset:resizeOffset
                  withCustomClosePosition:@"bottom-center"
                           allowOffscreen:YES];
    [self resize];
    
    CGRect defaultPosition = [self getDefaultPosition];
    CGFloat originX = defaultPosition.origin.x;
    CGFloat originY = defaultPosition.origin.y;
    XCTAssertTrue(initialOriginX == originX && initialOriginY == originY, @"Expected origin %f x %f, received %f x %f", initialOriginX, initialOriginY, originX, originY);
    
    resizeOffset = CGPointMake(0.0f, -50.0f);
    
    [self setResizePropertiesResizeToSize:CGSizeMake(320.0f, 250.0f)
                               withOffset:resizeOffset
                  withCustomClosePosition:@"bottom-center"
                           allowOffscreen:YES];
    [self resize];
    
    defaultPosition = [self getDefaultPosition];
    originX = defaultPosition.origin.x;
    originY = defaultPosition.origin.y;
    XCTAssertTrue(initialOriginX == originX && initialOriginY == originY, @"Expected origin %f x %f, received %f x %f", initialOriginX, initialOriginY, originX, originY);
    
    [self expand];
    
    defaultPosition = [self getDefaultPosition];
    originX = defaultPosition.origin.x;
    originY = defaultPosition.origin.y;
    XCTAssertTrue(initialOriginX == originX && initialOriginY == originY, @"Expected origin %f x %f, received %f x %f", initialOriginX, initialOriginY, originX, originY);

    [self close];
    [self clearTest];
}

#pragma mark mraid.getState()

- (void)testBasicStateChange {
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    
    [self expand];
    [self assertState:@"expanded"];
    
    [self close];
    [self assertState:@"default"];
    
    [self clearTest];
}


- (void)testResizeWhileExpandedStateChange {
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
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
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
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
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    [self assertState:@"default"];
    [self close];
    [self assertState:@"hidden"];
    [self clearTest];
}

- (void)testExpandedToHiddenStateChange {
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
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
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
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
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
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
    XCTAssertTrue([width length] > 0, @"Expected width to be defined");
    XCTAssertTrue([height length] > 0, @"Expected height to be defined");
    XCTAssertTrue([offsetX length] > 0, @"Expected offsetX to be defined");
    XCTAssertTrue([offsetY length] > 0, @"Expected offsetY to be defined");
    XCTAssertTrue([width isEqualToString:([NSString stringWithFormat:@"%d", (int)resizeWidth])], @"Expected different width");
    XCTAssertTrue([height isEqualToString:([NSString stringWithFormat:@"%d", (int)resizeHeight])], @"Expected different height");
    XCTAssertTrue([offsetX isEqualToString:@"0"], @"Expected offsetX to be 0");
    XCTAssertTrue([offsetY isEqualToString:@"0"], @"Expected offsetY to be 0");

    [self resize];
    [self assertState:@"resized"];
    XCTAssertTrue(self.banner.frame.size.width == resizeWidth, @"Expected new width of banner frame to be resized width");
    XCTAssertTrue(self.banner.frame.size.height == resizeHeight, @"Expected new height of banner frame to be resized height");
    [self clearTest];
}

- (void)testSetResizePropertiesOnlySizeAndOffset { // MS-525
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    CGFloat resizeHeight = 200.0f;
    [self setResizePropertiesResizeToSize:CGSizeMake(320.0f, resizeHeight) withOffset:CGPointZero];
    [self resize];
    XCTAssertTrue(self.banner.frame.size.height == resizeHeight , @"Expected new height of banner frame to be resized height");
    [self clearTest];
}

- (void)testGetCustomCloseAndAllowOffscreenAfterSettingSizeAndOffset { // MS-525
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    CGFloat resizeHeight = 200.0f;
    [self setResizePropertiesResizeToSize:CGSizeMake(320.0f, resizeHeight) withOffset:CGPointZero];
    NSString *customClosePosition = [self getResizePropertiesCustomClosePosition];
    NSString *allowOffscreen = [self getResizePropertiesAllowOffscreen];
    XCTAssertTrue([customClosePosition length] > 0, @"Expected custom close position to be defined");
    XCTAssertTrue([allowOffscreen length] > 0, @"Expected allow offscreen to be defined");
    [self clearTest];
}
    
- (void)testSetResizePropertiesMultipleTimes { // MS-525
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    CGSize size1 = CGSizeMake(320.0f, 250.0f);
    [self setResizePropertiesResizeToSize:size1 withOffset:CGPointMake(-50.0f, 240.0f) withCustomClosePosition:@"top-left" allowOffscreen:NO];
    NSString *customClosePosition = [self getResizePropertiesCustomClosePosition];
    NSString *allowOffscreen = [self getResizePropertiesAllowOffscreen];
    XCTAssertTrue([customClosePosition isEqualToString:@"top-left"], @"Expected close position to be top left");
    XCTAssertTrue([allowOffscreen isEqualToString:@"false"], @"Expected allow offscreen to be false");
    CGSize size2 = CGSizeMake(500.0f, 300.0f);
    [self setResizePropertiesResizeToSize:size2 withOffset:CGPointMake(100.0f, 270.0f)];
    NSString *width = [self getResizePropertiesWidth];
    NSString *height = [self getResizePropertiesHeight];
    XCTAssertTrue([width length] > 0, @"Expected width to be defined");
    XCTAssertTrue([height length] > 0, @"Expected height to be defined");
    XCTAssertTrue([width isEqualToString:@"500"], @"Expected different width");
    XCTAssertTrue([height isEqualToString:@"300"], @"Expected different height");
    NSString *offsetX = [self getResizePropertiesOffsetX];
    NSString *offsetY = [self getResizePropertiesOffsetY];
    XCTAssertTrue([offsetX isEqualToString:@"100"], @"Expected offsetX to be 100");
    XCTAssertTrue([offsetY isEqualToString:@"270"], @"Expected offsetY to be 270");
    customClosePosition = [self getResizePropertiesCustomClosePosition];
    allowOffscreen = [self getResizePropertiesAllowOffscreen];
    XCTAssertTrue([customClosePosition isEqualToString:@"top-right"], @"Expected close position to be top right (default)");
    XCTAssertTrue([allowOffscreen isEqualToString:@"true"], @"Expected allow offscreen to be true (default)");
    [self clearTest];
}
    
- (void)testResizeAfterSettingIncompleteResizeProperties { // MS-525
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    CGSize size = CGSizeMake(320.0f, 250.0f);
    [self setResizePropertiesResizeToSize:size];
    NSString *width = [self getResizePropertiesWidth];
    NSString *height = [self getResizePropertiesHeight];
    NSString *offsetX = [self getResizePropertiesOffsetX];
    NSString *offsetY = [self getResizePropertiesOffsetY];

    XCTAssertFalse([offsetX length], @"Expected offsetX to be undefined");
    XCTAssertFalse([offsetY length], @"Expected offsetY to be undefined");
    XCTAssertFalse([width length], @"Expected width to be undefined");
    XCTAssertFalse([height length], @"Expected height to be undefined");

    [self resize];
    [self assertState:@"default"]; // Should not have resized
    [self clearTest];
}

#pragma mark mraid.expandProperties

- (void)testSetExpandPropertiesOnlySize {
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    CGFloat expandHeight = 200.0f;
    [self setExpandPropertiesExpandToSize:CGSizeMake(320.0f, expandHeight)];
    NSString *useCustomClose = [self getExpandPropertiesUseCustomClose];
    XCTAssertTrue([useCustomClose isEqualToString:@"false"], @"Expected useCustomClose to be false");
    [self expand];
    XCTAssertTrue(self.banner.frame.size.height == expandHeight , @"Expected new height of banner frame to be expanded height");
    [self close];
    [self clearTest];
}

- (void)testSetExpandPropertiesEmptyObject { // MS-525
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    [self setExpandPropertiesEmpty];
    NSString *width = [self getExpandPropertiesWidth];
    NSString *height = [self getExpandPropertiesHeight];
    XCTAssertTrue([width length] > 0, @"Expected width to be defined");
    XCTAssertTrue([height length] > 0, @"Expected height to be defined");
    [self clearTest];
}

- (void)testExpandAfterSetExpandPropertiesEmptyObject { // MS-525
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    [self setExpandPropertiesEmpty];
    [self expand];
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGSize currentSize = [self getCurrentPosition].size;
    XCTAssertTrue(CGSizeEqualToSize(screenSize, currentSize), @"Expected expanded size to be screen size");
    [self close];
    [self clearTest];
}

- (void)testGetExpandPropertiesAfterSettingSize { // MS-525
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    CGFloat expandHeight = 200.0f;
    [self setExpandPropertiesExpandToSize:CGSizeMake(320.0f, expandHeight)];
    NSString *customClose = [self getExpandPropertiesUseCustomClose];
    XCTAssertTrue([customClose length], @"expected custom close value to not be undefined");
    XCTAssertTrue([customClose isEqualToString:@"false"], @"expected default value of custom close to be false");
    
    // isModal works because it is set on every call to setExpandProperties.
    NSString *isModal = [self getExpandPropertiesIsModal];
    XCTAssertTrue(![isModal isEqualToString:@""], @"expected isModal value to not be undefined");
    XCTAssertTrue([isModal isEqualToString:@"true"], @"expected default value of isModal to be true");
    [self clearTest];
}

- (void)testSetExpandPropertiesToSizeZero {
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    [self setExpandPropertiesExpandToSize:CGSizeZero];
    [self expand];
    [self assertState:@"default"];
    [self clearTest];
}
    
- (void)testSetExpandPropertiesToNegativeSize {
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    [self setExpandPropertiesExpandToSize:CGSizeMake(-10.0f, 250.0f)];
    [self expand];
    [self assertState:@"default"];
    [self clearTest];
}
    
- (void)testSetExpandPropertiesMultipleTimes {
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    CGSize size1 = CGSizeMake(320.0f, 250.0f);
    BOOL useCustomClose1 = YES;
    BOOL isModal1 = NO;
    [self setExpandPropertiesExpandToSize:size1 useCustomClose:useCustomClose1 setModal:isModal1];
    NSString *useCustomClose = [self getExpandPropertiesUseCustomClose];
    NSString *width = [self getExpandPropertiesWidth];
    NSString *height = [self getExpandPropertiesHeight];
    NSString *isModal = [self getExpandPropertiesIsModal];
    XCTAssertTrue([useCustomClose isEqualToString:@"true"], @"Expected useCustomClose to be true");
    XCTAssertTrue([width isEqualToString:@"320"], @"Expected width to be 320");
    XCTAssertTrue([height isEqualToString:@"250"], @"Expected height to be 250");
    XCTAssertTrue([isModal isEqualToString:@"true"], @"Expected isModal to be true");
    CGSize size2 = CGSizeMake(500.0f, 300.0f);
    [self setExpandPropertiesExpandToSize:size2];
    useCustomClose = [self getExpandPropertiesUseCustomClose];
    width = [self getExpandPropertiesWidth];
    height = [self getExpandPropertiesHeight];
    isModal = [self getExpandPropertiesIsModal];
    XCTAssertTrue([useCustomClose isEqualToString:@"false"], @"Expected useCustomClose to be false");
    XCTAssertTrue([width isEqualToString:@"500"], @"Expected width to be 320");
    XCTAssertTrue([height isEqualToString:@"300"], @"Expected height to be 250");
    XCTAssertTrue([isModal isEqualToString:@"true"], @"Expected isModal to be true");
    [self clearTest];
}

// WILL FAIL: Initial getExpandProperties returns -1 as width and height
/*- (void)testGetExpandPropertiesInitialSize {
 [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
 CGSize initSize = [self getExpandPropertiesSize];
 CGRect actualBounds = [[UIScreen mainScreen] bounds];
 STAssertTrue(actualBounds.size.width == initSize.width && actualBounds.size.height == initSize.height, @"Expected default expand properties to reflect actual screen values");
 [self clearTest];
 }*/

#pragma mark mraid.addEventListener

- (void)testOnReadyListener {
    [self addMRAIDListenerBannerWithSelectorName:NSStringFromSelector(_cmd)
                                        atOrigin:CGPointZero
                                        withSize:CGSizeMake(320.0f, 50.0f)];
    
    NSString *readyDidFire = [self.webView stringByEvaluatingJavaScriptFromString:@"testReadyDidFire"];
    XCTAssertTrue([readyDidFire isEqualToString:@"true"], @"ready event callback not fired");
    
    [self clearTest];
}

- (void)testExpandListeners {
    [self addMRAIDListenerBannerWithSelectorName:NSStringFromSelector(_cmd)
                                        atOrigin:CGPointZero
                                        withSize:CGSizeMake(320.0f, 50.0f)];
    
    NSString *width = [self.webView stringByEvaluatingJavaScriptFromString:@"testWidth"];
    NSString *height = [self.webView stringByEvaluatingJavaScriptFromString:@"testHeight"];
    NSString *state = [self.webView stringByEvaluatingJavaScriptFromString:@"testState"];
    
    XCTAssertTrue([width isEqualToString:@"320"] && [height isEqualToString:@"50"], @"Expected width and height to be different");
    XCTAssertTrue([state isEqualToString:@"default"], @"state change callback not fired");
                 
    [self expand];
    
    width = [self.webView stringByEvaluatingJavaScriptFromString:@"testWidth"];
    height = [self.webView stringByEvaluatingJavaScriptFromString:@"testHeight"];
    state = [self.webView stringByEvaluatingJavaScriptFromString:@"testState"];

    XCTAssertTrue([width isEqualToString:@"320"] && [height isEqualToString:@"568"], @"Expected width and height to be different");
    XCTAssertTrue([state isEqualToString:@"expanded"], @"state change callback not fired");

    [self close];
    
    width = [self.webView stringByEvaluatingJavaScriptFromString:@"testWidth"];
    height = [self.webView stringByEvaluatingJavaScriptFromString:@"testHeight"];
    state = [self.webView stringByEvaluatingJavaScriptFromString:@"testState"];

    XCTAssertTrue([width isEqualToString:@"320"] && [height isEqualToString:@"50"], @"Expected width and height to be different");
    XCTAssertTrue([state isEqualToString:@"default"], @"state change callback not fired");

    [self clearTest];
}

- (void)testResizeListeners {
    [self addMRAIDListenerBannerWithSelectorName:NSStringFromSelector(_cmd)
                                        atOrigin:CGPointZero
                                        withSize:CGSizeMake(320.0f, 50.0f)];
    
    NSString *width = [self.webView stringByEvaluatingJavaScriptFromString:@"testWidth"];
    NSString *height = [self.webView stringByEvaluatingJavaScriptFromString:@"testHeight"];
    NSString *state = [self.webView stringByEvaluatingJavaScriptFromString:@"testState"];
    
    XCTAssertTrue([width isEqualToString:@"320"] && [height isEqualToString:@"50"], @"Expected width and height to be different");
    XCTAssertTrue([state isEqualToString:@"default"], @"state change callback not fired");

    [self setResizePropertiesResizeToSize:CGSizeMake(400.0f, 200.0f) withOffset:CGPointZero withCustomClosePosition:@"top-left" allowOffscreen:YES];
    [self resize];
    
    width = [self.webView stringByEvaluatingJavaScriptFromString:@"testWidth"];
    height = [self.webView stringByEvaluatingJavaScriptFromString:@"testHeight"];
    state = [self.webView stringByEvaluatingJavaScriptFromString:@"testState"];
    
    XCTAssertTrue([width isEqualToString:@"400"] && [height isEqualToString:@"200"], @"Expected width and height to be different");
    XCTAssertTrue([state isEqualToString:@"resized"], @"state change callback not fired");

    [self close];
    [self clearTest];
}

- (void)testResizetoExpandListeners {
    [self addMRAIDListenerBannerWithSelectorName:NSStringFromSelector(_cmd)
                                        atOrigin:CGPointZero
                                        withSize:CGSizeMake(320.0f, 50.0f)];

    [self setResizePropertiesResizeToSize:CGSizeMake(400.0f, 200.0f) withOffset:CGPointZero withCustomClosePosition:@"top-left" allowOffscreen:YES];
    [self resize];
    [self expand];
    
    NSString *width = [self.webView stringByEvaluatingJavaScriptFromString:@"testWidth"];
    NSString *height = [self.webView stringByEvaluatingJavaScriptFromString:@"testHeight"];
    NSString *state = [self.webView stringByEvaluatingJavaScriptFromString:@"testState"];
    
    XCTAssertTrue([width isEqualToString:@"320"] && [height isEqualToString:@"568"], @"Expected width and height to be different");
    XCTAssertTrue([state isEqualToString:@"expanded"], @"state change callback not fired");
    
    [self close];
    [self clearTest];
}

- (void)testCloseFromDefaultStateListener {
    [self addMRAIDListenerBannerWithSelectorName:NSStringFromSelector(_cmd)
                                        atOrigin:CGPointZero
                                        withSize:CGSizeMake(320.0f, 50.0f)];
    [self close];
    NSString *state = [self.webView stringByEvaluatingJavaScriptFromString:@"testState"];
    XCTAssertTrue([state isEqualToString:@"hidden"], @"state change callback not fired");

    [self expand];
    state = [self.webView stringByEvaluatingJavaScriptFromString:@"testState"];
    NSString *errorAction = [self.webView stringByEvaluatingJavaScriptFromString:@"testErrorAction"];
    XCTAssertTrue([state isEqualToString:@"hidden"], @"state change callback fired when it should not have been");
    XCTAssertTrue([errorAction isEqualToString:@"mraid.expand()"], @"Expected error from mraid.expand()");
    
    [self setResizePropertiesResizeToSize:CGSizeMake(400.0f, 200.0f) withOffset:CGPointZero withCustomClosePosition:@"top-left" allowOffscreen:YES];
    [self resize];
    state = [self.webView stringByEvaluatingJavaScriptFromString:@"testState"];
    errorAction = [self.webView stringByEvaluatingJavaScriptFromString:@"testErrorAction"];
    XCTAssertTrue([state isEqualToString:@"hidden"], @"state change callback fired when it should not have been");
    XCTAssertTrue([errorAction isEqualToString:@"mraid.resize()"], @"Expected error from mraid.resize()");

    [self clearTest];
}

- (void)testViewabilityListener {
    [self loadMRAIDListenerBannerWithSelectorName:NSStringFromSelector(_cmd)
                                         atOrigin:CGPointZero
                                         withSize:CGSizeMake(320.0f, 50.0f)];
    NSString *isViewable = [self.webView stringByEvaluatingJavaScriptFromString:@"testIsViewable"];
    XCTAssertTrue([isViewable isEqualToString:@"false"], @"expected banner to not be viewable");
    
    [self addBannerAsSubview];
    isViewable = [self.webView stringByEvaluatingJavaScriptFromString:@"testIsViewable"];
    XCTAssertTrue([isViewable isEqualToString:@"true"], @"expected banner to be viewable");
    
    [self moveBannerSubviewToOrigin:CGPointMake(1000.0f, 1000.0f)];
    isViewable = [self.webView stringByEvaluatingJavaScriptFromString:@"testIsViewable"];
    XCTAssertTrue([isViewable isEqualToString:@"false"], @"expected banner to not be viewable");
    
    [self moveBannerSubviewToOrigin:CGPointMake(0.0f, 200.0f)];
    isViewable = [self.webView stringByEvaluatingJavaScriptFromString:@"testIsViewable"];
    XCTAssertTrue([isViewable isEqualToString:@"true"], @"expected banner to be viewable");

    [self clearTest];
}

- (void)testRemoveEventListener {
    [self addMRAIDListenerBannerWithSelectorName:NSStringFromSelector(_cmd)
                                        atOrigin:CGPointZero
                                        withSize:CGSizeMake(320.0f, 50.0f)];
    [self.webView stringByEvaluatingJavaScriptFromString:@"mraid.removeEventListener('ready', onReady);"];
    NSString *errorAction = [self.webView stringByEvaluatingJavaScriptFromString:@"testErrorAction"];
    XCTAssertTrue([errorAction isEqualToString:@""], @"Did not expect an error on removeEventListener()");
    
    [self.webView stringByEvaluatingJavaScriptFromString:@"mraid.removeEventListener('ready', onReady);"];
    errorAction = [self.webView stringByEvaluatingJavaScriptFromString:@"testErrorAction"];
    XCTAssertTrue([errorAction isEqualToString:@"mraid.removeEventListener()"], @"Expected error on removeEventListener()");
    
    [self clearTest];
}

#pragma mark mraid.supports()

- (void)testSupportSMS {
    [self loadBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    BOOL isSupported = [self supports:@"sms"];
    #if TARGET_IPHONE_SIMULATOR
    XCTAssertFalse(isSupported, @"Expected iphone simulator to not support SMS");
    #else
    STAssertTrue(isSupported, @"Expected iPhone device to support SMS");
    #endif
    [self clearTest];
}

- (void)testSupportTel {
    [self loadBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    BOOL isSupported = [self supports:@"tel"];
    #if TARGET_IPHONE_SIMULATOR
    XCTAssertFalse(isSupported, @"Expected iphone simulator to not support Tel");
    #else
    STAssertTrue(isSupported, @"Expected iPhone device to support Tel");
    #endif
    [self clearTest];
}

- (void)testSupportCal {
    [self loadBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    BOOL isSupported = [self supports:@"calendar"];
    XCTAssertTrue(isSupported, @"Expected calendar support");
    [self clearTest];
}

- (void)testSupportInlineVideo {
    [self loadBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    BOOL isSupported = [self supports:@"inlineVideo"];
    XCTAssertTrue(isSupported, @"Expected inline video support");
    [self clearTest];
}

- (void)testSupportStorePicture {
    [self loadBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    BOOL isSupported = [self supports:@"storePicture"];
    XCTAssertTrue(isSupported, @"Expected store picture support");
    [self clearTest];
}

#pragma mark Helper Functions

- (void)clearTest {
    self.webView = nil;
    [self removeBannerFromSuperview];
    if ([[UIApplication sharedApplication] statusBarOrientation] != UIInterfaceOrientationPortrait) {
        [self rotateDeviceToOrientation:UIInterfaceOrientationPortrait];
    }
    [super clearTest];
}

- (void)addBasicMRAIDBannerWithSelectorName:(NSString *)selector {
    [self loadBasicMRAIDBannerWithSelectorName:selector];
    [self addBannerAsSubview];
}

- (void)addBasicMRAIDBannerWithSelectorName:(NSString *)selector
                                   atOrigin:(CGPoint)origin
                                   withSize:(CGSize)size {
    [self loadBasicMRAIDBannerWithSelectorName:selector
                                      atOrigin:origin
                                      withSize:size];
    [self addBannerAsSubview];
}

- (void)addMRAIDListenerBannerWithSelectorName:(NSString *)selector
                                      atOrigin:(CGPoint)origin
                                      withSize:(CGSize)size {
    [self loadMRAIDListenerBannerWithSelectorName:selector
                                         atOrigin:origin
                                         withSize:size];
    [self addBannerAsSubview];
}

- (void)loadBasicMRAIDBannerWithSelectorName:(NSString *)selector {
    [self loadBasicMRAIDBannerWithSelectorName:selector
                                      atOrigin:CGPointMake(0.0f, 0.0f)
                                      withSize:CGSizeMake(320.0f, 50.0f)];
}

- (void)loadBasicMRAIDBannerWithSelectorName:(NSString *)selector
                                    atOrigin:(CGPoint)origin
                                    withSize:(CGSize)size {
    [self loadMRAIDBannerAtOrigin:origin
                         withSize:size
                    usingStubBody:[ANMRAIDTestResponses basicMRAIDBannerWithSelectorName:selector]];
}

- (void)loadMRAIDListenerBannerWithSelectorName:(NSString *)selector
                                        atOrigin:(CGPoint)origin
                                        withSize:(CGSize)size {
    [self loadMRAIDBannerAtOrigin:origin
                        withSize:size
                    usingStubBody:[ANMRAIDTestResponses MRAIDListenerBannerWithSelectorName:selector]];
}

- (void)loadMRAIDBannerAtOrigin:(CGPoint)origin
                       withSize:(CGSize)size
                  usingStubBody:(NSString *)body {
    [self stubWithBody:body];
    [self loadBannerAdAtOrigin:CGPointMake(origin.x, origin.y) withSize:CGSizeMake(size.width, size.height)];
    XCTAssertTrue([self waitForCompletion:MRAID_TESTS_TIMEOUT], @"Ad load timed out");
    XCTAssertTrue(self.adDidLoadCalled, @"Success callback should be called");
    XCTAssertFalse(self.adFailedToLoadCalled, @"Failure callback should not be called");
    id wv = [[self.banner subviews] firstObject];
    XCTAssertTrue([wv isKindOfClass:[ANWebView class]], @"Expected ANWebView as subview of BannerAdView");
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
        [self.banner setFrame:CGRectMake(origin.x, origin.y, self.banner.frame.size.width, self.banner.frame.size.height)];
        [self delay:MRAID_TESTS_DEFAULT_DELAY];
    }
}

- (void)loadBannerAdAtOrigin:(CGPoint)origin withSize:(CGSize)size {
    self.banner = [[ANBannerAdView alloc] initWithFrame:CGRectMake(origin.x, origin.y, size.width, size.height)
                                            placementId:@"1"
                                                 adSize:CGSizeMake(size.width, size.height)];
    self.banner.rootViewController = [[UIApplication sharedApplication].delegate window].rootViewController;
    self.banner.autoRefreshInterval = 0.0;
    self.banner.delegate = self;
    [self.banner loadAd];
}

/*- (void)testLoadInterstitialAd {
    //[self rotateDeviceToOrientation:UIInterfaceOrientationPortraitUpsideDown];
    [self stubWithBody:[ANMRAIDTestResponses basicMRAIDInterstitialWithSelectorName:NSStringFromSelector(_cmd)]];
    self.interstitial = [[ANInterstitialAd alloc] initWithPlacementId:@"1"];
    [self.interstitial loadAd];
    [self.interstitial setBackgroundColor:[UIColor redColor]];
    [self.interstitial setCloseDelay:0.1];
    [self delay:0.5];
    [self.interstitial displayAdFromViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
    UIViewController *pvc = [UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController;
    // webview is contained in a container view
    id wv = [[[[pvc.view subviews] firstObject] subviews] firstObject];
    STAssertTrue([wv isKindOfClass:[ANWebView class]], @"Expected ANWebView as subview of InterstitialAdView");
    self.webView = (ANWebView *)wv;
    [self delay:2];
    
    [self setResizePropertiesResizeToSize:CGSizeMake(320.0f, 50.0f) withOffset:CGPointZero withCustomClosePosition:@"top-left" allowOffscreen:YES];
    [self resize];
    
    [self delay:1];
}*/

- (void)removeBannerFromSuperview {
    if (self.banner) {
        [self.banner removeFromSuperview];
        [self delay:MRAID_TESTS_DEFAULT_DELAY];
    }
}

- (void)assertState:(NSString *)expectedState {
    XCTAssertTrue([[self getState] isEqualToString:expectedState], @"Expected state '%@', instead in state '%@'", expectedState, [self getState]);
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