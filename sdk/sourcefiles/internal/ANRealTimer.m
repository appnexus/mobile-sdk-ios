//
//  ANRealTimer.m
//  AppNexusSDK
//
//  Created by Punnaghai Puviarasu on 2/17/21.
//  Copyright © 2021 AppNexus. All rights reserved.
//

#import "ANRealTimer.h"
#import "NSTimer+ANCategory.h"
#import "ANGlobal.h"

@interface ANRealTimer()

@property (nonatomic, readwrite, strong) NSTimer *viewabilityTimer;

@end

@implementation ANRealTimer

+ (instancetype)sharedInstance {
    static ANRealTimer *manager;
    static dispatch_once_t managerToken;
    dispatch_once(&managerToken, ^{
        manager = [[ANRealTimer alloc] init];
    });
    return manager;
}

+ (void) scheduleTimer {
    [[self sharedInstance] scheduleTimer];
}

- (void) scheduleTimer {
    if(_viewabilityTimer == nil){
    __weak ANRealTimer *weakSelf = self;
    _viewabilityTimer = [NSTimer an_scheduledTimerWithTimeInterval:kAppNexusCheckViewableFrequency
                                                                     block:^ {
            ANRealTimer *strongSelf = weakSelf;
                                                                        
                                                                        [strongSelf notifyListenerObjects];
                                                                     }
                                                                   repeats:YES];
        
    }
}



-(void) notifyListenerObjects {
    if([self.timerDelegate respondsToSelector:@selector(handle1SecTimerSentNotification)]){
        ANLogInfo(@"Notifications pushed from time\
                  ");
        
        [self.timerDelegate handle1SecTimerSentNotification];
    }else {
        ANLogError(@"no delegate subscription found");
    }
    
}

@end
