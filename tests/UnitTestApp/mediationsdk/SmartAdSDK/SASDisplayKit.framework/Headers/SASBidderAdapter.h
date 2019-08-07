//
//  SASBidderAdapter.h
//  SmartAdServer
//
//  Created by Thomas Geley on 12/02/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SASBidderAdapterProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/**
 This class implements the SASBidderAdapterProtocol.
 
 You can use it as the base class to create your own in-app bidding adapter.
 Make sure your own class implements the SASBidderAdapterProtocol fully.
 */
@interface SASBidderAdapter : NSObject <SASBidderAdapterProtocol>

/**
 Initializes a new SASBidderAdapter instance.
 
 @param sspName The name of the SSP that won the in-app bidding competition.
 @param winningCreativeID The unique identifier of the ad that won the in-app bidding competition.
 @param price The CPM value of the ad that won the in-app bidding competition.
 @param currency The CPM currency of the ad that won the in-app bidding competition.
 @param dealID The dealID if the bid is a deal.
 
 @return An initialized instance of SASBidderAdapter.
 */
- (instancetype)initWithWinningSSPName:(NSString *)sspName winningCreativeID:(NSString *)winningCreativeID price:(float)price currency:(NSString *)currency dealID:(nullable NSString *)dealID;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
