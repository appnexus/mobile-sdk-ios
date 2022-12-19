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

#import "ANAdAdapterBannerAdMob.h"
#import "ANAdAdapterBaseDFP.h"
@interface ANAdAdapterBannerAdMob ()
@property (nonatomic, readwrite, strong) GADBannerView *bannerView;
@end


/**
 * Server side overridable
 */
@interface AdMobBannerServerSideParameters : NSObject
@property(nonatomic, readwrite) BOOL isSmartBanner;
@end
@implementation AdMobBannerServerSideParameters
@synthesize isSmartBanner;
@end





@implementation ANAdAdapterBannerAdMob
@synthesize delegate;
#pragma mark ANCustomAdapterBanner

- (void)requestBannerAdWithSize:(CGSize)size
             rootViewController:(nullable UIViewController *)rootViewController
                serverParameter:(nullable NSString *)parameterString
                       adUnitId:(nullable NSString *)idString
            targetingParameters:(nullable ANTargetingParameters *)targetingParameters
{
    ANLogDebug(@"Requesting AdMob banner with size: %fx%f", size.width, size.height);
	GADAdSize gadAdSize;
    
    AdMobBannerServerSideParameters *ssparam = [self parseServerSide:parameterString];
    
    // Allow server side to enable Smart Banners for this placement
    if (ssparam.isSmartBanner) {
        UIApplication *application = [UIApplication sharedApplication];
        BOOL orientationIsPortrait = UIInterfaceOrientationIsPortrait([application statusBarOrientation]);
        if(orientationIsPortrait) {
            gadAdSize = GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(size.width);
        } else {
            gadAdSize = GADLandscapeAnchoredAdaptiveBannerAdSizeWithWidth(size.height);
        }
    } else {
        gadAdSize = GADAdSizeFromCGSize(size);
    }
    self.bannerView = [[GADBannerView alloc] initWithAdSize:gadAdSize];
    
    self.bannerView.adUnitID = idString;
    self.bannerView.rootViewController = rootViewController;
    self.bannerView.delegate = self;
    [self.bannerView loadRequest:[self createRequestFromTargetingParameters:targetingParameters rootViewController: rootViewController]];
}

- (GADRequest *)createRequestFromTargetingParameters:(ANTargetingParameters *)targetingParameters rootViewController: (UIViewController *)rootViewController {
    return [ANAdAdapterBaseDFP googleAdMobRequestFromTargetingParameters:targetingParameters rootViewController: rootViewController];
}

- (AdMobBannerServerSideParameters*) parseServerSide:(NSString*) serverSideParameters
{
    AdMobBannerServerSideParameters *p = [AdMobBannerServerSideParameters new];
    NSError *jsonParsingError = nil;
    if (serverSideParameters == nil || [ serverSideParameters length] == 0) {
        return p;
    }
    NSData* data = [serverSideParameters dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
    
    if (jsonParsingError == nil && jsonResponse != nil) {
        p.isSmartBanner = [[jsonResponse valueForKey:@"smartbanner"] boolValue];
    }
    return p;
}


#pragma mark GADBannerViewDelegate

- (void)bannerViewDidReceiveAd:(nonnull GADBannerView *)bannerView
{
    ANLogDebug(@"AdMob banner did load");
    [self.delegate didLoadBannerAd:bannerView];
}
- (void)bannerView:(nonnull GADBannerView *)bannerView didFailToReceiveAdWithError:(nonnull NSError *)error
{
    ANLogDebug(@"AdMob banner failed to load with error: %@", error);
    [self.delegate didFailToLoadAd:[ANAdAdapterBaseDFP responseCodeFromRequestError:error]];
}

- (void)bannerViewWillPresentScreen:(nonnull GADBannerView *)bannerView{
    [self.delegate willPresentAd];
}

- (void)bannerViewWillDismissScreen:(nonnull GADBannerView *)bannerView {
    [self.delegate willCloseAd];
}

- (void)bannerViewDidDismissScreen:(nonnull GADBannerView *)bannerView {
    [self.delegate didCloseAd];
}

- (void)bannerViewDidRecordImpression:(GADBannerView *)bannerView {
    [self.delegate adDidLogImpression];
}

/* Tells the delegate that a click has been recorded for the ad. */
- (void)bannerViewDidRecordClick:(nonnull GADBannerView *)bannerView{
    [self.delegate adWasClicked];
}

- (void)dealloc
{
    ANLogDebug(@"AdMob banner being destroyed");
    self.bannerView.delegate = nil;
    self.bannerView = nil;
}


@end
