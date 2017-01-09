//
//  AdMarvelNativeAd.h
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AdMarvelNativeAdDelegate.h"

extern NSString *const AdMarvelHandleClickEvent;
extern NSString *const AdMarvelHandleNoticeClickEvent;

/// Native ad types.
typedef NS_ENUM(NSInteger, AdMarvelNativeAdType) {
    AdMarvelNativeAdTypeDefault,
    AdMarvelNativeAdTypeAppInstall,
    AdMarvelNativeAdTypeContent
};

/// Native ad SDK
typedef NS_ENUM(NSInteger, AdMarvelNativeAdSDKName) {
    ADCOLONY_SDK,
    ADMARVEL_SDK,
    CHARTBOOST_SDK,
    FACEBOOK_SDK,
    GOOGLE_ADMOB_SDK,
    HEYZAP_SDK,
    INMOBI_SDK
};

/*!
 The AdMarvelNativeAdVideoView class.
 This object represents a native ad video view.
 */
@interface AdMarvelNativeAdVideoView : UIView
@end

/*!
 The AdMarvelNativeAdImage class.
 This object represents a native ad image.
 */
@interface AdMarvelNativeAdImage : NSObject

/*!
 Image object to display. Use imageURL first if its nil then use image.
 */
@property (nonatomic, readonly, strong) UIImage *image;

/*!
 URL of the image.
 */
@property (nonatomic, readonly, strong) NSURL *imageURL;

/*!
 Width of the image.
 */
@property (nonatomic, readonly, assign) NSInteger width;

/*!
 Height of the image.
 */
@property (nonatomic, readonly, assign) NSInteger height;

@end


/*!
 The AdMarvelNativeAdClickToAction class.
 This object contains info about the ad click to action.
 */

@interface AdMarvelNativeAdClickToAction : NSObject

/*!
 The title of the action to be performed.
 Ex. "Install", "Download", "Click"
 */
@property (nonatomic, readonly, strong) NSString *title;

/*!
 The image to be shown on the click to action widget (Ex. Button)
 You can use this as an alternate to title.
 */
@property (nonatomic, readonly, strong) AdMarvelNativeAdImage *image;

@end


/*!
 The AdMarvelNativeAdRating class.
 This object represents the rating of the app being advertised (often a 1-5 star rating).
 */

@interface AdMarvelNativeAdRating : NSObject

/*!
 The base/maximum value of the rating.
 Ex. "5"
 */
@property (nonatomic, readonly, strong) NSString *baseValue;

/*!
 The value of the rating.
 Ex. "1", "2", "2.5"
 */
@property (nonatomic, readonly, strong) NSString *value;

/*!
 The complete image for rating. This is a single image representing the whole rating.
 */
@property (nonatomic, readonly, strong) AdMarvelNativeAdImage *completeRatingValueImage;

/*!
 The image for a single unit of rating.
 Ex. A star image filled fullly with some color.
 */
@property (nonatomic, readonly, strong) AdMarvelNativeAdImage *fullRatingValueImage;

/*!
 The image for a half unit of rating.
 Ex. A star image half filled fullly with some color and half blanked.
 */
@property (nonatomic, readonly, strong) AdMarvelNativeAdImage *halfRatingValueImage;

/*!
 The image for an empty unit of rating.
 Ex. A blank star image.
 */
@property (nonatomic, readonly, strong) AdMarvelNativeAdImage *blankRatingValueImage;

@end


/*!
 The AdMarvelNativeAdMetadata class.
 This provides any additional info about the ad.
 */
@interface AdMarvelNativeAdMetadata : NSObject

/*!
 The format of the data value.
 Ex. String, XML, JSON
 */
@property (nonatomic, readonly, strong) NSString *type;

/*!
 The value of data.
 */
@property (nonatomic, readonly, strong) NSString *value;

@end


/*!
 The AdMarvelNativeAdNotice class.
 This class provides information about ad notice.
 */
@interface AdMarvelNativeAdNotice : NSObject

/*!
 The image for the notice.
 */
@property (nonatomic, readonly, strong) AdMarvelNativeAdImage *icon;

/*!
 The title to be displayed on notice
 */
@property (nonatomic, readonly, strong) NSString *title;

/*!
 The URL to be shown when clicked on notice.
 */
@property (nonatomic, readonly, strong) NSURL *url;

/*!
 The view for the notice
 */
@property (nonatomic, readonly, strong) UIView *view;

@end


/*!
 The AdMarvelNativeAd class.
 
 The AdMarvelNativeAd object acts as container for all native ad data. This data can be used to construct custom ad views in your application.
 The AdMarvelNativeAd object also provides methods to load a native ad as well as to handle impressions and clicks.
 */

@interface AdMarvelNativeAd : NSObject 									

/*!
 Creates an AdMarvelNativeAd object. After creating this object you must call getNativeAd to request native ad content.
 */
+(AdMarvelNativeAd*) createAdMarvelNativeAdView:(NSObject<AdMarvelNativeAdDelegate>*) delegate;

/*!
 Request the native ad content from AdMarvel SDK.
 You can implement `getNativeAdSucceeded:` and `getNativeAdFailed:` methods of `AdMarvelNativeAdDelegate` protocol to be notified when the request succeeds or fails.
 This method should not be called on a valid native ad.  It will fail if you do so.  Please create new AdMarvelNativeAd objects for each new ad request.
 */
-(void) getNativeAd;


/*! 
 You MUST call this method with the application view containing the native ad. This view will be used for automatic impression  handling. Not calling this method will impact the impression count.
 */
-(void) registerContainerView:(UIView *)view;


/*!
 You MUST call this method to let AdMarvel SDK know about the click on your native view.
 
 This method should be called with the clickableViews (An array of UIView you created to render the native ads data element,e.g. CallToAction button, Icon image, which you want to specify as clickable) and click event (AdMarvelHandleClickEvent/AdMarvelHandleNoticeClickEvent) for those views.
 
 If you are calling this method then you must provide atleast one UIView in clickableViews array. Every UIView passed in this array will be responsible for triggering clicks.
 
 Not calling this method will consider whole area of the native ad contaner as clickable.
 */
-(void) registerViews:(NSArray *)clickableViews forClickEvent:(NSString *)event __deprecated_msg("Please use registerContainerView: or registerContainerView:withClickableViews:forClickEvent:");



/*!
 This method is optional method for 'registerContainerView:' method. You can use this method to register native ad container view for impression tracking and the clickable views to set clickable areas.
 
 NOTE: You should use either "registerContainerView:" or "registerContainerView:withClickableViews:forClickEvent:" method.
 */
- (void)registerContainerView:(UIView * _Nonnull)view withClickableViews:(NSArray * _Nonnull)clickableViews forClickEvent:(NSString * _Nonnull)event;



/*!
 If a view has been registered for interaction using registerContainerView: or registerViews:
 forClickEvent: method then this method should be used to disconnect a AdMarvelNativeAd with the UIView you used to display the native ads.
*/
 -(void) unregisterView;

/*!
 Call this method to know if a native ad is valid or not. An ad should only be valid if a previous call to getNativeAd was successful.
 If a native ad is valid you should not request another ad on that native ad object. It will fail if you do so.
 */
-(BOOL) isAdValid;

/*!
 Call this method to know the native ad type.
 */
-(AdMarvelNativeAdType) getAdType;

/*!
 Call this method to know the native ad SDK.
 */
-(AdMarvelNativeAdSDKName) getAdSDK;


/*!
 Returns recommeded height for native video view using provided width in such a way that video's aspect ratio is maintained.
 */
-(CGFloat) recommendedHeightForWidth:(CGFloat)width;

/*!
 The AdMarvelNativeAdDelegate property.  
 
 This needs to be used to set the delegate to nil if it is ever going to be dealloced. This prevents a released delegate from being referenced by the AdMarvelNativeAd.
 The delegate should also be set to nil right before you release the AdMarvelNativeAd itself.
 */
@property (nonatomic, weak) NSObject<AdMarvelNativeAdDelegate> *delegate;

/*!
 The display name or title of the ad.
 Ex. for install type ads "Name of the app"
 */
@property (nonatomic, readonly, strong) NSString *displayName;

/*!
 The small icon image for the ad.
 Refer AdMarvelNativeAdImage class description.
 */
@property (nonatomic, readonly, strong) AdMarvelNativeAdImage *iconImage;

/*!
 The short message or description of the ad.
 */
@property (nonatomic, readonly, strong) NSString *shortMessage;

/*!
 The full/long/detailed description of the ad.
 */
@property (nonatomic, readonly, strong) NSString *fullMessage;

/*!
 An array of various images of the ad content.
 */
@property (nonatomic, readonly, strong) NSArray *campaignImageArray;

/*!
 An object that contains info about the ad click to action.
 Refer AdMarvelNativeAdClickToAction class description.
 */
@property (nonatomic, readonly, strong) AdMarvelNativeAdClickToAction *cta;

/*!
 The marker text for the ad when embedded in app content.
 Ex. "Sponsered ad", "Ad"
 */
@property (nonatomic, readonly, strong) NSString *adSponsoredMarker;

/*!
 The ad rating object.
 Refer AdMarvelNativeAdRating class description.
 */
@property (nonatomic, readonly, strong) AdMarvelNativeAdRating *rating;

/*!
 The dictionary of AdMarvelNativeAdMetadata objects. This provides any additional info about the ad.
 Refer AdMarvelNativeAdMetadata class description.
 */
@property (nonatomic, readonly, strong) NSDictionary *metadata;

/*!
 The choice icon/text for the ad when embedded in app content.
 Ex. "ad Notice", "Ad"
 */
@property (nonatomic, readonly, strong) AdMarvelNativeAdNotice *notice;

/*!
 The video component of native video ads. Add this view to your application heirarchy for displaying native videos ad.
 */
@property (nonatomic, readonly, strong) AdMarvelNativeAdVideoView *nativeVideoView;

@end
