//
//  AdMarvelReward.h
//

#import <Foundation/Foundation.h>

/*!
 The AdMarvelReward class.
 This object represents all data related to reward for the user based on the display of a reward ad.
 */
@interface AdMarvelReward : NSObject

/*!
 Indicates whether the reward ad generated a succesful reward or not.  If it is a succes then the other items below can be used.
 */
@property (nonatomic, assign, readonly) BOOL success;

/*!
 The name of the reward configured for the reward site.
 */
@property (nonatomic, strong, readonly) NSString *rewardName;

/*!
 The value of the reward configured for the reward site.
 */
@property (nonatomic, strong, readonly) NSString *rewardValue;

/*!
 Dictionary of optional metadata that may be generated during reward validation.
 */
@property (nonatomic, strong, readonly) NSDictionary *metadata;

/*!
 The partner id of the original reward ad request.
 */
@property (nonatomic, strong, readonly) NSString *partnerId;

/*!
 The site id of the original reward ad request.
 */
@property (nonatomic, strong, readonly) NSString *siteId;

@end
