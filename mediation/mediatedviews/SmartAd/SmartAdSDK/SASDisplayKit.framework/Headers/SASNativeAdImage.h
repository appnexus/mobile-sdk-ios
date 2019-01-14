//
//  SASNativeAdImage.h
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 18/08/2015.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 A SASNativeAdImage represents an image that will be displayed in a native ad.
 */
@interface SASNativeAdImage: NSObject <NSCopying, NSCoding>

/// The URL of the image.
@property (nonatomic, readonly, strong) NSURL *URL;

/// The width of the image (optional).
@property (nonatomic, readonly) CGFloat width;

/// The height of the image (optional).
@property (nonatomic, readonly) CGFloat height;

/**
 Initializes a new native ad image.
 
 @param URL The image URL.
 @return An initialized instance of SASNativeAdImage.
 */
- (instancetype)initWithURL:(NSURL *)URL;

/**
 Initializes a new native ad image.
 
 @param URL The image URL.
 @param width The image width.
 @param height The image height.
 @return An initialized instance of SASNativeAdImage.
 */
- (instancetype)initWithURL:(NSURL *)URL width:(CGFloat)width height:(CGFloat)height;

@end

NS_ASSUME_NONNULL_END
