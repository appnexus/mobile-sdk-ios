/*   Copyright 2015 APPNEXUS INC
 
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

#import "ANNativeAdColonyView.h"
#import <AdColony/AdColonyNativeAdView.h>

@implementation ANNativeAdColonyView

- (instancetype)initWithNativeAdView:(AdColonyNativeAdView *)nativeAdView
                               frame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupNativeAdView:nativeAdView];
    }
    return self;
}

- (void)setupNativeAdView:(AdColonyNativeAdView *)nativeAdView {
    UILabel *advertiserName = [[UILabel alloc] init];
    advertiserName.text = nativeAdView.advertiserName;
    advertiserName.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    
    UILabel *sponsored = [[UILabel alloc] init];
    sponsored.text = @"Sponsored";
    sponsored.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    
    UILabel *adDescription = [[UILabel alloc] init];
    adDescription.text = nativeAdView.adDescription;
    adDescription.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    UIView *videoView = nativeAdView;
    UIImageView *iconImageView = [[UIImageView alloc] initWithImage:nativeAdView.advertiserIcon];
    
    [self addSubview:advertiserName];
    [self addSubview:iconImageView];
    [self addSubview:videoView];
    [self addSubview:sponsored];
    
    advertiserName.translatesAutoresizingMaskIntoConstraints = NO;
    iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
    videoView.translatesAutoresizingMaskIntoConstraints = NO;
    sponsored.translatesAutoresizingMaskIntoConstraints = NO;
    
    if (adDescription.text.length) {
        [self addSubview:adDescription];
        adDescription.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[title][adDescription]"
                                                                     options:NSLayoutFormatAlignAllLeading
                                                                     metrics:nil
                                                                       views:@{@"title":advertiserName,
                                                                               @"adDescription":adDescription}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[adDescription]-[videoView]"
                                                                     options:kNilOptions
                                                                     metrics:nil
                                                                       views:@{@"adDescription":adDescription,
                                                                               @"videoView":videoView}]];
    } else {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[title]-[videoView]"
                                                                     options:kNilOptions
                                                                     metrics:nil
                                                                       views:@{@"title":advertiserName,
                                                                               @"videoView":videoView}]];
    }
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[icon(==40)]-[title]-|"
                                                                 options:kNilOptions
                                                                 metrics:nil
                                                                   views:@{@"icon":iconImageView,
                                                                           @"title":advertiserName}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[icon(==40)]"
                                                                 options:kNilOptions
                                                                 metrics:nil
                                                                   views:@{@"icon":iconImageView}]];
    CGFloat width = self.frame.size.width - 16.0;
    NSString *widthVisualFormat = [NSString stringWithFormat:@"H:[videoView(==%ld)]", (long)width];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:widthVisualFormat
                                                                 options:kNilOptions
                                                                 metrics:nil
                                                                   views:@{@"videoView":videoView}]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:videoView
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0.0]];
    CGFloat height = [nativeAdView recommendedHeightForWidth:width];
    NSString *heightVisualFormat = [NSString stringWithFormat:@"V:[videoView(==%ld)]-[sponsored]", (long)height];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:heightVisualFormat
                                                                 options:kNilOptions
                                                                 metrics:nil
                                                                   views:@{@"videoView":videoView,
                                                                           @"sponsored":sponsored}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[sponsored]-|"
                                                                 options:kNilOptions
                                                                 metrics:nil
                                                                   views:@{@"sponsored":sponsored}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[sponsored]-|"
                                                                 options:kNilOptions
                                                                 metrics:nil
                                                                   views:@{@"sponsored":sponsored}]];
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

@end
