//
//  ANAdAdapterBannerRubicon.m
//  ANSDK
//
//  Created by Punnaghai Puviarasu on 1/11/17.
//  Copyright © 2017 AppNexus. All rights reserved.
//

#import "ANAdAdapterBannerRubicon.h"
#import "ANLogging.h"

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
        self.rfmAdView = [RFMAdView createAdWithDelegate:self];
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
    return self.rootViewController.view;
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
