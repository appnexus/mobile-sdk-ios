//
//  VdoAdView.h
//  iTennis
//
//  Created by Nitish garg on 28/10/13.
//
//

enum viewPosition
{
    topBanner=0,
    middleBanner,
    bottomBanner
    
};


#import <UIKit/UIKit.h>
#import "LVDOAdRequest.h"
#import "LVDOAdViewDelegate.h"



/**
 * The MPAdView class provides a view that can display banner advertisements.
 */

@interface LVDOAdView : UIViewController <LVDOAdViewDelegate>
{
    float BannerHieght;
    float BannerWidth;
    float Y_POSITION;
    int baneerPos;
    float statusBarHeight;
    float navBarHeight;
    float tabFactor;
    BOOL isExpanded;
    CGSize originalSize;

}

/** @name Initializing a Banner Ad */

/**
 * Initializes an MPAdView with the given ad unit ID and banner size.
 *
 * @param adUnitId A string representing a MoPub ad unit ID.
 * @param size The desired ad size. A list of standard ad sizes is available in MPConstants.h.
 * @return A newly initialized ad view corresponding to the given ad unit ID and size.
 */

- (void)setAdView:(UIView *)view;

- (LVDOAdRequest *)getAdRequest;
- (void)setMraidAdView:(UIView *)view;

- (void)setAdFormat:(int)adType;

/** @name Setting and Getting the Delegate */

/**
 * The delegate (`MPAdViewDelegate`) of the ad view.
 *
 * @warning **Important**: Before releasing an instance of `MPAdView`, you must set its delegate
 * property to `nil`.
 */
@property (nonatomic, assign) id<LVDOAdViewDelegate> delegate;
@property(nonatomic,assign)int bannerPosition;
/** @name Setting Request Parameters */

/**
 * The MoPub ad unit ID for this ad view.
 *
 * Ad unit IDs are created on the MoPub website. An ad unit is a defined placement in your
 * application set aside for advertising. If no ad unit ID is set, the ad view will use a default
 * ID that only receives test ads.
 */


@property (nonatomic, copy) NSString *adUnitId;
@property (nonatomic) int adType;

/**
 * A string representing a set of keywords that should be passed to the MoPub ad server to receive
 * more relevant advertising.
 *
 * Keywords are typically used to target ad campaigns at specific user segments. They should be
 * formatted as comma-separated key-value pairs (e.g. "marital:single,age:24").
 *
 * On the MoPub website, keyword targeting options can be found under the "Advanced Targeting"
 * section when managing campaigns.
 */
@property (nonatomic, strong) NSString *keywords;

/**
 * A `CLLocation` object representing a user's location that should be passed to the MoPub ad server
 * to receive more relevant advertising.
 */

@property (nonatomic,strong) LVDOAdRequest *request;

/** @name Enabling Test Mode */

/**
 * A Boolean value that determines whether the ad view should request ads in test mode.
 *
 * The default value is NO.
 * @warning **Important**: If you set this value to YES, make sure to reset it to NO before
 * submitting your application to the App Store.
 */
@property (nonatomic, assign, getter = isTesting) BOOL testing;

/** @name Loading a Banner Ad */

/**
 * Requests a new ad from the MoPub ad server.
 *
 * If the ad view is already loading an ad, this call will be ignored. You may use `forceRefreshAd`
 * if you would like cancel any existing ad requests and force a new ad to load.
 */
- (void)loadAd;
- (void)loadAd:(LVDOAdRequest *)request;

/**
 * Requests a new ad from the MoPub ad server.
 *
 * If the ad view is already loading an ad, this call will be ignored. You may use `forceRefreshAd`
 * if you would like cancel any existing ad requests and force a new ad to load.
 *
 * **Warning**: This method has been deprecated. Use `loadAd` instead.
 */

/**
 * Cancels any existing ad requests and requests a new ad from the MoPub ad server.
 */

/** @name Handling Orientation Changes */

/**
 * Informs the ad view that the device orientation has changed.
 *
 * Banners from some third-party ad networks have orientation-specific behavior. You should call
 * this method when your application's orientation changes if you want mediated ads to acknowledge
 * their new orientation.
 *
 * If your application layout needs to change based on the size of the mediated ad, you may want to
 * check the value of `adContentViewSize` after calling this method, in case the orientation change
 * causes the mediated ad to resize.
 *
 * @param newOrientation The new interface orientation (after orientation changes have occurred).
 */

/**
 * Forces third-party native ad networks to only use ads sized for the specified orientation.
 *
 * Banners from some third-party ad networks have orientation-specific behaviors and/or sizes.
 * You may use this method to lock ads to a certain orientation. For instance,
 * if you call this with MPInterfaceOrientationPortrait, native networks (e.g. iAd) will never
 * return ads sized for the landscape orientation.
 *
 * @param orientation An MPNativeAdOrientation enum value.
 *
 * <pre><code>typedef enum {
 *          MPNativeAdOrientationAny,
 *          MPNativeAdOrientationPortrait,
 *          MPNativeAdOrientationLandscape
 *      } MPNativeAdOrientation;
 * </pre></code>
 *
 * @see unlockNativeAdsOrientation
 * @see allowedNativeAdsOrientation
 */


/**
 * Allows third-party native ad networks to use ads sized for any orientation.
 *
 * You do not need to call this method unless you have previously called
 * `lockNativeAdsToOrientation:`.
 *
 * @see lockNativeAdsToOrientation:
 * @see allowedNativeAdsOrientation
 */

/**
 * Returns the banner orientations that third-party ad networks are allowed to use.
 *
 * @return An enum value representing an allowed set of orientations.
 *
 * @see lockNativeAdsToOrientation:
 * @see unlockNativeAdsOrientation
 */

/** @name Obtaining the Size of the Current Ad */

/**
 * Returns the size of the current ad being displayed in the ad view.
 *
 * Ad sizes may vary between different ad networks. This method returns the actual size of the
 * underlying mediated ad. This size may be different from the original, initialized size of the
 * ad view. You may use this size to determine to adjust the size or positioning of the ad view
 * to avoid clipping or border issues.
 *
 * @returns The size of the underlying mediated ad.
 */

/** @name Managing the Automatic Refreshing of Ads */

/**
 * Stops the ad view from periodically loading new advertisements.
 *
 * By default, an ad view is allowed to automatically load new advertisements if a refresh interval
 * has been configured on the MoPub website. This method prevents new ads from automatically loading,
 * even if a refresh interval has been specified.
 *
 * As a best practice, you should call this method whenever the ad view will be hidden from the user
 * for any period of time, in order to avoid unnecessary ad requests. You can then call
 * `startAutomaticallyRefreshingContents` to re-enable the refresh behavior when the ad view becomes
 * visible.
 *
 * @see startAutomaticallyRefreshingContents
 */

/**
 * Causes the ad view to periodically load new advertisements in accordance with user-defined
 * refresh settings on the MoPub website.
 *
 * Calling this method is only necessary if you have previously stopped the ad view's refresh
 * behavior using `stopAutomaticallyRefreshingContents`. By default, an ad view is allowed to
 * automatically load new advertisements if a refresh interval has been configured on the MoPub
 * website. This method has no effect if a refresh interval has not been set.
 *
 * @see stopAutomaticallyRefreshingContents
 */

/**
 * Replaces the content of the MPAdView with the specified view.
 *
 * @bug **Warning**: This method has been deprecated. You should instead implement banner custom
 * events using a subclass of `MPBannerCustomEvent`.
 *
 * @param view A view representing some banner content.
 */
- (void)setAdContentView:(UIView *)view;

/** @name Managing the Automatic Refreshing of Ads (Deprecated) */

/**
 * A Boolean value that determines whether the ad view should ignore directions from the MoPub
 * ad server to periodically refresh its contents.
 *
 * The default value of this property is NO. Set the property to YES if you want to prevent your ad
 * view from automatically refreshing. *Note:* if you wish to set the property to YES, you should do
 * so before you call `loadAd` for the first time.
 *
 * @bug **Warning**: This property has been deprecated. You should instead use
 * `stopAutomaticallyRefreshingContents` and `startAutomaticallyRefreshingContents` to manage
 * the ad view's refresh behavior.
 */
@property (nonatomic, assign) BOOL ignoresAutorefresh;
-(void)closeActivatedBySDK;
-(void)refreshAd;
-(void)setAdRefreshInterval:(float)selectedInterval;

- (id)initWithAdUnitId:(NSString *)adUnitId size:(int)sizeType delegate:(id)delegate bannerPosition:(int)positionType;

@end

