/*   Copyright 2021 APPNEXUS INC
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "ANRealTimer.h"
#import "NSTimer+ANCategory.h"
#import "ANGlobal.h"
#import "ANLogging.h"


@interface ANRealTimer()

@property (nonatomic, readwrite, strong) NSTimer *viewabilityTimer;
@property (nonatomic, readwrite, strong)  NSMutableArray<id<ANRealTimerDelegate>> *timerDelegates;


@end

@implementation ANRealTimer

+ (instancetype)sharedInstance {
    static ANRealTimer *manager;
    static dispatch_once_t managerToken;
    dispatch_once(&managerToken, ^{
        manager = [[ANRealTimer alloc] init];
        manager.timerDelegates = [[NSMutableArray alloc] init];
    });
    return manager;
}

+ (void) scheduleTimer {
    [self sharedInstance];
}

+ (BOOL)addDelegate:(nonnull id<ANRealTimerDelegate>)delegate {
    return [[self sharedInstance] addDelegate:delegate];
}

+ (BOOL)removeDelegate:(nonnull id<ANRealTimerDelegate>)delegate {
    return [[self sharedInstance] removeDelegate:delegate];
}

- (void) scheduleTimer {
    if(_viewabilityTimer == nil){
    __weak ANRealTimer *weakSelf = self;
    _viewabilityTimer = [NSTimer an_scheduledTimerWithTimeInterval:kAppNexusNativeAdIABShouldBeViewableForTrackingDuration
                                                                     block:^ {
            ANRealTimer *strongSelf = weakSelf;
                                                                        
                                                                        [strongSelf notifyListenerObjects];
                                                                     }
                                                                   repeats:YES];
        
    }
}

- (BOOL)addDelegate:(nonnull id<ANRealTimerDelegate>)delegate {
    
    if(![delegate conformsToProtocol:@protocol(ANRealTimerDelegate)]){
        ANLogError(@"FAILED to add delegate, delegate does not confront to protocol");
        return NO;
    }
    if([self.timerDelegates containsObject:delegate]){
        ANLogWarn(@"Delegate already added");
        return YES;
    }
    if(self.viewabilityTimer == nil){
        [self scheduleTimer];
    }
    [self.timerDelegates addObject:delegate];
    return YES;
    
}

- (BOOL)removeDelegate:(nonnull id<ANRealTimerDelegate>)delegate {
    if(![delegate conformsToProtocol:@protocol(ANRealTimerDelegate)]){
        ANLogError(@"FAILED to remove delegate, delegate does not confront to protocol");
        return NO;
    }
    
    [self.timerDelegates removeObject:delegate];
    
    //if no delegates found then the timer can be stopped & added again if a new delegate is added
    if(self.timerDelegates.count <= 0){
        [self.viewabilityTimer invalidate];
        self.viewabilityTimer = nil;
    }
    
    return YES;
}

-(void) notifyListenerObjects {
    if(self.timerDelegates.count > 0) {
        for (id<ANRealTimerDelegate> delegate in self.timerDelegates) {
            if([delegate respondsToSelector:@selector(handle1SecTimerSentNotification)]){
                ANLogInfo(@"Notifications pushed from time\
                          ");
                
                [delegate handle1SecTimerSentNotification];
            }
        }
    }
    else {
        ANLogError(@"no delegate subscription found");
    }
}

@end
