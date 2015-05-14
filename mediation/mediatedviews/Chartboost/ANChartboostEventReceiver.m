/*   Copyright 2015 APPNEXUS INC
 
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

#import "ANChartboostEventReceiver.h"
#import "ANLogging.h"

@interface ANChartboostEventReceiver()

@property (nonatomic, readwrite, strong) NSMapTable *adapterMap;

@end

@implementation ANChartboostEventReceiver

+ (ANChartboostEventReceiver *)sharedReceiver {
    static dispatch_once_t sharedChartboostEventReceiverToken;
    static ANChartboostEventReceiver *eventReceiver;
    dispatch_once(&sharedChartboostEventReceiverToken, ^{
        eventReceiver = [[ANChartboostEventReceiver alloc] init];
    });
    return eventReceiver;
}

- (instancetype)init {
    if (self = [super init]) {
        _adapterMap = [NSMapTable strongToWeakObjectsMapTable];
    }
    return self;
}

- (void)cacheInterstitial:(CBLocation)location
             withDelegate:(id<ANChartboostInterstitialDelegate>)delegate {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if ([self.adapterMap objectForKey:location]) {
        ANLogDebug(@"%@ %@ | Interstitial already being loaded for %@. Only one interstitial adapter per location can load at once.", NSStringFromClass([self class]), NSStringFromSelector(_cmd), location);
        [delegate didFailToLoadInterstitialWithError:ANAdResponseUnableToFill];
    }
    
    if ([Chartboost hasInterstitial:location]) {
        [delegate didCacheInterstitial];
    } else {
        [Chartboost cacheInterstitial:location];
    }
    [self.adapterMap setObject:delegate
                        forKey:location];
}

- (ANAdResponseCode)responseCodeForLoadError:(CBLoadError)error {
    ANAdResponseCode errorCode = ANAdResponseInternalError;
    
    switch (error) {
        case CBLoadErrorInternal:
            errorCode = ANAdResponseInternalError;
            break;
        case CBLoadErrorInternetUnavailable:
            errorCode = ANAdResponseNetworkError;
            break;
        case CBLoadErrorTooManyConnections:
            errorCode = ANAdResponseNetworkError;
            break;
        case CBLoadErrorWrongOrientation:
            errorCode = ANAdResponseInvalidRequest;
            break;
        case CBLoadErrorFirstSessionInterstitialsDisabled:
            errorCode = ANAdResponseInvalidRequest;
            break;
        case CBLoadErrorNetworkFailure:
            errorCode = ANAdResponseNetworkError;
            break;
        case CBLoadErrorNoAdFound:
            errorCode = ANAdResponseUnableToFill;
            break;
        case CBLoadErrorSessionNotStarted:
            errorCode = ANAdResponseInternalError;
            break;
        case CBLoadErrorUserCancellation:
            errorCode = ANAdResponseInvalidRequest;
            break;
        case CBLoadErrorNoLocationFound:
            errorCode = ANAdResponseInternalError;
            break;
        case CBLoadErrorPrefetchingIncomplete:
            errorCode = ANAdResponseInternalError;
            break;
        default:
            errorCode = ANAdResponseInternalError;
            break;
    }
    
    return errorCode;
}

#pragma mark - ChartboostDelegate

- (void)didCacheInterstitial:(CBLocation)location {
    ANLogTrace(@"%@ %@ | %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), location);
    id<ANChartboostInterstitialDelegate> delegate = [self.adapterMap objectForKey:location];
    [delegate didCacheInterstitial];
}

- (void)didFailToLoadInterstitial:(CBLocation)location
                        withError:(CBLoadError)error {
    ANLogTrace(@"%@ %@ | %@ | Received Chartboost Error %ld", NSStringFromClass([self class]), NSStringFromSelector(_cmd), location, (long)error);
    id<ANChartboostInterstitialDelegate> delegate = [self.adapterMap objectForKey:location];
    [delegate didFailToLoadInterstitialWithError:[self responseCodeForLoadError:error]];
}

- (void)didDisplayInterstitial:(CBLocation)location {
    ANLogTrace(@"%@ %@ | %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), location);
    id<ANChartboostInterstitialDelegate> delegate = [self.adapterMap objectForKey:location];
    [delegate didDisplayInterstitial];
}
- (void)didDismissInterstitial:(CBLocation)location {
    ANLogTrace(@"%@ %@ | %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), location);
    id<ANChartboostInterstitialDelegate> delegate = [self.adapterMap objectForKey:location];
    [delegate didDismissInterstitial];
}
- (void)didCloseInterstitial:(CBLocation)location {
    ANLogTrace(@"%@ %@ | %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), location);
    id<ANChartboostInterstitialDelegate> delegate = [self.adapterMap objectForKey:location];
    [delegate didCloseInterstitial];
}
- (void)didClickInterstitial:(CBLocation)location {
    ANLogTrace(@"%@ %@ | %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), location);
    id<ANChartboostInterstitialDelegate> delegate = [self.adapterMap objectForKey:location];
    [delegate didClickInterstitial];
}

@end