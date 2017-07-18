/*   Copyright 2016 APPNEXUS INC
 
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
#import "ANAdAdapterBannerRubicon.h"
#import "ANLogging.h"
#import "ANBannerAdView.h"

@interface ANAdAdapterBannerRubicon()

    @property (nonatomic, strong) RFMAdView *rfmAdView;
    @property (nonatomic, strong) RFMAdRequest *rfmAdRequest;
    @property (nonatomic, strong) UIViewController *rootViewController;

@end

@implementation ANAdAdapterBannerRubicon

@synthesize delegate;

- (void)requestBannerAdWithSize:(CGSize)size
             rootViewController:(UIViewController *)rootViewController
                serverParameter:(NSString *)parameterString
                       adUnitId:(NSString *)idString
            targetingParameters:(ANTargetingParameters *)targetingParameters {
    
    self.rootViewController = rootViewController;
    
    if (!_rfmAdView) {
        self.rfmAdView = [RFMAdView createAdOfFrame:RFM_AD_FRAME_OF_SIZE(size.width,size.height)
                                   withPortraitCenter:RFM_AD_SET_CENTER(size.width/2,size.height/2)
                                   withLandscapeCenter:RFM_AD_SET_CENTER(size.width/2,size.height/2)
                                          withDelegate:self];
        
    }
    self.rfmAdRequest = [super constructRequestObject:idString];
    //set the targeting parameters for the request object
    [super setTargetingParameters:targetingParameters forRequest:self.rfmAdRequest];
    
    if (![self.rfmAdView requestFreshAdWithRequestParams:self.rfmAdRequest]) {
        ANLogError(@"Ad request denied");
    }
    
    
}

- (void)dealloc {
    
    self.rfmAdView.delegate = nil;
    self.rfmAdRequest = nil;
    self.rfmAdView = nil;
}

#pragma mark - RFM Ad Delegate

-(UIView *)rfmAdSuperView{
    ANBannerAdView *bannerAdView = [self.delegate performSelector:@selector(adViewDelegate)];
    return [bannerAdView.subviews firstObject]; // Should be an ANMediationContainerView
}

-(UIViewController *)viewControllerForRFMModalView{
    return self.rootViewController;
}

- (void)didRequestAd:(RFMAdView *)adView withUrl:(NSString *)requestUrlString{
    ANLogTrace(@"");
}

- (void)didReceiveAd:(RFMAdView *)adView {
    ANLogTrace(@"");
    [self.delegate didLoadBannerAd:self.rfmAdView];
}

- (void)didFailToReceiveAd:(RFMAdView *)adView
                    reason:(NSString *)errorReason{
    ANLogTrace(@"");
    [self.delegate didFailToLoadAd:ANAdResponseUnableToFill];
}

@end
