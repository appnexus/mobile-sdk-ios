/*   Copyright 2013 APPNEXUS INC
 
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

#import "ANAdAdapterBannerMillennialMedia.h"
#import <MMAdSDK/MMAdSDK.h>


#if __has_include(<AppNexusSDK/AppNexusSDK.h>)
#import <AppNexusSDK/AppNexusSDK.h>
#else
#import "ANLogging.h"
#endif


@interface ANAdAdapterBannerMillennialMedia () <MMInlineDelegate>

@property (nonatomic, readwrite, strong) MMInlineAd *inlineAd;
@property (nonatomic, readwrite, weak) UIViewController *rootViewController;

@end

@implementation ANAdAdapterBannerMillennialMedia
@synthesize delegate;

#pragma mark ANCustomAdapterBanner

- (void)requestBannerAdWithSize:(CGSize)size
             rootViewController:(nullable UIViewController *)rootViewController
                serverParameter:(nullable NSString *)parameterString
                       adUnitId:(nullable NSString *)idString
            targetingParameters:(nullable ANTargetingParameters *)targetingParameters {
    ANLogTrace(@"%@ %@ | Requesting MillennialMedia banner with size %fx%f",
               NSStringFromClass([self class]), NSStringFromSelector(_cmd), size.width, size.height);
    if (!idString) {
        [self.delegate didFailToLoadAd:ANAdResponseCode.UNABLE_TO_FILL];
        return;
    }
    [self configureMillennialSettingsWithTargetingParameters:targetingParameters];
    self.inlineAd = [[MMInlineAd alloc] initWithPlacementId:idString
                                                       size:size];
    self.inlineAd.delegate = self;
    self.inlineAd.refreshInterval = MMInlineDisableRefresh;
    self.rootViewController = rootViewController;
    
    MMRequestInfo *requestInfo = [[MMRequestInfo alloc] init];
    requestInfo.keywords = [[targetingParameters.customKeywords allValues] copy];
    
    [self.inlineAd request:requestInfo];
}

- (void)dealloc {
    self.inlineAd.delegate = nil;
}

#pragma mark - MMInlineDelegate

- (UIViewController * __nonnull)viewControllerForPresentingModalView {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    return self.rootViewController;
}

- (void)inlineAdRequestDidSucceed:(MMInlineAd * __nonnull)ad {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (self.inlineAd.view) {
        [self.delegate didLoadBannerAd:self.inlineAd.view];
    } else {
        [self.delegate didFailToLoadAd:ANAdResponseCode.UNABLE_TO_FILL];
    }
}

- (void)inlineAd:(MMInlineAd * __nonnull)ad requestDidFailWithError:(NSError * __nonnull)error {
    ANLogDebug(@"MillennialMedia banner failed to load with error: %@", error);
    ANAdResponseCode *code = ANAdResponseCode.INTERNAL_ERROR;
    
    switch (error.code) {
        case MMSDKErrorServerResponseBadStatus:
            code = ANAdResponseCode.INVALID_REQUEST;
            break;
        case MMSDKErrorServerResponseNoContent:
            code = ANAdResponseCode.UNABLE_TO_FILL;
            break;
        case MMSDKErrorPlacementRequestInProgress:
            code = ANAdResponseCode.INTERNAL_ERROR;
            break;
        case MMSDKErrorRequestsDisabled:
            ANLogDebug(@"%@ - MMSDKErrorRequestsDisabled", NSStringFromSelector(_cmd));
            code = ANAdResponseCode.MEDIATED_SDK_UNAVAILABLE;
            break;
        case MMSDKErrorNoFill:
            code = ANAdResponseCode.UNABLE_TO_FILL;
            break;
        case MMSDKErrorVersionMismatch:
            code = ANAdResponseCode.INTERNAL_ERROR;
            break;
        case MMSDKErrorMediaDownloadFailed:
            code = ANAdResponseCode.NETWORK_ERROR;
            break;
        case MMSDKErrorRequestTimeout:
            code = ANAdResponseCode.NETWORK_ERROR;
            break;
        case MMSDKErrorNotInitialized:
            ANLogDebug(@"%@ - MMSDKErrorNotInitialized", NSStringFromSelector(_cmd));
            code = ANAdResponseCode.INTERNAL_ERROR;
            break;
        default:
            code = ANAdResponseCode.INTERNAL_ERROR;
            break;
    }
    
    [self.delegate didFailToLoadAd:code];
}

- (void)inlineAdContentTapped:(MMInlineAd * __nonnull)ad {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate adWasClicked];
}

- (void)inlineAd:(MMInlineAd * __nonnull)ad
    willResizeTo:(CGRect)frame
       isClosing:(BOOL)isClosingResize {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    // Do nothing
}

- (void)inlineAd:(MMInlineAd * __nonnull)ad
     didResizeTo:(CGRect)frame
       isClosing:(BOOL)isClosingResize {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    // Do nothing
}

- (void)inlineAdWillPresentModal:(MMInlineAd * __nonnull)ad {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate willPresentAd];
}

- (void)inlineAdDidPresentModal:(MMInlineAd * __nonnull)ad {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate didPresentAd];
}

- (void)inlineAdWillCloseModal:(MMInlineAd * __nonnull)ad {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate willCloseAd];
}

- (void)inlineAdDidCloseModal:(MMInlineAd * __nonnull)ad {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate didCloseAd];
}

- (void)inlineAdWillLeaveApplication:(MMInlineAd * __nonnull)ad {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate willLeaveApplication];
}

@end
