/*   Copyright 2020 APPNEXUS INC
 
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

#import "MultiAdViewController.h"
#import <AppNexusSDK/AppNexusSDK.h>

@interface MultiAdViewController () <ANMultiAdRequestDelegate  , ANBannerAdViewDelegate ,  ANInstreamVideoAdPlayDelegate , ANInterstitialAdDelegate , ANNativeAdRequestDelegate , ANNativeAdDelegate  , ANInstreamVideoAdLoadDelegate>
@property (weak, nonatomic) IBOutlet UIView *bannerAdView;
@property (weak, nonatomic) IBOutlet UIView *videoAdView;
@property (weak, nonatomic) IBOutlet UIView *nativeAdView;
@property (weak, nonatomic) IBOutlet UIImageView *nativeIconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *nativeMainImageView;
@property (weak, nonatomic) IBOutlet UILabel *nativeTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *nativeBodyLabel;
@property (weak, nonatomic) IBOutlet UILabel *nativesponsoredLabel;


@property (strong, nonatomic)  ANBannerAdView      *bannerAd;
@property (strong, nonatomic)  ANInterstitialAd      *interstitialAd;
@property (strong, nonatomic)  ANNativeAdRequest      *nativeAdRequest;
@property (strong, nonatomic)  ANNativeAdResponse      *nativeAdResponse;
@property (strong, nonatomic)  ANInstreamVideoAd      *videoAd;
@property (strong, nonatomic)  ANMultiAdRequest      *marAdRequest;


@end

@implementation MultiAdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Multi Ad Request";

    // Init ANMultiAdRequest
    self.marAdRequest = [[ANMultiAdRequest alloc] initWithMemberId:10094 andDelegate:self];
    // Add Ad Units
    [self.marAdRequest addAdUnit:[self createBannerAd:self.bannerAdView]];
    //[self.marAdRequest addAdUnit:[self createInterstitialAd]];
    //[self.marAdRequest addAdUnit: [self createVideoAd]];
    //[self.marAdRequest addAdUnit:[self createNativeAd]];
    // Load Ad Units
    [self.marAdRequest load];
    
    // Do any additional setup after loading the view.
}


// Create Banner Ad Object
- (ANBannerAdView *)createBannerAd:(UIView *) adView
{
    self.bannerAd = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 300, 250) placementId:@"17058950" adSize:CGSizeMake(300, 250)];
    self.bannerAd.rootViewController =self;
    self.bannerAd.delegate =self;
    self.bannerAd.shouldResizeAdToFitContainer = YES;
    [adView addSubview:self.bannerAd];
    return self.bannerAd;
    
}

// Create Interstitial Ad Object
- (ANInterstitialAd *)createInterstitialAd
{
    self.interstitialAd = [[ANInterstitialAd alloc] initWithPlacementId:@"17058950"];
    self.interstitialAd.delegate =self;
    return self.interstitialAd;
    
}


// Create InstreamVideo Ad Object
- (ANInstreamVideoAd *)createVideoAd
{
    self.videoAd = [[ANInstreamVideoAd alloc] initWithPlacementId:@"17058950"];
    self.videoAd.loadDelegate =self;
    return self.videoAd;
}

// Create Native Ad Object
- (ANNativeAdRequest *)createNativeAd
{
    self.nativeAdRequest = [[ANNativeAdRequest alloc] init];
    self.nativeAdRequest.placementId = @"17058950";
    self.nativeAdRequest.shouldLoadIconImage = YES;
    self.nativeAdRequest.shouldLoadMainImage = YES;
    self.nativeAdRequest.delegate = self;
    return self.nativeAdRequest;
}



#pragma mark - Delegate methods exclusively for ANMultiAdRequest.
- (void) multiAdRequestDidComplete:(nonnull ANMultiAdRequest *)mar{
    NSLog(@"Multi Ad Request Did Complete");
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.marAdRequest load];
    });
}

- (void) multiAdRequest:(nonnull ANMultiAdRequest *)mar didFailWithError:(nonnull NSError *)error{
    NSLog(@"MultiAdRequest failed with error : \(error)");
}

#pragma mark - Delegate methods exclusively for ANAdDelegate.

- (void)adDidReceiveAd:(id)ad
{
    if([ad isKindOfClass:[ANInterstitialAd class]] && [self.interstitialAd isReady]){
        NSLog(@"Interstitial Ad did Receive");
        [self.interstitialAd displayAdFromViewController:self];
    }else if([ad isKindOfClass:[ANInstreamVideoAd class]]){
        NSLog(@"Video Ad did Receive");
        [self.videoAd playAdWithContainer:self.videoAdView withDelegate:self];
    }else if([ad isKindOfClass:[ANBannerAdView class]]){
        NSLog(@"Banner Ad did Receive");
    }
}

- (void)ad:(id)ad requestFailedWithError:(NSError *)error{
    NSLog(@"requestFailedWithError %@:",error);
    
}

-(void) lazyAdDidReceiveAd:(id)ad {
    [self.bannerAd loadLazyAd];
}

#pragma mark - Delegate methods exclusively for ANNativeAd.
- (void)adRequest:(ANNativeAdRequest *)request didFailToLoadWithError:(NSError *)error withAdResponseInfo:(ANAdResponseInfo *)adResponseInfo{
    NSLog(@"requestFailedWithError %@:",error);
}

- (void)adRequest:(ANNativeAdRequest *)request didReceiveResponse:(ANNativeAdResponse *)response{
    NSLog(@"Native Ad did Receive");
    
    self.nativeAdResponse = response;
    self.nativeIconImageView.image = self.nativeAdResponse.iconImage;
    self.nativeMainImageView.image = self.nativeAdResponse.mainImage;
    self.nativeTitleLabel.text = self.nativeAdResponse.title;
    self.nativeBodyLabel.text = self.nativeAdResponse.body;
    self.nativesponsoredLabel.text = self.nativeAdResponse.sponsoredBy;
    [self.nativeAdResponse registerViewForTracking:self.nativeAdView
                            withRootViewController:self
                                    clickableViews:@[self.nativeAdView]
                                             error:nil];
}


@end
