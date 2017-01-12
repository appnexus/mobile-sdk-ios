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
    
    @property (nonatomic, strong) SASBannerView *adView;

@end

@implementation ANAdAdapterBannerSmartAd
    
    @synthesize delegate;
    
- (void)requestBannerAdWithSize:(CGSize)size
             rootViewController:(UIViewController *)rootViewController
                serverParameter:(NSString *)parameterString
                       adUnitId:(NSString *)idString
            targetingParameters:(ANTargetingParameters *)targetingParameters {
    
    NSDictionary * adUnitDictionary = [self parseAdUnitParameters:idString];
    NSString *targetString;
    if(targetingParameters != nil){
        targetString = [super keywordsFromTargetingParameters:targetingParameters];
    }
    
    if(adUnitDictionary[SMART_SITEID] == nil || [adUnitDictionary[SMART_SITEID] isEqualToString:@""]){
        ANLogTrace(@"SmartAd mediation failed. siteId not provided in the adUnit dictionary");
        [self.delegate didFailToLoadAd:ANAdResponseMediatedSDKUnavailable];
        return;
    }else {
        NSString *pageId = adUnitDictionary[SMART_PAGEID];
        NSString *formatIdString = adUnitDictionary[SMART_FORMATID];
        self.adView = [[SASBannerView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height) loader:NO];
        self.adView.delegate = self;
        self.adView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.adView.modalParentViewController = rootViewController;
        if(formatIdString != nil && ![formatIdString isEqualToString:@""]){
            [self.adView loadFormatId:[formatIdString integerValue] pageId:pageId master:TRUE target:targetString];
        }else {
            ANLogTrace(@"SmartAd mediation failed. FormatId not provided in the adUnit dictionary");
            [self.delegate didFailToLoadAd:ANAdResponseMediatedSDKUnavailable];
            return;
        }
    }
}

- (void)dealloc {
    self.adView.delegate = nil;
}
    
#pragma mark - SASAdView delegate
    
- (void)adViewDidLoad:(SASAdView *)adView {
    ANLogTrace(@"");
     [self.delegate didLoadBannerAd:adView];
}
    
    
- (void)adView:(SASAdView *)adView didFailToLoadWithError:(NSError *)error {
    ANLogTrace(@"");
    [self.delegate didFailToLoadAd:ANAdResponseUnableToFill];
}
    
    
- (void)adViewWillExpand:(SASAdView *)adView {
    ANLogTrace(@"");
}
    
    
- (void)adView:(SASAdView *)adView didCloseExpandWithFrame:(CGRect)frame {
    ANLogTrace(@"");
}
    
-(BOOL)adView:(SASAdView *)adView shouldHandleURL:(NSURL *)URL {
    ANLogTrace(@"");
    [self.delegate adWasClicked];
    return YES;
}

    
@end
