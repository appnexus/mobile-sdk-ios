//
//  SASBidderAdapter.h
//  SmartAdServer
//
//  Created by Thomas Geley on 07/02/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Bidder adapter rendering type, indicates which rendering mode should be triggered if
/// the winning auction comes from the in-app bidding after Holistic+ competition.
typedef NS_ENUM(NSInteger, SASBidderAdapterCreativeRenderingType) {
    
    /// Smart Display SDK is responsible for rendering the third party winning creative.
    SASBidderAdapterCreativeRenderingTypePrimarySDK            = 0,
    
    /// Third party SDK is responsible for rendering the winning creative.
    SASBidderAdapterCreativeRenderingType3rdPartySDK           = 1,
    
};

/**
 A protocol to be implemented by bidder adapter classes to beneficiate of inapp in-app bidding and Holistic+ capabilities.
 */
@protocol SASBidderAdapterProtocol <NSObject>

#pragma mark - Adapter informations

/// The creative rendering type for the adapter.
@property (nonatomic, assign) SASBidderAdapterCreativeRenderingType creativeRenderingType;

/// The name of the adapter.
@property (nonatomic, strong) NSString *adapterName;

#pragma mark - Winning creative informations

/// The name of the winning SSP after bidder competition.
@property (nonatomic, strong) NSString *winningSSPName;

/// The winning creative ID.
@property (nonatomic, strong) NSString *winningCreativeID;

/// The CPM value of the winner ad.
@property (nonatomic, assign) float price;

/// The CPM currency of the winner ad.
@property (nonatomic, strong) NSString *currency;

/// The Smart DealID if any available, nil otherwise.
@property (nonatomic, strong, nullable) NSString *dealID;

#pragma mark - Primary SDK Display

/**
 Implements this method with the HTML markup to be displayed by the primary SDK when the winning creative
 is the one returned by the bidder.
 
 This markup is available in the documentation of each in-app bidding partner and often depends on several
 parameters, including the creative size.
 */
- (NSString *)bidderWinningAdMarkup;

/**
 This method is called when the bidder's winning ad is displayed, in case the primary SDK is responsible for creative rendering.
 
 You may perform actions when receiving this event, like counting impressions on your side, or trigger a new in-app bidding call, etc…
 */
- (void)primarySDKDisplayedBidderAd;

/**
 This method is called when the bidder's winning ad is clicked, in case the primary SDK is responsible for creative rendering.
 
 You may perform action when receiving this event, like counting clicks on your side, etc…
 */
- (void)primarySDKClickedBidderAd;


#pragma mark - Third party SDK Display

/**
 This method is called when the primary SDK did not return an ad with a better CPM than the bidder ad.
 
 If rendering the ad is the ad server SDK responsability, there is nothing to implement here.
 
 If rendering the ad is a third party SDK responsability, you should cascade the information, with all necessary
 parameters so that the winning ad is properly displayed.
 */
- (void)primarySDKLostBidCompetition;

@end

NS_ASSUME_NONNULL_END
