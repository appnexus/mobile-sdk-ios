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

#import <WebKit/WebKit.h>

#import "ANBaseTestCase.h"
#import "ANMRAIDTestResponses.h"
#import "ANLogging.h"
#import "ANLogManager.h"
#import "ANGlobal.h"
#import "ANMRAIDContainerView.h"
#import "ANMRAIDUtil.h"
#import "XCTestCase+ANCategory.h"
#import "ANHTTPStubbingManager.h"
#import "ANAdWebViewController+ANTest.h"
#import "XandrAd.h"

#define  MRAID_TESTS_TIMEOUT        60.0
#define  MRAID_TESTS_DEFAULT_DELAY  6.0




#pragma mark - ANMRAIDContainerView (ANMRAIDTestsCategory)

@interface ANMRAIDContainerView (ANMRAIDTestsCategory)

@property (nonatomic, readwrite, assign) BOOL userInteractedWithContentView;

@end




#pragma mark - UIDevice (HackyWayToRotateTheDeviceForTestingPurposesBecauseAppleDeclaredSuchAMethodInTheirPrivateImplementationOfTheUIDeviceClass)

@interface UIDevice (HackyWayToRotateTheDeviceForTestingPurposesBecauseAppleDeclaredSuchAMethodInTheirPrivateImplementationOfTheUIDeviceClass)

-(void)setOrientation:(UIInterfaceOrientation)orientation animated:(BOOL)animated;
-(void)setOrientation:(UIInterfaceOrientation)orientation;

@end




#pragma mark - ANMRAIDContainerView (PrivateMethods)

@interface ANMRAIDContainerView (PrivateMethods)

- (CGRect)currentPosition;

@end




#pragma mark - ANMRAIDTests

@interface ANMRAIDTests : ANBaseTestCase

@property (strong, nonatomic) id webView; // Could be WKWebView or UIWebView

@property (strong, nonatomic) ANMRAIDContainerView *standardAdView;
@end



@implementation ANMRAIDTests

- (void)setUp {
    [super setUp];
    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
   
   // Init here if not the tests will crash
   [[XandrAd sharedInstance] initWithMemberID:1 preCacheRequestObjects:true completionHandler:nil];
}

- (void)tearDown {
   // Put teardown code here. This method is called after the invocation of each test method in the class.
   [super tearDown];
   
   [ANHTTPStubbingManager sharedStubbingManager].broadcastRequests = NO;
   [[ANHTTPStubbingManager sharedStubbingManager] disable];
   [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
   self.webView = nil;
   self.standardAdView = nil;
   self.banner.delegate = nil;
   self.banner.appEventDelegate = nil;
   [self.banner removeFromSuperview];
   self.banner = nil;
   for (UIView *additionalView in [[ANGlobal getKeyWindow].rootViewController.view subviews]){
      [additionalView removeFromSuperview];
   }
}

#pragma mark - Basic MRAID Banner Test

- (void)testSuccessfulBannerDidLoad {
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    [self clearTest];
}



#pragma mark - mraid.isViewable()

- (void)testBasicViewability { // MS-453
    [self loadBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    XCTAssertFalse([[self isViewable] boolValue], @"Expected ANWebView not to be visible");
    
    [self addBannerAsSubview];
    XCTAssertTrue([[self isViewable] boolValue], @"Expected ANWebView to be visible");
    
    [self removeBannerFromSuperview];
    XCTAssertFalse([[self isViewable] boolValue], @"Expected ANWebView not to be visible");
    
    [self clearTest];
}



#pragma mark - mraid.setOrientationProperties()

- (void)testForceOrientationLandscapeFromPortrait { // MS-481
    XCTAssertTrue(ANStatusBarOrientation() == UIInterfaceOrientationPortrait, @"Expected portrait orientation");

    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    [self setOrientationPropertiesWithAllowOrientationChange:NO forceOrientation:@"landscape"];
    [self expand];
    XCTAssertTrue(ANStatusBarOrientation() == UIInterfaceOrientationLandscapeLeft, @"Expected landscape left orientation");
    
    [self close];
    [self clearTest];
}

- (void)testForceOrientationPortraitFromLandscape { // MS-481
    [self rotateDeviceToOrientation:UIInterfaceOrientationLandscapeRight];
    XCTAssertTrue(ANStatusBarOrientation() == UIInterfaceOrientationLandscapeRight, @"Expected landscape right orientation");

    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    [self setOrientationPropertiesWithAllowOrientationChange:NO forceOrientation:@"portrait"];
    [self expand];
    XCTAssertTrue(ANStatusBarOrientation() == UIInterfaceOrientationPortrait, @"Expected portrait orientation");
    
    [self close];
    [self clearTest];
}

- (void)testForceOrientationLandscapeFromLandscapeRight { // MS-481
    [self rotateDeviceToOrientation:UIInterfaceOrientationLandscapeRight];
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    [self setOrientationPropertiesWithAllowOrientationChange:NO forceOrientation:@"landscape"];
    [self expand];
    XCTAssertTrue(ANStatusBarOrientation() == UIInterfaceOrientationLandscapeRight, @"Expected landscape right orientation");

    [self close];
    XCTAssertTrue(ANStatusBarOrientation() == UIInterfaceOrientationLandscapeRight, @"Expected landscape right orientation");

    [self clearTest];
}



#pragma mark - mraid.expand()

-(BOOL)isSupportPortraitUpsideDown {
    BOOL ishasPortraitUpsideDown = YES;
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
        // with notch: 44.0 on iPhone X, XS, XS Max, XR on iOS 12+. and >0.0 on iOS 11
        // without notch: 20.0 on iPhone 8 on iOS 12+.  will be 0 on iOS 11
        if (mainWindow.safeAreaInsets.top > 20.0 || (mainWindow.safeAreaInsets.top > 0.0 && mainWindow.safeAreaInsets.top != 20.0)) {
            ishasPortraitUpsideDown = NO;
        }
        int deviceHeight  = (int)[[UIScreen mainScreen] nativeBounds].size.height;
        if (deviceHeight ==  2208) {
            ishasPortraitUpsideDown = NO;
        }
        
    }
    return ishasPortraitUpsideDown;
}

- (void)testExpandFromPortraitUpsideDown { // MS-510
    
    if ([self isSupportPortraitUpsideDown]) {
        //testExpandFromPortraitUpsideDown can't run for iPhone X
        // Apps are now designed to accommodate the notch and adjacent tabs on the iPhone X display and would not work with the phone upside-down.
        [self rotateDeviceToOrientation:UIInterfaceOrientationPortraitUpsideDown];
        [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
        [self expand];
        XCTAssertFalse(ANStatusBarOrientation() == UIInterfaceOrientationPortrait, @"Did not expect portrait right side up orientation");
        XCTAssertTrue(ANStatusBarOrientation() == UIInterfaceOrientationPortraitUpsideDown, @"Expected portrait upside down orientation");
        
        [self close];
        XCTAssertTrue(ANStatusBarOrientation() == UIInterfaceOrientationPortraitUpsideDown, @"Expected portrait upside down orientation");
    }
    
    
    [self clearTest];
}



#pragma mark - mraid.getScreenSize()

- (void)testScreenSizePortraitOnLoad {
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    CGPoint screenSize = [self getScreenSize];
    CGFloat width = screenSize.x;
    CGFloat height = screenSize.y;
    CGRect screenBounds = ANPortraitScreenBounds();
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
    CGRect screenBounds = ANPortraitScreenBounds();
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
    CGRect screenBounds = ANPortraitScreenBounds();
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



#pragma mark - mraid.getMaxSize()
-(CGFloat )eliminatePortraitSafeAreaInsets :(CGFloat)expectedHeight {
   if (@available(iOS 11.0, *)) {
      UIWindow *window = UIApplication.sharedApplication.keyWindow;
      CGFloat topPadding = window.safeAreaInsets.top;
      CGFloat bottomPadding = window.safeAreaInsets.bottom;

      expectedHeight -= (topPadding + bottomPadding);
   }
   return expectedHeight;
}

-(CGFloat )eliminateLandscapeSafeAreaInsets :(CGFloat)expectedHeight {
   if (@available(iOS 11.0, *)) {
      UIWindow *window = UIApplication.sharedApplication.keyWindow;
      CGFloat leftPadding = window.safeAreaInsets.left;
      CGFloat rightPadding = window.safeAreaInsets.right;
      expectedHeight -= (leftPadding + rightPadding);
   }
   return expectedHeight;
}
-(CGFloat )originYWithSafeAreaInsets :(CGFloat)originY {
   if (@available(iOS 11.0, *)) {
      UIWindow *window = UIApplication.sharedApplication.keyWindow;
      CGFloat topPadding = window.safeAreaInsets.top;
      originY += topPadding;
   }
   return originY;
}


- (void)testMaxSizePortraitOnLoad {
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    CGPoint maxSize = [self getMaxSize];
    CGFloat width = maxSize.x;
    CGFloat height = maxSize.y;
    CGRect screenBounds = ANPortraitScreenBounds();
    CGFloat expectedWidth = screenBounds.size.width;
    CGFloat expectedHeight = [self eliminatePortraitSafeAreaInsets:screenBounds.size.height];

   if (!ANStatusBarHidden()) {
        expectedHeight -= ANStatusBarFrame().size.height;
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
    CGRect screenBounds = ANPortraitScreenBounds();
    CGFloat expectedWidth = [self eliminateLandscapeSafeAreaInsets:screenBounds.size.height];
    CGFloat expectedHeight = [self eliminatePortraitSafeAreaInsets:screenBounds.size.width];

    if (!ANStatusBarHidden()) {
        expectedHeight -= ANStatusBarFrame().size.width;
    }
    XCTAssertTrue(expectedWidth == width && expectedHeight == height, @"Expected landscape max size %f x %f, received %f x %f", expectedWidth, expectedHeight, width, height);

    [self clearTest];
}

- (void)testMaxSizeLandscapeOnRotate {
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    XCTAssertTrue(UIInterfaceOrientationIsPortrait(ANStatusBarOrientation()), @"Expected to start in portrait orientation");
    [self rotateDeviceToOrientation:UIInterfaceOrientationLandscapeRight];
    
    CGPoint maxSize = [self getMaxSize];
    CGFloat width = maxSize.x;
    CGFloat height = maxSize.y;
    CGRect screenBounds = ANPortraitScreenBounds();
    CGFloat expectedWidth = [self eliminateLandscapeSafeAreaInsets:screenBounds.size.height];
    CGFloat expectedHeight = [self eliminatePortraitSafeAreaInsets:screenBounds.size.width];

    if (!ANStatusBarHidden()) {
        expectedHeight -= ANStatusBarFrame().size.width;
    }
    XCTAssertTrue(expectedWidth == width && expectedHeight == height, @"Expected landscape max size %f x %f, received %f x %f", expectedWidth, expectedHeight, width, height);
    
    if (![self isSupportPortraitUpsideDown]) {
        [self rotateDeviceToOrientation:UIInterfaceOrientationPortraitUpsideDown];
        // Apps are now designed to accommodate the notch and adjacent tabs on the iPhone X display and would not work with the phone upside-down.
    }else {
        [self rotateDeviceToOrientation:UIInterfaceOrientationPortrait];
    }
    
    
    maxSize = [self getMaxSize];
    width = maxSize.x;
    height = maxSize.y;
    expectedWidth = [self eliminateLandscapeSafeAreaInsets:screenBounds.size.width];
    expectedHeight = [self eliminatePortraitSafeAreaInsets:screenBounds.size.height];

    if (!ANStatusBarHidden()) {
        expectedHeight -= ANStatusBarFrame().size.height;
    }
    XCTAssertTrue(expectedWidth == width && expectedHeight == height, @"Expected portrait max size %f x %f, received %f x %f", expectedWidth, expectedHeight, width, height);
    
    [self clearTest];
}



#pragma mark - mraid.getCurrentPosition()

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

    CGRect screenBounds = ANPortraitScreenBounds();
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
    CGFloat expectedOriginY = [self originYWithSafeAreaInsets:0.0f];

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
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(coordinateSpace)]) {
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
    } else {
        [self close];
    }
    
    [self clearTest];
}



#pragma mark - mraid.getDefaultPosition()

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

    [XCTestCase delayForTimeInterval:0.5];

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



#pragma mark - mraid.getState()

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



#pragma mark - mraid.resizeProperties

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
    
    CGRect currentPosition = [self.standardAdView currentPosition];
    
    XCTAssertTrue(currentPosition.size.width == resizeWidth, @"Expected new width of banner frame to be resized width");
    XCTAssertTrue(currentPosition.size.height == resizeHeight, @"Expected new height of banner frame to be resized height");
    [self clearTest];
}

- (void)testSetResizePropertiesOnlySizeAndOffset { // MS-525
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    CGFloat resizeHeight = 200.0f;
    [self setResizePropertiesResizeToSize:CGSizeMake(320.0f, resizeHeight) withOffset:CGPointZero];
    [self resize];
    
    CGRect currentPosition = [self.standardAdView currentPosition];
    XCTAssertTrue(currentPosition.size.height == resizeHeight , @"Expected new height of banner frame to be resized height");
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



#pragma mark - mraid.expandProperties

- (void)testSetExpandPropertiesOnlySize {
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    CGFloat expandHeight = 200.0f;
    [self setExpandPropertiesExpandToSize:CGSizeMake(320.0f, expandHeight)];
    
    NSString *useCustomClose = [self getExpandPropertiesUseCustomClose];
    XCTAssertTrue([useCustomClose isEqualToString:@"false"], @"Expected useCustomClose to be false");
    [self expand];
    
    XCTAssertTrue([ANMRAIDUtil screenSize].height == [self.standardAdView currentPosition].size.height , @"Expected expand height to be ignored");
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
    CGSize screenSize = ANPortraitScreenBounds().size;
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
    [self assertState:@"expanded"]; // Size is ignored in MRAID 2.0
    [self clearTest];
}
    
- (void)testSetExpandPropertiesToNegativeSize {
    [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    [self setExpandPropertiesExpandToSize:CGSizeMake(-10.0f, 250.0f)];
    [self expand];
    [self assertState:@"expanded"]; // Size is ignored in MRAID 2.0
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
    XCTAssertTrue([useCustomClose isEqualToString:@"true"], @"Expected useCustomClose to still be true");
    XCTAssertTrue([width isEqualToString:@"500"], @"Expected width to be 320");
    XCTAssertTrue([height isEqualToString:@"300"], @"Expected height to be 250");
    XCTAssertTrue([isModal isEqualToString:@"true"], @"Expected isModal to be true");
    [self clearTest];
}

// WILL FAIL: Initial getExpandProperties returns -1 as width and height
/*- (void)testGetExpandPropertiesInitialSize {
 [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
 CGSize initSize = [self getExpandPropertiesSize];
 CGRect actualBounds = ANPortraitScreenBounds();
 STAssertTrue(actualBounds.size.width == initSize.width && actualBounds.size.height == initSize.height, @"Expected default expand properties to reflect actual screen values");
 [self clearTest];
 }*/



#pragma mark - mraid.addEventListener

- (void)testOnReadyListener {
    [self addMRAIDListenerBannerWithSelectorName:NSStringFromSelector(_cmd)
                                        atOrigin:CGPointZero
                                        withSize:CGSizeMake(320.0f, 50.0f)];
    
    NSString *readyDidFire = [self evaluateJavascript:@"testReadyDidFire"];
    XCTAssertTrue([readyDidFire isEqualToString:@"true"], @"ready event callback not fired");
    
    [self clearTest];
}

- (void)testExpandListeners {
    [self addMRAIDListenerBannerWithSelectorName:NSStringFromSelector(_cmd)
                                        atOrigin:CGPointZero
                                        withSize:CGSizeMake(320.0f, 50.0f)];
    
    NSString *width = [self evaluateJavascript:@"testWidth"];
    NSString *height = [self evaluateJavascript:@"testHeight"];
    NSString *state = [self evaluateJavascript:@"testState"];
    
    XCTAssertTrue([width isEqualToString:@"320"] && [height isEqualToString:@"50"], @"Expected width and height to be different");
    XCTAssertTrue([state isEqualToString:@"default"], @"state change callback not fired");
                 
    [self expand];
    
    width = [self evaluateJavascript:@"testWidth"];
    height = [self evaluateJavascript:@"testHeight"];
    state = [self evaluateJavascript:@"testState"];

    CGRect portraitBounds = ANPortraitScreenBounds();
    NSString *expectedWidth = [NSString stringWithFormat:@"%d", (int)portraitBounds.size.width];
    NSString *expectedHeight = [NSString stringWithFormat:@"%d", (int)portraitBounds.size.height];
    
    XCTAssertTrue([width isEqualToString:expectedWidth] && [height isEqualToString:expectedHeight], @"Expected width and height to be different");
    XCTAssertTrue([state isEqualToString:@"expanded"], @"state change callback not fired");

    [self close];
    
    width = [self evaluateJavascript:@"testWidth"];
    height = [self evaluateJavascript:@"testHeight"];
    state = [self evaluateJavascript:@"testState"];

    XCTAssertTrue([width isEqualToString:@"320"] && [height isEqualToString:@"50"], @"Expected width and height to be different");
    XCTAssertTrue([state isEqualToString:@"default"], @"state change callback not fired");

    [self clearTest];
}

- (void)testResizeListeners {
    [self addMRAIDListenerBannerWithSelectorName:NSStringFromSelector(_cmd)
                                        atOrigin:CGPointZero
                                        withSize:CGSizeMake(320.0f, 50.0f)];
    
    NSString *width = [self evaluateJavascript:@"testWidth"];
    NSString *height = [self evaluateJavascript:@"testHeight"];
    NSString *state = [self evaluateJavascript:@"testState"];
    
    XCTAssertTrue([width isEqualToString:@"320"] && [height isEqualToString:@"50"], @"Expected width and height to be different");
    XCTAssertTrue([state isEqualToString:@"default"], @"state change callback not fired");

    [self setResizePropertiesResizeToSize:CGSizeMake(400.0f, 200.0f) withOffset:CGPointZero withCustomClosePosition:@"top-left" allowOffscreen:YES];
    [self resize];
    
    width = [self evaluateJavascript:@"testWidth"];
    height = [self evaluateJavascript:@"testHeight"];
    state = [self evaluateJavascript:@"testState"];
    
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
    
    NSString *width = [self evaluateJavascript:@"testWidth"];
    NSString *height = [self evaluateJavascript:@"testHeight"];
    NSString *state = [self evaluateJavascript:@"testState"];
    
    CGRect portraitBounds = ANPortraitScreenBounds();
    NSString *expectedWidth = [NSString stringWithFormat:@"%d", (int)portraitBounds.size.width];
    NSString *expectedHeight = [NSString stringWithFormat:@"%d", (int)portraitBounds.size.height];

    XCTAssertTrue([width isEqualToString:expectedWidth] && [height isEqualToString:expectedHeight], @"Expected width and height to be different");
    XCTAssertTrue([state isEqualToString:@"expanded"], @"state change callback not fired");
    
    [self close];
    [self clearTest];
}

- (void)testCloseFromDefaultStateListener {
    [self addMRAIDListenerBannerWithSelectorName:NSStringFromSelector(_cmd)
                                        atOrigin:CGPointZero
                                        withSize:CGSizeMake(320.0f, 50.0f)];
    [self close];
    NSString *state = [self evaluateJavascript:@"testState"];
    XCTAssertTrue([state isEqualToString:@"hidden"], @"state change callback not fired");

    [self expand];
    state = [self evaluateJavascript:@"testState"];
    NSString *errorAction = [self evaluateJavascript:@"testErrorAction"];
    XCTAssertTrue([state isEqualToString:@"hidden"], @"state change callback fired when it should not have been");
    XCTAssertTrue([errorAction isEqualToString:@"mraid.expand()"], @"Expected error from mraid.expand()");
    
    [self setResizePropertiesResizeToSize:CGSizeMake(400.0f, 200.0f) withOffset:CGPointZero withCustomClosePosition:@"top-left" allowOffscreen:YES];
    [self resize];
    state = [self evaluateJavascript:@"testState"];
    errorAction = [self evaluateJavascript:@"testErrorAction"];
    XCTAssertTrue([state isEqualToString:@"hidden"], @"state change callback fired when it should not have been");
    XCTAssertTrue([errorAction isEqualToString:@"mraid.resize()"], @"Expected error from mraid.resize()");

    [self clearTest];
}

- (void)testViewabilityListener {
    [self loadMRAIDListenerBannerWithSelectorName:NSStringFromSelector(_cmd)
                                         atOrigin:CGPointZero
                                         withSize:CGSizeMake(320.0f, 50.0f)];
    NSString *isViewable = [self evaluateJavascript:@"testIsViewable"];
    XCTAssertTrue([isViewable isEqualToString:@"false"], @"expected banner to not be viewable");
    
    [self addBannerAsSubview];
    isViewable = [self evaluateJavascript:@"testIsViewable"];
    XCTAssertTrue([isViewable isEqualToString:@"true"], @"expected banner to be viewable");
    
    [self moveBannerSubviewToOrigin:CGPointMake(1000.0f, 1000.0f)];
    isViewable = [self evaluateJavascript:@"testIsViewable"];
    XCTAssertTrue([isViewable isEqualToString:@"false"], @"expected banner to not be viewable");
    
    [self moveBannerSubviewToOrigin:CGPointMake(0.0f, 200.0f)];
    isViewable = [self evaluateJavascript:@"testIsViewable"];
    XCTAssertTrue([isViewable isEqualToString:@"true"], @"expected banner to be viewable");

    [self clearTest];
}

- (void)testExposureChangeEventDefaultSizeAndPosition {
    [self loadMRAIDListenerBannerWithSelectorName:NSStringFromSelector(_cmd)
                                         atOrigin:CGPointZero
                                         withSize:CGSizeMake(320.0f, 50.0f)];
   
    [self addBannerAsSubview];
    NSString *actualExposedPer = [self evaluateJavascript:@"testExposedPercentage"];
    XCTAssertTrue([actualExposedPer isEqualToString:@"100"], @"expected exposed percentage::100 but actual::%@",actualExposedPer);
    
    NSString *actualVisibleRectX = [self evaluateJavascript:@"testVisibleRectangleX"];
    XCTAssertTrue([actualVisibleRectX isEqualToString:@"0"], @"expected visibleRectX::0 but actual::%@",actualVisibleRectX);
    
    
    NSString *actualVisibleRectY = [self evaluateJavascript:@"testVisibleRectangleY"];
    XCTAssertTrue([actualVisibleRectY isEqualToString:@"0"], @"expected visibleRectY ::0 but actual::%@",actualVisibleRectY);
    
    
    NSString *actualVisibleRectWidth = [self evaluateJavascript:@"testVisibleRectangleWidth"];
    XCTAssertTrue([actualVisibleRectWidth isEqualToString:@"320"], @"expected visibleRectWidth::320 but actual::%@",actualVisibleRectWidth);
    
    
    NSString *actualVisibleRectHeight = [self evaluateJavascript:@"testVisibleRectangleHeight"];
    XCTAssertTrue([actualVisibleRectHeight isEqualToString:@"50"], @"expected visibleRectHeight::50 but actual::%@",actualVisibleRectHeight);
    [self clearTest];
}

- (void)testExposureChangeEventMovedToBottomOfSubView {
    [self loadMRAIDListenerBannerWithSelectorName:NSStringFromSelector(_cmd)
                                         atOrigin:CGPointZero
                                         withSize:CGSizeMake(320.0f, 50.0f)];
   
    
    [self addBannerAsSubview];
    [self moveBannerSubviewToOrigin:CGPointMake(1000.0f, 1000.0f)];
    
    
    NSString *actualExposedPer = [self evaluateJavascript:@"testExposedPercentage"];
    XCTAssertTrue([actualExposedPer isEqualToString:@"0"], @"expected exposed percentage::0 but actual::%@",actualExposedPer);
    
    NSString *actualVisibleRectX = [self evaluateJavascript:@"testVisibleRectangleX"];
    XCTAssertTrue([actualVisibleRectX isEqualToString:@"invisible"], @"expected visibleRectX::invisible but actual::%@",actualVisibleRectX);
    
    
    NSString *actualVisibleRectY = [self evaluateJavascript:@"testVisibleRectangleY"];
    XCTAssertTrue([actualVisibleRectY isEqualToString:@"invisible"], @"expected visibleRectY ::invisible but actual::%@",actualVisibleRectY);
    
    
    NSString *actualVisibleRectWidth = [self evaluateJavascript:@"testVisibleRectangleWidth"];
    XCTAssertTrue([actualVisibleRectWidth isEqualToString:@"invisible"], @"expected visibleRectWidth::invisible but actual::%@",actualVisibleRectWidth);
    
    
    NSString *actualVisibleRectHeight = [self evaluateJavascript:@"testVisibleRectangleHeight"];
    XCTAssertTrue([actualVisibleRectHeight isEqualToString:@"invisible"], @"expected visibleRectHeight::invisible but actual::%@",actualVisibleRectHeight);
    
    [self clearTest];
}

- (void)testRemoveEventListener {
    [self addMRAIDListenerBannerWithSelectorName:NSStringFromSelector(_cmd)
                                        atOrigin:CGPointZero
                                        withSize:CGSizeMake(320.0f, 50.0f)];
    [self evaluateJavascript:@"mraid.removeEventListener('ready', onReady);"];
    NSString *errorAction = [self evaluateJavascript:@"testErrorAction"];
    XCTAssertTrue([errorAction isEqualToString:@""], @"Did not expect an error on removeEventListener()");
    
    [self evaluateJavascript:@"mraid.removeEventListener('ready', onReady);"];
    errorAction = [self evaluateJavascript:@"testErrorAction"];
    XCTAssertTrue([errorAction isEqualToString:@"mraid.removeEventListener()"], @"Expected error on removeEventListener()");
    
    [self clearTest];
}

#pragma mark - mraid.addEventListener AudioVolumeChange

- (void)testAudioVolumeChangeEventOnScreen {
    [self loadMRAIDListenerBannerWithSelectorName:NSStringFromSelector(_cmd)
                                          atOrigin:CGPointZero
                                          withSize:CGSizeMake(320.0f, 50.0f)];
    [self addBannerAsSubview];
    [self audioVolumeChange];
    NSString *actualVolumePer = [self evaluateJavascript:@"testVolumePercentage"];
    XCTAssertTrue([self isVolumePercentageNumeric:actualVolumePer], @"expected volume percentage::numeric but actual::%@",actualVolumePer);
    
    [self clearTest];
   
}

- (void)testAudioVolumeChangeEventOffScreen {
    [self loadMRAIDListenerBannerWithSelectorName:NSStringFromSelector(_cmd)
                                          atOrigin:CGPointZero
                                          withSize:CGSizeMake(320.0f, 50.0f)];
   
    [self addBannerAsSubview];
    [self moveBannerSubviewToOrigin:CGPointMake(1000.0f, 1000.0f)];
    [self audioVolumeChange];
    NSString *actualVolumePer = [self evaluateJavascript:@"testVolumePercentage"];
    XCTAssertTrue([actualVolumePer isEqualToString:@"0"], @"expected volume percentage::null but actual::%@",actualVolumePer);
    
    [self clearTest];
}

#pragma mark - mraid.supports()

- (void)testSupportSMS {
    [self loadBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    BOOL isSupported = [self supports:@"sms"];
    #if TARGET_IPHONE_SIMULATOR
    XCTAssertFalse(isSupported, @"Expected iphone simulator to not support SMS");
    #elif TARGET_OS_IPHONE
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        XCTAssertTrue(isSupported, @"Expected iPhone device to support SMS");
    }
    #else
    XCTAssertFalse(isSupported);
    #endif
    [self clearTest];
}

- (void)testSupportTel {
    [self loadBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    BOOL isSupported = [self supports:@"tel"];
    #if TARGET_IPHONE_SIMULATOR
    XCTAssertFalse(isSupported, @"Expected iphone simulator to not support Tel");
    #else
    XCTAssertTrue(isSupported, @"Expected iPhone device to support Tel");
    #endif
    [self clearTest];
}

- (void)testSupportCal {
    [self loadBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd)];
    BOOL isSupported = [self supports:@"calendar"];
    XCTAssertFalse(isSupported, @"Calendar support NOT expected.");
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
    XCTAssertFalse(isSupported, @"Store support NOT expected.");
    [self clearTest];
}



#pragma mark - Test about: Loading

- (void)testiFrameAboutProtocolLoading {
    [self loadMRAIDBannerAtOrigin:CGPointZero
                         withSize:CGSizeMake(320, 50)
                    usingStubBody:[ANMRAIDTestResponses iFrameAboutBannerWithSelectorName:NSStringFromSelector(_cmd)]];
    [self addBannerAsSubview];
    NSString *result = [self evaluateJavascript:@"messageReceived"];
    XCTAssertEqualObjects(result, @"true", @"Expected about:srcdoc to be supported");
    [self clearTest];
}

- (void)testMainFrameAboutProtocolLoading {
    [self loadMRAIDBannerAtOrigin:CGPointZero
                         withSize:CGSizeMake(320, 50)
                    usingStubBody:[ANMRAIDTestResponses mainFrameAboutBannerWithSelectorName:NSStringFromSelector(_cmd)]];
    [self addBannerAsSubview];
    NSString *result = [self evaluateJavascript:@"document.documentURI"];
    XCTAssertEqualObjects(result, @"https://mediation.adnxs.com/", @"Did not expect redirect to about:blank");
    [self clearTest];
}

#pragma mark - mraid.exposureChange()

- (void)testExposureChangeOnLoad {
   
   CGRect screenBounds = ANPortraitScreenBounds();
   CGFloat expectedHeight = screenBounds.size.height;
   CGFloat expectedOriginX = screenBounds.size.width/2 - 160;
   CGFloat expectedOriginY = expectedHeight/5;
   
   [self addBasicMRAIDBannerWithSelectorName:NSStringFromSelector(_cmd) atOrigin:CGPointMake(expectedOriginX, expectedOriginY) withSize:CGSizeMake(320.0f, 50.0f)];
   
   [self delay:3];
   ANAdWebViewController  *webViewController  = self.standardAdView.webViewController;
   XCTAssertTrue(webViewController.lastKnownExposedPercentage == 100);
   XCTAssertTrue(CGRectEqualToRect(webViewController.lastKnownVisibleRect, CGRectMake(0, 0, 320, 50)));
   
   expectedOriginY = expectedHeight/2;
   [self updatePositionOfBanner:expectedOriginY];
   [self delay:3];
   webViewController  = self.standardAdView.webViewController;
   XCTAssertTrue(webViewController.lastKnownExposedPercentage == 100);
   XCTAssertTrue(CGRectEqualToRect(webViewController.lastKnownVisibleRect, CGRectMake(0, 0, 320, 50)));
   
   expectedOriginY = expectedHeight - 50;
   [self updatePositionOfBanner:expectedOriginY];
   [self delay:3];
   webViewController  = self.standardAdView.webViewController;
   XCTAssertTrue(webViewController.lastKnownExposedPercentage == 100);
   XCTAssertTrue(CGRectEqualToRect(webViewController.lastKnownVisibleRect, CGRectMake(0, 0, 320, 50)));
   
   expectedOriginY = expectedHeight - 40;
   [self updatePositionOfBanner:expectedOriginY];
   [self delay:3];
   webViewController  = self.standardAdView.webViewController;
   XCTAssertTrue(webViewController.lastKnownExposedPercentage == 80);
   XCTAssertTrue(CGRectEqualToRect(webViewController.lastKnownVisibleRect, CGRectMake(0, 0, 320, 40)));
   
   expectedOriginY = expectedHeight - 30;
   [self updatePositionOfBanner:expectedOriginY];
   [self delay:3];
   webViewController  = self.standardAdView.webViewController;
   XCTAssertTrue(webViewController.lastKnownExposedPercentage == 60);
   XCTAssertTrue(CGRectEqualToRect(webViewController.lastKnownVisibleRect, CGRectMake(0, 0, 320, 30)));
   
   expectedOriginY = expectedHeight - 20;
   [self updatePositionOfBanner:expectedOriginY];
   [self delay:3];
   webViewController  = self.standardAdView.webViewController;
   XCTAssertTrue(webViewController.lastKnownExposedPercentage == 40);
   XCTAssertTrue(CGRectEqualToRect(webViewController.lastKnownVisibleRect, CGRectMake(0, 0, 320, 20)));
   
   expectedOriginY = expectedHeight - 10;
   [self updatePositionOfBanner:expectedOriginY];
   [self delay:3];
   webViewController  = self.standardAdView.webViewController;
   XCTAssertTrue(webViewController.lastKnownExposedPercentage == 20);
   XCTAssertTrue(CGRectEqualToRect(webViewController.lastKnownVisibleRect, CGRectMake(0, 0, 320, 10)));
   
   expectedOriginY = expectedHeight;
   [self updatePositionOfBanner:expectedOriginY];
   [self delay:3];
   webViewController  = self.standardAdView.webViewController;
   XCTAssertTrue(webViewController.lastKnownExposedPercentage == 0);
   XCTAssertTrue(CGRectEqualToRect(webViewController.lastKnownVisibleRect, CGRectMake(0, 0, 0, 0)));
   
   expectedOriginY = expectedHeight/5;
   [self updatePositionOfBanner:expectedOriginY];
   [self delay:3];
   webViewController  = self.standardAdView.webViewController;
   XCTAssertTrue(webViewController.lastKnownExposedPercentage == 100);
   XCTAssertTrue(CGRectEqualToRect(webViewController.lastKnownVisibleRect, CGRectMake(0, 0, 320, 50)));
}

#pragma mark - Helper Functions

- (void)clearTest
{
    [self removeBannerFromSuperview];

    if (ANStatusBarOrientation() != UIInterfaceOrientationPortrait) {
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
                                    withSize:(CGSize)size
{
    [self loadMRAIDBannerAtOrigin: origin
                         withSize: size
                    usingStubBody: [ANMRAIDTestResponses basicMRAIDBannerWithSelectorName:selector]];
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
                  usingStubBody:(NSString *)body
{
    [self stubWithInitialMockResponse:body];
    [self loadBannerAdAtOrigin:CGPointMake(origin.x, origin.y) withSize:CGSizeMake(size.width, size.height)];

    XCTAssertTrue([self waitForCompletion:MRAID_TESTS_TIMEOUT], @"Ad load timed out");
    XCTAssertTrue(self.adDidLoadCalled, @"Success callback should be called");
    XCTAssertFalse(self.adFailedToLoadCalled, @"Failure callback should not be called");

    id  containerView  = [[self.banner subviews] firstObject];

    XCTAssertTrue([containerView isKindOfClass:[ANMRAIDContainerView class]], @"Expected ANMRAIDContainerView as subview of BannerAdView");

    self.standardAdView                                 = (ANMRAIDContainerView *)containerView;
    self.standardAdView.userInteractedWithContentView   = YES;

    ANAdWebViewController  *webViewController  = self.standardAdView.webViewController;

    self.webView = webViewController.contentView;
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
    [self stubWithInitialMockResponse:[ANMRAIDTestResponses basicMRAIDInterstitialWithSelectorName:NSStringFromSelector(_cmd)]];
    self.interstitial = [[ANInterstitialAd alloc] initWithPlacementId:@"1"];
    [self.interstitial loadAd];
    [self.interstitial setBackgroundColor:[UIColor redColor]];
    [self.interstitial setCloseDelay:0.1];
    [self delay:0.5];
    [self.interstitial displayAdFromViewController:[ANGlobal getKeyWindow].rootViewController];
    UIViewController *pvc = [ANGlobal getKeyWindow].rootViewController.presentedViewController;
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

-(void) updatePositionOfBanner:(CGFloat) originY
{
   CGRect screenBounds = ANPortraitScreenBounds();
   CGFloat originX = screenBounds.size.width/2 - 160;
   CGRect frame = self.banner.frame;
   frame.origin = CGPointMake(originX, originY);
   self.banner.frame = frame;
}

-(bool) isVolumePercentageNumeric:(NSString*) volumePercentage{
   NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
   [numberFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
   NSNumber* number = [numberFormatter numberFromString:volumePercentage];
   if (number != nil) {
      return true;
   }
   return false;
}

# pragma mark - MRAID Accessor Functions

- (void)expand {
    [self mraidNativeCall:@"expand()" withDelay:MRAID_TESTS_DEFAULT_DELAY];
}

- (void)close {
    [self mraidNativeCall:@"close()" withDelay:MRAID_TESTS_DEFAULT_DELAY];
}

- (void)resize {
    [self mraidNativeCall:@"resize()" withDelay:MRAID_TESTS_DEFAULT_DELAY];
}

- (void)audioVolumeChange {
   [self mraidNativeCall:@"audioVolumeChange()" withDelay:MRAID_TESTS_DEFAULT_DELAY];
}

- (NSString *)getState {
    return [self mraidNativeCall:@"getState()" withDelay:3];
}

- (NSString *)isViewable {
    return [self mraidNativeCall:@"isViewable()" withDelay:3];
}

- (CGPoint)getScreenSize {
    return CGPointMake([[self mraidNativeCall:@"getScreenSize()[\"width\"]" withDelay:3] floatValue], [[self mraidNativeCall:@"getScreenSize()[\"height\"]" withDelay:3] floatValue]);
}

- (CGPoint)getMaxSize {
    return CGPointMake([[self mraidNativeCall:@"getMaxSize()[\"width\"]" withDelay:3] floatValue], [[self mraidNativeCall:@"getMaxSize()[\"height\"]" withDelay:3] floatValue]);
}

- (CGRect)getCurrentPosition {
    return CGRectMake([[self mraidNativeCall:@"getCurrentPosition()[\"x\"]" withDelay:3] floatValue],
                      [[self mraidNativeCall:@"getCurrentPosition()[\"y\"]" withDelay:3] floatValue],
                      [[self mraidNativeCall:@"getCurrentPosition()[\"width\"]" withDelay:3] floatValue],
                      [[self mraidNativeCall:@"getCurrentPosition()[\"height\"]" withDelay:3] floatValue]);
}

- (CGRect)getDefaultPosition {
    return CGRectMake([[self mraidNativeCall:@"getDefaultPosition()[\"x\"]" withDelay:3] floatValue],
                      [[self mraidNativeCall:@"getDefaultPosition()[\"y\"]" withDelay:3] floatValue],
                      [[self mraidNativeCall:@"getDefaultPosition()[\"width\"]" withDelay:3] floatValue],
                      [[self mraidNativeCall:@"getDefaultPosition()[\"height\"]" withDelay:3] floatValue]);
}

- (void)setOrientationPropertiesWithAllowOrientationChange:(BOOL)changeAllowed forceOrientation:(NSString *)orientation {
    NSString *allowOrientationChange = changeAllowed ? @"true":@"false";
    [self mraidNativeCall:[NSString stringWithFormat:@"setOrientationProperties({allowOrientationChange:%@, forceOrientation:\"%@\"});", allowOrientationChange, orientation] withDelay:MRAID_TESTS_DEFAULT_DELAY];
}

- (CGSize)getExpandPropertiesSize {
    return CGSizeMake([[self mraidNativeCall:@"getExpandProperties()[\"width\"]" withDelay:3] floatValue], [[self mraidNativeCall:@"getExpandProperties()[\"height\"]" withDelay:3] floatValue]);
}

- (NSString *)getExpandPropertiesUseCustomClose { // want to test actual response against being "undefined"
    return [self mraidNativeCall:@"getExpandProperties()[\"useCustomClose\"]" withDelay:3];
}

- (NSString *)getExpandPropertiesIsModal { // want to validate actual response against being "undefined"
    return [self mraidNativeCall:@"getExpandProperties()[\"isModal\"]" withDelay:3];
}

- (NSString *)getExpandPropertiesWidth {
    return [self mraidNativeCall:@"getExpandProperties()[\"width\"]" withDelay:3];
}

- (NSString *)getExpandPropertiesHeight {
    return [self mraidNativeCall:@"getExpandProperties()[\"height\"]" withDelay:3];
}

- (void)setExpandPropertiesExpandToSize:(CGSize)size useCustomClose:(BOOL)useCustomClose setModal:(BOOL)isModal {
    [self mraidNativeCall:[NSString stringWithFormat:@"setExpandProperties({width:%f, height: %f, useCustomClose: %@, isModal: %@});", size.width, size.height,
                           useCustomClose ? @"true":@"false", isModal ? @"true":@"false"] withDelay:3];
}
    
- (void)setExpandPropertiesExpandToSize:(CGSize)size {
    [self mraidNativeCall:[NSString stringWithFormat:@"setExpandProperties({width:%f, height: %f});", size.width, size.height] withDelay:3];
}

- (void)setExpandPropertiesEmpty {
    [self mraidNativeCall:[NSString stringWithFormat:@"setExpandProperties({});"] withDelay:3];
}

- (void)setResizePropertiesEmpty {
    [self mraidNativeCall:[NSString stringWithFormat:@"setResizeProperties({});"] withDelay:3];
}

- (void)setResizePropertiesResizeToSize:(CGSize)size
                             withOffset:(CGPoint)offset
                withCustomClosePosition:(NSString *)position
                         allowOffscreen:(BOOL)allowOffscreen {
    NSString *offscreen = allowOffscreen ? @"true" : @"false";
    [self mraidNativeCall:[NSString stringWithFormat:@"setResizeProperties({width:%f, height: %f, offsetX: %f, offsetY: %f, customClosePosition: '%@', allowOffscreen: %@});",
                           size.width, size.height, offset.x, offset.y, position, offscreen] withDelay:3];
    
}

- (void)setResizePropertiesResizeToSize:(CGSize)size withOffset:(CGPoint)offset {
    [self mraidNativeCall:[NSString stringWithFormat:@"setResizeProperties({width:%f, height: %f, offsetX: %f, offsetY: %f});", size.width, size.height, offset.x, offset.y] withDelay:3];
}

- (void)setResizePropertiesResizeToSize:(CGSize)size {
    [self mraidNativeCall:[NSString stringWithFormat:@"setResizeProperties({width:%f, height: %f});", size.width, size.height] withDelay:3];
}

- (NSString *)getResizePropertiesWidth {
    return [self mraidNativeCall:@"getResizeProperties()[\"width\"]" withDelay:3];
}

- (NSString *)getResizePropertiesHeight {
    return [self mraidNativeCall:@"getResizeProperties()[\"height\"]" withDelay:3];
}

- (NSString *)getResizePropertiesOffsetX {
    return [self mraidNativeCall:@"getResizeProperties()[\"offsetX\"]" withDelay:3];
}

- (NSString *)getResizePropertiesOffsetY {
    return [self mraidNativeCall:@"getResizeProperties()[\"offsetY\"]" withDelay:3];
}

- (NSString *)getResizePropertiesCustomClosePosition {
    return [self mraidNativeCall:@"getResizeProperties()[\"customClosePosition\"]" withDelay:3];
}

- (NSString *)getResizePropertiesAllowOffscreen {
    return [self mraidNativeCall:@"getResizeProperties()[\"allowOffscreen\"]" withDelay:3];
}

- (BOOL)supports:(NSString *)feature {
    return [[self mraidNativeCall:[NSString stringWithFormat:@"supports('%@')", feature] withDelay:3] boolValue];
}

- (NSString *)evaluateJavascript:(NSString *)javascript {
    if ([self.webView isKindOfClass:[WKWebView class]]) {
        WKWebView *webView = (WKWebView *)self.webView;
        __block BOOL responseReceived = NO;
        __block NSString *resultString = nil;
        
        [webView evaluateJavaScript:javascript
                  completionHandler:^(id result, NSError *error) {
                      if ([result isKindOfClass:[NSClassFromString(@"__NSCFBoolean") class]]) {
                          resultString = [NSString stringWithFormat:@"%@", [result boolValue] ? @"true" : @"false"];
                      } else if (result != nil) {
                          resultString = [NSString stringWithFormat:@"%@", result];
                      }
                      responseReceived = YES;
        }];
        
        while (!responseReceived) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
        
        return resultString;
    } else {
        UIWebView *webView = (UIWebView *)self.webView;
        return [webView stringByEvaluatingJavaScriptFromString:javascript];
    }
}

- (NSString *)mraidNativeCall:(NSString *)script withDelay:(NSTimeInterval)delay {
    NSString *response = [self evaluateJavascript:[NSString stringWithFormat:@"mraid.%@",script]];
    if (delay) {
        [self delay:delay];
    }
    return response;
}

@end
