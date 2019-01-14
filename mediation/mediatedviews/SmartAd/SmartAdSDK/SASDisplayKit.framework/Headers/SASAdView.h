//
//  SASAdView.h
//  SmartAdServer
//
//  Created by Clémence Laurent on 20/07/12.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "SASAdPlacement.h"

#define kSASCloseLinearMessage                  @"closeLinear"

NS_ASSUME_NONNULL_BEGIN

@class SASRequestManager, SASLoaderView, SASMRAIDBridge, SASAdViewController;
@protocol SASBidderAdapterProtocol;

/**
 The SASAdView class provides a view that automatically loads and displays a creative.
 
 @warning This class should never be instantiated and used directly, use the SASBannerView class instead.
 
 @note Starting to SDK 7.0.0, there isn't any public SASInterstitialView anymore. Use a SASInterstitialManager or a
 SASRewardedVideoManager to load and display an interstitial ad and the underlying interstitial view will be
 instantiated and handled for you automatically.
 */
@interface SASAdView : UIView

#pragma mark - Ad view properties

/// The modal parent view controller is used to present the modal view controller following the ad's click.
///
/// @note You should always set a valid modal parent view controller, otherwise most post-click interactions
/// will not be able to work properly (post-click modal, StoreKit, …).
@property (nonatomic, weak, nullable) UIViewController *modalParentViewController;

/// YES if the ad is displayed using a web view for the rendering, NO if the ad is using native components.
@property (assign, readonly) BOOL webViewRendering;

#pragma mark - Loading ad data

/**
 Fetches an ad from Smart.
 
 Call this method after initializing your SASAdView object to load the appropriate SASAd object from the server.
 
 @param placement The ad placement that should be used for the call.
 */
- (void)loadWithPlacement:(SASAdPlacement *)placement;

/**
 Fetches an ad from Smart and create in-app bidding competition.
 
 Call this method after initializing your SASAdView object to load the appropriate SASAd object from the server.
 
 @param placement The ad placement that should be used for the call.
 @param bidderAdapter The bidder adapter created from the result of the in-app bidding competition.
 */
- (void)loadWithPlacement:(SASAdPlacement *)placement bidderAdapter:(nullable id <SASBidderAdapterProtocol>)bidderAdapter;

/**
 Loads a new ad using the last placement provided to the loadWithPlacement: method.
 */
- (void)refresh;

#pragma mark - Communication with the creative

/**
 Sends a message to the web view hosting the creative (if any).
 
 The message can be retrieved in the creative by adding an MRAID event listener on the 'sasMessage' event. It will not be sent if the creative is not
 fully loaded.
 
 @param message A non empty message that will be sent to the creative.
 */
- (void)sendMessageToWebView:(NSString *)message NS_SWIFT_NAME(sendMessageToWebView(_:));

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
