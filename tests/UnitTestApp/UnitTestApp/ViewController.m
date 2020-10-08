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

#import "ViewController.h"
#import "ANBannerAdView.h"
#import "ANSDKSettings.h"
#import <CoreLocation/CoreLocation.h>
#import "ANInterstitialAd.h"
#import "ANMediatedAd.h"
#import "ANURLConnectionStub.h"
#import "ANHTTPStubbingManager.h"
#import "ANLogManager.h"
#import "ANNativeAdRequest.h"
#import "ANNativeAdView.h"
#import "ANGADUnifiedNativeAdView.h"
#import "ANAdAdapterNativeAdMob.h"
#import "UIView+ANCategory.h"
#import "ANGlobal.h"
@class UITestViewController;

@interface ViewController ()< CLLocationManagerDelegate , ANBannerAdViewDelegate, ANInterstitialAdDelegate, ANNativeAdRequestDelegate, ANNativeAdDelegate>
@property (nonatomic, readwrite, strong) CLLocationManager *locationManager;

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic) ANInterstitialAd *interstitialAd;
@property (nonatomic, weak) ANBannerAdView *bannerAdView;
@property (nonatomic) ANNativeAdRequest *nativeAdRequest;
@property (nonatomic) ANNativeAdResponse *nativeAdResponse;
@property (nonatomic) ANNativeAdView *nativeAdView;
@property (nonatomic) ANGADUnifiedNativeAdView *gadUnifiedNativeAdView;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self hideStatusBar];
    
}
- (void)viewDidAppear:(BOOL)animated{
    NSArray *processList = [[NSProcessInfo processInfo] arguments];
    if([processList containsObject:@"FunctionalUITest"]){
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FunctionalUITest" bundle:nil];
        UIViewController *uiTestVC =
        [storyboard instantiateViewControllerWithIdentifier:@"BannerAdFunctionalViewController"];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:uiTestVC];
        navController.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:navController animated:YES completion:nil];
    }else if([processList containsObject:@"FunctionalUITestClickThru"]){
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FunctionalUITest" bundle:nil];
        UIViewController *uiTestVC =
        [storyboard instantiateViewControllerWithIdentifier:@"BannerAdClickThruViewController"];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:uiTestVC];
        navController.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:navController animated:YES completion:nil];
    }else{
        [self locationSetup]; // If you want to pass location...
    }
    
}

- (void)locationSetup {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        [self.locationManager requestWhenInUseAuthorization];
    
    [self.locationManager startUpdatingLocation];
    
}
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    CLLocation* location = [locations lastObject];
    NSLog(@"NewLocation %f %f", location.coordinate.latitude, location.coordinate.longitude);
}

- (void)hideStatusBar {
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self setNeedsStatusBarAppearanceUpdate];
    } else {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    }
}

+ (NSArray *)networks {
    return @[@"AdMobNative",
             @"AdMarvelBanner",
             @"AdMarvelInterstitial",
             @"YahooNative",
             @"YahooBanner",
             @"YahooInterstitial",
             @"VdopiaBanner",
             @"VdopiaInterstitial",
             @"AdColonyInterstitial",
             @"VungleInterstitial",
             @"ChartboostInterstitial",
             @"AdMobBanner",
             @"AdMobInterstitial",
             @"DFPBanner",
             @"DFPSmartBanner",
             @"DFPInterstitial",
             @"DoesNotExistBanner",
             @"DoesNotExistInterstitial"];
}

- (void)clearCurrentAd {
    [self.bannerAdView removeFromSuperview];
    self.interstitialAd = nil;
    [self.nativeAdView removeFromSuperview];
    self.nativeAdView = nil;
    self.nativeAdResponse = nil;
    [self.gadUnifiedNativeAdView removeFromSuperview];
    self.gadUnifiedNativeAdView = nil;
}

#pragma mark - Ad Mob

- (ANBannerAdView *)loadAdMobBannerWithDelegate:(id<ANBannerAdViewDelegate>)delegate {
    [self stubAdMobBanner];
    return [self bannerWithDelegate:delegate];
}

- (ANBannerAdView *)loadAdMobBannerResizeWithDelegate:(id<ANBannerAdViewDelegate>)delegate shouldResize:(BOOL)resize {
    [self stubAdMobBanner];
    return [self bannerResizeWithDelegate:delegate shouldResize:resize];
}


- (ANInterstitialAd *)loadAdMobInterstitialWithDelegate:(id<ANInterstitialAdDelegate>)delegate {
    [self stubAdMobInterstitial];
    return [self interstitialWithDelegate:delegate];
}

- (ANNativeAdRequest *)loadAdMobNativeWithDelegate:(id<ANNativeAdRequestDelegate>)delegate {
    [self stubAdMobNative];
    // [ANAdAdapterNativeAdMob enableNativeAppInstallAds];
    // [ANAdAdapterNativeAdMob enableNativeContentAds];
    ANNativeAdRequest *nativeAdRequest = [self nativeAdRequestWithDelegate:delegate];
    nativeAdRequest.shouldLoadIconImage = YES;
    nativeAdRequest.shouldLoadMainImage = YES;
    return nativeAdRequest;
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

- (void)stubAdMobNative {
    ANMediatedAd *mediatedAd = [[ANMediatedAd alloc] init];
    mediatedAd.className = @"ANAdAdapterNativeAdMob";
    mediatedAd.adId = @"ca-app-pub-3940256099942544/3986624511";
    [self stubMediatedAd:mediatedAd];
}

#pragma mark - DFP

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
    mediatedAd.adId = @"/6499/example/interstitial";
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
    switch (self.nativeAdResponse.networkCode) {
        case ANNativeAdNetworkCodeAdMob: {
            UINib *adNib;
            adNib = [UINib nibWithNibName:@"ANGADUnifiedNativeAdView"
                                   bundle:[NSBundle bundleForClass:[self class]]];
            NSArray *array = [adNib instantiateWithOwner:self
                                                 options:nil];
            self.gadUnifiedNativeAdView = [array firstObject];
            break;
            return;
        }
        default: {
            UINib *adNib = [UINib nibWithNibName:@"ANNativeAdViewMainImage"
                                          bundle:[NSBundle bundleForClass:[self class]]];
            NSArray *array = [adNib instantiateWithOwner:self
                                                 options:nil];
            self.nativeAdView = [array firstObject];
            return;
        }
    }
}

- (void)populateNativeViewWithResponse {
    switch (self.nativeAdResponse.networkCode) {
        case ANNativeAdNetworkCodeAdMob: {
            if (self.gadUnifiedNativeAdView) {
                ((UIImageView *)self.gadUnifiedNativeAdView.iconView).image = self.nativeAdResponse.iconImage;
                ((UIImageView *)self.gadUnifiedNativeAdView.imageView).image = self.nativeAdResponse.mainImage;
                ((UILabel *)self.gadUnifiedNativeAdView.headlineView).text = self.nativeAdResponse.title;
                ((UILabel *)self.gadUnifiedNativeAdView.bodyView).text = self.nativeAdResponse.body;
                [((UIButton *)self.gadUnifiedNativeAdView.callToActionView) setTitle:self.nativeAdResponse.callToAction
                                                                            forState:UIControlStateNormal];
            }
            return;
        }
        default: {
            ANNativeAdView *nativeAdView = self.nativeAdView;
            nativeAdView.iconImageView.image = self.nativeAdResponse.iconImage;
            nativeAdView.titleLabel.text = self.nativeAdResponse.title;
            nativeAdView.bodyLabel.text = self.nativeAdResponse.body;
            nativeAdView.mainImageView.image = self.nativeAdResponse.mainImage;
            [nativeAdView.callToActionButton setTitle:self.nativeAdResponse.callToAction
                                             forState:UIControlStateNormal];
            return;
        }
    }
}

- (void)registerNativeView {
    NSError *registerError;
    UIViewController *rvc = [ANGlobal getKeyWindow].rootViewController;
    self.nativeAdResponse.delegate = self;
    switch (self.nativeAdResponse.networkCode) {
        case ANNativeAdNetworkCodeAdMob:
            if (self.gadUnifiedNativeAdView) {
                [self.nativeAdResponse registerViewForTracking:self.gadUnifiedNativeAdView
                                        withRootViewController:rvc
                                                clickableViews:nil
                                                         error:&registerError];
            }
            return;
        default:
            [self.nativeAdResponse registerViewForTracking:self.nativeAdView
                                    withRootViewController:rvc
                                            clickableViews:@[self.nativeAdView.callToActionButton]
                                                     error:&registerError];
            return;
    }
}

- (void)addNativeViewToViewHierarchy {
    switch (self.nativeAdResponse.networkCode) {
        case ANNativeAdNetworkCodeAdMob: {
            UIView *nativeAdView;
            if (self.gadUnifiedNativeAdView) {
                nativeAdView = self.gadUnifiedNativeAdView;
            }
            nativeAdView.translatesAutoresizingMaskIntoConstraints = NO;
            [nativeAdView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[nativeAdView(==320)]"
                                                                                 options:kNilOptions
                                                                                 metrics:nil
                                                                                   views:@{@"nativeAdView":nativeAdView}]];
            CGSize fittingSize = [nativeAdView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
            [nativeAdView an_constrainWithSize:fittingSize];
            [self.view addSubview:nativeAdView];
            [nativeAdView an_alignToSuperviewWithXAttribute:NSLayoutAttributeCenterX
                                                 yAttribute:NSLayoutAttributeTop];
            return;
        }
        default:
            [self.view addSubview:self.nativeAdView];
            return;
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
    stub.requestURL = @"https://mediation.adnxs.com/ut/v3";
    stub.responseCode = 200;
    stub.responseBody = [mutableBaseResponse copy];
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    [[ANHTTPStubbingManager sharedStubbingManager] addStub:stub];
    
}


- (ANBannerAdView *)bannerResizeWithDelegate:(id<ANBannerAdViewDelegate>)delegate shouldResize:(BOOL)resize {
    
    ANBannerAdView *bannerAdView = [[ANBannerAdView alloc] initWithFrame:CGRectMake(10, 70, 400, 100)
                                                             placementId:@"2054679"
                                                                  adSize:CGSizeMake(320, 50)];
    bannerAdView.rootViewController = self;
    bannerAdView.backgroundColor = [UIColor blackColor];
    bannerAdView.shouldResizeAdToFitContainer = resize;
    [self.view addSubview:bannerAdView];
    [bannerAdView an_alignToSuperviewWithXAttribute:NSLayoutAttributeCenterX yAttribute:NSLayoutAttributeCenterY];
    [bannerAdView loadAd];
    bannerAdView.delegate = delegate;
    bannerAdView.autoRefreshInterval = 0;
    return bannerAdView;
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
    bannerAdView.translatesAutoresizingMaskIntoConstraints = NO;
    [bannerAdView an_constrainWithSize:CGSizeMake(320, 50)];
    [bannerAdView an_alignToSuperviewWithXAttribute:NSLayoutAttributeCenterX yAttribute:NSLayoutAttributeCenterY];
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

#if __IPHONE_9_0
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
#else
    - (NSUInteger)supportedInterfaceOrientations {
#endif
        return UIInterfaceOrientationMaskAll;
    }
    
    @end
