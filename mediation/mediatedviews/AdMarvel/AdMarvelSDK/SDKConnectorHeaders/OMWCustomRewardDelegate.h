//
//  OMWCustomRewardDelegate.h
//

#import <Foundation/Foundation.h>

@protocol OMWCustomRewardDelegate <NSObject>

/* Use this method to report reward events to AdMarvelSDK
@success - tells AdMarvelSDK whether reward event was success or failure.
@currencyName - name of the currency received from ad-network after reward success.
@amount - currency amount received from ad-network after reward success.
 */
-(void) didReceiveReward:(BOOL)success currencyName:(NSString*)currencyName currencyAmount:(int)amount;

@end
