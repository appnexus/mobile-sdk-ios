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

#import <Foundation/Foundation.h>
#import <TrackerTest-Swift.h>
#import "BannerAdViewController.h"
#import "ANBannerAdView.h"
#import "ANGlobal.h"
#import "ANStubManager.h"
#import "ANNativeAdView.h"
@interface BannerAdViewController () <ANBannerAdViewDelegate,ANNativeAdDelegate>

@property (nonatomic, readwrite, strong) ANBannerAdView *banner;
@property (weak, nonatomic) IBOutlet UILabel *impressionTracker;
@property (weak, nonatomic) IBOutlet UILabel *clickTracker;
@property (nonatomic,readwrite,strong) ANNativeAdResponse *nativeAdResponse;


@end

@implementation BannerAdViewController

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    [self prepareStubbing];
    
    int adWidth  = 300;
    int adHeight = 250;
    NSString *adID = @"15215010";

    // We want to center our ad on the screen.
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat originX = (screenRect.size.width / 2) - (adWidth / 2);
    CGFloat originY = (screenRect.size.height / 2) - (adHeight / 2);
    
    // Needed for when we create our ad view.
    CGRect rect = CGRectMake(originX, originY, adWidth, adHeight);
    CGSize size = CGSizeMake(adWidth, adHeight);
    
    // Make a banner ad view.
    self.banner = [ANBannerAdView adViewWithFrame:rect placementId:adID adSize:size];
    self.banner.rootViewController = self;
    self.banner.shouldAllowNativeDemand = YES;
    self.banner.enableNativeRendering = YES;
    self.banner.shouldAllowVideoDemand = YES;
    self.banner.delegate = self;
    self.banner.clickThroughAction = ANClickThroughActionOpenSDKBrowser;
    self.banner.accessibilityIdentifier = @"bannerAdElements";
    [self.view addSubview:self.banner];
    self.banner.shouldServePublicServiceAnnouncements = NO;
    self.banner.autoRefreshInterval = 10;
    [self.banner loadAd];
}

-(void)prepareStubbing{
    
    [NSURLProtocol registerClass:[WebKitURLProtocol class]];
    [NSURLProtocol wk_registerWithScheme:@"https"];
    [NSURLProtocol wk_registerWithScheme:@"http"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateNetworkLog:)
                                                 name:@"didReceiveURLResponse"
                                               object:nil];
    self.title = self.adType;
    [[ANStubManager sharedInstance] disableStubbing];
    [[ANStubManager sharedInstance] enableStubbing];
    
    if([self.adType isEqualToString:@"Banner"]){
        [[ANStubManager sharedInstance] stubRequestWithResponse:@"RTBBannerAd"];
    }else if([self.adType isEqualToString:@"BannerNative"]){
        [[ANStubManager sharedInstance] stubRequestWithResponse:@"RTBBannerNativeAd"];
    }else if([self.adType isEqualToString:@"BannerNativeRenderer"]){
        [[ANStubManager sharedInstance] stubRequestWithResponse:@"RTBBannerNativeRendererAd"];
    }else if([self.adType isEqualToString:@"BannerVideo"]){
        [[ANStubManager sharedInstance] stubRequestWithResponse:@"RTBBannerVideoAd"];
    }else if([self.adType isEqualToString:@"BannerAdAdmob"]){
        [[ANStubManager sharedInstance] stubRequestWithResponse:@"CSMBannerAd"];
    }
    
}

- (void)adDidReceiveAd:(id)ad {
    NSLog(@"Ad did receive ad");
}

-(void)ad:(id)ad requestFailedWithError:(NSError *)error{
    NSLog(@"Ad request Failed With Error");
}

- (void)ad:(id)loadInstance didReceiveNativeAd:(id)responseInstance{
    self.nativeAdResponse = (ANNativeAdResponse *)responseInstance;
    
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
    self.nativeAdResponse.clickThroughAction = ANClickThroughActionOpenSDKBrowser;
    
    [self.view addSubview:nativeAdView];
    
    [self.nativeAdResponse registerViewForTracking:nativeAdView
                            withRootViewController:self
                                    clickableViews:@[nativeAdView.callToActionButton,nativeAdView.mainImageView]
                                             error:nil];
}

- (void)adRequest:(nonnull ANNativeAdRequest *)request didFailToLoadWithError:(nonnull NSError *)error withAdResponseInfo:(nullable ANAdResponseInfo *)adResponseInfo {
    NSLog(@"Ad request Failed With Error");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


# pragma mark - Ad Server Response Stubbing

- (void) updateNetworkLog:(NSNotification *) notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSURLResponse *response = [userInfo objectForKey:@"response"];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *absoluteURLText = [response.URL.absoluteURL absoluteString];
        NSLog(@"absoluteURLText -> %@",absoluteURLText);
        if([absoluteURLText containsString:@"https://pagead2.googlesyndication.com/pcs/activeview?"]){
            self.impressionTracker.text  = @"CSMImpressionTracker";
        }else if([absoluteURLText containsString:@"https://googleads.g.doubleclick.net/pagead/conversion/?ai"]){
            self.clickTracker.text  = @"CSMClickTracker";
        }else if([absoluteURLText containsString:@"https://sin1-mobile.adnxs.com/click?"] || [absoluteURLText containsString:@"http://nym1-ib.adnxs.com/click?"] || [absoluteURLText containsString:@"https://wiki.xandr.com/"] || [absoluteURLText containsString:@"https://nym1-mobile.adnxs.com/click?"] ){
            self.clickTracker.text  = @"ClickTracker";
        }
        
        if([absoluteURLText containsString:@"https://sin1-mobile.adnxs.com/it?an_audit=0&referrer=itunes.apple"] || [absoluteURLText containsString:@"http://nym1-ib.adnxs.com/it?"] ||[absoluteURLText containsString:@"https://nym1-mobile.adnxs.com/it?"] ){
            self.impressionTracker.text  = @"ImpressionTracker";
        }
    });
}

@end
