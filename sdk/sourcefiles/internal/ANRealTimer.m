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

+ (instancetype)sharedManager {
    static ANRealTimer *manager;
    static dispatch_once_t managerToken;
    dispatch_once(&managerToken, ^{
        manager = [[ANRealTimer alloc] init];
        [manager scheduleTimer];
    });
    return manager;
}

- (void) scheduleTimer {
    if(_viewabilityTimer == nil){
    __weak ANRealTimer *weakSelf = self;
    _viewabilityTimer = [NSTimer an_scheduledTimerWithTimeInterval:kAppNexusNativeAdCheckViewabilityForTrackingFrequency
                                                                     block:^ {
            ANRealTimer *strongSelf = weakSelf;
                                                                        
                                                                        [strongSelf notifyListenerObjects];
                                                                     }
                                                                   repeats:YES];
        
    }
}

+ (void) addListenerObject: (id) adObject {
    [[self sharedManager] addListenerObject:nil];
}

+(void) removeListenerObject: (id) adObject {
    
}

- (void) addListenerObject: (id) adObject {
    
}

-(void) notifyListenerObjects {
    NSLog(@"Notifications pushed");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kHandleTimerSentNotification"
                                                        object:nil
                                                      userInfo:nil];
    //ANPostNotifications(@"kHandleTimerSentNotification", nil, nil);
    
}



@end
