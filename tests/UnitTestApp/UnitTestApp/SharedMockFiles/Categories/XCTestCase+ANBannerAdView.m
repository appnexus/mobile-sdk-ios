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

#import "XCTestCase+ANBannerAdView.h"
#import "XCTestCase+ANCategory.h"

@implementation XCTestCase (ANBannerAdView)

- (ANBannerAdView *)bannerViewWithFrameSize:(CGSize)frameSize {
    ANBannerAdView *bannerAdView = [[ANBannerAdView alloc] init];
    bannerAdView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:bannerAdView
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1.0f
                                                                        constant:frameSize.width];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:bannerAdView
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1.0f
                                                                         constant:frameSize.height];
    [bannerAdView addConstraints:@[widthConstraint, heightConstraint]];
    return bannerAdView;
}

- (UIImageView *)catContentView {
    return [[UIImageView alloc] initWithImage:[self imageForResource:@"GreyWhiteCat"
                                                              ofType:@"jpg"]];
}

- (UIImageView *)dogContentView {
    return [[UIImageView alloc] initWithImage:[self imageForResource:@"dogSelfie"
                                                              ofType:@"jpg"]];
}

@end
