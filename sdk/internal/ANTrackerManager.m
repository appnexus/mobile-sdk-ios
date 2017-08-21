/*   Copyright 2014 APPNEXUS INC
 
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

#import "ANTrackerManager.h"
#import "ANReachability.h"
#import "ANTrackerInfo.h"
#import "ANGlobal.h"
#import "ANLogging.h"

#import "NSTimer+ANCategory.h"

@interface ANTrackerManager ()

@property (nonatomic, readwrite, strong) NSMutableArray *trackerArray;
@property (nonatomic, readwrite, strong) ANReachability *internetReachability;

@property (nonatomic, readonly, assign) BOOL internetIsReachable;

@property (nonatomic, readwrite, strong) NSTimer *impressionTrackerRetryTimer;

@end

@implementation ANTrackerManager

+ (instancetype)sharedManager {
    static ANTrackerManager *manager;
    static dispatch_once_t managerToken;
    dispatch_once(&managerToken, ^{
        manager = [[ANTrackerManager alloc] init];
    });
    return manager;
}

+ (void)fireImpressionTrackerURLArray:(NSArray *)arrayWithURLs {
    ANTrackerManager *manager = [[self class] sharedManager];
    [manager fireImpressionTrackerURLArray:arrayWithURLs];
}

+ (void)fireImpressionTrackerURL:(NSURL *)URL {
    ANTrackerManager *manager = [[self class] sharedManager];
    [manager fireImpressionTrackerURL:URL];
}

#pragma mark ANNativeImpressionTrackerHandlerManager implementation

- (instancetype)init {
    if (self = [super init]) {
        _internetReachability = [ANReachability reachabilityForInternetConnection];
    }
    return self;
}

- (void)fireImpressionTrackerURLArray:(NSArray *)arrayWithURLs {
    if (self.internetIsReachable) {
        ANLogDebug(@"Internet is reachable - Firing impression trackers %@", arrayWithURLs);
        [arrayWithURLs enumerateObjectsUsingBlock:^(NSURL *URL, NSUInteger idx, BOOL *stop) {
            __weak ANTrackerManager *weakSelf = self;
            [NSURLConnection sendAsynchronousRequest:ANBasicRequestWithURL(URL)
                                               queue:[NSOperationQueue mainQueue]
                                   completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                       ANTrackerManager *strongSelf = weakSelf;
                                       if (connectionError) {
                                           ANLogDebug(@"Connection error - queing impression tracker for firing later %@", URL);
                                           [strongSelf queueImpressionTrackerURLForRetry:URL];
                                       }
                                   }];
        }];
    } else {
        ANLogDebug(@"Internet is unreachable - queing impression trackers for firing later %@", arrayWithURLs);
        [arrayWithURLs enumerateObjectsUsingBlock:^(NSURL *URL, NSUInteger idx, BOOL *stop) {
            [self queueImpressionTrackerURLForRetry:URL];
        }];
    }
}

- (void)fireImpressionTrackerURL:(NSURL *)URL {
    if (URL) {
        [self fireImpressionTrackerURLArray:@[URL]];
    }
}

- (BOOL)internetIsReachable {
    ANNetworkStatus networkStatus = [self.internetReachability currentReachabilityStatus];
    BOOL connectionRequired = [self.internetReachability connectionRequired];
    if (networkStatus != ANNetworkStatusNotReachable && !connectionRequired) {
        return YES;
    }
    return NO;
}

- (void)retryImpressionTrackerFires {
    NSArray *trackerArrayCopy;
    @synchronized(self) {
        if (self.trackerArray.count > 0 && self.internetIsReachable) {
            ANLogDebug(@"Internet back online - Firing impression trackers %@", self.trackerArray);
            trackerArrayCopy = [self.trackerArray copy];
            [self.trackerArray removeAllObjects];
            [self.impressionTrackerRetryTimer invalidate];
        }
    }
    __weak ANTrackerManager *weakSelf = self;
    [trackerArrayCopy enumerateObjectsUsingBlock:^(ANTrackerInfo *info, NSUInteger idx, BOOL *stop) {
        if (!info.isExpired) {
            [NSURLConnection sendAsynchronousRequest:ANBasicRequestWithURL(info.URL)
                                               queue:[NSOperationQueue mainQueue]
                                   completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                       ANTrackerManager *strongSelf = weakSelf;
                                       if (connectionError) {
                                           ANLogDebug(@"Connection error - queing impression tracker for firing later %@", info.URL);
                                           info.numberOfTimesFired += 1;
                                           if (info.numberOfTimesFired < kANNativeImpressionTrackerManagerMaximumNumberOfRetries && !info.isExpired) {
                                               @synchronized(strongSelf) {
                                                   [strongSelf.trackerArray addObject:info];
                                                   [strongSelf scheduleRetryTimerIfNecessary];
                                               }
                                           }
                                       } else {
                                           ANLogDebug(@"Retry successful for %@", info);
                                       }
                                   }];
        }
    }];
}

- (void)queueImpressionTrackerURLForRetry:(NSURL *)URL {
    ANTrackerInfo *trackerInfo = [[ANTrackerInfo alloc] initWithURL:URL];
    @synchronized(self) {
        [self.trackerArray addObject:trackerInfo];
        [self scheduleRetryTimerIfNecessary];
    }
}

- (void)scheduleRetryTimerIfNecessary {
    if (![self.impressionTrackerRetryTimer an_isScheduled]) {
        __weak ANTrackerManager *weakSelf = self;
        self.impressionTrackerRetryTimer = [NSTimer an_scheduledTimerWithTimeInterval:kANNativeImpressionTrackerManagerRetryInterval
                                                                                block:^{
                                                                                    ANTrackerManager *strongSelf = weakSelf;
                                                                                    [strongSelf retryImpressionTrackerFires];
                                                                                }
                                                                              repeats:YES];
    }
}

- (NSArray *)trackerArray {
    if (!_trackerArray) _trackerArray = [[NSMutableArray alloc] init];
    return _trackerArray;
}

@end
