//
//  RFMNativeAssets.h
//  RFMAdSDK
//
//  Created by Rubicon Project on 8/17/16.
//  Copyright © 2016 Rubicon Project. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RFMNativeImage.h"
#import "RFMNativeTitle.h"
#import "RFMNativeVideo.h"
#import "RFMNativeDataAsset.h"

@interface RFMNativeAssets : NSObject

@property (nonatomic, strong) RFMNativeTitle *title;
@property (nonatomic, strong) RFMNativeImage *iconImage;
@property (nonatomic, strong) RFMNativeImage *mainImage;
@property (nonatomic, strong) RFMNativeVideo *video;
@property (nonatomic, strong) RFMNativeDataAsset *desc;
@property (nonatomic, strong) RFMNativeDataAsset *rating;
@property (nonatomic, strong) RFMNativeDataAsset *sponsored;
@property (nonatomic, strong) RFMNativeDataAsset *ctaText;

- (id)initWithTitle:(RFMNativeTitle *)title
          iconImage:(RFMNativeImage *)iconImage
          mainImage:(RFMNativeImage *)mainImage
              video:(RFMNativeVideo *)video
               desc:(RFMNativeDataAsset *)desc
             rating:(RFMNativeDataAsset *)rating
          sponsored:(RFMNativeDataAsset *)sponsored
            ctaText:(RFMNativeDataAsset *)ctaText;

@end
