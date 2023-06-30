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
#import "ANNativeAdRequest.h"

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




#pragma mark - Example implementation

/**
 This view displays ads from placements that return banner, video and/or native ads.
 Note the implementation requires delaying the point where the ad is displayed,
   because native ads are displayed with ANNativeAdResponse and because the type of ad must be
   tested after load in order to determine the proper means for display.

 @code
    ANBannerAdView  *banner  = nil;

    - (void) loadMultiFormatAd
    {
        CGSize  size      = CGSizeMake(300, 250);  // NOTE  Setting size is necessary only for fetching banner and video ad objects.
                                                   //       This field is ignored when the placement returns a native ad object.
        CGRect  someRect  = CGRectMake(...);

        // Create the banner ad view here, but wait until the delegate fires before displaying.
        //
        ANBannerAdView  *banner  = [ANBannerAdView adViewWithFrame:someRect placementId:@"<YOUR_PLACEMENT_ID>" adSize:size];
        banner.rootViewController = self;

        // Load an ad!
        [banner loadAd];
    }

    // Display all multi-format ads in success method from ANBannerAdViewDelegate.
    //
    - (void) adDidReceiveAd:(id)adObject
    {
        if ([adObject isKindOfClass:[ANNativeAdResponse class]])
        {
            ANNativeAdResponse  *nativeAdResponse  = (ANNativeAdResponse *)ad;
            MyNativeView        *nativeView        = [[MyNativeView alloc] init];

            nativeView.title.text            = nativeAdResponse.title;
            nativeView.text.text             = nativeAdResponse.body;
            nativeView.iconImageView.image   = nativeAdResponse.iconImage;
            nativeView.mainImageView.image   = nativeAdResponse.mainImage;

            [nativeView.callToActionButton setTitle:response.callToAction forState:UIControlStateNormal];

            nativeAdResponse.delegate = self;

            [nativeAdResponse registerViewForTracking: nativeView
                              withRootViewController: self
                                      clickableViews: @[nativeView.callToActionButton, nativeView.mainImageView]
                                               error: nil
              ];

            [self.view addSubview:nativeView];

        } else {
            [self.view addSubview:banner];
        }
    }
 @endcode


 If this view will be displaying placements that include only banner and/or video ads,
   then display can be (optimistically) handled without using ANBannerAdViewDelegate:

 @code
    - (void) loadMultiFormatAdThatDoesNotIncludeNative
    {
        CGSize size = CGSizeMake(300, 250);

        // Create the banner ad view and add it as a subview.
        //
        ANBannerAdView  *banner  = [ANBannerAdView adViewWithFrame:rect placementId:@"13572468" adSize:size];
        banner.rootViewController = self;

        [self.view addSubview:banner];

        // Load an ad!
        // NOTE  Upon loadAd failure, the view impression simply remains blank.
        //
        [banner loadAd];
    }
 @endcode
 */



#pragma mark - ANBannerAdView

@interface ANBannerAdView : ANAdView <ANVideoAdProtocol>

/**
 Delegate object that receives notifications from this ANBannerAdView.  Equivalent to ANAdDelegate.
 Overloaded as the delegate for ANNativeAdResponse object which is a perfect subset of ANAdDelegate.
 */
@property (nonatomic, readwrite, weak, nullable) id<ANBannerAdViewDelegate> delegate;

/**
 Delegate object that receives custom app event notifications from this ANBannerAdView.
 */
@property (nonatomic, readwrite, weak, nullable) id<ANAppEventDelegate> appEventDelegate;

/**
 Required reference to the root view controller.  Used as shown in
 the example above to set the banner ad view's controller to your
 own view controller implementation.
*/
@property (nonatomic, readwrite, weak, nullable) UIViewController *rootViewController;

/**
 Represents the width and height of the ad view.  In order for ads
 to display correctly, you must verify that your AppNexus placement
 is a ``sizeless'' placement.  If you are seeing ads of a fixed size
 being squeezed into differently-sized views, you probably do not
 have a sizeless placement.
 */
@property (nonatomic, readwrite, assign) CGSize adSize;

/**
 Return the loaded Ad Size.
 */
@property (nonatomic, readonly) CGSize loadedAdSize;

/**
 The set of allowed ad sizes for the banner ad.
 The set should contain CGSize values wrapped as NSValue objects.
 */
@property (nonatomic, readwrite, strong, nonnull) NSArray<NSValue *> *adSizes;

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

/**
 Set whether ads will resize to fit the container width. This
 feature will cause ad creatives that are smaller than the view
 size to 'stretch' to the current size. This may cause image
 quality degradation for the benefit of having an ad occupy the
 entire ad view. This feature is disabled by default.
 */
@property (nonatomic, readwrite, assign) BOOL shouldResizeAdToFitContainer;

/**
 * Sets whether or not Video Ads(AppNexus Media Type:4) can serve on this Ad object.
 */
@property (nonatomic, readwrite) BOOL shouldAllowVideoDemand;

@property (nonatomic, readwrite, assign) CGSize landscapeBannerVideoPlayerSize;

@property (nonatomic, readwrite, assign) CGSize portraitBannerVideoPlayerSize;

@property (nonatomic, readwrite, assign) CGSize squareBannerVideoPlayerSize;

/**
 * Sets whether or not Native Ads(AppNexus Media Type:12) can serve on this Ad object.
 *
*/
@property (nonatomic, readwrite) BOOL shouldAllowNativeDemand;

/**
 * Sets whether or not High Impact Media(AppNexus Media Type:11) can serve on this Ad object.
 *
*/
@property (nonatomic, readwrite) BOOL shouldAllowHighImpactDemand;


/**
 * Sets whether or not banner Ads(AppNexus Media Type:1) can serve on this Ad object.
 *  If shouldAllowBannerDemand is not set, the default is true.
*/
@property (nonatomic, readwrite) BOOL shouldAllowBannerDemand;



/**
 *  If enableNativeRendering is not set, the default is false.
 *  Rendering NativeAd to behave as BannerAd
 */
@property (nonatomic, readwrite) BOOL enableNativeRendering;

/**
 *  nativeAdRendererId :  Native Assembly renderer_id that is associated with the placement.
 *  If rendererId is not set, the default is zero (0).
 *  A value of zero indicates that renderer_id will not be sent in the UT Request.
 */
@property (nonatomic, readwrite) NSInteger nativeAdRendererId;


/**
 *  If enableLazyLoad is not set, the default is NO.
 *  Generate AdUnit without loading webview automatically.
 *  Host app must complete load with [self loadLazyAd].
 */
@property (nonatomic, readwrite)  BOOL  enableLazyLoad;


#pragma mark - Creating an ad view and loading an ad

/**
 You can use either of the initialization methods below.
 adViewWithFrame handles calling initWithFrame for you, but it's
 there if you need to use it directly.

 Initializes an ad view with the specified frame (this frame must be
 smaller than the view's size).  Used internally by adViewWithFrame,
 so you may want to use that instead, unless you prefer to manage
 this manually.
 */
- (nonnull instancetype)initWithFrame:(CGRect)frame placementId:(nonnull NSString *)placementId;
- (nonnull instancetype)initWithFrame:(CGRect)frame placementId:(nonnull NSString *)placementId adSize:(CGSize)size;

/**
 Instead of requesting ads using placement id, alternatively, you can 
 use either of the initialization methods below to initialize a banner
 using member id and inventory code.
 */
- (nonnull instancetype)initWithFrame:(CGRect)frame memberId:(NSInteger)memberId inventoryCode:(nonnull NSString *)inventoryCode;
- (nonnull instancetype)initWithFrame:(CGRect)frame memberId:(NSInteger)memberId inventoryCode:(nonnull NSString *)inventoryCode adSize:(CGSize)size;

/**
 Initializes an ad view.  These are autoreleased constructors of the
 above initializers that will handle the frame initialization for
 you.  (For usage, see the example at the top of this file).
 */
+ (nonnull ANBannerAdView *)adViewWithFrame:(CGRect)frame placementId:(nonnull NSString *)placementId;
+ (nonnull ANBannerAdView *)adViewWithFrame:(CGRect)frame placementId:(nonnull NSString *)placementId adSize:(CGSize)size;




#pragma mark - Loading an ad

/**
 Loads a single ad into this ad view.  If autorefresh is not set to
 0, this will also start a timer to refresh the banner
 automatically.
 */
- (void) loadAd;

- (BOOL) loadLazyAd;


@end




#pragma mark - ANBannerAdViewDelegate

/**
 See ANAdDelegate for common delegate methods.
 */
@protocol ANBannerAdViewDelegate <ANAdDelegate>

@end
