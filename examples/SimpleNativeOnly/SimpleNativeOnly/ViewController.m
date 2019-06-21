//
//  ViewController.m
//  SimpleNativeOnly
//
//  Created by Wei Zhang on 5/20/19.
//  Copyright © 2019 AppNexus. All rights reserved.
//

#import "ViewController.h"
@import AppNexusNativeSDK;
@import FBAudienceNetwork;

@interface ViewController () <ANNativeAdRequestDelegate, UIPickerViewDelegate,UIPickerViewDataSource>
@property (nonatomic,readwrite,strong) ANNativeAdRequest *nativeAdRequest;
@property UIView *adHolder;
@property ANNativeAdResponse *reponse;
@property CGFloat screenWidth;
@property CGFloat screenHeight;
@property NSArray *testNames;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
#if DEBUG >= 1
    [FBAdSettings setLogLevel:FBAdLogLevelLog];
    [FBAdSettings addTestDevice:[FBAdSettings testDeviceHash]];
#endif
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
                       @"Facebook CSM"];
    self.nativeAdRequest = [[ANNativeAdRequest alloc] init];
    self.nativeAdRequest.gender = ANGenderMale;
    self.nativeAdRequest.shouldLoadIconImage = YES;
    self.nativeAdRequest.shouldLoadMainImage = YES;
    self.nativeAdRequest.delegate = self;
}

- (void)removePreviousAds{
    if (self.adHolder != nil) {
        for (UIView *view in self.adHolder.subviews) {
            [view removeFromSuperview];
        }
    }
    self.reponse = nil;
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
    [self removePreviousAds];
    switch (row) {
        case 0:
            // do nothing
            break;
        case 1:
            self.nativeAdRequest.placementId = @"16170363";
            [self.nativeAdRequest loadAd];
            break;
        case 2:
            self.nativeAdRequest.placementId = @"16268678";
            [self.nativeAdRequest loadAd];
            break;
        default:
            break;
    }
}

- (void)adRequest:(ANNativeAdRequest *)request didReceiveResponse:(ANNativeAdResponse *)response
{
    self.reponse = response; // keep a reference for views to be clickable
    if (response.networkCode == ANNativeAdNetworkCodeFacebook) {
        FBNativeAd *nativeAd = (FBNativeAd *) response.customElements[kANNativeElementObject];
        UIView *nativeContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 150, self.screenWidth, 400)];
        FBMediaView *icon = [[FBMediaView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        [nativeContainer addSubview:icon];
        UITextView *title = [[UITextView alloc] initWithFrame:CGRectMake(50, 0, self.screenWidth -50, 50)];
        [title setFont:[UIFont systemFontOfSize:18]];
        title.text = nativeAd.advertiserName;
        [nativeContainer addSubview:title];
        CGFloat mainMediaWidth = 300;
        CGFloat mainMediaHeight = 300 / nativeAd.aspectRatio;
        FBMediaView *mainImage = [[FBMediaView alloc] initWithFrame:CGRectMake((self.screenWidth - mainMediaWidth)/2, 50, mainMediaWidth, mainMediaHeight)];
        [nativeContainer addSubview:mainImage];
        UITextView *body = [[UITextView alloc] initWithFrame:CGRectMake(0, 50 + mainMediaHeight, self.screenWidth, 80)];
        body.text = nativeAd.bodyText;
        [body setFont:[UIFont systemFontOfSize:15]];
        [nativeContainer addSubview:body];
        UIButton *callToAction = [[UIButton alloc] initWithFrame:CGRectMake(0, 50 + mainMediaHeight +80, self.screenWidth, 20)];
        [callToAction setTitle:nativeAd.callToAction forState:UIControlStateNormal];
        [callToAction setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [nativeContainer addSubview:callToAction];
        [self.adHolder addSubview:nativeContainer];
        [nativeAd registerViewForInteraction:nativeContainer mediaView:mainImage iconView:icon viewController:self clickableViews:@[callToAction]];
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
@end
