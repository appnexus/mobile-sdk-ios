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

#import "ANAdAdapterCSRNativeBannerFacebook.h"

typedef NS_ENUM(NSUInteger, FBRequestError) {
    FBNoFill = 1001,
    FBAdLoadTooFrequently = 1002,
    FBInternalError = 2001
};

@import FBAudienceNetwork;

@protocol ANCSRNativeAdRequestAdDelegate;



@interface ANAdAdapterCSRNativeBannerFacebook () <FBNativeBannerAdDelegate , ANNativeCustomAdapter>

@property (nonatomic, strong) FBNativeBannerAd *nativeBannerAd;
@property (nonatomic) FBMediaView *fbAdMediaViewIcon;
@property (nonatomic) UIImageView *fbAdImageViewIcon;
@property (nonatomic , weak) ANCSRNativeAdResponse *csrNativeAdResponse;

@end

@implementation ANAdAdapterCSRNativeBannerFacebook

@synthesize requestDelegate;
@synthesize nativeAdDelegate;
@synthesize expired;

- (void) requestAdwithPayload:(nonnull NSString *) payload targetingParameters:(nullable ANTargetingParameters *)targetingParameters{
    
    NSString *placement = [self getPlacementIdFrom:payload];
    FBNativeBannerAd *nativeBannerAd = [[FBNativeBannerAd alloc]
                                        initWithPlacementID:placement];
    
    // Set a delegate to get notified when the ad was loaded.
    nativeBannerAd.delegate = self;
    // Initiate a request to load an ad.
    [nativeBannerAd loadAdWithBidPayload:payload];
}

-(NSString *)getPlacementIdFrom:(NSString *)payload{
    NSData *data = [payload dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    return json[@"placement_id"];
}

- (void)nativeBannerAdDidLoad:(FBNativeBannerAd *)nativeBannerAd
{
    self.nativeBannerAd = nativeBannerAd;
    [self showNativeBannerAd];
}

- (void)showNativeBannerAd
{
    ANLogDebug(@"Ad did receive FacebookNativeBannerAd.");
    
    ANCSRNativeAdResponse *csrNativeAdResponse = [[ANCSRNativeAdResponse alloc] initWithCustomAdapter:self
                                                                        networkCode:ANNativeAdNetworkCodeFacebook];
    csrNativeAdResponse.title = self.nativeBannerAd.headline;
    csrNativeAdResponse.body = self.nativeBannerAd.bodyText;
    csrNativeAdResponse.callToAction = self.nativeBannerAd.callToAction;
    csrNativeAdResponse.customElements = @{ kANNativeCSRObject : self , kANNativeElementObject : self.nativeBannerAd};
    self.csrNativeAdResponse = csrNativeAdResponse;
    [self.requestDelegate didLoadNativeAd:self.csrNativeAdResponse];
}


#pragma mark FBNativeBannerAdDelegate

- (void)nativeBannerAdDidDownloadMedia:(FBNativeBannerAd *)nativeBannerAd{
    ANLogDebug(@"FacebookNativeBannerAd did download media");
}

- (void)nativeBannerAdWillLogImpression:(FBNativeBannerAd *)nativeBannerAd{
    ANLogDebug(@"FacebookNativeBannerAd impression is being captured.");
    [self.nativeAdDelegate adDidLogImpression];
}

- (void)nativeBannerAd:(FBNativeBannerAd *)nativeBannerAd didFailWithError:(NSError *)error{
    ANLogError(@"Error loading Facebook banner native ad: %@", error);
    ANAdResponseCode *code;
    switch (error.code) {
        case FBNoFill:
            code = ANAdResponseCode.UNABLE_TO_FILL;
            break;
        case FBAdLoadTooFrequently:
            code = ANAdResponseCode.REQUEST_TOO_FREQUENT;
            break;
        case FBInternalError:
            code = ANAdResponseCode.INTERNAL_ERROR;
            break;
        default:
            code = [ANAdResponseCode CUSTOM_ADAPTER_ERROR:[NSString stringWithFormat:@"Error: %ld Message: %@", (long)error.code, error.localizedDescription]];
            break;
    }
    [self.requestDelegate didFailToLoadNativeAd:code];
}

- (void)nativeBannerAdDidFinishHandlingClick:(FBNativeBannerAd *)nativeBannerAd{
    ANLogDebug(@"FacebookNativeBannerAd did finish handling click");
}

- (void)nativeBannerAdDidClick:(FBNativeBannerAd *)nativeBannerAd
{
    ANLogDebug(@"FacebookNativeBannerAd ad was clicked.");
    [self.nativeAdDelegate adWasClicked];
}



- (void)registerViewForTracking:(nonnull UIView *)view
         withRootViewController:(nonnull UIViewController *)controller
                       iconView:(FBMediaView *_Nonnull)iconView
                 clickableViews:(nullable NSArray *)clickableViews{
    
    if(![self hasExpired]){
        [self registerNativeAdDelegate];
        [self.nativeBannerAd registerViewForInteraction:view
                                               iconView:iconView
                                         viewController:controller
                                         clickableViews:clickableViews];
    }
    else{
        ANLogDebug(@"FacebookNativeBannerAd is expired.");
    }
}

- (void)registerViewForTracking:(nonnull UIView *)view
         withRootViewController:(nonnull UIViewController *)controller
                  iconImageView:(UIImageView *_Nonnull)iconImageView
                 clickableViews:(nullable NSArray *)clickableViews{
    
    if(![self hasExpired] ){
        [self registerNativeAdDelegate];
        [self.nativeBannerAd registerViewForInteraction:view
                                          iconImageView:iconImageView
                                         viewController:controller
                                         clickableViews:clickableViews];
    }
    else{
        ANLogDebug(@"FacebookNativeBannerAd is expired.");
    }
}


- (void)registerViewForTracking:(nonnull UIView *)view
         withRootViewController:(nonnull UIViewController *)controller
                       iconView:(FBMediaView *_Nonnull)iconView{
    if(![self hasExpired]){
        [self registerNativeAdDelegate];
        [self.nativeBannerAd registerViewForInteraction:view
                                               iconView:iconView
                                         viewController:controller];
    }
    else{
        ANLogDebug(@"FacebookNativeBannerAd is expired.");
    }
}

- (void)registerViewForTracking:(nonnull UIView *)view
         withRootViewController:(nonnull UIViewController *)controller
                  iconImageView:(UIImageView *_Nonnull)iconImageView{
    
    if(![self hasExpired]){
        [self registerNativeAdDelegate];
        [self.nativeBannerAd registerViewForInteraction:view
                                          iconImageView:iconImageView
                                         viewController:controller];
    }
    else{
        ANLogDebug(@"FacebookNativeBannerAd is expired.");
    }
}

- (void)dealloc {
    [self unregisterViewFromTracking];
}

- (BOOL)hasExpired {
    return ![self.nativeBannerAd isAdValid];
}

- (void)unregisterViewFromTracking {
    [self.nativeBannerAd unregisterView];
    self.nativeBannerAd = nil;
    self.csrNativeAdResponse = nil;
}

- (void)registerNativeAdDelegate {
    if(self.csrNativeAdResponse != nil && self.csrNativeAdResponse.adapter!= nil){
        self.csrNativeAdResponse.adapter.nativeAdDelegate = self.csrNativeAdResponse;
        [self.csrNativeAdResponse registerOMID];
    }
}
@end
