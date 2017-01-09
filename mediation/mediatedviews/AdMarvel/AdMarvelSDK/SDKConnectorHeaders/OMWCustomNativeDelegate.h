//
//  OMWCustomNativeDelegate.h
//

#import <Foundation/Foundation.h>
#import "OMWCustomNativeAd.h"

@protocol OMWCustomNative;

@protocol OMWCustomNativeDelegate <NSObject>


// Call this method after recieving native ad.
// Convert native ad object to OMWCustomNativeAd before calling
- (void)didReceiveNativeAd:(OMWCustomNativeAd*)nativeAd;

// call this method to notify failed native ad request
- (void)didFailNativeAdWithError:(NSError *)error;

// Call this method whenever app goes background or teminated
- (void)nativeAdWillLeaveApplication;

// Call this method when fullscreen webview is activated
- (void)nativeAdDidPresentModel;

// Call this method when full screen webview is closed
- (void)nativeAdDidDismissModel;


@end
