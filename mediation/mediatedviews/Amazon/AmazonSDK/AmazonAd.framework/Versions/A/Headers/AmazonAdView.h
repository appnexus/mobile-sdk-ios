//
//  AmazonAdView.h
//  AmazonMobileAdsSDK
//
//  Copyright (c) 2012-2015 Amazon.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AmazonAdOptions.h"

@class AmazonAdError;
@class AmazonAdOptions;
@protocol AmazonAdViewDelegate;

@interface AmazonAdView : UIView

@property (nonatomic, weak) id<AmazonAdViewDelegate> delegate;

// Create an Ad view and instantiate it using one of the standard AdSize options specified in AmazonAdOptions
+ (instancetype)amazonAdViewWithAdSize:(CGSize)adSize;

// Instantiate an auto size ad via nib or storyboard
- (instancetype)initWithCoder:(NSCoder *)aDecoder;
// Instantiate an auto size ad
- (instancetype)initWithFrame:(CGRect)frame;
// Instantiate using one of the standard AdSize options specified in AmazonAdOptions.
- (instancetype)initWithAdSize:(CGSize)adSize;

// Set vertical alignment constraint for an ad in the ad view container
- (void)setVerticalAlignment:(AmazonAdVerticalAlignment)alignment;
// Set horizontal alignment constraint for an ad in the ad view container
- (void)setHorizontalAlignment:(AmazonAdHorizontalAlignment)alignment;

// Loads an Ad in this view
- (void)loadAd:(AmazonAdOptions *)options;

// Returns YES if the Ad in this view is expanded
- (BOOL)isAdExpanded;

@end

@protocol AmazonAdViewDelegate <NSObject>

@required

/*
 * The ad view relies on this method to determine which view controller will be 
 * used for presenting/dismissing modal views, such as the browser view presented 
 * when a user clicks on an ad.
 */
- (UIViewController *)viewControllerForPresentingModalView;

@optional

/*
 * These callbacks are triggered when the ad view is about to present/dismiss a
 * modal view. If your application may be disrupted by these actions, you can
 * use these notifications to handle them.
 */
- (void)adViewWillExpand:(AmazonAdView *)view;
- (void)adViewDidCollapse:(AmazonAdView *)view;


/*
 * These callbacks are related to the mraid resize function which changes the size and potentially location of this view. The frame parameter's origin specifies how the top-right corner of the view should move (e.g. x = 0 and y = -50 would represent moving the top-right corner up 50 pixels. The size represents the soon-to-be size of the ad view.
 * willHandleAdViewResize allows the app to handle resizing and moving any views containing this one. When it returns true the SDK will only change the size of the ad view and it is the responsibility of the app to make sure the location of the view is correct according to the frame parameter's origin. When it returns false, the SDK will modify the origin of the ad view which may result it going out of bounds of any parent views.
 */
- (void)adViewWillResize:(AmazonAdView *)view toFrame:(CGRect)frame;
- (BOOL)willHandleAdViewResize:(AmazonAdView *)view toFrame:(CGRect)frame;

/*
 * These callbacks notify you whether the ad view (un)successfully loaded an ad.
 */
- (void)adViewDidFailToLoad:(AmazonAdView *)view withError:(AmazonAdError *)error;
- (void)adViewDidLoad:(AmazonAdView *)view;

@end
