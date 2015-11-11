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

#import "ANAdView.h"

@protocol ANBannerAdViewDelegate;

typedef NS_ENUM(NSUInteger, ANBannerViewAdTransitionType) {
    ANBannerViewAdTransitionTypeNone = 0,
    ANBannerViewAdTransitionTypeFade,
    ANBannerViewAdTransitionTypePush,
    ANBannerViewAdTransitionTypeMoveIn,
    ANBannerViewAdTransitionTypeReveal,
    ANBannerViewAdTransitionTypeFlip,
};

typedef NS_ENUM(NSUInteger, ANBannerViewAdTransitionDirection) {
    ANBannerViewAdTransitionDirectionUp = 0,
    ANBannerViewAdTransitionDirectionDown,
    ANBannerViewAdTransitionDirectionLeft,
    ANBannerViewAdTransitionDirectionRight,
    ANBannerViewAdTransitionDirectionRandom
};

typedef NS_ENUM(NSUInteger, ANBannerViewAdAlignment) {
    ANBannerViewAdAlignmentCenter = 0,
    ANBannerViewAdAlignmentTopLeft,
    ANBannerViewAdAlignmentTopCenter,
    ANBannerViewAdAlignmentTopRight,
    ANBannerViewAdAlignmentCenterLeft,
    ANBannerViewAdAlignmentCenterRight,
    ANBannerViewAdAlignmentBottomLeft,
    ANBannerViewAdAlignmentBottomCenter,
    ANBannerViewAdAlignmentBottomRight
};

#pragma mark Example implementation

/**
 This view displays banner ads.  A simple implementation that shows
 a 300x50 ad is:

 @code
  CGSize size = CGSizeMake(300, 50);
 
  // Create the banner ad view and add it as a subview
  ANBannerAdView *banner = [ANBannerAdView adViewWithFrame:rect placementId:@"1326299" adSize:size];
  banner.rootViewController = self;
  [self.view addSubview:banner];

  // Load an ad!
  [banner loadAd];
  [banner release]; // Only required for non-ARC projects
 @endcode
 
 */
@interface ANBannerAdView : ANAdView

/**
 Delegate object that receives notifications from this
 ANBannerAdView.
 */
@property (nonatomic, readwrite, weak) id<ANBannerAdViewDelegate> delegate;

/**
 Delegate object that receives custom app event notifications from this
 ANBannerAdView.
 */
@property (nonatomic, readwrite, weak) id<ANAppEventDelegate> appEventDelegate;

/**
 Required reference to the root view controller.  Used as shown in
 the example above to set the banner ad view's controller to your
 own view controller implementation.
*/
@property (nonatomic, readwrite, weak) UIViewController *rootViewController;

/**
 Represents the width and height of the ad view.  In order for ads
 to display correctly, you must verify that your AppNexus placement
 is a ``sizeless'' placement.  If you are seeing ads of a fixed size
 being squeezed into differently-sized views, you probably do not
 have a sizeless placement.
 */
@property (nonatomic, readwrite, assign) CGSize adSize;

/**
 Autorefresh interval.  Default interval is 30.0; the minimum
 allowed is 15.0.  To disable autorefresh, set to 0.
 */
@property (nonatomic, readwrite, assign) NSTimeInterval autoRefreshInterval;

/**
 The type of transition that occurs between an old ad and a new ad when the ad slot is refreshed
 (either automatically or by calling loadAd). Transitions are disabled by default. See the
 ANBannerViewAdTransitionType enumeration above for accepted values.
 */
@property (nonatomic, readwrite, assign) ANBannerViewAdTransitionType transitionType;

/**
 The direction in which the transition between ads progresses. The default direction is up. Has no
 effect if transitions are disabled, or set to "fade". See the ANBannerViewAdTransitionDirection
 enumeration above for accepted values.
 */
@property (nonatomic, readwrite, assign) ANBannerViewAdTransitionDirection transitionDirection;

/**
 The duration of the transition between ads, default is 1 second. Has no effect if transitions
 are disabled.
 */
@property (nonatomic, readwrite, assign) NSTimeInterval transitionDuration;

/**
 The alignment of the ad within the banner view, in the event the ad is a different size than the 
 banner view. This can happen if the adSize is omitted and an ad smaller than the frame size is
 returned from the ad server. See the ANBannerViewAdAlignment enumeration above for accepted values.
 */
@property (nonatomic, readwrite, assign) ANBannerViewAdAlignment alignment;

#pragma mark Creating an ad view and loading an ad

/**
 You can use either of the initialization methods below.
 adViewWithFrame handles calling initWithFrame for you, but it's
 there if you need to use it directly.

 Initializes an ad view with the specified frame (this frame must be
 smaller than the view's size).  Used internally by adViewWithFrame,
 so you may want to use that instead, unless you prefer to manage
 this manually.
 */
- (instancetype)initWithFrame:(CGRect)frame placementId:(NSString *)placementId;
- (instancetype)initWithFrame:(CGRect)frame placementId:(NSString *)placementId adSize:(CGSize)size;

/**
 Instead of requesting ads using placement id, alternatively, you can 
 use either of the initialization methods below to initialize a banner
 using member id and inventory code.
 */
- (instancetype)initWithFrame:(CGRect)frame memberId:(NSInteger)memberId inventoryCode:(NSString *)inventoryCode;
- (instancetype)initWithFrame:(CGRect)frame memberId:(NSInteger)memberId inventoryCode:(NSString *)inventoryCode adSize:(CGSize)size;

/**
 Initializes an ad view.  These are autoreleased constructors of the
 above initializers that will handle the frame initialization for
 you.  (For usage, see the example at the top of this file).
 */
+ (ANBannerAdView *)adViewWithFrame:(CGRect)frame placementId:(NSString *)placementId;
+ (ANBannerAdView *)adViewWithFrame:(CGRect)frame placementId:(NSString *)placementId adSize:(CGSize)size;

#pragma mark Loading an ad

/**
 Loads a single ad into this ad view.  If autorefresh is not set to
 0, this will also start a timer to refresh the banner
 automatically.
 */
- (void)loadAd;

@end

#pragma mark ANBannerAdViewDelegate

/**
 See ANAdDelegate for common delegate methods.
 */
@protocol ANBannerAdViewDelegate <ANAdDelegate>

@end
