//
//  ANAdAdapterBannerSmartAd.m
//  ANSDK
//
//  Created by Punnaghai Puviarasu on 11/21/16.
//  Copyright © 2016 AppNexus. All rights reserved.
//

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
    
    if(adUnitDictionary[@"siteId"] == nil || [adUnitDictionary[@"siteId"] isEqualToString:@""]){
        ANLogTrace(@"SmartAd mediation failed. siteId not provided in the adUnit dictionary");
        [self.delegate didFailToLoadAd:ANAdResponseMediatedSDKUnavailable];
        return;
    }else {
        NSString *pageId = adUnitDictionary[@"pageId"];
        NSString *formatIdString = adUnitDictionary[@"formatId"];
        self.adView = [[SASBannerView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height) loader:NO];
        self.adView.delegate = self;
        self.adView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.adView.modalParentViewController = rootViewController;
        if(formatIdString != nil && ![formatIdString isEqualToString:@""]){
            [self.adView loadFormatId:(NSInteger)formatIdString pageId:pageId master:TRUE target:nil];
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
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
     [self.delegate didLoadBannerAd:adView];
}
    
    
- (void)adView:(SASAdView *)adView didFailToLoadWithError:(NSError *)error {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate didFailToLoadAd:ANAdResponseUnableToFill];
}
    
    
- (void)adViewWillExpand:(SASAdView *)adView {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}
    
    
- (void)adView:(SASAdView *)adView didCloseExpandWithFrame:(CGRect)frame {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));}
    
-(BOOL)adView:(SASAdView *)adView shouldHandleURL:(NSURL *)URL {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate adWasClicked];
    return YES;
}

    
@end
