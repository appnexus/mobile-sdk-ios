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

#import "MARBannerNativeRendererAdTrackerTestVC.h"
@import AppNexusSDK;
#import "ANStubManager.h"
#import <Integration-Swift.h>
#import "ANHTTPStubbingManager.h"
#import "Constant.h"
@interface MARBannerNativeRendererAdTrackerTestVC () <ANMultiAdRequestDelegate  , ANBannerAdViewDelegate ,  ANInstreamVideoAdPlayDelegate , ANInterstitialAdDelegate , ANNativeAdRequestDelegate , ANNativeAdDelegate  , ANInstreamVideoAdLoadDelegate>
@property (weak, nonatomic) IBOutlet UIView *bannerAdView;
@property (weak, nonatomic) IBOutlet UIView *nativeAdView;
@property (weak, nonatomic) IBOutlet UIImageView *nativeIconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *nativeMainImageView;
@property (weak, nonatomic) IBOutlet UILabel *nativeTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *nativeBodyLabel;
@property (weak, nonatomic) IBOutlet UILabel *nativesponsoredLabel;


@property (strong, nonatomic)  ANBannerAdView      *bannerAd;
@property (strong, nonatomic)  ANInterstitialAd      *interstitialAd;
@property (strong, nonatomic)  ANNativeAdRequest      *nativeAdRequest;
@property (strong, nonatomic)  ANNativeAdResponse      *nativeAdResponse;
@property (strong, nonatomic)  ANInstreamVideoAd      *videoAd;
@property (strong, nonatomic)  ANMultiAdRequest      *marAdRequest;

@property (weak, nonatomic) IBOutlet UILabel *impressionTracker;
@property (weak, nonatomic) IBOutlet UILabel *clickTracker;
@property (weak, nonatomic) IBOutlet UITableViewCell *bannerCell;


@end

@implementation MARBannerNativeRendererAdTrackerTestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareStubbing];
    
    
    self.bannerCell.frame = CGRectMake(self.bannerCell.frame.origin.x, self.bannerCell.frame.origin.y, self.bannerCell.frame.size.width, 10);
    //  Disable stubbing
    
    [[ANHTTPStubbingManager sharedStubbingManager] disable];
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    [[ANStubManager sharedInstance] enableStubbing];
    [[ANStubManager sharedInstance] disableStubbing];
    
    self.title = @"Multi Ad Request";
    
    
    self.bannerAdView.hidden = YES;
    self.nativeAdView.hidden = YES;
    // Init ANMultiAdRequest
    // Prepair the ANMultiAdRequest
    self.marAdRequest = [[ANMultiAdRequest alloc] initWithMemberId:10094 andDelegate:self];
    if( [[NSProcessInfo processInfo].arguments containsObject:MARBannerImpressionClickTrackerTest]){
        [self.marAdRequest addAdUnit:[self createBannerAd:self.bannerAdView andPlacementId:BannerPlacementId]];
        // Set Creative Id if ForceCreative is enabled
       if(ForceCreative){
            self.bannerAd.forceCreativeId = BannerForceCreativeId;
        }
        self.bannerAdView.hidden = NO;
    }else if ([[NSProcessInfo processInfo].arguments containsObject:MARNativeImpressionClickTrackerTest]){
        [self.marAdRequest addAdUnit:[self createNativeAd]];
        self.nativeAdView.hidden = NO;
    }else if ([[NSProcessInfo processInfo].arguments containsObject:MARBannerNativeRendererImpressionClickTrackerTest]){
        [self.marAdRequest addAdUnit:[self createBannerAd:self.bannerAdView andPlacementId:MARPlacementId]];
        self.bannerAd.shouldAllowNativeDemand = YES;
        self.bannerAd.shouldAllowBannerDemand = NO;
        self.bannerAd.enableNativeRendering = YES;
        self.bannerAdView.hidden = NO;
    }
    
    [self.marAdRequest load];
    
}

//  prepareStubbing if MockTestcase is enabled(set to 1) prepare stubbing with mock response else disable stubbing
-(void)prepareStubbing{
    
    [NSURLProtocol registerClass:[WebKitURLProtocol class]];
    [NSURLProtocol wk_registerWithScheme:@"https"];
    [NSURLProtocol wk_registerWithScheme:@"http"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateNetworkLog:)
                                                 name:@"didReceiveURLResponse"
                                               object:nil];
}

// Create Banner Ad Object
- (ANBannerAdView *)createBannerAd:(UIView *) adView andPlacementId:(NSString *)placement
{
    self.bannerAd = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 300, 250) placementId:placement adSize:CGSizeMake(300, 250)];
    self.bannerAd.rootViewController =self;
    self.bannerAd.delegate =self;
    self.bannerAd.shouldResizeAdToFitContainer = YES;
    [adView addSubview:self.bannerAd];
    return self.bannerAd;
    
}

// Create Interstitial Ad Object
- (ANInterstitialAd *)createInterstitialAd
{
    self.interstitialAd = [[ANInterstitialAd alloc] initWithPlacementId:@"19213468"];
    self.interstitialAd.delegate =self;
    // Set Creative Id if ForceCreative is enabled
    if(ForceCreative){
        self.interstitialAd.forceCreativeId = InterstitialForceCreativeId;
    }
    return self.interstitialAd;
    
}


// Create InstreamVideo Ad Object
- (ANInstreamVideoAd *)createVideoAd
{
    self.videoAd = [[ANInstreamVideoAd alloc] initWithPlacementId:VideoPlacementId];
    self.videoAd.loadDelegate =self;
    // Set Creative Id if ForceCreative is enabled
    if(ForceCreative){
        self.videoAd.forceCreativeId = VideoForceCreativeId;
    }
    return self.videoAd;
}

// Create Native Ad Object
- (ANNativeAdRequest *)createNativeAd
{
    self.nativeAdRequest = [[ANNativeAdRequest alloc] init];
    self.nativeAdRequest.placementId = NativePlacementId;
    self.nativeAdRequest.shouldLoadIconImage = YES;
    self.nativeAdRequest.shouldLoadMainImage = YES;
    self.nativeAdRequest.delegate = self;
    // Set Creative Id if ForceCreative is enabled
    if(ForceCreative){
        self.nativeAdRequest.forceCreativeId = NativeForceCreativeId;
    }
    return self.nativeAdRequest;
}



#pragma mark - Delegate methods exclusively for ANMultiAdRequest.
- (void) multiAdRequestDidComplete:(nonnull ANMultiAdRequest *)mar{
    NSLog(@"Multi Ad Request Did Complete");
}

- (void) multiAdRequest:(nonnull ANMultiAdRequest *)mar didFailWithError:(nonnull NSError *)error{
    NSLog(@"MultiAdRequest failed with error : \(error)");
}

#pragma mark - Delegate methods exclusively for ANAdDelegate.

- (void)adDidReceiveAd:(id)ad
{
    if([ad isKindOfClass:[ANInterstitialAd class]] && [self.interstitialAd isReady]){
        NSLog(@"Interstitial Ad did Receive");
        [self.interstitialAd displayAdFromViewController:self];
    }
//    else if([ad isKindOfClass:[ANInstreamVideoAd class]]){
//        NSLog(@"Video Ad did Receive");
//        [self.videoAd playAdWithContainer:self.videoAdView withDelegate:self];
//    }
    else if([ad isKindOfClass:[ANBannerAdView class]]){
        NSLog(@"Banner Ad did Receive");
    }
}

- (void)ad:(id)ad requestFailedWithError:(NSError *)error{
    NSLog(@"requestFailedWithError %@:",error);
    
}

#pragma mark - Delegate methods exclusively for ANNativeAd.
- (void)adRequest:(ANNativeAdRequest *)request didFailToLoadWithError:(NSError *)error withAdResponseInfo:(ANAdResponseInfo *)adResponseInfo{
    NSLog(@"requestFailedWithError %@:",error);
}

- (void)adRequest:(ANNativeAdRequest *)request didReceiveResponse:(ANNativeAdResponse *)response{
    NSLog(@"Native Ad did Receive");
    
    self.nativeAdResponse = response;
    self.nativeIconImageView.image = self.nativeAdResponse.iconImage;
    self.nativeMainImageView.image = self.nativeAdResponse.mainImage;
    self.nativeTitleLabel.text = self.nativeAdResponse.title;
    self.nativeBodyLabel.text = self.nativeAdResponse.body;
    self.nativesponsoredLabel.text = self.nativeAdResponse.sponsoredBy;
    [self.nativeAdResponse registerViewForTracking:self.nativeAdView
                            withRootViewController:self
                                    clickableViews:@[self.nativeAdView]
                                             error:nil];
}


# pragma mark - Ad Server Response Stubbing

// updateNetworkLog: Will return event in fire of URL from Application(or SDK)
- (void) updateNetworkLog:(NSNotification *) notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSURLResponse *response = [userInfo objectForKey:@"response"];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *absoluteURLText = [response.URL.absoluteURL absoluteString];

        // Loop for Impression Tracker and match with the returned URL if matched set the label to ImpressionTracker.
        for (NSString* url in impressionTrackerURLRTB){
            if([absoluteURLText containsString:url]){
                self.impressionTracker.text  = @"ImpressionTracker";
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
