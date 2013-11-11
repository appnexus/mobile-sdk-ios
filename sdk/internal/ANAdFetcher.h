/*   Copyright 2013 APPNEXUS INC
 
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

#import <Foundation/Foundation.h>
#import "ANAdResponse.h"
#import "ANAdProtocol.h"
#import "ANAdViewDelegate.h"
#import "ANCustomAdapter.h"

@class ANAdWebViewController;
@class ANMRAIDAdWebViewController;
@class ANLocation;
@protocol ANAdFetcherDelegate;

extern NSString *const kANAdFetcherWillRequestAdNotification;
extern NSString *const kANAdFetcherDidReceiveResponseNotification;
extern NSString *const kANAdFetcherAdRequestURLKey;
extern NSString *const kANAdFetcherAdResponseKey;

@interface ANAdFetcher : NSObject

@property (nonatomic, readwrite, weak) id<ANAdFetcherDelegate> delegate;
@property (nonatomic, readonly, getter = isLoading) BOOL loading;

- (void)stopAd;
- (void)requestAd;
- (void)requestAdWithURL:(NSURL *)URL;
- (void)startAutorefreshTimer;
- (void)setupAutorefreshTimerIfNecessary;
- (void)fireResultCB:(NSString *)resultCBString
              reason:(ANAdResponseCode)reason
            adObject:(id)adObject;
- (void)processFinalResponse:(ANAdResponse *)response;
@end

@protocol ANAdFetcherDelegate <NSObject, ANAdViewDelegate>

@property (nonatomic, readwrite, strong) NSString *placementId;
@property (nonatomic, readwrite, assign) BOOL shouldServePublicServiceAnnouncements;
@property (nonatomic, readwrite, assign) BOOL clickShouldOpenInBrowser;
@property (nonatomic, readwrite, strong) ANLocation *location;
@property (nonatomic, readwrite, assign) CGFloat reserve;
@property (nonatomic, readwrite, strong) NSString *age;
@property (nonatomic, readwrite, assign) ANGender gender;
@property (nonatomic, readwrite, strong) NSMutableDictionary *customKeywords;

- (void)adFetcher:(ANAdFetcher *)fetcher didFinishRequestWithResponse:(ANAdResponse *)response;
- (NSTimeInterval)autorefreshIntervalForAdFetcher:(ANAdFetcher *)fetcher;

@optional
- (CGSize)requestedSizeForAdFetcher:(ANAdFetcher *)fetcher;
- (NSString *)placementTypeForAdFetcher:(ANAdFetcher *)fetcher;

- (void)adFetcher:(ANAdFetcher *)fetcher adShouldResizeToSize:(CGSize)size;
- (void)adFetcher:(ANAdFetcher *)fetcher adShouldShowCloseButtonWithTarget:(id)target action:(SEL)action;
- (void)adShouldRemoveCloseButtonWithAdFetcher:(ANAdFetcher *)fetcher;
- (void)adFetcher:(ANAdFetcher *)fetcher adShouldOpenInBrowserWithURL:(NSURL *)URL;

// Delegate method for ANAdView subclasses to provide parameters that are specific to them. Should return an array of NSString
- (NSArray *)extraParametersForAdFetcher:(ANAdFetcher *)fetcher;

@end