//
//  RFMVideoPlayerProgressObserver.h
//  RFMAdSDK
//
//  Created by Rubicon Project on 3/1/17.
//  Copyright © 2017 Rubicon Project. All rights reserved.
//

#ifndef RFMVideoPlayerObserver_h
#define RFMVideoPlayerObserver_h

/**
 * Protocol that defines methods to assist with the observation of video player progress.
 */
@protocol RFMVideoPlayerProgressObserver <NSObject>

@property (readonly, nonatomic) NSUInteger currentProgress;

/**
 * Creates and initializes an instance that conforms to the RFMVideoPlayerProgressObserver protocol.
 * @param player instance of the video player
 * @return opaque instance of the observer
 */
- (instancetype)initWithPlayer:(id)player;

/**
 * Removes or stops video player observation.
 * @see startObservationWithSession:
 */
- (void)stopObservation;

/**
 * Adds or begins observation of the video player.
 * @param session Instance of the video ad session
 * @see stopObservation
 */
- (void)startObservationWithSession:(id)session;

@end

#endif /* RFMVideoPlayerObserver_h */
