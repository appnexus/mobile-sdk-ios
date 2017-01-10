//
//  SASReward.h
//  SmartAdServer
//
//  Created by Thomas Geley on 10/11/2016.
//
//

#import <Foundation/Foundation.h>

/** 
 SASReward is a class that represents a reward object collected after an ad event.
 */

@interface SASReward : NSObject 

/** The currency of the reward (e.g coins, lives, points...).
 
 Let you know which currency should be rewarded. 
 Useful to know what kind of behavior to trigger in your code if you use different currencies.
 */
@property (nonatomic, readonly) NSString *currency;


/** The amount of currency to be rewarded.
 
 Let you know the amount to reward for a given currency.
 */
@property (nonatomic, readonly) NSNumber *amount;

@end
