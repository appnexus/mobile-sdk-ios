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
#import "ANBannerAdView.h"
#import "ANLocation.h"

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
    NSLog(@"Requesting AN Banner");

    id widthParam = [info objectForKey:@"width"];
    id heightParam = [info objectForKey:@"height"];
    id placementId = [info objectForKey:@"id"];
    
    // fail if any of the parameters is missing
    if (!widthParam || !heightParam || !placementId) {
        NSLog(@"Parameters from server were invalid");
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:nil];
        return;
    }
    
    CGRect frame = CGRectMake(0, 0, [widthParam floatValue], [heightParam floatValue]);
    
    self.adBannerView = [ANBannerAdView adViewWithFrame:frame
                                            placementId:placementId];
    
    if ([self.delegate location]) {
        CLLocation *mpLoc = [self.delegate location];
        ANLocation *anLoc = [ANLocation getLocationWithLatitude:(CGFloat)mpLoc.coordinate.latitude
                                                      longitude:(CGFloat)mpLoc.coordinate.longitude
                                                      timestamp:mpLoc.timestamp
                                             horizontalAccuracy:(CGFloat)mpLoc.horizontalAccuracy];
        [self.adBannerView setLocation:anLoc];
    }
    
    NSMutableDictionary *customKeywords = [info mutableCopy];
    [customKeywords removeObjectForKey:@"width"];
    [customKeywords removeObjectForKey:@"height"];
    [customKeywords removeObjectForKey:@"id"];
    [self.adBannerView setCustomKeywords:customKeywords];
    
    self.adBannerView.delegate = self;
    [self.adBannerView loadAd];
}

- (void)adDidReceiveAd:(id<ANAdProtocol>)ad
{
    NSLog(@"Did load AN Banner");
    if (self.delegate)
        [self.delegate bannerCustomEvent:self didLoadAd:self.adBannerView];
}

- (void)ad:(id<ANAdProtocol>)ad requestFailedWithError:(NSError *)error
{
    NSLog(@"Did fail to load AN Banner");
    if (self.delegate)
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)adWillPresent:(id<ANAdProtocol>)ad {
    [self.delegate bannerCustomEventWillBeginAction:self];
}

- (void)adDidClose:(id<ANAdProtocol>)ad {
    [self.delegate bannerCustomEventDidFinishAction:self];
}

- (void)adWillLeaveApplication:(id<ANAdProtocol>)ad {
    [self.delegate bannerCustomEventWillLeaveApplication:self];
}

@end
