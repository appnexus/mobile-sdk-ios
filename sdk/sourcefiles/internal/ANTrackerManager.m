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
        _internetReachability = [ANReachability sharedReachabilityForInternetConnection];
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

+ (void)fireTrackerURLArray: (NSArray<NSString *> *)arrayWithURLs withBlock:(OnComplete)completionBlock
{
    [[self sharedManager] fireTrackerURLArray:arrayWithURLs withBlock:completionBlock];
}

+ (void)fireTrackerURL: (NSString *)URL
{
    [[self sharedManager] fireTrackerURL:URL];
}


#pragma mark - Private methods.

- (void)fireTrackerURLArray: (NSArray<NSString *> *)arrayWithURLs withBlock:(OnComplete)completionBlock
{
    if (!arrayWithURLs || ([arrayWithURLs count] <= 0)) {
        if(completionBlock)
        {
          completionBlock(NO);
        }
        return;
    }

    //
    if (!self.internetIsReachable)
    {
        ANLogDebug(@"Internet IS UNREACHABLE - queing trackers for firing later: %@", arrayWithURLs);

        [arrayWithURLs enumerateObjectsUsingBlock:^(NSString *URL, NSUInteger idx, BOOL *stop) {
            [self queueTrackerURLForRetry:URL withBlock:completionBlock];
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

                                                    [strongSelf queueTrackerURLForRetry:URL withBlock:completionBlock];
                                                } else {
                                                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                                    ANLogDebug(@"BURDA Response status code: %ld", (long)[httpResponse statusCode]);
                                                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                                    NSInteger requestCount = [defaults integerForKey:@"totalImpSuccessCount"];
                                                    [defaults setInteger:requestCount+1 forKey:@"totalImpSuccessCount"];
                                                    [defaults synchronize];
                                                
                                                    if (completionBlock) {
                                                        completionBlock(YES);
                                                    }
                                                }
                                            }
            ] resume];
    }];
}

- (void)fireTrackerURL: (NSString *)URL
{
    if ([URL length] > 0) {
        [self fireTrackerURLArray:@[URL] withBlock:nil];
    }
}

- (void)retryTrackerFiresWithBlock:(OnComplete)completionBlock
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
            if (completionBlock) {
              completionBlock(NO);
            }
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

                                                            [strongSelf queueTrackerInfoForRetry:info withBlock:completionBlock];
                                                        } else {
                                                            ANLogDebug(@"BURDA retry count exceeded no tracker fired");
                                                            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                                            NSInteger requestCount = [defaults integerForKey:@"totalImpFailureCount"];
                                                            [defaults setInteger:requestCount+1 forKey:@"totalImpFailureCount"];
                                                            [defaults synchronize];
                                                            ANLogDebug(@"BURDA Impression failure %ld", requestCount+1);
                                                        }
                                                    } else {
                                                        ANLogDebug(@"RETRY SUCCESSFUL for %@", info);
                                                        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                                        
                                                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                                        NSInteger requestCount = [defaults integerForKey:@"totalImpSuccessCount"];
                                                        [defaults setInteger:requestCount+1 forKey:@"totalImpSuccessCount"];
                                                        [defaults synchronize];
                                                        ANLogDebug(@"BURDA Request Success %ld", requestCount+1);
                                                        
                                                        ANLogDebug(@"BURDA Response status code: %ld", (long)[httpResponse statusCode]);
                                                        ANLogDebug(@"RETRY SUCCESSFUL for %@", info);
                                                        if (completionBlock) {
                                                          completionBlock(YES);
                                                        }
                                                    }
                                                }
                ] resume];
        }];
}


- (void)queueTrackerURLForRetry:(NSString *)URL withBlock:(OnComplete)completionBlock
{
    [self queueTrackerInfoForRetry:[[ANTrackerInfo alloc] initWithURL:URL] withBlock:completionBlock];
}

- (void)queueTrackerInfoForRetry:(ANTrackerInfo *)trackerInfo withBlock:(OnComplete)completionBlock
{
    @synchronized(self) {
        [self.trackerArray addObject:trackerInfo];
        [self scheduleRetryTimerIfNecessaryWithBlock:completionBlock];
    }
}

- (void)scheduleRetryTimerIfNecessaryWithBlock:(OnComplete)completionBlock {
    if (![self.trackerRetryTimer an_isScheduled]) {
        __weak ANTrackerManager *weakSelf = self;
        self.trackerRetryTimer = [NSTimer an_scheduledTimerWithTimeInterval: kANTrackerManagerRetryInterval
                                                                      block: ^{
                                                                                  ANTrackerManager  *strongSelf  = weakSelf;
                                                                                  if (!strongSelf)  {
                                                                                     ANLogError(@"FAILED TO ACQUIRE strongSelf.");
                                                                                     return;
                                                                                  }
                                                                                  [strongSelf retryTrackerFiresWithBlock:completionBlock];
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
