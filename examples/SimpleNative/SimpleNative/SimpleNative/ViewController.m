/*   Copyright 2019 APPNEXUS INC
 
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
#import <AppNexusNativeSDK/ANNativeAdRequest.h>
#import <AppNexusNativeSDK/AppNexusNativeSDK.h>
#import <AppNexusNativeSDK/ANMultiAdRequest.h>
#import "ANNativeAdView.h"

@interface ViewController () <ANNativeAdRequestDelegate,ANNativeAdDelegate, ANMultiAdRequestDelegate>
@property (nonatomic,readwrite,strong) ANNativeAdRequest *nativeAdRequest;
@property (nonatomic,readwrite,strong) ANNativeAdResponse *nativeAdResponse;
@property (nonatomic,readwrite,strong) ANNativeAdRequest *nativeAdRequest2;
@property (nonatomic,readwrite,strong) ANNativeAdResponse *nativeAdResponse2;
@property (nonatomic, readwrite,strong) ANMultiAdRequest *multiRequest;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    ANSDKSettings.sharedInstance.HTTPSEnabled=YES;
    [ANLogManager setANLogLevel:ANLogLevelAll];
    
    self.multiRequest = [[ANMultiAdRequest alloc] initWithMemberId:10094 andDelegate:self];
    
   
    self.nativeAdRequest= [[ANNativeAdRequest alloc] init];
    self.nativeAdRequest.placementId = @"14361525";
    self.nativeAdRequest.gender = ANGenderMale;
    self.nativeAdRequest.shouldLoadIconImage = YES;
    self.nativeAdRequest.shouldLoadMainImage = YES;
    self.nativeAdRequest.delegate = self;
    [self.multiRequest addAdUnit:self.nativeAdRequest];
    
    
    self.nativeAdRequest2= [[ANNativeAdRequest alloc] init];
    self.nativeAdRequest2.placementId = @"14361525";
    self.nativeAdRequest2.gender = ANGenderMale;
    self.nativeAdRequest2.shouldLoadIconImage = YES;
    self.nativeAdRequest2.shouldLoadMainImage = YES;
    self.nativeAdRequest2.delegate = self;
    
    
    [self.multiRequest addAdUnit:self.nativeAdRequest2];
    [self.multiRequest load];
}


- (void) multiAdRequestDidComplete:(nonnull ANMultiAdRequest *)MulitAdRequest {
    ANLogDebug(@"request complete");
}

- (void)adRequest:(ANNativeAdRequest *)request didFailToLoadWithError:(NSError *)error {
    
}


- (void)adRequest:(ANNativeAdRequest *)request didReceiveResponse:(ANNativeAdResponse *)response {
    
    if(request== self.nativeAdRequest){
    // (code which loads the view)
    self.nativeAdResponse = response;
    
    UINib *adNib = [UINib nibWithNibName:@"ANNativeAdView" bundle:[NSBundle mainBundle]];
    NSArray *array = [adNib instantiateWithOwner:self options:nil];
    ANNativeAdView *nativeAdView = [array firstObject];
    nativeAdView.titleLabel.text = self.nativeAdResponse.title;
    nativeAdView.bodyLabel.text = self.nativeAdResponse.body;
    nativeAdView.iconImageView.image = self.nativeAdResponse.iconImage;
    nativeAdView.mainImageView.image = self.nativeAdResponse.mainImage;
    nativeAdView.sponsoredLabel.text = self.nativeAdResponse.sponsoredBy;
    
    [nativeAdView.callToActionButton setTitle:self.nativeAdResponse.callToAction forState:UIControlStateNormal];
    self.nativeAdResponse.delegate = self;
    self.nativeAdResponse.clickThroughAction = ANClickThroughActionOpenDeviceBrowser;
    
    [self.view1 addSubview:nativeAdView];
    
    [self.nativeAdResponse registerViewForTracking:nativeAdView
                   withRootViewController:self
                           clickableViews:@[nativeAdView.callToActionButton,nativeAdView.mainImageView]
                                    error:nil];
    }else  if(request == self.nativeAdRequest2){
    // (code which loads the view)
    self.nativeAdResponse2 = response;
    
    UINib *adNib = [UINib nibWithNibName:@"ANNativeAdView" bundle:[NSBundle mainBundle]];
    NSArray *array = [adNib instantiateWithOwner:self options:nil];
    ANNativeAdView *nativeAdView = [array firstObject];
    nativeAdView.titleLabel.text = self.nativeAdResponse2.title;
    nativeAdView.bodyLabel.text = self.nativeAdResponse2.body;
    nativeAdView.iconImageView.image = self.nativeAdResponse2.iconImage;
    nativeAdView.mainImageView.image = self.nativeAdResponse2.mainImage;
    nativeAdView.sponsoredLabel.text = self.nativeAdResponse2.sponsoredBy;
    
    [nativeAdView.callToActionButton setTitle:self.nativeAdResponse2.callToAction forState:UIControlStateNormal];
    self.nativeAdResponse2.delegate = self;
    self.nativeAdResponse2.clickThroughAction = ANClickThroughActionOpenDeviceBrowser;
    
    [self.view2 addSubview:nativeAdView];
    
    [self.nativeAdResponse2 registerViewForTracking:nativeAdView
                   withRootViewController:self
                           clickableViews:@[nativeAdView.callToActionButton,nativeAdView.mainImageView]
                                    error:nil];
    }
    
}


@end
