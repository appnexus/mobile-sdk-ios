//
//  RFMNativeAdChoices.h
//  RFMAdSDK
//
//  Created by Rubicon Project on 9/14/16.
//  Copyright © 2016 Rubicon Project. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RFMNativeAdChoices : NSObject

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSURL *optOutUrl;

- (id)initWithImage:(UIImage *)image
          optOutUrl:(NSURL *)optOutUrl;

@end
