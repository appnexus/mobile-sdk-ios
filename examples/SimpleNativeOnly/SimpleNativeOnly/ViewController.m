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
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[GADMobileAds sharedInstance] startWithCompletionHandler:nil];
    // Do any additional setup after loading the view.
    ANSDKSettings.sharedInstance.HTTPSEnabled=YES;
    [ANLogManager setANLogLevel:ANLogLevelAll];
    
    self.nativeAdRequest= [[ANNativeAdRequest alloc] init];
    self.nativeAdRequest.placementId = @"9505207";
    self.nativeAdRequest.gender = ANGenderMale;
    self.nativeAdRequest.shouldLoadIconImage = YES;
    self.nativeAdRequest.shouldLoadMainImage = YES;
    self.nativeAdRequest.delegate = self;
    [self.nativeAdRequest loadAd];
}

- (void)adRequest:(ANNativeAdRequest *)request didReceiveResponse:(ANNativeAdResponse *)response
{
    UIView *nativeContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 100, 300, 400)];
    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    icon.image = response.iconImage;
    [nativeContainer addSubview:icon];
    UITextView *title = [[UITextView alloc] initWithFrame:CGRectMake(50, 0, 300, 50)];
    [title setFont:[UIFont systemFontOfSize:18]];
    title.text = response.title;
    [nativeContainer addSubview:title];
    UIImageView *mainImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 50, 300, 250)];
    mainImage.image = response.mainImage;
    [nativeContainer addSubview:mainImage];
    UITextView *body = [[UITextView alloc] initWithFrame:CGRectMake(0, 300, 300, 80)];
    body.text = response.body;
    [body setFont:[UIFont systemFontOfSize:15]];
    [nativeContainer addSubview:body];
    UIButton *callToAction = [[UIButton alloc] initWithFrame:CGRectMake(0, 380, 300, 20)];
    [callToAction setTitle:response.callToAction forState:UIControlStateNormal];
    [callToAction setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [nativeContainer addSubview:callToAction];
    [self.view addSubview:nativeContainer];
    [response registerViewForTracking:nativeContainer withRootViewController:self clickableViews:@[mainImage, callToAction] error:nil];

}

- (void)adRequest:(ANNativeAdRequest *)request didFailToLoadWithError:(NSError *)error
{
    NSLog(@"Native ad request failed: %@", error);
}

@end
