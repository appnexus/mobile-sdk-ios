//
//  IMNative.h
//  APIs
//  Copyright (c) 2015 InMobi. All rights reserved.
//
/**
 * Class to integrate native ads in your application
 * Use this class to integrate native ads in your application. For native ads, your application is given the raw assets for the ad. Your application can render these in a manner that is native to the look and feel of your application to drive better user engagement with the ad. If you need to customize aspects of ad impression and click-through reporting, your application can use the IMCustomNative class.
 */
#import <Foundation/Foundation.h>
#include "IMCommonConstants.h"
#import "IMNativeDelegate.h"

@interface IMNative : NSObject
/**
 * The primary view of the native ad. This view is rendered by InMobi and should be used by the publisher to display the ad. Impressions will be computed on this view.
 * @param width The width of the primary view. Typically this should be the screen width.
 */
-(UIView*)primaryViewOfWidth:(CGFloat)width;
/**
 * The content of the native ad.
 */
@property (nonatomic, strong, readonly) NSString* customAdContent;
/**
 * The title of the native ad.
 */
@property (nonatomic, strong, readonly) NSString* adTitle;
/**
 * The description of the native ad.
 */
@property (nonatomic, strong, readonly) NSString* adDescription;
/**
 * The icon url of the ad.
 */
@property (nonatomic, strong, readonly) UIImage* adIcon;
/**
 * The text to be specified for the cta. Typically this should be the text of the button.
 */
@property (nonatomic, strong, readonly) NSString* adCtaText;
/**
 * A custom rating field for the native ad.
 */
@property (nonatomic, strong, readonly) NSString* adRating;
/**
 * The landing page url of the Native ad.
 */
@property (nonatomic, strong, readonly) NSURL* adLandingPageUrl;
/**
 * Indicates if the ad is an app download ad.
 */
@property (nonatomic, readonly) BOOL isAppDownload;
/**
 * The delegate to receive callbacks
 */
@property (nonatomic, weak) id<IMNativeDelegate> delegate;
/**
 * A free form set of keywords, separated by ',' to be sent with the ad request.
 * E.g: "sports,cars,bikes"
 */
@property (nonatomic, strong) NSString* keywords;
/**
 * Any additional information to be passed to InMobi.
 */
@property (nonatomic, strong) NSDictionary* extras;
/**
 * A unique identifier for the creative.
 */
@property (nonatomic, strong, readonly) NSString* creativeId;
/**
 * Initialize a Native ad with the given PlacementId
 * @param placementId The placementId for loading the native ad
 */
-(instancetype)initWithPlacementId:(long long)placementId;
/**
 * Initialize a Native ad with the given PlacementId
 * @param placementId The placementId for loading the native ad
 * @param delegate The delegate to receive callbacks from IMNative
 */
-(instancetype)initWithPlacementId:(long long)placementId delegate:(id<IMNativeDelegate>)delegate;
/**
 * Loads a Native ad
 */
-(void)load;
/**
 * Indicates if the native ad is ready to be displayed.
 */
-(BOOL)isReady;
/**
 * Reports the click action to the native ad and open the landing page.
 */
-(void)reportAdClickAndOpenLandingPage;
/**
 * Recycle the view that was presented by the native ad
 */
-(void)recyclePrimaryView;
/**
 * Contains additional information of ad.
 */
- (NSDictionary *)getAdMetaInfo;

@end
