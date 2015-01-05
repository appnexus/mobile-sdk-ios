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
             @"AdMobInterstitial",
             @"DFPBanner",
             @"DFPInterstitial",
             @"DoesNotExistBanner",
             @"DoesNotExistInterstitial"];
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
    ANMediatedAd *mediatedAd = [[ANMediatedAd alloc] init];
    mediatedAd.className = @"ANAdAdapterBannerFacebook";
    mediatedAd.adId = @"210827375150_10154672420735151";
    mediatedAd.width = @"320";
    mediatedAd.height = @"50";
    [self stubMediatedAd:mediatedAd];
}

- (void)stubFacebookInterstitial {
    ANMediatedAd *mediatedAd = [[ANMediatedAd alloc] init];
    mediatedAd.className = @"ANAdAdapterInterstitialFacebook";
    mediatedAd.adId = @"210827375150_10154672420735151";
    [self stubMediatedAd:mediatedAd];
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
    ANMediatedAd *mediatedAd = [[ANMediatedAd alloc] init];
    mediatedAd.className = @"ANAdAdapterBannerAmazon";
    mediatedAd.adId = @"123";
    mediatedAd.width = @"320";
    mediatedAd.height = @"50";
    [self stubMediatedAd:mediatedAd];
}

- (void)stubAmazonInterstitial {
    ANMediatedAd *mediatedAd = [[ANMediatedAd alloc] init];
    mediatedAd.className = @"ANAdAdapterInterstitialAmazon";
    mediatedAd.adId = @"123";
    [self stubMediatedAd:mediatedAd];
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
    ANMediatedAd *mediatedAd = [[ANMediatedAd alloc] init];
    mediatedAd.className = @"ANAdAdapterBanneriAd";
    mediatedAd.width = @"320";
    mediatedAd.height = @"50";
    [self stubMediatedAd:mediatedAd];
}

- (void)stubiAdInterstitial {
    ANMediatedAd *mediatedAd = [[ANMediatedAd alloc] init];
    mediatedAd.className = @"ANAdAdapterInterstitialiAd";
    mediatedAd.width = @"320";
    mediatedAd.height = @"50";
    [self stubMediatedAd:mediatedAd];
}

#pragma mark - MoPub

- (ANBannerAdView *)loadMoPubBannerWithDelegate:(id<ANBannerAdViewDelegate>)delegate {
    [self stubMoPubBanner];
    return [self bannerWithDelegate:delegate];
    //return [self bannerWithDelegate:delegate frameSize:CGSizeMake(300,250) adSize:CGSizeMake(300, 250)]; // MRAID
}

- (ANInterstitialAd *)loadMoPubInterstitialWithDelegate:(id<ANInterstitialAdDelegate>)delegate {
    [self stubMoPubInterstitial];
    return [self interstitialWithDelegate:delegate];
}

- (void)stubMoPubBanner {
    ANMediatedAd *mediatedAd = [[ANMediatedAd alloc] init];
    mediatedAd.className = @"ANAdAdapterBannerMoPub";
    mediatedAd.adId = @"b735fe4e98b0449da95917215cb32268";
    mediatedAd.width = @"320";
    mediatedAd.height = @"50";
    /*mediatedAd.adId = @"3d10bc157e724dfdb060347ae9884d64"; // MRAID
    mediatedAd.width = @"300";
    mediatedAd.height = @"250";*/
    [self stubMediatedAd:mediatedAd];
}

- (void)stubMoPubInterstitial {
    ANMediatedAd *mediatedAd = [[ANMediatedAd alloc] init];
    mediatedAd.className = @"ANAdAdapterInterstitialMoPub";
    mediatedAd.adId = @"783ac4a38cc44144b3f62b9b89ca85b4";
    [self stubMediatedAd:mediatedAd];
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
    ANMediatedAd *mediatedAd = [[ANMediatedAd alloc] init];
    mediatedAd.className = @"ANAdAdapterBannerMillennialMedia";
    mediatedAd.adId = @"139629";
    mediatedAd.width = @"320";
    mediatedAd.height = @"50";
    [self stubMediatedAd:mediatedAd];
}

- (void)stubMillennialMediaInterstitial {
    ANMediatedAd *mediatedAd = [[ANMediatedAd alloc] init];
    mediatedAd.className = @"ANAdAdapterInterstitialMillennialMedia";
    mediatedAd.adId = @"139629";
    [self stubMediatedAd:mediatedAd];
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
    ANMediatedAd *mediatedAd = [[ANMediatedAd alloc] init];
    mediatedAd.className = @"ANAdAdapterBannerAdMob";
    mediatedAd.adId = @"ca-app-pub-5668774179595841/1125462353";
    mediatedAd.width = @"320";
    mediatedAd.height = @"50";
    [self stubMediatedAd:mediatedAd];
}

- (void)stubAdMobInterstitial {
    ANMediatedAd *mediatedAd = [[ANMediatedAd alloc] init];
    mediatedAd.className = @"ANAdAdapterInterstitialAdMob";
    mediatedAd.adId = @"ca-app-pub-5668774179595841/1125462353";
    [self stubMediatedAd:mediatedAd];
}

#pragma mark - DFP

- (ANBannerAdView *)loadDFPBannerWithDelegate:(id<ANBannerAdViewDelegate>)delegate {
    [self stubDFPBanner];
    return [self bannerWithDelegate:delegate];
}

- (ANInterstitialAd *)loadDFPInterstitialWithDelegate:(id<ANInterstitialAdDelegate>)delegate {
    [self stubDFPInterstitial];
    return [self interstitialWithDelegate:delegate];
}

- (void)stubDFPBanner {
    ANMediatedAd *mediatedAd = [[ANMediatedAd alloc] init];
    mediatedAd.className = @"ANAdAdapterBannerDFP";
    mediatedAd.adId = @"/6925/Shazam_iPhoneAPP/Standard_Banners/AutoShazam_TagsTab";
    mediatedAd.width = @"320";
    mediatedAd.height = @"50";
    [self stubMediatedAd:mediatedAd];
}

- (void)stubDFPInterstitial {
    ANMediatedAd *mediatedAd = [[ANMediatedAd alloc] init];
    mediatedAd.className = @"ANAdAdapterInterstitialDFP";
    mediatedAd.adId = @"/6925/Shazam_iPhoneAPP/Standard_Banners/AutoShazam_TagsTab";
    [self stubMediatedAd:mediatedAd];
}

#pragma mark - Does Not Exist

- (ANBannerAdView *)loadDoesNotExistBannerWithDelegate:(id<ANBannerAdViewDelegate>)delegate {
    [self stubNonExistentBanner];
    return [self bannerWithDelegate:delegate];
}

- (ANInterstitialAd *)loadDoesNotExistInterstitialWithDelegate:(id<ANInterstitialAdDelegate>)delegate {
    [self stubNonExistentInterstitial];
    return [self interstitialWithDelegate:delegate];
}

- (void)stubNonExistentBanner {
    ANMediatedAd *mediatedAd = [[ANMediatedAd alloc] init];
    mediatedAd.className = @"ANAdAdapterBannerDoesNotExist";
    mediatedAd.adId = @"/6925/Shazam_iPhoneAPP/Standard_Banners/AutoShazam_TagsTab";
    mediatedAd.width = @"320";
    mediatedAd.height = @"50";
    [self stubMediatedAd:mediatedAd];
}

- (void)stubNonExistentInterstitial {
    ANMediatedAd *mediatedAd = [[ANMediatedAd alloc] init];
    mediatedAd.className = @"ANAdAdapterInterstitialDoesNotExist";
    mediatedAd.adId = @"/6925/Shazam_iPhoneAPP/Standard_Banners/AutoShazam_TagsTab";
    [self stubMediatedAd:mediatedAd];
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

- (void)stubMediatedAd:(ANMediatedAd *)mediatedAd {
    NSBundle *currentBundle = [NSBundle bundleForClass:[self class]];
    NSString *baseResponse = [NSString stringWithContentsOfFile:[currentBundle pathForResource:@"BaseMediationSingleNetworkResponse"
                                                                                        ofType:@"json"]
                                                 encoding:NSUTF8StringEncoding
                                                    error:nil];
    NSMutableString *mutableBaseResponse = [baseResponse mutableCopy];
    [mutableBaseResponse replaceOccurrencesOfString:@"#{CLASS}"
                                         withString:mediatedAd.className ? mediatedAd.className : @""
                                            options:NSLiteralSearch
                                              range:NSMakeRange(0, [mutableBaseResponse length])];
    [mutableBaseResponse replaceOccurrencesOfString:@"#{WIDTH}"
                                         withString:mediatedAd.width ? mediatedAd.width : @""
                                            options:NSLiteralSearch
                                              range:NSMakeRange(0, [mutableBaseResponse length])];
    [mutableBaseResponse replaceOccurrencesOfString:@"#{HEIGHT}"
                                         withString:mediatedAd.height ? mediatedAd.height : @""
                                            options:NSLiteralSearch
                                              range:NSMakeRange(0, [mutableBaseResponse length])];
    [mutableBaseResponse replaceOccurrencesOfString:@"#{ID}"
                                         withString:mediatedAd.adId ? mediatedAd.adId : @""
                                            options:NSLiteralSearch
                                              range:NSMakeRange(0, [mutableBaseResponse length])];
    [mutableBaseResponse replaceOccurrencesOfString:@"#{PARAM}"
                                         withString:mediatedAd.param ? mediatedAd.param : @""
                                            options:NSLiteralSearch
                                              range:NSMakeRange(0, [mutableBaseResponse length])];
    ANURLConnectionStub *stub = [[ANURLConnectionStub alloc] init];
    stub.requestURLRegexPatternString = @"http://mediation.adnxs.com/mob\\?.*";
    stub.responseCode = 200;
    stub.responseBody = [mutableBaseResponse copy];
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    [[ANHTTPStubbingManager sharedStubbingManager] addStub:stub];
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
    return [self bannerWithDelegate:delegate
                          frameSize:CGSizeMake(320, 50)
                             adSize:CGSizeMake(320, 50)];
}

- (ANBannerAdView *)bannerWithDelegate:(id<ANBannerAdViewDelegate>)delegate
                             frameSize:(CGSize)frameSize
                                adSize:(CGSize)adSize {
    ANBannerAdView *bannerAdView = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 0, frameSize.width, frameSize.height)
                                                             placementId:@"2054679"
                                                                  adSize:CGSizeMake(adSize.width, adSize.height)];
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