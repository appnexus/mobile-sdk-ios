//
//  RFMNativeImage.h
//  RFMAdSDK
//
//  Created by Rubicon Project on 9/14/16.
//  Copyright © 2016 Rubicon Project. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RFMNativeLink.h"

@interface RFMNativeImage : NSObject

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSURL *imageUrl;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;
@property (nonatomic, strong) RFMNativeLink *link;

- (id)initWithImage:(UIImage *)image
           imageUrl:(NSURL *)imageUrl
              width:(CGFloat)width
             height:(CGFloat)height
               link:(RFMNativeLink *)link;

@end
