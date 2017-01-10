//
//  OMWCustomNativeAd.h
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


/*!
 The OMWCustomNativeAdImage class.
 This object represents a native ad image.
 */
@interface OMWCustomNativeAdImage : NSObject

/*!
 Image object to display. Use imageURL first if its nil then use image.
 */
@property (nonatomic, strong) UIImage *image;

/*!
 URL of the image.
 */
@property (nonatomic, strong) NSURL *imageURL;

/*!
 Width of the image.
 */
@property (nonatomic, assign) NSInteger width;

/*!
 Height of the image.
 */
@property (nonatomic, assign) NSInteger height;


@end


/*!
 The OMWCustomNativeAdClickToAction class.
 This object contains info about the ad click to action.
 */

@interface OMWCustomNativeAdClickToAction : NSObject

/*!
 The title of the action to be performed.
 Ex. "Install", "Download", "Click"
 */
@property (nonatomic, strong) NSString *title;

/*!
 The image to be shown on the click to action widget (Ex. Button)
 You can use this as an alternate to title.
 */
@property (nonatomic, strong) OMWCustomNativeAdImage *image;

/*!
  The url to be shown on the click of click to action widget.
 */
@property (nonatomic, strong) NSURL *clickURL;

@end


/*!
 The OMWCustomNativeAdRating class.
 This object represents the rating of the app being advertised (often a 1-5 star rating).
 */

@interface OMWCustomNativeAdRating : NSObject

/*!
 The base/maximum value of the rating.
 Ex. "5"
 */
@property (nonatomic, strong) NSString *baseValue;

/*!
 The value of the rating.
 Ex. "1", "2", "2.5"
 */
@property (nonatomic, strong) NSString *value;

/*!
 The complete image for rating. This is a single image representing the whole rating.
 */
@property (nonatomic, strong) OMWCustomNativeAdImage *completeRatingValueImage;

/*!
 The image for a single unit of rating.
 Ex. A star image filled fullly with some color.
 */
@property (nonatomic, strong) OMWCustomNativeAdImage *fullRatingValueImage;

/*!
 The image for a half unit of rating.
 Ex. A star image half filled fullly with some color and half blanked.
 */
@property (nonatomic, strong) OMWCustomNativeAdImage *halfRatingValueImage;

/*!
 The image for an empty unit of rating.
 Ex. A blank star image.
 */
@property (nonatomic, strong) OMWCustomNativeAdImage *blankRatingValueImage;


@end


/*!
 The OMWCustomNativeAdNotice class.
 This class provides information about ad notice.
 */
@interface OMWCustomNativeAdNotice : NSObject

/*!
 The image for the notice.
 */
@property (nonatomic, strong) OMWCustomNativeAdImage *icon;

/*!
 The title to be displayed on notice
 */
@property (nonatomic, strong) NSString *title;

/*!
 The URL to be shown when clicked on notice.
 */
@property (nonatomic, strong) NSURL *url;

/*!
 The view for the notice
 */
@property (nonatomic, strong) UIView *view;


@end


/*!
 The OMWCustomNativeAd class.
*/

@interface OMWCustomNativeAd : NSObject


/*!
 The display name or title of the ad.
 Ex. for install type ads "Name of the app"
 */
@property (nonatomic, strong) NSString *displayName;

/*!
 The small icon image for the ad.
 Refer AdMarvelNativeAdImage class description.
 */
@property (nonatomic, strong) OMWCustomNativeAdImage *iconImage;

/*!
 The short message or description of the ad.
 */
@property (nonatomic, strong) NSString *shortMessage;

/*!
 The full/long/detailed description of the ad.
 */
@property (nonatomic, strong) NSString *fullMessage;

/*!
 An array of various images of the ad content.
 */
@property (nonatomic, strong) NSArray *campaignImageArray;

/*!
 An object that contains info about the ad click to action.
 Refer OMWCustomNativeAdClickToAction class description.
 */
@property (nonatomic, strong) OMWCustomNativeAdClickToAction *cta;

/*!
 The marker text for the ad when embedded in app content.
 Ex. "Sponsered ad", "Ad"
 */
@property (nonatomic, strong) NSString *adSponsoredMarker;

/*!
 The ad rating object.
 Refer OMWCustomNativeAdRating class description.
 */
@property (nonatomic, strong) OMWCustomNativeAdRating *rating;

/*!
 This provides any additional info about the ad.
 */
@property (nonatomic, strong) NSDictionary *metadata;

/*!
 The choice icon/text for the ad when embedded in app content.
 Ex. "ad Notice", "Ad"
 */
@property (nonatomic, strong) OMWCustomNativeAdNotice *notice;

-(id) initWithAdSponsoredMarker:(NSString*) adSponsoredMarker displayName:(NSString*) displayName shortMessage:(NSString*) shortMessage fullMessage:(NSString*) fullMessage iconImage:(OMWCustomNativeAdImage*) iconImage campaignImages:(NSArray*) campaignImageArray cta:(OMWCustomNativeAdClickToAction*) cta rating:(OMWCustomNativeAdRating*)rating metadata:(NSDictionary*) metadata andAdNotice:(OMWCustomNativeAdNotice*)notice;


@end

