//
//  RFMAVPlayerProgressObserver.h
//  RFMAdSDK
//
//  Created by Rubicon Project on 2/28/17.
//  Copyright © 2017 Rubicon Project. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RFMVideoPlayerProgressObserver.h"

/**
 * This class is responsible for monitoring the current progress of an AVPlayer instance, and
 * serves as an observation proxy between the video player and the video session.
 * Conforms to the RFMVideoPlayerProgressObserver protocol.
 */
@interface RFMAVPlayerProgressObserver : NSObject <RFMVideoPlayerProgressObserver>

@property (readonly, nonatomic) NSUInteger currentProgress;

/**
 * Create and initialize an instance of RFMAVPlayerProgressObserver
 * @param player AVPlayer instance that will be observed
 * @return RFMAVPlayerProgressObserver instance
 * @see RFMVideoPlayerProgressObserver
 */
- (instancetype)initWithPlayer:(id)player;

@end
