/*   Copyright 2014 APPNEXUS INC
 
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

#import "XCTestCase+ANMediatedAd.h"

@implementation XCTestCase (ANMediatedAd)

- (ANMediatedAd *)mediatedAdWithFakeClass {
    return [self defaultMediatedAdWithClassName:@"ANAdAdapterBannerFakeClass"];
}

- (ANMediatedAd *)mediatedAdUnableToFill {
    return [self defaultMediatedAdWithClassName:@"ANAdAdapterBannerUnableToFill"];
}

- (ANMediatedAd *)mediatedAdNetworkError {
    return [self defaultMediatedAdWithClassName:@"ANAdAdapterBannerNetworkError"];
}

- (ANMediatedAd *)mediatedAdSuccessful {
    return [self defaultMediatedAdWithClassName:@"ANAdAdapterBannerSuccessful"];
}

- (ANMediatedAd *)mediatedAdWithNoDelegateInClass {
    return [self defaultMediatedAdWithClassName:@"ANAdAdapterBannerNoDelegate"];
}

- (ANMediatedAd *)mediatedAdWithNoRequestMethodInClass {
    return [self defaultMediatedAdWithClassName:@"ANAdAdapterBannerNoRequestMethod"];
}

- (ANMediatedAd *)mediatedAdTimeout {
    return [self defaultMediatedAdWithClassName:@"ANAdAdapterBannerTimeoutThenSuccessful"];
}

- (ANMediatedAd *)mediatedAdUnableToFillThenSuccessful {
    return [self defaultMediatedAdWithClassName:@"ANAdAdapterBannerUnableToFillThenSuccessful"];
}

- (ANMediatedAd *)mediatedAdMultipleSuccessCallbacks {
    return [self defaultMediatedAdWithClassName:@"ANAdAdapterBannerMultipleSuccessCallbacks"];
}

- (ANMediatedAd *)mediatedAdMultipleFailureCallbacks {
    return [self defaultMediatedAdWithClassName:@"ANAdAdapterBannerMultipleFailureCallbacks"];
}

- (ANMediatedAd *)mediatedAdSuccessfulThenUnableToFill {
    return [self defaultMediatedAdWithClassName:@"ANAdAdapterBannerSuccessfulThenUnableToFill"];
}

- (ANMediatedAd *)defaultMediatedAdWithClassName:(NSString *)className {
    ANMediatedAd *mediatedAd = [[ANMediatedAd alloc] init];
    mediatedAd.className = className;
    mediatedAd.width = @"300";
    mediatedAd.height = @"250";
    return mediatedAd;
}

- (ANMediatedAd *)facebookInterstitialMediatedAd {
    ANMediatedAd *mediatedAd = [[ANMediatedAd alloc] init];
    mediatedAd.className = @"ANAdAdapterInterstitialFacebook";
    return mediatedAd;
}

@end
