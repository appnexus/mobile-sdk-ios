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

#import "ANNativeImpressionTrackerManager.h"
#import "ANReachability.h"
#import "ANNativeImpressionTrackerInfo.h"
#import "ANGlobal.h"
#import "ANLogging.h"

@interface ANNativeImpressionTrackerManager ()

@property (nonatomic, readwrite, strong) NSMutableArray *trackerArray;
@property (nonatomic, readwrite, strong) ANReachability *internetReachability;

@property (nonatomic, readonly, assign) BOOL internetIsReachable;

@end

@implementation ANNativeImpressionTrackerManager

+ (instancetype)sharedManager {
    static ANNativeImpressionTrackerManager *manager;
    static dispatch_once_t managerToken;
    dispatch_once(&managerToken, ^{
        manager = [[ANNativeImpressionTrackerManager alloc] init];
    });
    return manager;
}

+ (void)fireImpressionTrackerURLArray:(NSArray *)arrayWithURLs {
    ANNativeImpressionTrackerManager *manager = [[self class] sharedManager];
    [manager fireImpressionTrackerURLArray:arrayWithURLs];
}

+ (void)fireImpressionTrackerURL:(NSURL *)URL {
    ANNativeImpressionTrackerManager *manager = [[self class] sharedManager];
    [manager fireImpressionTrackerURL:URL];
}

#pragma mark ANNativeImpressionTrackerHandlerManager implementation

- (instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reachabilityChanged:)
                                                     name:kANReachabilityChangedNotification
                                                   object:nil];
        _internetReachability = [ANReachability reachabilityForInternetConnection];
        [_internetReachability startNotifier];
    }
    return self;
}

- (BOOL)internetIsReachable {
    ANNetworkStatus networkStatus = [self.internetReachability currentReachabilityStatus];
    BOOL connectionRequired = [self.internetReachability connectionRequired];
    if (networkStatus != ANNetworkStatusNotReachable && !connectionRequired) {
        return YES;
    }
    return NO;
}

- (void)reachabilityChanged:(NSNotification *)notification {
    [self fireImpressionTrackersIfPossible];
}

- (void)fireImpressionTrackersIfPossible {
    @synchronized(self) {
        if (self.trackerArray.count > 0 && self.internetIsReachable) {
            ANLogDebug(@"Internet back online - Firing impression trackers %@", self.trackerArray);
            [self.trackerArray enumerateObjectsUsingBlock:^(ANNativeImpressionTrackerInfo *info, NSUInteger idx, BOOL *stop) {
                if (!info.isExpired) {
                    [self sendRequestForImpressionTrackerURL:info.URL];
                }
            }];
            self.trackerArray = nil;
        }
    }
}

- (void)fireImpressionTrackerURLArray:(NSArray *)arrayWithURLs {
    if (self.internetIsReachable) {
        ANLogDebug(@"Internet is reachable - Firing impression trackers %@", arrayWithURLs);
        [arrayWithURLs enumerateObjectsUsingBlock:^(NSURL *URL, NSUInteger idx, BOOL *stop) {
            [self sendRequestForImpressionTrackerURL:URL];
        }];
    } else {
        ANLogDebug(@"Internet is unreachable - queing impression trackers for firing later %@", arrayWithURLs);
        [arrayWithURLs enumerateObjectsUsingBlock:^(NSURL *URL, NSUInteger idx, BOOL *stop) {
            ANNativeImpressionTrackerInfo *trackerInfo = [[ANNativeImpressionTrackerInfo alloc] initWithURL:URL];
            @synchronized(self) {
                [self.trackerArray addObject:trackerInfo];
            }
        }];
    }
}

- (void)fireImpressionTrackerURL:(NSURL *)URL {
    if (URL) {
        [self fireImpressionTrackerURLArray:@[URL]];
    }
}

- (void)sendRequestForImpressionTrackerURL:(NSURL *)URL {
    [NSURLConnection sendAsynchronousRequest:ANBasicRequestWithURL(URL)
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kANReachabilityChangedNotification
                                                  object:nil];
}

- (NSArray *)trackerArray {
    if (!_trackerArray) _trackerArray = [[NSMutableArray alloc] init];
    return _trackerArray;
}

@end