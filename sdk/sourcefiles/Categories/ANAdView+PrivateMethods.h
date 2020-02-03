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

#import "ANAdView.h"
#import "ANAdViewInternalDelegate.h"
#import "ANUniversalAdFetcher.h"



@interface ANAdView (PrivateMethods) <ANAdViewInternalDelegate>

@property (nonatomic, readwrite, strong, nonnull)  ANUniversalAdFetcher  *universalAdFetcher;

@property (nonatomic, readwrite)  BOOL  allowSmallerSizes;


//
- (void)initialize;
- (BOOL)errorCheckConfiguration;

- (void)loadAd;
- (void)loadAdFromHtml:(nonnull NSString *)html
                 width:(int)width
                height:(int)height;

- (void)loadAdFromVast: (nonnull NSString *)xml width: (int)width
                height: (int)height;

- (void)setAdResponse:(nonnull ANAdResponseElements *)adResponseElements;
- (void)setCreativeId:(nonnull NSString *)creativeId;



// Multi-Ad Request support.
//
@property (nonatomic, readwrite, weak, nullable)  ANMultiAdRequest  *marManager;

/**
 * utRequestUUIDString associates a unique identifier with each adunit per request, allowing ad objects
 *   in the UT Response to be matched with adunit elements of the UT Request.
 *
 * NB  This value is updated for each UT Request.  It does not persist across the lifecycle of the instance.
 */
@property (nonatomic, readwrite, strong, nonnull)   NSString  *utRequestUUIDString;


- (void)ingestAdResponseTag: (nonnull id)tag
      totalLatencyStartTime: (NSTimeInterval)totalLatencyStartTime;

@end
