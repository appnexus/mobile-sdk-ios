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

@property (nonatomic, readwrite, strong) NSTimer *trackerRetryTimer;

@end

@implementation ANTrackerManager

#pragma mark - Lifecycle.

+ (instancetype)sharedManager {
    static ANTrackerManager *manager;
    static dispatch_once_t managerToken;
    dispatch_once(&managerToken, ^{
        manager = [[ANTrackerManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        _internetReachability = [ANReachability reachabilityForInternetConnection];
    }
    return self;
}



#pragma mark - Getters and Setters.

- (NSArray *)trackerArray
{
    if (!_trackerArray)  { _trackerArray = [[NSMutableArray alloc] init]; }
    return _trackerArray;
}



#pragma mark - Public methods.

+ (void)fireTrackerURLArray: (NSArray<NSString *> *)arrayWithURLs
{
    [[self sharedManager] fireTrackerURLArray:arrayWithURLs];
}

+ (void)fireTrackerURL: (NSString *)URL
{
    [[self sharedManager] fireTrackerURL:URL];
}


#pragma mark - Private methods.

- (void)fireTrackerURLArray: (NSArray<NSString *> *)arrayWithURLs
{
    if (!arrayWithURLs || ([arrayWithURLs count] <= 0))  { return; }

    //
    if (!self.internetIsReachable)
    {
        ANLogDebug(@"Internet IS UNREACHABLE - queing trackers for firing later: %@", arrayWithURLs);

        [arrayWithURLs enumerateObjectsUsingBlock:^(NSString *URL, NSUInteger idx, BOOL *stop) {
            [self queueTrackerURLForRetry:URL];
        }];

        return;
    }


    //
    ANLogDebug(@"Internet is reachable - FIRING TRACKERS %@", arrayWithURLs);

    [arrayWithURLs enumerateObjectsUsingBlock:^(NSString *URL, NSUInteger idx, BOOL *stop)
    {
        __weak ANTrackerManager  *weakSelf  = self;

        [[[NSURLSession sharedSession] dataTaskWithRequest: ANBasicRequestWithURL([NSURL URLWithString:URL])
                                         completionHandler: ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
                                            {
                                                if (error) {
                                                    ANLogDebug(@"Internet REACHABILITY ERROR - queing tracker for firing later: %@", URL);

                                                    ANTrackerManager  *strongSelf  = weakSelf;
                                                    if (!strongSelf) {
                                                        ANLogError(@"FAILED TO ACQUIRE strongSelf.");
                                                        return;
                                                    }

                                                    [strongSelf queueTrackerURLForRetry:URL];
                                                }
                                            }
            ] resume];
    }];
}

- (void)fireTrackerURL: (NSString *)URL
{
    if ([URL length] > 0) {
        [self fireTrackerURLArray:@[URL]];
    }
}

- (void)retryTrackerFires 
{
    NSArray *trackerArrayCopy;

    @synchronized(self) {
        if ((self.trackerArray.count > 0) && self.internetIsReachable)
        {
            ANLogDebug(@"Internet back online - Firing trackers %@", self.trackerArray);

            trackerArrayCopy = [[NSArray alloc] initWithArray:self.trackerArray];
            [self.trackerArray removeAllObjects];
            [self.trackerRetryTimer invalidate];

        } else {
            return;
        }
    }

    __weak ANTrackerManager *weakSelf = self;

    [trackerArrayCopy enumerateObjectsUsingBlock:^(ANTrackerInfo *info, NSUInteger idx, BOOL *stop) 
        {
            if (info.isExpired)  { return; }

            [[[NSURLSession sharedSession] dataTaskWithRequest: ANBasicRequestWithURL([NSURL URLWithString:info.URL])
                                             completionHandler: ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
                                                {
                                                    if (error) 
                                                    {
                                                        ANLogDebug(@"CONNECTION ERROR - queing tracker for firing later: %@", info.URL);
                                                        info.numberOfTimesFired += 1;

                                                        if ((info.numberOfTimesFired < kANTrackerManagerMaximumNumberOfRetries) && !info.isExpired) 
                                                        {
                                                            ANTrackerManager *strongSelf = weakSelf;
                                                            if (!strongSelf)  {
                                                                ANLogError(@"FAILED TO ACQUIRE strongSelf.");
                                                                return;
                                                            }

                                                            [strongSelf queueTrackerInfoForRetry:info];
                                                        }
                                                    } else {
                                                        ANLogDebug(@"RETRY SUCCESSFUL for %@", info);
                                                    }
                                                }
                ] resume];
        }];
}


- (void)queueTrackerURLForRetry:(NSString *)URL 
{
    [self queueTrackerInfoForRetry:[[ANTrackerInfo alloc] initWithURL:URL]];
}

- (void)queueTrackerInfoForRetry:(ANTrackerInfo *)trackerInfo 
{
    @synchronized(self) {
        [self.trackerArray addObject:trackerInfo];
        [self scheduleRetryTimerIfNecessary];
    }
}

- (void)scheduleRetryTimerIfNecessary {
    if (![self.trackerRetryTimer an_isScheduled]) {
        __weak ANTrackerManager *weakSelf = self;
        self.trackerRetryTimer = [NSTimer an_scheduledTimerWithTimeInterval: kANTrackerManagerRetryInterval
                                                                      block: ^{
                                                                                  ANTrackerManager  *strongSelf  = weakSelf;
                                                                                  if (!strongSelf)  {
                                                                                     ANLogError(@"FAILED TO ACQUIRE strongSelf.");
                                                                                     return;
                                                                                  }
                                                                                  [strongSelf retryTrackerFires];
                                                                              }
                                                                    repeats: YES ];
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


@end
