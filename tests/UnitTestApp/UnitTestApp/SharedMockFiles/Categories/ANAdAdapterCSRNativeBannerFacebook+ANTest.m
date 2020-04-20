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

#import "ANAdAdapterCSRNativeBannerFacebook+ANTest.h"
@import FBAudienceNetwork;

@protocol ANCSRNativeAdRequestAdDelegate;

@implementation ANAdAdapterCSRNativeBannerFacebook (ANTest)

//@synthesize requestDelegate;
//@synthesize nativeAdDelegate;
//@synthesize expired;


- (void) requestAdwithPayload:(nonnull NSString *) payload targetingParameters:(nullable ANTargetingParameters *)targetingParameters{
    
    [self showNativeBannerAd];
}

- (void)showNativeBannerAd
{
    ANLogError(@"Ad did receive Native BannerAd.");
    
    ANCSRNativeAdResponse *csrNativeAdResponse = [[ANCSRNativeAdResponse alloc] initWithCustomAdapter:self
                                                                        networkCode:ANNativeAdNetworkCodeFacebook];
    csrNativeAdResponse.title = @"CSRNativeBannerFacebook Title";
    csrNativeAdResponse.body = @"CSRNativeBannerFacebook Body";
    csrNativeAdResponse.callToAction = @"CSRNativeBannerFacebook callToAction";
    csrNativeAdResponse.customElements = @{ kANNativeCSRObject : self};
    self.csrNativeAdResponse = csrNativeAdResponse;
    [self.requestDelegate didLoadNativeAd:self.csrNativeAdResponse];
}

- (BOOL)hasExpired {
    return NO;
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
        ANLogDebug(@"Facebook Native BannerAd does not contain mediaView for registerViewForTracking.");
    }
    [self fireTracker];
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
        ANLogDebug(@"Facebook Native BannerAd does not contain ImageView for registerViewForTracking.");
    }
    
    [self fireTracker];
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
        ANLogDebug(@"Facebook Native BannerAd does not contain mediaView for registerViewForTracking.");
    }
    
    [self fireTracker];
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
        ANLogDebug(@"Facebook Native BannerAd does not contain ImageView for registerViewForTracking.");
    }
    [self fireTracker];
}


- (void)registerNativeAdDelegate {
    if(self.csrNativeAdResponse != nil && self.csrNativeAdResponse.adapter!= nil){
        self.csrNativeAdResponse.adapter.nativeAdDelegate = self.csrNativeAdResponse;
        [self.csrNativeAdResponse registerOMID];
    }
}


-(void)fireTracker{    
    ANLogError(@"Native banner ad was clicked.");
    [self.nativeAdDelegate adWasClicked];
    
    ANLogDebug(@"Facebook Native BannerAd impression is being captured.");
    [self.nativeAdDelegate adDidLogImpression];

}
@end
