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
        [self.view addSubview:self.nativeContainer];
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
        [self.view addSubview:self.nativeContainer];
        [response registerViewForTracking:self.nativeContainer withRootViewController:self clickableViews:@[callToAction] error:nil];
    }
}

- (void)adRequest:(ANNativeAdRequest *)request didFailToLoadWithError:(NSError *)error
{
    NSLog(@"Native ad request failed: %@", error);
}
@end
