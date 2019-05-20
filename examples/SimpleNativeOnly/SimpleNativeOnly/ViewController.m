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


@interface ViewController () <ANNativeAdRequestDelegate>
@property (nonatomic,readwrite,strong) ANNativeAdRequest *nativeAdRequest;
@property UIView *nativeContainer;
@property CGFloat screenWidth;
@property CGFloat screenHeight;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGSize screenSize = screenBound.size;
    self.screenWidth = screenSize.width;
    self.screenHeight = screenSize.height;
    // Do any additional setup after loading the view.
    ANSDKSettings.sharedInstance.HTTPSEnabled=YES;
    [ANLogManager setANLogLevel:ANLogLevelAll];
    UIView *buttonHolder = [[UIView alloc] initWithFrame:CGRectMake(0, 100, self.screenWidth, 50)];
    UIButton *rtbButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.screenWidth/2, 50)];
    [rtbButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [rtbButton setTitle:@"RTB ad" forState:UIControlStateNormal];
    [rtbButton addTarget:self action:@selector(rtbPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIButton *admobButton = [[UIButton alloc] initWithFrame:CGRectMake(self.screenWidth/2, 0, self.screenWidth/2, 50)];
    [admobButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [admobButton setTitle:@"AdMob ad" forState:UIControlStateNormal];
    [admobButton addTarget:self action:@selector(admobPressed:) forControlEvents:UIControlEventTouchUpInside];
    [buttonHolder addSubview:rtbButton];
    [buttonHolder addSubview:admobButton];
    [self.view addSubview:buttonHolder];
    self.nativeAdRequest = [[ANNativeAdRequest alloc] init];
    self.nativeAdRequest.gender = ANGenderMale;
    self.nativeAdRequest.shouldLoadIconImage = YES;
    self.nativeAdRequest.shouldLoadMainImage = YES;
    self.nativeAdRequest.delegate = self;
}

- (void)rtbPressed:(id)sender
{
    NSLog(@"RTB pressed");
    self.nativeAdRequest.placementId = @"13255429";
    [self.nativeAdRequest loadAd];
}

- (void)admobPressed:(id)sender
{
    NSLog(@"Admob pressed");
    self.nativeAdRequest.placementId = @"9505207";
    [self.nativeAdRequest loadAd];
}

- (void)adRequest:(ANNativeAdRequest *)request didReceiveResponse:(ANNativeAdResponse *)response
{
    if (self.nativeContainer != nil) {
        [self.nativeContainer removeFromSuperview];
    }
    if (response.networkCode == ANNativeAdNetworkCodeAdMob) {
        self.nativeContainer = [[GADUnifiedNativeAdView alloc] initWithFrame:CGRectMake(0, 150, 300, 400)];
        // TODO: display admob native ad programmatically
    } else {
        self.nativeContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 150, 300, 400)];
        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        icon.image = response.iconImage;
        [self.nativeContainer addSubview:icon];
        UITextView *title = [[UITextView alloc] initWithFrame:CGRectMake(50, 0, 300, 50)];
        [title setFont:[UIFont systemFontOfSize:18]];
        title.text = response.title;
        [self.nativeContainer addSubview:title];
        UIImageView *mainImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 50, 300, 250)];
        mainImage.image = response.mainImage;
        [self.nativeContainer addSubview:mainImage];
        UITextView *body = [[UITextView alloc] initWithFrame:CGRectMake(0, 300, 300, 80)];
        body.text = response.body;
        [body setFont:[UIFont systemFontOfSize:15]];
        [self.nativeContainer addSubview:body];
        UIButton *callToAction = [[UIButton alloc] initWithFrame:CGRectMake(0, 380, 300, 20)];
        [callToAction setTitle:response.callToAction forState:UIControlStateNormal];
        [callToAction setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self.nativeContainer addSubview:callToAction];
        [self.view addSubview:self.nativeContainer];
        [response registerViewForTracking:self.nativeContainer withRootViewController:self clickableViews:@[callToAction] error:nil];
    }
}

- (void)adRequest:(ANNativeAdRequest *)request didFailToLoadWithError:(NSError *)error
{
    NSLog(@"Native ad request failed: %@", error);
}

@end
