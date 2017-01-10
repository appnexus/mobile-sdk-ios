//
//  OMWCustomBanner.h
//

#import <Foundation/Foundation.h>
#import "OMWCustomBannerDelegate.h"


@protocol OMWCustomBanner <NSObject>


/* This method will be invoked when there is a request for a banner ad. When this method is invoked, you must send ad request to concerned ad-network SDK.
@adSize - the size of the ad.
@serverParams - the parameters configured in the map UI for the ad-network.
@targetParams - the parameters passed by application while making an ad request using AdMarvelSDK.
*/
- (void)requestBannerAd:(CGSize)adSize withServerParams:(NSDictionary *)serverParams andTargetingParams:(NSDictionary *)targetParams;


/* Use this property for reporting all events provided by ad-network SDK back to AdMarvelSDK. */
@property (nonatomic, weak) id <OMWCustomBannerDelegate> bannerDelegate;

@optional

/* Use this method for disabling an ad-network for an ad request. */
+(BOOL)isAdNetworkDisabled;

@end
