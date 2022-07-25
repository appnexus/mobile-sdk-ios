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
#import <Integration-Swift.h>
#import "BannerNativeVideoTrackerTestVC.h"
//#import "ANBannerAdView.h"
@import AppNexusSDK;
#import "ANStubManager.h"
#import "ANNativeAdView.h"
#import "Constant.h"
#import "ANHTTPStubbingManager.h"
@interface BannerNativeVideoTrackerTestVC () <ANBannerAdViewDelegate,ANNativeAdDelegate>

@property (nonatomic, readwrite, strong) ANBannerAdView *banner;
@property (weak, nonatomic) IBOutlet UILabel *impressionTracker;
@property (weak, nonatomic) IBOutlet UILabel *clickTracker;
@property (nonatomic,readwrite,strong) ANNativeAdResponse *nativeAdResponse;


@end

@implementation BannerNativeVideoTrackerTestVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//  MockTestcase is enabled(set to 1) prepare stubbing with mock response else disable stubbing
    if(MockTestcase){
        [self prepareStubbing];
    }
    else {
        [[ANHTTPStubbingManager sharedStubbingManager] disable];
        [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
        [[ANStubManager sharedInstance] enableStubbing];
        [[ANStubManager sharedInstance] disableStubbing];
    }
    //  registerEventListener is used to register for tracking the URL fired by Application(or SDK)
    [self registerEventListener];
    
    int adWidth  = 300;
    int adHeight = 250;
    
    
    // Select placement Id based on Selected UI testcase
    NSString *adID = BannerPlacementId;
    if ([[NSProcessInfo processInfo].arguments containsObject:BannerImpressionClickTrackerTest]) {
        adID = BannerPlacementId;
    }else if ([[NSProcessInfo processInfo].arguments containsObject:BannerNativeImpressionClickTrackerTest]) {
        adID = NativePlacementId;
    } else if([[NSProcessInfo processInfo].arguments containsObject:BannerNativeRendererImpressionClickTrackerTest]){
        adID = BannerNativeRendererPlacementId;
     }else if([[NSProcessInfo processInfo].arguments containsObject:BannerVideoImpressionClickTrackerTest]){
        adID = VideoPlacementId;
    }
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat originX = (screenRect.size.width / 2) - (adWidth / 2);
    CGFloat originY = (screenRect.size.height / 2) - (adHeight / 2);
    CGRect rect = CGRectMake(originX, originY, adWidth, adHeight);
    CGSize size = CGSizeMake(adWidth, adHeight);
   
    // Prepair the BannerAd
    self.banner = [ANBannerAdView adViewWithFrame:rect placementId:adID adSize:size];
    self.banner.rootViewController = self;
    // Select Creative Id based on Selected UI testcase
    [self setCreativeId];
    // Select Allow Media Type based on Selected UI testcase
    [self allowMediaType];
    self.banner.delegate = self;
    self.banner.clickThroughAction = ANClickThroughActionOpenSDKBrowser;
    self.banner.accessibilityIdentifier = @"bannerAdElements";
    self.banner.shouldServePublicServiceAnnouncements = NO;
    self.banner.autoRefreshInterval = 0;
    [self.banner loadAd];
}
// Select Allow Media Type based on Selected UI testcase
-(void)allowMediaType{

    if ([[NSProcessInfo processInfo].arguments containsObject:BannerNativeImpressionClickTrackerTest]) {
        self.banner.shouldAllowNativeDemand = YES;
    } else if([[NSProcessInfo processInfo].arguments containsObject:BannerNativeRendererImpressionClickTrackerTest]){
        self.banner.shouldAllowNativeDemand = YES;
        self.banner.enableNativeRendering = YES;
    }else if([[NSProcessInfo processInfo].arguments containsObject:BannerVideoImpressionClickTrackerTest]){
        self.banner.shouldAllowVideoDemand = YES;
    }
}

// Select Creative Id based on Selected UI testcase
-(void)setCreativeId{
    if(ForceCreative){
        if ([[NSProcessInfo processInfo].arguments containsObject:BannerImpressionClickTrackerTest]) {
            self.banner.forceCreativeId = BannerForceCreativeId;
        }else if ([[NSProcessInfo processInfo].arguments containsObject:BannerNativeImpressionClickTrackerTest]) {
            self.banner.forceCreativeId = NativeForceCreativeId;
        } else if([[NSProcessInfo processInfo].arguments containsObject:BannerNativeRendererImpressionClickTrackerTest]){
            self.banner.forceCreativeId = NativeForceCreativeId;
        }else if([[NSProcessInfo processInfo].arguments containsObject:BannerVideoImpressionClickTrackerTest]){
            self.banner.forceCreativeId = VideoForceCreativeId;
        }
    }
}

//  registerEventListener is used to register for tracking the URL fired by Application(or SDK)
-(void)registerEventListener{
    [NSURLProtocol registerClass:[WebKitURLProtocol class]];
    [NSURLProtocol wk_registerWithScheme:@"https"];
    [NSURLProtocol wk_registerWithScheme:@"http"];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateNetworkLog:)
                                                 name:@"didReceiveURLResponse"
                                               object:nil];
}

//  prepareStubbing if MockTestcase is enabled(set to 1) prepare stubbing with mock response else disable stubbing
-(void)prepareStubbing{
    
    if ([[NSProcessInfo processInfo].arguments containsObject:BannerImpressionClickTrackerTest]) {
        self.title = @"BannerAd";
    }
    [[ANStubManager sharedInstance] disableStubbing];
    [[ANStubManager sharedInstance] enableStubbing];
    
    // Select Stub Response based on Selected UI testcase
    if ([[NSProcessInfo processInfo].arguments containsObject:BannerImpressionClickTrackerTest]) {
        [[ANStubManager sharedInstance] stubRequestWithResponse:@"RTBBannerAdTracker"];
    }else if ([[NSProcessInfo processInfo].arguments containsObject:BannerNativeImpressionClickTrackerTest]) {
        [[ANStubManager sharedInstance] stubRequestWithResponse:@"RTBBannerNativeAd"];
    }else if([[NSProcessInfo processInfo].arguments containsObject:BannerNativeRendererImpressionClickTrackerTest]){
        [[ANStubManager sharedInstance] stubRequestWithResponse:@"RTBBannerNativeRendererAd"];
    }else if([[NSProcessInfo processInfo].arguments containsObject:BannerVideoImpressionClickTrackerTest]){
        [[ANStubManager sharedInstance] stubRequestWithResponse:@"RTBBannerVideoAd"];
    }
}

- (void)adDidReceiveAd:(id)ad {
    NSLog(@"Ad did receive ad");
    
    [self.view addSubview:self.banner];
}

- (void)adDidLogImpression:(id)ad  {
    if([[NSProcessInfo processInfo].arguments containsObject:BannerImpressionClickTrackerTestWithCallback]){
        self.impressionTracker.text  = @"ImpressionTracker via adDidLogImpression";
    }
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
    nativeAdView.callToActionButton.accessibilityIdentifier = @"clickElements";
    
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

// updateNetworkLog: Will return event in fire of URL from Application(or SDK)
- (void) updateNetworkLog:(NSNotification *) notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSURLResponse *response = [userInfo objectForKey:@"response"];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *absoluteURLText = [response.URL.absoluteURL absoluteString];
        NSLog(@"absoluteURLText -> %@",absoluteURLText);
        
        // Loop for Impression Tracker and match with the returned URL if matched set the label to ImpressionTracker.
        for (NSString* url in impressionTrackerURLRTB){
            if([absoluteURLText containsString:url]){
                if(![[NSProcessInfo processInfo].arguments containsObject:BannerImpressionClickTrackerTestWithCallback]){
                self.impressionTracker.text  = @"ImpressionTracker";
                }
            }
        }
        // Loop for Click Tracker and match with the returned URL if matched set the label to ClickTracker.
        for (NSString* url in clickTrackerURLRTB){
            if([absoluteURLText containsString:url]){
                self.clickTracker.text  = @"ClickTracker";
            }
        }
    });
}

@end
