//
//  SCSTimerDelegate.h
//  SCSCoreKit
//
//  Created by Loïc GIRON DIT METAZ on 20/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

@class SCSTimer;

/**
 SCSTimer delegate.
 */
@protocol SCSTimerDelegate <NSObject>

/**
 Method called when the timer is fired.
 
 This method can be called once or multiple times depending of the timer's interval setting.
 
 @param timer The timer that has been fired.
 */
- (void)timerFired:(SCSTimer *)timer;

@end

NS_ASSUME_NONNULL_END
