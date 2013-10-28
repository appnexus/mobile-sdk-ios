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

#import "ANMoPubMediationBanner.h"
#import "MPLogging.h"
#import "ANBannerAdView.h"
#import "MPError.h"

@interface ANMoPubMediationBanner ()

@property (nonatomic, retain) ANBannerAdView *adBannerView;

@end


@implementation ANMoPubMediationBanner

- (id)init
{
    self = [super init];
    return self;
}

- (void)invalidate
{
    self.delegate = nil;
}

// requires server to return info with "id" field, corresponding to AN placement id,
// and also "width" and "height" fields.

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info
{
    MPLogInfo(@"Requesting AN Banner");

    id widthParam = [info objectForKey:@"width"];
    id heightParam = [info objectForKey:@"height"];
    id placementId = [info objectForKey:@"id"];
    
    // fail if any of the parameters is missing
    if (!widthParam || !heightParam || !placementId) {
        MPLogInfo(@"Parameters from server were invalid");
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:[MPError errorWithCode:MPErrorAdapterInvalid]];
        return;
    }
    
    CGRect frame = CGRectMake(0, 0, [widthParam floatValue], [heightParam floatValue]);
    
    self.adBannerView = [ANBannerAdView adViewWithFrame:frame
                                            placementId:placementId];
    self.adBannerView.delegate = self;
    [self.adBannerView loadAd];
}

- (void)adDidReceiveAd:(id<ANAdProtocol>)ad
{
    MPLogInfo(@"Did load AN Banner");
    if (self.delegate)
        [self.delegate bannerCustomEvent:self didLoadAd:self.adBannerView];
}

- (void)ad:(id<ANAdProtocol>)ad requestFailedWithError:(NSError *)error
{
    MPLogInfo(@"Did fail to load AN Banner");
    if (self.delegate)
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:[MPError errorWithCode:MPErrorAdapterHasNoInventory]];
}

@end
