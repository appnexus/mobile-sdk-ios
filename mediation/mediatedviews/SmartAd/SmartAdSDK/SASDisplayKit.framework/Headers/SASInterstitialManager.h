//
//  SASInterstitialManager.h
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 26/07/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SASBaseInterstitialManager.h"
#import "SASInterstitialManagerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@class SASAdPlacement;

/**
 Class used to load and display interstitial ads.
 */
@interface SASInterstitialManager : SASBaseInterstitialManager

/// An object implementing the SASInterstitialManagerDelegate protocol.
@property (nonatomic, weak, nullable) id<SASInterstitialManagerDelegate> delegate;

/**
 Initialize a new SASInterstitialManager instance.
 
 @param placement The placement that will be used to load interstitial ads.
 @param delegate An object implementing the SASInterstitialManagerDelegate protocol.
 
 @return An initialized instance of SASInterstitialManager.
 */
- (instancetype)initWithPlacement:(SASAdPlacement *)placement delegate:(nullable id <SASInterstitialManagerDelegate>)delegate;

/**
 Sends a message to the webview hosting the creative.
 
 The message can be retrieved in the creative by adding an MRAID event listener on the 'sasMessage' event. It will not
 be sent if the creative is not fully loaded.
 
 @param message A non empty message that will be sent to the creative.
 */
- (void)sendMessageToWebView:(NSString *)message NS_SWIFT_NAME(sendMessageToWebView(_:));

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
