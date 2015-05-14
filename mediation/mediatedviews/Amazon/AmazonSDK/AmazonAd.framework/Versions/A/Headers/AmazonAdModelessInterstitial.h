//
//  AmazonAdModelessInterstitial.h
//  AmazonMobileAdsSDK
//
//  Copyright (c) 2015 Amazon.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AmazonAdError;
@class AmazonAdOptions;
@protocol AmazonAdModelessInterstitialDelegate;

@interface AmazonAdModelessInterstitial : NSObject

// Delegate to receive modeless interstitial callbacks
@property (nonatomic, weak) id<AmazonAdModelessInterstitialDelegate> delegate;

// True if this modeless interstitial instance is ready to present in the container view
@property (readonly) BOOL isReady;

// Create and instantiate a modeless interstitial
+ (instancetype)modelessInterstitialWithContainerView:(UIView *)view;

// Load a modeless interstitial
- (void)load:(AmazonAdOptions *)options;

// True if this modeless interstitial instance is sucessfully presented on the screen
// Call this method when the container view becomes visible on screen
- (BOOL)onPresented;

// Call this method when the container view becomes invisible
- (void)onHidden;

@end

@protocol AmazonAdModelessInterstitialDelegate <NSObject>

@required

/*
 * The modeless interstitial relies on this method to determine which view controller will be
 * used for presenting/dismissing modal views, such as the browser view presented
 * when a user clicks on an ad.
 */
- (UIViewController *)viewControllerForPresentingModalView;

@optional

// Sent when load has succeeded and the modeless interstitial isReady for display at the appropriate moment.
- (void)modelessInterstitialDidLoad:(AmazonAdModelessInterstitial *)modelessInterstitial;

// Sent when load has failed, typically because of network failure, an application configuration error or lack of interstitial inventory
- (void)modelessInterstitialDidFailToLoad:(AmazonAdModelessInterstitial *)modelessInterstitial withError:(AmazonAdError *)error;

// Sent when trying to present an expired modeless interstitial
- (void)modelessInterstitialDidExpire:(AmazonAdModelessInterstitial *)interstitial;

@end
