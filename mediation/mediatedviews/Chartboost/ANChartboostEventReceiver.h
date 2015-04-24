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

#import <Chartboost/Chartboost.h>
#import "ANAdConstants.h"

@protocol ANChartboostInterstitialDelegate;

@interface ANChartboostEventReceiver : NSObject <ChartboostDelegate>

+ (ANChartboostEventReceiver *)sharedReceiver;

- (void)cacheInterstitial:(CBLocation)location
             withDelegate:(id<ANChartboostInterstitialDelegate>)delegate;

@end

@protocol ANChartboostInterstitialDelegate <NSObject>

- (void)didDisplayInterstitial;
- (void)didCacheInterstitial;
- (void)didFailToLoadInterstitialWithError:(ANAdResponseCode)errorCode;
- (void)didDismissInterstitial;
- (void)didCloseInterstitial;
- (void)didClickInterstitial;

@end