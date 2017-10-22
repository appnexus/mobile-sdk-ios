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

#import "ANMockMediationAdapterLoadAndHitOtherCallbacks.h"
#import "ANTestGlobal.h"



@implementation ANMockMediationAdapterLoadAndHitOtherCallbacks

@synthesize delegate;


#pragma mark - ANCustomAdapterBanner

- (void)requestBannerAdWithSize:(CGSize)size
             rootViewController:(UIViewController *)rootViewController
                serverParameter:(NSString *)parameterString
                       adUnitId:(NSString *)idString
            targetingParameters:(ANTargetingParameters *)targetingParameters
{
    TESTTRACEM(@"Load UIView, then... click, (will/did) present ad, (will/did) close ad, (will) leave application.");
    
    [self.delegate didLoadBannerAd:[UIView new]];
    [self.delegate adWasClicked];
    [self.delegate willPresentAd];
    [self.delegate didPresentAd];
    [self.delegate willCloseAd];
    [self.delegate didCloseAd];
    [self.delegate willLeaveApplication];
}

@end
