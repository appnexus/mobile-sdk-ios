//
//  OMWCustomInterstitial.h
//

#import <Foundation/Foundation.h>
#import "OMWCustomInterstitialDelegate.h"
#import "OMWCustomRewardDelegate.h"


@protocol OMWCustomInterstitial <NSObject>


/* This method will be invoked when there is a request for an interstitial ad. When this method is invoked, publisher must send ad request to concerned ad-network SDK.
 @serverParams - the parameters configured in the map UI for the ad-network.
 @targetParams - the parameters passed by application while making an ad request using AdMarvelSDK.
*/
- (void)requestInterstitialAdWithServerParams:(NSDictionary *)serverParams andTargetingParams:(NSDictionary *)targetParams;


/* This method will be invoked, when application request to display an interstitial ad. The connector class is responsible for displaying ad-network interstitial ad.
@rootViewController - The UIVIewController to present the interstitial ad as a modal view.
*/
- (void)displayInterstitial:(UIViewController *)rootViewController;


/* Use this property for reporting all events provided by ad-network SDK back to OWM SDK.
 */
@property (nonatomic, weak) id <OMWCustomInterstitialDelegate> interstitialDelegate;

@optional

/* Use this method for disabling an ad-network for an ad request. */
+ (BOOL)isAdNetworkDisabled;

@end
