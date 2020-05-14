/*   Copyright 2020 APPNEXUS INC
 
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


#import "ANAudioVolumeChangeListener.h"
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ANAudioVolumeChangeListener ()

@property (nonatomic, readwrite, assign)  BOOL isAudioSessionActive;

@end

@implementation ANAudioVolumeChangeListener

#pragma mark - Init

- (id)initWithDelegate:(id<ANAudioVolumeChangeListenerDelegate>)delegate {
    self = [super init];
    if ( self ) {
        self.delegate = delegate;
        self.isAudioSessionActive = NO;
        [self subscribeToAudioChangeListening];
        [self registerObserverAndNotification];
    }
    
    return self;
}


#pragma mark - Subscribe/Unsubscribe

- (void)subscribeToAudioChangeListening
{
    NSError *error;
    AVAudioSession *sessionInstance = [AVAudioSession sharedInstance];
    [sessionInstance setActive:YES error:&error];
    if (error)
    {
        self.isAudioSessionActive = NO;
    }
    else
    {
        self.isAudioSessionActive = YES;
    }
}

- (void)registerObserverAndNotification{
    //To observe when volume change event occurs
    [[AVAudioSession sharedInstance] addObserver:self
                   forKeyPath:@"outputVolume"
                      options:0
                      context:nil];
    //To notify if interruption comes for active audio session due to an incoming call, alarm clock, etc
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(interruption:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:nil];
    //InterruptionTypeEnded sometimes is not called, so this is handled in handleApplicationBecameActive.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(handleApplicationBecameActive:)
                                                name:UIApplicationDidBecomeActiveNotification
                                              object:nil];
}


#pragma mark - KVO

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqual:@"outputVolume"]) {
        [self.delegate didUpdateAudioLevel:[self getAudioVolumePercentage]];
    }
}


#pragma mark - Responding to Volume level change

-(NSNumber *) getAudioVolumePercentage {
    if (!self.isAudioSessionActive) {
        return nil;
    }
    return @(100.0 * [AVAudioSession sharedInstance].outputVolume);
}


#pragma mark - Interruption Notification

- (void)interruption:(NSNotification*)notification {
    // get the user info dictionary
    NSDictionary *interruptionDict = notification.userInfo;
    // get the AVAudioSessionInterruptionTypeKey enum from the dictionary
    NSInteger interruptionType = [[interruptionDict valueForKey:AVAudioSessionInterruptionTypeKey] integerValue];
    // decide what to do based on interruption type here...
    switch (interruptionType) {
        case AVAudioSessionInterruptionTypeBegan:
        {
            // Interruption began,system deactivates audio session.In that case audio focus is not active so pass nil to AudioVolumeChange event
            self.isAudioSessionActive = NO;
            [self.delegate didUpdateAudioLevel:nil];
        }
            break;
            
        case AVAudioSessionInterruptionTypeEnded:
        {
            // Interruption end, reactivate the audio session
            [self subscribeToAudioChangeListening];
            [self.delegate didUpdateAudioLevel:[self getAudioVolumePercentage]];
        }
            break;
    }
}

- (void)handleApplicationBecameActive:(NSNotification *)notification{
    if (!self.isAudioSessionActive) {
        [self subscribeToAudioChangeListening];
    }
}


#pragma mark - Dealloc

- (void)dealloc {
    [[AVAudioSession sharedInstance] removeObserver:self forKeyPath:@"outputVolume"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionInterruptionNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

@end
