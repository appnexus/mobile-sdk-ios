//
//  SASMediationNativeAdAdapter.h
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 05/09/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASMediationNativeAdAdapterDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Protocol that must be implemented by mediation adapters that load and return native ads.
 */
@protocol SASMediationNativeAdAdapter <NSObject>

@required

/**
 Initialize a new instance of the native ad adapter with an adapter delegate.
 
 @param delegate An instance of the delegate you will use to provide information to Smart SDK.
 @return An initialized instance of the native ad adapter.
 */
- (instancetype)initWithDelegate:(id<SASMediationNativeAdAdapterDelegate>)delegate;

/**
 Requests a mediated native ad asynchronously.
 
 Use the delegate provided in the init method to inform the SDK about the loading status of the ad.
 
 @param serverParameterString A string containing all needed parameters (as returned by Smart ad delivery) to make the mediation ad call.
 @param clientParameters Additional client-side parameters (see SASMediationAdapterConstants.h for an exhaustive list).
 */
- (void)requestNativeAdWithServerParameterString:(NSString *)serverParameterString clientParameters:(NSDictionary *)clientParameters;

/**
 This method is called to tell the adapter to register a view (or several views) as tappable.
 
 When native ad information are provided to the application, they will be displayed on one or several views by the app developer, then
 registered with the Smart SDK. In case of a mediation native ad, this registering process is the responsability of the adapter.
 
 The adapter will receive a main view that should be registered, some additional views that should also respond to tap events (these
 views are optional), a dictionary that can contains some particular views that you might want to override (like a media view or an
 ad choice button).
 
 The impression will be counted by the Smart SDK as soon as this method is called.
 
 @param view The main view that should react to touch events.
 @param tappableViews Optional views that should also react to touch events
 @param overridableViews A dictionary of views that you might want to override with the one provided by the third party SDK
 (see SASMediationAdapterConstants.h for an exhaustive list).
 @param viewController The view controller from which the views are displayed.
 */
- (void)registerView:(UIView *)view tappableViews:(nullable NSArray *)tappableViews overridableViews:(NSDictionary *)overridableViews fromViewController:(UIViewController *)viewController;

/**
 This method is called when the adapter should unregister views that have been registered previously.
 
 @note This method might be called before the registerView:tappableViews:overridableViews:fromViewController: is called. In this case,
 there isn't anything to do.
 */
- (void)unregisterViews;

/**
 Request the URL that should be used when the 'Ad Choices' button is tapped.
 
 @warning If you return nil, the button might still be visible in the view hierarchy (but it will do nothing). It's up to your adapter
 to hide it or replace it by something else in the registerView:tappableViews:overridableViews:fromViewController: method (if available,
 the button view will be found in the 'overridableViews' dictionary).
 
 @return The URL that should be used when the 'Ad Choices' button is tapped, or nil if you want to handle the button yourself.
 */
- (nullable NSURL *)adChoicesURL;

/**
 Return whether the currently loaded native ad has a video media or not.
 
 @note There is two way for the third party SDK to handle media. This first one is to simply returns the video URL (and tracking pixels if
 any) in the SASMediationNativeAdInfo object and let the Smart SDK handles everything, the second one is to instantiate a view and display
 the video. For both cases, this method must return YES.
 
 @return YES if the currently loaded native ad has a video media, NO otherwise.
 */
- (BOOL)hasMedia;

/**
 Return the media view used for the third party SDK to renders the video media (if any).
 
 @note There is two way for the third party SDK to handle media. This first one is to simply returns the video URL (and tracking pixels if
 any) in the SASMediationNativeAdInfo object and let the Smart SDK handles everything, the second one is to instantiate a view and display
 the video. If you want to let the Smart SDK handles the media, you must return nil.
 
 @return The media view used for the third party SDK to renders the video media (if any), nil otherwise.
 */
- (nullable UIView *)mediaView;

@end

NS_ASSUME_NONNULL_END
