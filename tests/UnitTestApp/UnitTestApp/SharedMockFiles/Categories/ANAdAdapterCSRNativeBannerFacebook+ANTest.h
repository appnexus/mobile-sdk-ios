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


NS_ASSUME_NONNULL_BEGIN

@interface ANAdAdapterCSRNativeBannerFacebook  (ANTest)<FBNativeBannerAdDelegate , ANNativeCustomAdapter>
@property (nonatomic, strong) FBNativeBannerAd *nativeBannerAd;
@property (nonatomic) FBMediaView *fbAdMediaViewIcon;
@property (nonatomic) UIImageView *fbAdImageViewIcon;
@property (nonatomic , weak) ANCSRNativeAdResponse *csrNativeAdResponse;
- (void) requestAdwithPayload:(nonnull NSString *) payload targetingParameters:(nullable ANTargetingParameters *)targetingParameters;
- (BOOL)hasExpired;
- (void)registerNativeAdDelegate;
@end

NS_ASSUME_NONNULL_END
