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
#import <AVFoundation/AVFoundation.h>

@implementation ANAudioVolumeChangeListener

#pragma mark - Init

- (id)initWithDelegate:(id<ANAudioVolumeChangeListenerDelegate>)delegate {
    self = [super init];
    if ( self ) {
        self.delegate = delegate;
        [self subscribeToAudioChangeListening:YES];
        [self registerObserverAndNotification];
    }
    
    return self;
}


#pragma mark - Subscribe/Unsubscribe

- (void)subscribeToAudioChangeListening:(BOOL) value {
    AVAudioSession* audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:value error:nil];
}

- (void)registerObserverAndNotification{
    //To observe when volume change event occurs
    [[AVAudioSession sharedInstance] addObserver:self
                   forKeyPath:@"outputVolume"
                      options:0
                      context:nil];
    //To notify if interruption comes for active audio session
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(interruption:)
                                                 name:AVAudioSessionInterruptionNotification
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
            [self.delegate didUpdateAudioLevel:nil];
        }
            break;
            
        case AVAudioSessionInterruptionTypeEnded:
        {
            // Interruption end, reactivate the audio session
            [self subscribeToAudioChangeListening:YES];
            [self.delegate didUpdateAudioLevel:[self getAudioVolumePercentage]];
        }
            break;
    }
}

#pragma mark - Dealloc

- (void)dealloc {
    [self subscribeToAudioChangeListening:NO];
    [[AVAudioSession sharedInstance] removeObserver:self forKeyPath:@"outputVolume"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionInterruptionNotification object:nil];
}

@end
