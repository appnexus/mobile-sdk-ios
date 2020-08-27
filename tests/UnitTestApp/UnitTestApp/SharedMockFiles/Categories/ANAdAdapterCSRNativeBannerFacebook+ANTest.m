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

typedef NS_ENUM(NSUInteger, FBRequestError) {
    FBNoFill = 1001,
    FBAdLoadTooFrequently = 1002,
    FBInternalError = 2001
};

@import FBAudienceNetwork;

@protocol ANCSRNativeAdRequestAdDelegate;

@implementation ANAdAdapterCSRNativeBannerFacebook (ANTest)

//@synthesize requestDelegate;
//@synthesize nativeAdDelegate;
//@synthesize expired;


- (void) requestAdwithPayload:(nonnull NSString *) payload targetingParameters:(nullable ANTargetingParameters *)targetingParameters{
    NSString *placement = [self getPlacementIdFrom:payload];
    if ([placement isEqualToString:@"2038077109846299_2562578650729473"]) {
        [self showNativeBannerAd];
    }else{
        [self showErrorsForNativeBannerAd:placement];
    }
   
}

-(NSString *)getPlacementIdFrom:(NSString *)payload{
    NSData *data = [payload dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    return json[@"placement_id"];
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

- (void)showErrorsForNativeBannerAd:(NSString *)placement
{
    NSInteger errorCode = 0;
    if ([placement isEqualToString:@"2038077109846299_2562578650721000"]) {
        errorCode = 1000;
    }else if ([placement isEqualToString:@"2038077109846299_2562578650721001"]) {
        errorCode = 1001;
    }else if ([placement isEqualToString:@"2038077109846299_2562578650721002"]) {
        errorCode = 1002;
    }else if ([placement isEqualToString:@"2038077109846299_2562578650721011"]) {
        errorCode = 1011;
    }else if ([placement isEqualToString:@"2038077109846299_2562578650721012"]) {
        errorCode = 1012;
    }else if ([placement isEqualToString:@"2038077109846299_2562578650721203"]) {
        errorCode = 1203;
    }else if ([placement isEqualToString:@"2038077109846299_2562578650722000"]) {
        errorCode = 2000;
    }else if ([placement isEqualToString:@"2038077109846299_25625786507220001"]) {
        errorCode = 2001;
    }
    [self nativeBannerAdFailedWithError:errorCode];
}

- (void)nativeBannerAdFailedWithError:(NSInteger)errorCode
{
    NSError *error;
    ANAdResponseCode *code;
    switch (errorCode) {
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
            error = [NSError errorWithDomain:@"com.facebook.ads.sdk" code:errorCode userInfo:@{NSLocalizedDescriptionKey:@"CUSTOM_ADAPTER_ERROR"}];
            code = [ANAdResponseCode CUSTOM_ADAPTER_ERROR:[NSString stringWithFormat:@"Error: %ld Message: %@", (long)error.code, error.localizedDescription]];
            break;
    }
    [self.requestDelegate didFailToLoadNativeAd:code];
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
