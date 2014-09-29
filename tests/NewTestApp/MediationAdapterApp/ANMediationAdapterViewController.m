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

#import "ANMediationAdapterViewController.h"
#import "ANURLConnectionStub.h"
#import "ANHTTPStubbingManager.h"
#import "ANLogManager.h"
#import "ANAdAdapterBaseAmazon.h"

@interface ANMediationAdapterViewController () <ANBannerAdViewDelegate, ANInterstitialAdDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic) ANInterstitialAd *interstitialAd;
@property (nonatomic, weak) ANBannerAdView *bannerAdView;
@end

@implementation ANMediationAdapterViewController

+ (NSArray *)networks {
    return @[@"FacebookBanner",
             @"FacebookInterstitial",
             @"MoPubBanner",
             @"MoPubInterstitial",
             @"iAdBanner",
             @"iAdInterstitial",
             @"AmazonBanner",
             @"AmazonInterstitial",
             @"MillennialMediaBanner",
             @"MillennialMediaInterstitial",
             @"AdMobBanner",
             @"AdMobInterstitial"];
}

#pragma mark - Picker View

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [[[self class] networks] count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component {
    return [[self class] networks][row];
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
    [self clearCurrentAd];
    [self.activityIndicator startAnimating];
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id ad = [self performSelector:NSSelectorFromString([NSString stringWithFormat:@"load%@WithDelegate:", [[self class] networks][row]])
                       withObject:self];
    #pragma clang diagnostic pop
    if ([ad isKindOfClass:[ANBannerAdView class]]) {
        self.bannerAdView = (ANBannerAdView *)ad;
    } else {
        self.interstitialAd = (ANInterstitialAd *)ad;
    }
}

- (void)clearCurrentAd {
    [self.bannerAdView removeFromSuperview];
    self.interstitialAd = nil;
}

#pragma mark - Facebook

- (ANBannerAdView *)loadFacebookBannerWithDelegate:(id<ANBannerAdViewDelegate>)delegate {
    [self stubFacebookBanner];
    return [self bannerWithDelegate:delegate];
}

- (ANInterstitialAd *)loadFacebookInterstitialWithDelegate:(id<ANInterstitialAdDelegate>)delegate {
    [self stubFacebookInterstitial];
    return [self interstitialWithDelegate:delegate];
}

- (void)stubFacebookBanner {
    [self stubMediatedAdCallWithJSONResource:@"FacebookBanner"];
}

- (void)stubFacebookInterstitial {
    [self stubMediatedAdCallWithJSONResource:@"FacebookInterstitial"];
}

#pragma mark - Amazon

- (ANBannerAdView *)loadAmazonBannerWithDelegate:(id<ANBannerAdViewDelegate>)delegate {
    [self stubAmazonBanner];
    return [self bannerWithDelegate:delegate];
}

-  (ANInterstitialAd *)loadAmazonInterstitialWithDelegate:(id<ANInterstitialAdDelegate>)delegate {
    [self stubAmazonInterstitial];
    return [self interstitialWithDelegate:delegate];
}

- (void)stubAmazonBanner {
    [self stubMediatedAdCallWithJSONResource:@"AmazonBanner"];
}

- (void)stubAmazonInterstitial {
    [self stubMediatedAdCallWithJSONResource:@"AmazonInterstitial"];
}

#pragma mark - iAd

- (ANBannerAdView *)loadiAdBannerWithDelegate:(id<ANBannerAdViewDelegate>)delegate {
    [self stubiAdBanner];
    return [self bannerWithDelegate:delegate];
}

- (ANInterstitialAd *)loadiAdInterstitialWithDelegate:(id<ANInterstitialAdDelegate>)delegate {
    [self stubiAdInterstitial];
    return [self interstitialWithDelegate:delegate];
}

- (void)stubiAdBanner {
    [self stubMediatedAdCallWithJSONResource:@"iAdBanner"];
}

- (void)stubiAdInterstitial {
    [self stubMediatedAdCallWithJSONResource:@"iAdInterstitial"];
}

#pragma mark - MoPub

- (ANBannerAdView *)loadMoPubBannerWithDelegate:(id<ANBannerAdViewDelegate>)delegate {
    [self stubMoPubBanner];
    return [self bannerWithDelegate:delegate];
}

- (ANInterstitialAd *)loadMoPubInterstitialWithDelegate:(id<ANInterstitialAdDelegate>)delegate {
    [self stubMoPubInterstitial];
    return [self interstitialWithDelegate:delegate];
}

- (void)stubMoPubBanner {
    [self stubMediatedAdCallWithJSONResource:@"MoPubBanner"];
}

- (void)stubMoPubInterstitial {
    [self stubMediatedAdCallWithJSONResource:@"MoPubInterstitial"];
}

#pragma mark - Millennial Media

- (ANBannerAdView *)loadMillennialMediaBannerWithDelegate:(id<ANBannerAdViewDelegate>)delegate {
    [self stubMillennialMediaBanner];
    return [self bannerWithDelegate:delegate];
}

- (ANInterstitialAd *)loadMillennialMediaInterstitialWithDelegate:(id<ANInterstitialAdDelegate>)delegate {
    [self stubMillennialMediaInterstitial];
    return [self interstitialWithDelegate:delegate];
}

- (void)stubMillennialMediaBanner {
    [self stubMediatedAdCallWithJSONResource:@"MillennialMediaBanner"];
}

- (void)stubMillennialMediaInterstitial {
    [self stubMediatedAdCallWithJSONResource:@"MillennialMediaInterstitial"];
}

#pragma mark - Ad Mob

- (ANBannerAdView *)loadAdMobBannerWithDelegate:(id<ANBannerAdViewDelegate>)delegate {
    [self stubAdMobBanner];
    return [self bannerWithDelegate:delegate];
}

- (ANInterstitialAd *)loadAdMobInterstitialWithDelegate:(id<ANInterstitialAdDelegate>)delegate {
    [self stubAdMobInterstitial];
    return [self interstitialWithDelegate:delegate];
}

- (void)stubAdMobBanner {
    [self stubMediatedAdCallWithJSONResource:@"AdMobBanner"];
}

- (void)stubAdMobInterstitial {
    [self stubMediatedAdCallWithJSONResource:@"AdMobInterstitial"];
}

#pragma mark - ANAdProtocol

- (void)ad:(id<ANAdProtocol>)ad requestFailedWithError:(NSError *)error {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self.activityIndicator stopAnimating];
}

- (void)adDidReceiveAd:(id<ANAdProtocol>)ad {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    if (self.interstitialAd == ad) {
        [self.interstitialAd displayAdFromViewController:self];
    }
    [self.activityIndicator stopAnimating];
}

# pragma mark - General

- (void)stubMediatedAdCallWithJSONResource:(NSString *)resource {
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    ANURLConnectionStub *mediatedResponseStub = [ANURLConnectionStub stubForResource:resource
                                                                              ofType:@"json"
                                                    withRequestURLRegexPatternString:@"http://mediation.adnxs.com/mob\\?.*"
                                                                            inBundle:[NSBundle bundleForClass:[self class]]];
    [[ANHTTPStubbingManager sharedStubbingManager] addStub:mediatedResponseStub];
    [self stubResultCBResponse];
}

- (void)stubResultCBResponse {
    ANURLConnectionStub *resultCBStub = [[ANURLConnectionStub alloc] init];
    resultCBStub.requestURLRegexPatternString = @"http://nym1.mobile.adnxs.com/mediation.*";
    resultCBStub.responseCode = 200;
    resultCBStub.responseBody = @"";
    [[ANHTTPStubbingManager sharedStubbingManager] addStub:resultCBStub];
}

- (ANBannerAdView *)bannerWithDelegate:(id<ANBannerAdViewDelegate>)delegate {
    ANBannerAdView *bannerAdView = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)
                                                             placementId:@"2054679"
                                                                  adSize:CGSizeMake(320, 50)];
    bannerAdView.rootViewController = self;
    bannerAdView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:bannerAdView];
    [bannerAdView loadAd];
    bannerAdView.delegate = delegate;
    bannerAdView.autoRefreshInterval = 0;
    return bannerAdView;
}

- (ANInterstitialAd *)interstitialWithDelegate:(id<ANInterstitialAdDelegate>)delegate {
    ANInterstitialAd *interstitialAd = [[ANInterstitialAd alloc] initWithPlacementId:@"2054679"];
    interstitialAd.delegate = delegate;
    [interstitialAd loadAd];
    return interstitialAd;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end