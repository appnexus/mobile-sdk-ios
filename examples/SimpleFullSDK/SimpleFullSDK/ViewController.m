//
//  ViewController.m
//  SimpleFullSDK
//
//  Created by Wei Zhang on 6/10/19.
//  Copyright © 2019 AppNexus. All rights reserved.
//

#import "ViewController.h"
#import <AppNexusSDK/AppNexusSDK.h>
#import <GoogleMobileAds/GADMobileAds.h>

@interface ViewController () <ANNativeAdRequestDelegate,
                                ANBannerAdViewDelegate,
                                ANInterstitialAdDelegate,
                                ANInstreamVideoAdLoadDelegate,
                                ANInstreamVideoAdPlayDelegate,
                                UIPickerViewDelegate,
                                UIPickerViewDataSource>
@property UIView *adHolder;
@property CGFloat screenWidth;
@property CGFloat screenHeight;
@property NSArray *testNames;
// To hold references
@property ANNativeAdRequest* nativeAdRequest;
@property ANInterstitialAd *intersititial;
@property ANInstreamVideoAd *videoAd;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGSize screenSize = screenBound.size;
    self.screenWidth = screenSize.width;
    self.screenHeight = screenSize.height;
    // Do any additional setup after loading the view.
    ANSDKSettings.sharedInstance.HTTPSEnabled=NO;
    [ANLogManager setANLogLevel:ANLogLevelAll];
    self.adHolder = [[UIView alloc] initWithFrame:CGRectMake(0, 50, self.screenWidth, self.screenHeight-150)];
    [self.view addSubview:self.adHolder];
    UIPickerView *testPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, self.screenHeight-100, self.screenWidth, 100)];
    testPicker.delegate = self;
    testPicker.dataSource = self;
    [self.view addSubview:testPicker];
    self.testNames = @[@"Empty",
                       @"NativeRTBOnlyResponse",
                       @"NativeCSMFailsThenRTBAd",
                       @"NativeCSMPassesDoNotShowRTBAd",
                       @"NativeTwoCSMsFirstFailsSecondsShows",
                       @"NativeTwoCSMsBothFailsNoAd",
                       @"NativeTwoCSMsFirstShowsDoNotMediateSecond",
                       @"BannerRTBOnlyResponse",
                       @"BannerCSMFailsThenRTBResponse",
                       @"BannerCSMPassesWithRTBResponse",
                       @"BannerTwoCSMFirstFailsSecondShows",
                       @"BannerTwoCSMsBothFailNoAd",
                       @"BannerTwoCSMsFirstShowsDoNotMediateSecond",
                       @"InterstitialRTBOnlyResponse",
                       @"InterstitialCSMFailsThenRTBResponse",
                       @"InterstitialCSMPassesWithRTBResponse",
                       @"InterstitialTwoCSMFirstFailsSecondShows",
                       @"InterstitialTwoCSMsBothFailNoAd",
                       @"InterstitialTwoCSMsFirstShowsDoNotMediateSecond",
                       @"VideoRTBResponseOnly",
                       @"VideoCSMFailsThenRTBResponse",
                       @"VideoCSMPassesWithRTBResponse",
                       @"VideoTwoCSMFirstFailsSecondShows",
                       @"VideoTwoCSMsBothFailNoAd",
                       @"VideoTwoCSMsFirstShowsDoNotMediateSecond"];
    [ANLogManager setANLogLevel:ANLogLevelDebug];
}

- (void)removePreviousAds{
    if (self.adHolder != nil) {
        for (UIView *view in self.adHolder.subviews) {
            [view removeFromSuperview];
        }
    }
}

#pragma mark Test Picker Delegate & Source
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.testNames.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    return self.testNames[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self removePreviousAds];
    switch (row) {
        case 0:
            // Empty Case
            break;
        case 1:
            // @"NativeRTBOnlyResponse"
            [self loadNativeWithPlacementId:@"16170363"];
            break;
        case 2:
            // @"NativeCSMFailsThenRTBAd"
            [self loadNativeWithPlacementId:@"16173152"];
            break;
        case 3:
            // @"NativeCSMPassesDoNotShowRTBAd"
            [self loadNativeWithPlacementId:@"16173161"];
            break;
        case 4:
            // @"NativeTwoCSMsFirstFailsSecondsShows"
            [self loadNativeWithPlacementId:@"16187339"];
            break;
        case 5:
            // @"NativeTwoCSMsBothFailsNoAd"
            [self loadNativeWithPlacementId:@"16187341"];
            break;
        case 6:
            // @"NativeTwoCSMsFirstShowsDoNotMediateSecond"
            [self loadNativeWithPlacementId:@"16187345"];
            break;
        case 7:
            [self loadBannerWithPlacementId:@"16187447"];
            break;
        case 8:
            [self loadBannerWithPlacementId:@"16189698"];
            break;
        case 9:
            [self loadBannerWithPlacementId:@"16189703"];
            break;
        case 10:
            [self loadBannerWithPlacementId:@"16189705"];
            break;
        case 11:
            [self loadBannerWithPlacementId:@"16189708"];
            break;
        case 12:
            [self loadBannerWithPlacementId:@"16189709"];
            break;
        case 13:
            [self loadInterstitialWithPlacementId:@"16212038"];
            break;
        case 14:
            [self loadInterstitialWithPlacementId:@"16216280"];
            break;
        case 15:
            [self loadInterstitialWithPlacementId:@"16216418"];
            break;
        case 16:
            [self loadInterstitialWithPlacementId:@"16216647"];
            break;
        case 17:
            [self loadInterstitialWithPlacementId:@"16216794"];
            break;
        case 18:
            [self loadInterstitialWithPlacementId:@"16216966"];
            break;
        case 19:
            [self loadVideoWithPlacementId:@"16233195"];
            break;
        case 20:
            [self loadVideoWithPlacementId:@"16233494"];
            break;
        case 21:
            [self loadVideoWithPlacementId:@"16233498"];
            break;
        case 22:
            [self loadVideoWithPlacementId:@"16233499"];
            break;
        case 23:
            [self loadVideoWithPlacementId:@"16233504"];
            break;
        case 24:
            [self loadVideoWithPlacementId:@"16233507"];
            break;
    }
}

#pragma mark Native Code Section
- (void)loadNativeWithPlacementId:(NSString*)placementID{
    self.nativeAdRequest = [[ANNativeAdRequest alloc] init];
    self.nativeAdRequest.shouldLoadIconImage = YES;
    self.nativeAdRequest.shouldLoadMainImage = YES;
    self.nativeAdRequest.delegate = self;
    self.nativeAdRequest.placementId = placementID;
    [self.nativeAdRequest loadAd];
}

- (void)adRequest:(ANNativeAdRequest *)request didReceiveResponse:(ANNativeAdResponse *)response
{
    if (response.networkCode == ANNativeAdNetworkCodeAdMob) {
        UINib *adNib = [UINib nibWithNibName:@"UnifiedNativeAdView" bundle:[NSBundle bundleForClass:[self class]]];
        NSArray *array = [adNib instantiateWithOwner:self options:nil];
        GADUnifiedNativeAdView *nativeContainer = [array firstObject];
        
        ((UILabel *) nativeContainer.headlineView).text = response.title;
        
        ((UILabel *) nativeContainer.bodyView).text = response.body;
        
        
        [((UIButton *) nativeContainer.callToActionView) setTitle:response.callToAction
                                                                                        forState:UIControlStateNormal];
        
        ((UIImageView *) nativeContainer.iconView).image = response.iconImage;
        // Main Image is automatically added by GoogleSDK in the MediaView
        
        ((UILabel *) nativeContainer.advertiserView).text = response.sponsoredBy;
        [response registerViewForTracking:nativeContainer withRootViewController:self clickableViews:@[((GADUnifiedNativeAdView*)nativeContainer).callToActionView] error:nil];
        nativeContainer.frame = CGRectMake(0, 150, self.screenWidth, 300);
        [self.adHolder addSubview:nativeContainer];
    } else {
        UIView *nativeContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 150, self.screenWidth, 400)];
        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        icon.image = response.iconImage;
        [nativeContainer addSubview:icon];
        UITextView *title = [[UITextView alloc] initWithFrame:CGRectMake(50, 0, self.screenWidth -50, 50)];
        [title setFont:[UIFont systemFontOfSize:18]];
        title.text = response.title;
        [nativeContainer addSubview:title];
        CGFloat width = response.mainImageSize.width * 250 / response.mainImageSize.height;
        UIImageView *mainImage = [[UIImageView alloc] initWithFrame:CGRectMake((self.screenWidth - width)/2, 50, width, 250)];
        mainImage.image = response.mainImage;
        [nativeContainer addSubview:mainImage];
        UITextView *body = [[UITextView alloc] initWithFrame:CGRectMake(0, 300, self.screenWidth, 80)];
        body.text = response.body;
        [body setFont:[UIFont systemFontOfSize:15]];
        [nativeContainer addSubview:body];
        UIButton *callToAction = [[UIButton alloc] initWithFrame:CGRectMake(0, 380, self.screenWidth, 20)];
        [callToAction setTitle:response.callToAction forState:UIControlStateNormal];
        [callToAction setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [nativeContainer addSubview:callToAction];
        [self.adHolder addSubview:nativeContainer];
        [response registerViewForTracking:nativeContainer withRootViewController:self clickableViews:@[callToAction] error:nil];
    }
}

- (void)adRequest:(ANNativeAdRequest *)request didFailToLoadWithError:(NSError *)error
{
    UIView *nativeContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 150, self.screenWidth, 400)];
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.screenWidth, 400)];
    textView.text = [NSString stringWithFormat:@"No ad because of %@", error];
    [nativeContainer addSubview:textView];
    [self.adHolder addSubview:nativeContainer];
}

#pragma mark Banner Code Section
- (void)loadBannerWithPlacementId:(NSString*)placementID{
    // Do any additional setup after loading the view.
    int adWidth  = 300;
    int adHeight = 250;
    NSString *adID = placementID;
    
    // We want to center our ad on the screen.
    CGFloat adHolderWidth = self.screenWidth;
    CGFloat adHolderHeight = self.screenHeight - 150;
    CGFloat originX = (adHolderWidth / 2) - (adWidth / 2);
    CGFloat originY = (adHolderHeight / 2) - (adHeight / 2);
    
    // Needed for when we create our ad view.
    CGRect rect = CGRectMake(originX, originY, adWidth, adHeight);
    CGSize size = CGSizeMake(adWidth, adHeight);
    
    // Make a banner ad view.
    ANBannerAdView *banner = [ANBannerAdView adViewWithFrame:rect placementId:adID adSize:size];
    banner.externalUid = @"123e4567e89b12da456426655440000";
    banner.rootViewController = self;
    banner.delegate = self;
    banner.clickThroughAction = ANClickThroughActionReturnURL;
    banner.autoRefreshInterval = 0;
    [self.adHolder addSubview:banner];
    [banner loadAd];
}

- (void)adDidReceiveAd:(id)ad {
    if([[ad class] isEqual:[ANBannerAdView class]]){
        NSLog(@"Banner placement %@ did receive ad",((ANBannerAdView *)ad).placementId);
    } else if ([[ad class] isEqual:[ANInterstitialAd class]]){
        [((ANInterstitialAd *)ad) displayAdFromViewController:self];
    } else if ([[ad class] isEqual:[ANInstreamVideoAd class]]){
        [((ANInstreamVideoAd *)ad) playAdWithContainer:self.adHolder withDelegate:self];
    }
}


- (void)adDidClose:(id)ad {
    NSLog(@"Ad did close");
}

- (void)adWasClicked:(id)ad {
    NSLog(@"Ad was clicked");
}

- (void)adWasClicked:(id)ad withURLString:(NSString *)urlString
{
    NSLog(@"Ad was clicked with url: %@", urlString);
}


- (void)ad:(id)ad requestFailedWithError:(NSError *)error {
    NSLog(@"Ad failed to load because of %@", error);
}

#pragma mark Intersitital Code Section
- (void)loadInterstitialWithPlacementId: (NSString*) placementID
{
    self.intersititial = [[ANInterstitialAd alloc] initWithPlacementId:placementID];
    self.intersititial.closeDelay = 0;
    self.intersititial.delegate = self;
    [self.intersititial loadAd];
}

#pragma mark Video Code Section
-(void) loadVideoWithPlacementId: (NSString *) placementID
{
    self.videoAd = [[ANInstreamVideoAd alloc] initWithPlacementId:placementID];
    [self.videoAd loadAdWithDelegate:self];
}

- (void)adCompletedMidQuartile:(id<ANAdProtocol>)ad
{
    NSLog(@"Video ad completed mid quartile");
}

- (void)adCompletedFirstQuartile:(id<ANAdProtocol>)ad
{
    NSLog(@"Video ad completed first quartile");
}

- (void)adCompletedThirdQuartile:(id<ANAdProtocol>)ad
{
    NSLog(@"Video ad completed third quartile");
}

- (void)adDidComplete:(id<ANAdProtocol>)ad withState:(ANInstreamVideoPlaybackStateType)state
{
    NSLog(@"Video ad completed.");
}
@end
