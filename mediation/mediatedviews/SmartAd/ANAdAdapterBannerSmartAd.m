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
#import "ANAdAdapterBannerSmartAd.h"
#import "ANLogging.h"
#import "ANAdAdapterSmartAdBase+PrivateMethods.h"

@interface ANAdAdapterBannerSmartAd ()
    
@property (nonatomic, strong) SASBannerView *bannerView;

@end

@implementation ANAdAdapterBannerSmartAd

@synthesize delegate;
    
- (void)requestBannerAdWithSize:(CGSize)size
             rootViewController:(UIViewController *)rootViewController
                serverParameter:(NSString *)parameterString
                       adUnitId:(NSString *)idString
            targetingParameters:(ANTargetingParameters *)targetingParameters {
    
    SASAdPlacement *placement = [self parseAdUnitParameters:idString targetingParameters:targetingParameters];
    
    if (placement != nil) {
        
        // Banner view initialization & configuration
        self.bannerView = [[SASBannerView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        self.bannerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.bannerView.delegate = self;
        self.bannerView.modalParentViewController = rootViewController;
        
        // Banner view loading
        [self.bannerView loadWithPlacement:placement];
        
    } else {
        [self.delegate didFailToLoadAd:ANAdResponseMediatedSDKUnavailable];
    }
    
}

- (void)dealloc {
    self.bannerView.delegate = nil;
}
    
#pragma mark - SASAdView delegate
    
- (void)bannerViewDidLoad:(SASBannerView *)bannerView {
    ANLogTrace(@"");
     [self.delegate didLoadBannerAd:bannerView];
}
    
- (void)bannerView:(SASBannerView *)bannerView didFailToLoadWithError:(NSError *)error {
    ANLogTrace(@"");
    [self.delegate didFailToLoadAd:ANAdResponseUnableToFill];
}
    
- (void)bannerViewWillExpand:(SASBannerView *)bannerView {
    ANLogTrace(@"");
}
    
- (void)bannerView:(SASAdView *)bannerView didCloseExpandWithFrame:(CGRect)frame {
    ANLogTrace(@"");
}
    
-(BOOL)bannerView:(SASAdView *)bannerView shouldHandleURL:(NSURL *)URL {
    ANLogTrace(@"");
    [self.delegate adWasClicked];
    return YES;
}
    
@end
