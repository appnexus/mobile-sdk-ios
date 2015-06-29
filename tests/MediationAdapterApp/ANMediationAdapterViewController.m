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
#import "ANAdAdapterBaseInMobi.h"
#import "ANAdAdapterBaseAdColony.h"
#import "ANAdAdapterBaseVungle.h"
#import "ANAdAdapterBaseChartboost.h"
#import "ANNativeAdRequest.h"
#import "ANNativeAdView.h"
#import "ANNativeAdColonyView.h"
#import "ANDFPCacheManager.h"

@interface ANMediationAdapterViewController () <ANBannerAdViewDelegate, ANInterstitialAdDelegate, UIPickerViewDelegate, UIPickerViewDataSource, ANNativeAdRequestDelegate, ANNativeAdDelegate>
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic) ANInterstitialAd *interstitialAd;
@property (nonatomic, weak) ANBannerAdView *bannerAdView;
@property (nonatomic) ANNativeAdRequest *nativeAdRequest;
@property (nonatomic) ANNativeAdResponse *nativeAdResponse;
@property (nonatomic) ANNativeAdView *nativeAdView;
@property (nonatomic) ANNativeAdColonyView *adColonyView;
@end

@implementation ANMediationAdapterViewController

+ (NSArray *)networks {
    return @[@"VdopiaBanner",
             @"VdopiaInterstitial",
             @"AdColonyInterstitial",
             @"AdColonyNative",
             @"VungleInterstitial",
             @"ChartboostInterstitial",
             @"FacebookBanner",
             @"FacebookInterstitial",
             @"FacebookNative",
             @"MoPubBanner",
             @"MoPubInterstitial",
             @"MoPubNative",
             @"iAdBanner",
             @"iAdInterstitial",
             @"AmazonBanner",
             @"AmazonInterstitial",
             @"MillennialMediaBanner",
             @"MillennialMediaInterstitial",
             @"AdMobBanner",
             @"AdMobInterstitial",
             @"DFPCacheBanner",
             @"DFPCacheSmartBanner",
             @"DFPBanner",
             @"DFPSmartBanner",
             @"DFPInterstitial",
             @"InMobiBanner",
             @"InMobiInterstitial",
             @"InMobiNative",
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
    } else if ([ad isKindOfClass:[ANInterstitialAd class]]) {
        self.interstitialAd = (ANInterstitialAd *)ad;
    } else {
        self.nativeAdRequest = (ANNativeAdRequest *)ad;
    }
}

- (void)clearCurrentAd {
    [self.bannerAdView removeFromSuperview];
    self.interstitialAd = nil;
    [self.nativeAdView removeFromSuperview];
    self.nativeAdView = nil;
    self.nativeAdResponse = nil;
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

- (ANNativeAdRequest *)loadFacebookNativeWithDelegate:(id<ANNativeAdRequestDelegate>)delegate {
    [self stubFacebookNative];
    ANNativeAdRequest *nativeAdRequest = [self nativeAdRequestWithDelegate:delegate];
    nativeAdRequest.shouldLoadIconImage = YES;
    nativeAdRequest.shouldLoadMainImage = YES;
    return nativeAdRequest;
}

- (void)stubFacebookNative {
    ANMediatedAd *mediatedAd = [[ANMediatedAd alloc] init];
    mediatedAd.className = @"ANAdAdapterNativeFacebook";
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

#pragma mark - Vungle

-  (ANInterstitialAd *)loadVungleInterstitialWithDelegate:(id<ANInterstitialAdDelegate>)delegate {
    static dispatch_once_t vungleToken;
    dispatch_once(&vungleToken, ^{
        [ANAdAdapterBaseVungle setVungleAppId:@"736869833"];
    });
    [self stubVungleInterstitial];
    return [self interstitialWithDelegate:delegate];
}

- (void)stubVungleInterstitial {
    ANMediatedAd *mediatedAd = [[ANMediatedAd alloc] init];
    mediatedAd.className = @"ANAdAdapterInterstitialVungle";
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

- (ANNativeAdRequest *)loadMoPubNativeWithDelegate:(id<ANNativeAdRequestDelegate>)delegate {
    [self stubMoPubNative];
    ANNativeAdRequest *nativeAdRequest = [self nativeAdRequestWithDelegate:delegate];
    nativeAdRequest.shouldLoadIconImage = YES;
    nativeAdRequest.shouldLoadMainImage = YES;
    return nativeAdRequest;
}

- (void)stubMoPubNative {
    ANMediatedAd *mediatedAd = [[ANMediatedAd alloc] init];
    mediatedAd.className = @"ANAdAdapterNativeMoPub";
    mediatedAd.adId = @"2e1dc30d43c34a888d91b5203560bbf6";
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
    mediatedAd.adId = @"ca-app-pub-8961681709559022/7336091790";
    mediatedAd.width = @"320";
    mediatedAd.height = @"50";
    [self stubMediatedAd:mediatedAd];
}

- (void)stubAdMobInterstitial {
    ANMediatedAd *mediatedAd = [[ANMediatedAd alloc] init];
    mediatedAd.className = @"ANAdAdapterInterstitialAdMob";
    mediatedAd.adId = @"ca-app-pub-8961681709559022/1180736194";
    [self stubMediatedAd:mediatedAd];
}

#pragma mark - DFP

- (id)loadDFPCacheBannerWithDelegate:(id)delegate {
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    [ANDFPCacheManager cacheBannerWithDFPAdUnitId:@"/6925/Shazam_iPhoneAPP/Standard_Banners/AutoShazam_TagsTab"
                                           adSize:CGSizeMake(320.0, 50.0)];
    return nil;
}

- (id)loadDFPCacheSmartBannerWithDelegate:(id)delegate {
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    [ANDFPCacheManager cacheSmartBannerWithDFPAdUnitId:@"/6925/Shazam_iPhoneAPP/Standard_Banners/AutoShazam_TagsTab"];
    return nil;
}

- (ANBannerAdView *)loadDFPBannerWithDelegate:(id<ANBannerAdViewDelegate>)delegate {
    [self stubDFPBanner];
    return [self bannerWithDelegate:delegate];
}

- (ANBannerAdView *)loadDFPSmartBannerWithDelegate:(id<ANBannerAdViewDelegate>)delegate {
    [self stubDFPSmartBanner];
    return [self bannerWithDelegate:delegate
                          frameSize:CGSizeMake(self.view.frame.size.width, 50)
                             adSize:CGSizeMake(320, 50)];
}

- (ANInterstitialAd *)loadDFPInterstitialWithDelegate:(id<ANInterstitialAdDelegate>)delegate {
    [self stubDFPInterstitial];
    return [self interstitialWithDelegate:delegate];
}

- (void)stubDFPBanner {
    ANMediatedAd *mediatedAd = [[ANMediatedAd alloc] init];
    mediatedAd.className = @"ANAdAdapterBannerDFP";
    mediatedAd.adId = @"/19968336/MediationAdapterAppTest";
    mediatedAd.width = @"320";
    mediatedAd.height = @"50";
    [self stubMediatedAd:mediatedAd];
}

- (void)stubDFPSmartBanner {
    ANMediatedAd *mediatedAd = [[ANMediatedAd alloc] init];
    mediatedAd.className = @"ANAdAdapterBannerDFP";
    mediatedAd.adId = @"/6925/Shazam_iPhoneAPP/Standard_Banners/AutoShazam_TagsTab";
    mediatedAd.width = @"320";
    mediatedAd.height = @"50";
    mediatedAd.param = @"{\\\"smartbanner\\\":1}";
    [self stubMediatedAd:mediatedAd];
}

- (void)stubDFPInterstitial {
    ANMediatedAd *mediatedAd = [[ANMediatedAd alloc] init];
    mediatedAd.className = @"ANAdAdapterInterstitialDFP";
    mediatedAd.adId = @"/19968336/MediationAdapterAppTest";
    [self stubMediatedAd:mediatedAd];
}

#pragma mark - InMobi

- (ANBannerAdView *)loadInMobiBannerWithDelegate:(id<ANBannerAdViewDelegate>)delegate {
    [self stubInMobiBanner];
    [ANAdAdapterBaseInMobi setInMobiAppID:@"0c4a211baa254c3ab8bfb7dee681a666"];
    return [self bannerWithDelegate:delegate];
}

- (ANInterstitialAd *)loadInMobiInterstitialWithDelegate:(id<ANInterstitialAdDelegate>)delegate {
    [self stubInMobiInterstitial];
    [ANAdAdapterBaseInMobi setInMobiAppID:@"0c4a211baa254c3ab8bfb7dee681a666"];
    return [self interstitialWithDelegate:delegate];
}

- (void)stubInMobiBanner {
    ANMediatedAd *mediatedAd = [[ANMediatedAd alloc] init];
    mediatedAd.className = @"ANAdAdapterBannerInMobi";
    mediatedAd.width = @"320";
    mediatedAd.height = @"50";
    [self stubMediatedAd:mediatedAd];
}

- (void)stubInMobiInterstitial {
    ANMediatedAd *mediatedAd = [[ANMediatedAd alloc] init];
    mediatedAd.className = @"ANAdAdapterInterstitialInMobi";
    [self stubMediatedAd:mediatedAd];
}

- (ANNativeAdRequest *)loadInMobiNativeWithDelegate:(id<ANNativeAdRequestDelegate>)delegate {
    [self stubInMobiNative];
    [ANAdAdapterBaseInMobi setInMobiAppID:@"0c4a211baa254c3ab8bfb7dee681a666"];
    ANNativeAdRequest *nativeAdRequest = [self nativeAdRequestWithDelegate:delegate];
    nativeAdRequest.shouldLoadIconImage = YES;
    nativeAdRequest.shouldLoadMainImage = YES;
    return nativeAdRequest;
}

- (void)stubInMobiNative {
    ANMediatedAd *mediatedAd = [[ANMediatedAd alloc] init];
    mediatedAd.className = @"ANAdAdapterNativeInMobi";
    [self stubMediatedAd:mediatedAd];
}

#pragma mark - Vdopia

- (ANBannerAdView *)loadVdopiaBannerWithDelegate:(id<ANBannerAdViewDelegate>)delegate {
    [self stubVdopiaBanner];
    return [self bannerWithDelegate:delegate];
}

- (ANInterstitialAd *)loadVdopiaInterstitialWithDelegate:(id<ANInterstitialAdDelegate>)delegate {
    [self stubVdopiaInterstitial];
    return [self interstitialWithDelegate:delegate];
}

- (void)stubVdopiaBanner {
    ANMediatedAd *mediatedAd = [[ANMediatedAd alloc] init];
    mediatedAd.className = @"ANAdAdapterBannerVdopia";
    mediatedAd.width = @"320";
    mediatedAd.height = @"50";
    mediatedAd.adId = @"AX123";
    [self stubMediatedAd:mediatedAd];
}

- (void)stubVdopiaInterstitial {
    ANMediatedAd *mediatedAd = [[ANMediatedAd alloc] init];
    mediatedAd.className = @"ANAdAdapterInterstitialVdopia";
    mediatedAd.adId = @"AX123";
    [self stubMediatedAd:mediatedAd];
}

#pragma mark - AdColony

- (ANInterstitialAd *)loadAdColonyInterstitialWithDelegate:(id<ANInterstitialAdDelegate>)delegate {
    [self stubAdColonyInterstitial];
    static dispatch_once_t startToken;
    dispatch_once(&startToken, ^{
        [ANAdAdapterBaseAdColony configureWithAppID:@"appe1ba2960e786424bb5"
                                            zoneIDs:@[@"vzcc692652bbe74d4e92"]];
    });
    return [self interstitialWithDelegate:delegate];
}

- (void)stubAdColonyInterstitial {
    ANMediatedAd *mediatedAd = [[ANMediatedAd alloc] init];
    mediatedAd.className = @"ANAdAdapterInterstitialAdColony";
    mediatedAd.adId = @"vzcc692652bbe74d4e92";
    [self stubMediatedAd:mediatedAd];
}

- (ANNativeAdRequest *)loadAdColonyNativeWithDelegate:(id<ANNativeAdRequestDelegate>)delegate {
    [self stubAdColonyNative];
    static dispatch_once_t startToken;
    dispatch_once(&startToken, ^{
        [ANAdAdapterBaseAdColony configureWithAppID:@"app553a8f6740d84f3ba0"
                                            zoneIDs:@[@"vzee73d915bab747ee8a"]];
    });
    ANNativeAdRequest *nativeAdRequest = [self nativeAdRequestWithDelegate:delegate];
    nativeAdRequest.shouldLoadIconImage = YES;
    nativeAdRequest.shouldLoadMainImage = YES;
    return nativeAdRequest;
}

- (void)stubAdColonyNative {
    ANMediatedAd *mediatedAd = [[ANMediatedAd alloc] init];
    mediatedAd.className = @"ANAdAdapterNativeAdColony";
    mediatedAd.adId = @"vzee73d915bab747ee8a";
    [self stubMediatedAd:mediatedAd];
}

#pragma mark - Chartboost

- (ANInterstitialAd *)loadChartboostInterstitialWithDelegate:(id<ANInterstitialAdDelegate>)delegate {
    [self stubChartboostInterstitial];
    static dispatch_once_t startToken;
    dispatch_once(&startToken, ^{
       [ANAdAdapterBaseChartboost startWithAppId:@"552d680204b01658a177f467"
                                    appSignature:@"8051c2d6e6178ad46448e54460c255f04cfc50e0"];
    });
    ANInterstitialAd *interstitialAd = [[ANInterstitialAd alloc] initWithPlacementId:@"2054679"];
    interstitialAd.delegate = delegate;
    [interstitialAd addCustomKeywordWithKey:kANAdAdapterBaseChartboostCBLocationKey
                                      value:CBLocationHomeScreen];
    [interstitialAd loadAd];
    return interstitialAd;
}

- (void)stubChartboostInterstitial {
    ANMediatedAd *mediatedAd = [[ANMediatedAd alloc] init];
    mediatedAd.className = @"ANAdAdapterInterstitialChartboost";
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

#pragma mark - ANNativeAdRequestDelegate

- (void)adRequest:(ANNativeAdRequest *)request didReceiveResponse:(ANNativeAdResponse *)response {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    self.nativeAdResponse = response;
    [self createMainImageNativeView];
    [self populateNativeViewWithResponse];
    [self registerNativeView];
    [self addNativeViewToViewHierarchy];
    [self.activityIndicator stopAnimating];
}

- (void)adRequest:(ANNativeAdRequest *)request didFailToLoadWithError:(NSError *)error {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self.activityIndicator stopAnimating];
}


#pragma mark - ANAdProtocol/ANNativeAdDelegate

- (void)adWasClicked:(id)ad {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)adWillPresent:(id)ad {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)adDidPresent:(id)ad {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)adWillClose:(id)ad {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)adDidClose:(id)ad {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)adWillLeaveApplication:(id)ad {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

#pragma mark - Native

- (void)createMainImageNativeView {
    if (self.nativeAdResponse.networkCode == ANNativeAdNetworkCodeAdColony) {
        AdColonyNativeAdView *videoView = (AdColonyNativeAdView *)self.nativeAdResponse.customElements[kANAdAdapterNativeAdColonyVideoView];
        self.adColonyView = [[ANNativeAdColonyView alloc] initWithNativeAdView:videoView
                                                                         frame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 480)];
    } else {
        UINib *adNib = [UINib nibWithNibName:@"ANNativeAdViewMainImage" bundle:[NSBundle bundleForClass:[self class]]];
        NSArray *array = [adNib instantiateWithOwner:self options:nil];
        self.nativeAdView = [array firstObject];
    }
}

- (void)populateNativeViewWithResponse {
    ANNativeAdView *nativeAdView = self.nativeAdView;
    if (self.nativeAdResponse.networkCode != ANNativeAdNetworkCodeAdColony) {
        nativeAdView.iconImageView.image = self.nativeAdResponse.iconImage;
        nativeAdView.titleLabel.text = self.nativeAdResponse.title;
        nativeAdView.bodyLabel.text = self.nativeAdResponse.body;
        nativeAdView.mainImageView.image = self.nativeAdResponse.mainImage;
        [nativeAdView.callToActionButton setTitle:self.nativeAdResponse.callToAction forState:UIControlStateNormal];
    }
}

- (void)registerNativeView {
    NSError *registerError;
    UIViewController *rvc = [UIApplication sharedApplication].keyWindow.rootViewController;
    self.nativeAdResponse.delegate = self;
    if (self.nativeAdResponse.networkCode == ANNativeAdNetworkCodeAdColony) {
        [self.nativeAdResponse registerViewForTracking:self.adColonyView
                                withRootViewController:rvc
                                        clickableViews:nil
                                                 error:&registerError];
    } else {
        [self.nativeAdResponse registerViewForTracking:self.nativeAdView
                                withRootViewController:rvc
                                        clickableViews:@[self.nativeAdView.callToActionButton]
                                                 error:&registerError];
    }
}

- (void)addNativeViewToViewHierarchy {
    if (self.nativeAdResponse.networkCode == ANNativeAdNetworkCodeAdColony) {
        CGSize fittingSize = [self.adColonyView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        self.adColonyView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), fittingSize.height);
        [self.view addSubview:self.adColonyView];
    } else {
        [self.view addSubview:self.nativeAdView];
    }
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

- (ANNativeAdRequest *)nativeAdRequestWithDelegate:(id<ANNativeAdRequestDelegate>)delegate {
    ANNativeAdRequest *nativeAdRequest = [[ANNativeAdRequest alloc] init];
    nativeAdRequest.delegate = self;
    [nativeAdRequest loadAd];
    return nativeAdRequest;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end