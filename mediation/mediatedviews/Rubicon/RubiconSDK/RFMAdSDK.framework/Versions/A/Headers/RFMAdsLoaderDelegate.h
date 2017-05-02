//
//  RFMAdsLoaderDelegate.h
//  RFMAdSDK
//
//  Created by Rubicon Project on 2/28/17.
//  Copyright © 2017 Rubicon Project. All rights reserved.
//

#ifndef RFMAdsLoaderDelegate_h
#define RFMAdsLoaderDelegate_h

#import <Foundation/Foundation.h>

@class RFMAdsLoader, RFMAdSession, RFMAdSession, RFMAdRequest, RFMVideoAdSession;

/**
 * Defines protocol methods that informs the delegate
 * of the ad loading state.
 */
@protocol RFMAdsLoaderDelegate <NSObject>
@optional
/**
 * Optional method that informs the delegate when the session has been successfully loaded
 * @param session RFMAdSession instance created by the loader
 * @param loader RFMAdsLoader instance used during the initial loading
 * @see failedToLoadWithErrorString:loader:
 */
- (void)didLoadSession:(RFMAdSession*)session loader:(RFMAdsLoader*)loader;
/**
 * Optional method that informs the delegate when there was an loading error
 * @param error NSString instance that describes the loading error
 * @param loader RFMAdsLoader instance used during the initial loading
 * @see didLoadSession:loader:
 */
- (void)failedToLoadWithErrorString:(NSString*)error loader:(RFMAdsLoader*)loader;

@end

#endif /* RFMAdsLoaderDelegate_h */
