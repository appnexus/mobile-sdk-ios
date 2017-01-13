//
//  SASNativeAdDelegate.h
//  SmartAdServer
//
//  Created by Julien Gomez on 12/10/2015.
//
//

#import <UIKit/UIKit.h>


/**
 
 The delegate of a SASNativeAd object must adopt the SASNativeAdDelegate protocol.
 
 Many methods of SASNativeAdDelegate return the native ad sent by the message.
 The protocol methods allow the delegate to be aware of the ad-related events.
 You can use it to handle your app's or the native ad's behavior.
 
 */

@class SASNativeAd;

@protocol SASNativeAdDelegate <NSObject>

@optional


/** Asks the delegate whether to execute the ad action.
 
 Implement this method if you want to process some URLs yourself.
 
 @param nativeAd The instance of SASAdNativeAd responsible for the click.
 @param URL The URL that will be called.
 @return Whether the Smart AdServer SDK should handle the URL.
 @warning Returning NO means that the URL won't be processed by the SDK.
 @warning Please note that a click will be counted, even if you return NO (you are supposed to handle the URL in this case).
 
 */

- (BOOL)nativeAd:(nonnull SASNativeAd *)nativeAd shouldHandleClickURL:(nonnull NSURL *)URL;


/** Notifies the delegate that a modal view will appear to display the ad's redirect URL web page if appropriate.
 This won't be called in case of URLs which should not be displayed in a browser like YouTube, iTunes,...
 In this case, it will call adView:shouldHandleURL:.
 
 @param nativeAd The instance of SASAdNativeAd displaying the modal view.
 
 */

- (void)nativeAdWillPresentModalView:(nonnull SASNativeAd *)nativeAd;


/** Notifies the delegate that the modal view will be dismissed.
 
 @param nativeAd The instance of SASAdNativeAd closing the modal view.
 
 */

- (void)nativeAdWillDismissModalView:(nonnull SASNativeAd *)nativeAd;

@end