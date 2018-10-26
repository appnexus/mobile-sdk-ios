//
//  SASBidderAdapter.h
//  SmartAdServer
//
//  Created by Thomas Geley on 12/02/2018.
//

#import <Foundation/Foundation.h>
#import "SASBidderAdapterProtocol.h"

/**
 This class implements the SASBidderAdapterProtocol.
 You can use it has the base class to create your own in-app bidding adapter.
 Make sure your own class implements the SASBidderAdapterProtocol fully.
 */
@interface SASBidderAdapter : NSObject <SASBidderAdapterProtocol>

/**
 Instantiate a SASBidderAdapter object.
 
 @param sspName the name of the ssp that won the in-app bidding competition.
 @param winningCreativeID the unique identifier of the ad that won the in-app bidding competition.
 @param price the CPM value of the ad that won the in-app bidding competition.
 @param currency the CPM currency of the ad that won the in-app bidding competition.
 @param dealID the dealID if the bid is a deal.
 
 return an initialized instance of the SASBidderAdapter.
 */
- (instancetype)initWithWinningSSPName:(NSString *)sspName winningCreativeID:(NSString *)winningCreativeID price:(float)price currency:(NSString *)currency dealID:(NSString *)dealID;

@end
