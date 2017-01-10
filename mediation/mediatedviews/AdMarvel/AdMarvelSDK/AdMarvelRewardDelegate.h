//
//  AdMarvelRewardDelegate.h
//


#import "AdMarvelReward.h"

@protocol AdMarvelRewardDelegate <NSObject>

@required

// Fired when an reward event has been triggered.
// Check the success flag of the AdMarvelRewardObject to see if the event was a success or failure.
// If the reward is a success then the various other parameters of the reward can be used for processing and notifying the user.
-(void) didReceiveReward:(AdMarvelReward*) adMarvelReward;

@optional

@end
