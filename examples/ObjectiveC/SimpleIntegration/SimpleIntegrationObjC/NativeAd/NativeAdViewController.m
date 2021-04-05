/*   Copyright 2020 APPNEXUS INC
 
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

#import "NativeAdViewController.h"
#import <AppNexusSDK/AppNexusSDK.h>
#import "ANNativeAdView.h"

@interface NativeAdViewController () <ANNativeAdRequestDelegate,ANNativeAdDelegate>
@property (nonatomic,readwrite,strong) ANNativeAdRequest *nativeAdRequest;
//@property (nonatomic,readwrite,strong) ANNativeAdResponse *nativeAdResponse;
@property (nonatomic,readwrite,strong) ANNativeAdView *nativeAdView;
@end

@implementation NativeAdViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Native Ad";

    [ANLogManager setANLogLevel:ANLogLevelAll];
   
    
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.nativeAdRequest= [[ANNativeAdRequest alloc] init];
    self.nativeAdRequest.placementId = @"17058950";
    self.nativeAdRequest.gender = ANGenderMale;
    self.nativeAdRequest.shouldLoadIconImage = YES;
    self.nativeAdRequest.shouldLoadMainImage = YES;
    self.nativeAdRequest.delegate = self;
    [self.nativeAdRequest loadAd];
    
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //self.nativeAdRequest = nil;
    //self.nativeAdResponse = nil;
    self.nativeAdView = nil;
    
}

- (void)adRequest:(ANNativeAdRequest *)request didReceiveResponse:(ANNativeAdResponse *)response {
    // (code which loads the view)
    ANNativeAdResponse *nativeAdResponse = response;
    
    UINib *adNib = [UINib nibWithNibName:@"ANNativeAdView" bundle:[NSBundle mainBundle]];
    NSArray *array = [adNib instantiateWithOwner:self options:nil];
    self.nativeAdView = [array firstObject];
    self.nativeAdView.nativeResponse = response;
//    self.nativeAdView.titleLabel.text = self.nativeAdResponse.title;
//    self.nativeAdView.bodyLabel.text = self.nativeAdResponse.body;
//    self.nativeAdView.iconImageView.image = self.nativeAdResponse.iconImage;
//    self.nativeAdView.mainImageView.image = self.nativeAdResponse.mainImage;
//    self.nativeAdView.sponsoredLabel.text = self.nativeAdResponse.sponsoredBy;
    
//    [self.nativeAdView.callToActionButton setTitle:self.nativeAdResponse.callToAction forState:UIControlStateNormal];
    nativeAdResponse.delegate = self;
    nativeAdResponse.clickThroughAction = ANClickThroughActionOpenDeviceBrowser;
    
    [self.view addSubview:self.nativeAdView];
    
    [nativeAdResponse registerViewForTracking:self.nativeAdView
                   withRootViewController:self
                           clickableViews:@[self.nativeAdView.callToActionButton,self.nativeAdView.mainImageView]
                                    error:nil];
    
}

- (void)adRequest:(nonnull ANNativeAdRequest *)request didFailToLoadWithError:(nonnull NSError *)error withAdResponseInfo:(nullable ANAdResponseInfo *)adResponseInfo {
    NSLog(@"Ad request Failed With Error");
}

#pragma mark - ANNativeAdDelegate

- (void)adDidLogImpression:(id)ad {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)adWillExpire:(id)ad {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)adDidExpire:(id)ad {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

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


@end
