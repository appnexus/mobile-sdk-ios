//
//  ViewController.m
//  SimpleNativeOnly
//
//  Created by Wei Zhang on 5/20/19.
//  Copyright © 2019 AppNexus. All rights reserved.
//

#import "ViewController.h"
#import <AppNexusNativeSDK/AppNexusNativeSDK.h>
#import <GoogleMobileAds/GADMobileAds.h>


@interface ViewController () <ANNativeAdRequestDelegate, UIPickerViewDelegate,UIPickerViewDataSource>
@property (nonatomic,readwrite,strong) ANNativeAdRequest *nativeAdRequest;
@property UIView *adHolder;
@property UIView *nativeContainer;
@property CGFloat screenWidth;
@property CGFloat screenHeight;
@property NSArray *testNames;
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
                       @"RTB only response",
                       @"CSM fails then RTB ad",
                       @"CSM passes do not show RTB ad",
                       @"Two CSMs first fails seconds shows",
                       @"Two CSMs both fails no ad",
                       @"Two CSMs first shows do not mediate second"];
    self.nativeAdRequest = [[ANNativeAdRequest alloc] init];
    self.nativeAdRequest.gender = ANGenderMale;
    self.nativeAdRequest.shouldLoadIconImage = YES;
    self.nativeAdRequest.shouldLoadMainImage = YES;
    self.nativeAdRequest.delegate = self;
}

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
    if (self.nativeContainer != nil) {
        [self.nativeContainer removeFromSuperview];
    }
    switch (row) {
        case 0:
            // do nothing
            break;
        case 1:
            self.nativeAdRequest.placementId = @"16170363";
            [self.nativeAdRequest loadAd];
            break;
        case 2:
            self.nativeAdRequest.placementId = @"16173152";
            [self.nativeAdRequest loadAd];
            break;
        case 3:
            self.nativeAdRequest.placementId = @"16173161";
            [self.nativeAdRequest loadAd];
            break;
        case 4:
            self.nativeAdRequest.placementId = @"16187339";
            [self.nativeAdRequest loadAd];
            break;
        case 5:
            self.nativeAdRequest.placementId = @"16187341";
            [self.nativeAdRequest loadAd];
            break;
        case 6:
            self.nativeAdRequest.placementId = @"16187345";
            [self.nativeAdRequest loadAd];
            break;
        default:
            break;
    }
}

- (void)adRequest:(ANNativeAdRequest *)request didReceiveResponse:(ANNativeAdResponse *)response
{
    if (response.networkCode == ANNativeAdNetworkCodeAdMob) {
        UINib *adNib = [UINib nibWithNibName:@"UnifiedNativeAdView" bundle:[NSBundle bundleForClass:[self class]]];
        NSArray *array = [adNib instantiateWithOwner:self options:nil];
        self.nativeContainer = [array firstObject];
        
        ((UILabel *)((GADUnifiedNativeAdView*)self.nativeContainer).headlineView).text = response.title;

        ((UILabel *)((GADUnifiedNativeAdView*)self.nativeContainer).bodyView).text = response.body;


        [((UIButton *)((GADUnifiedNativeAdView*)self.nativeContainer).callToActionView) setTitle:response.callToAction
                                                     forState:UIControlStateNormal];

        ((UIImageView *)((GADUnifiedNativeAdView*)self.nativeContainer).iconView).image = response.iconImage;
        // Main Image is automatically added by GoogleSDK in the MediaView

        ((UILabel *)((GADUnifiedNativeAdView*)self.nativeContainer).advertiserView).text = response.sponsoredBy;
        [response registerViewForTracking:self.nativeContainer withRootViewController:self clickableViews:@[((GADUnifiedNativeAdView*)self.nativeContainer).callToActionView] error:nil];
        self.nativeContainer.frame = CGRectMake(0, 150, self.screenWidth, 300);
        [self.adHolder addSubview:self.nativeContainer];
    } else {
        self.nativeContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 150, self.screenWidth, 400)];
        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        icon.image = response.iconImage;
        [self.nativeContainer addSubview:icon];
        UITextView *title = [[UITextView alloc] initWithFrame:CGRectMake(50, 0, self.screenWidth -50, 50)];
        [title setFont:[UIFont systemFontOfSize:18]];
        title.text = response.title;
        [self.nativeContainer addSubview:title];
        CGFloat width = response.mainImageSize.width * 250 / response.mainImageSize.height;
        UIImageView *mainImage = [[UIImageView alloc] initWithFrame:CGRectMake((self.screenWidth - width)/2, 50, width, 250)];
        mainImage.image = response.mainImage;
        [self.nativeContainer addSubview:mainImage];
        UITextView *body = [[UITextView alloc] initWithFrame:CGRectMake(0, 300, self.screenWidth, 80)];
        body.text = response.body;
        [body setFont:[UIFont systemFontOfSize:15]];
        [self.nativeContainer addSubview:body];
        UIButton *callToAction = [[UIButton alloc] initWithFrame:CGRectMake(0, 380, self.screenWidth, 20)];
        [callToAction setTitle:response.callToAction forState:UIControlStateNormal];
        [callToAction setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self.nativeContainer addSubview:callToAction];
        [self.adHolder addSubview:self.nativeContainer];
        [response registerViewForTracking:self.nativeContainer withRootViewController:self clickableViews:@[callToAction] error:nil];
    }
}

- (void)adRequest:(ANNativeAdRequest *)request didFailToLoadWithError:(NSError *)error
{
   self.nativeContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 150, self.screenWidth, 400)];
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.screenWidth, 400)];
    textView.text = [NSString stringWithFormat:@"No ad because of %@", error];
    [self.nativeContainer addSubview:textView];
    [self.adHolder addSubview:self.nativeContainer];
}
@end
