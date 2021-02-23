//
//  ANRealTimer.h
//  AppNexusSDK
//
//  Created by Punnaghai Puviarasu on 2/17/21.
//  Copyright © 2021 AppNexus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANLogging.h"

@protocol  ANRealTimerDelegate<NSObject>

- (void)handle1SecTimerSentNotification;

@end

@interface ANRealTimer : NSObject

@property (nonatomic, readwrite, weak)  id<ANRealTimerDelegate> timerDelegate;

+ (instancetype) sharedInstance;

+ (void) scheduleTimer;

@end



