//
//  SASNativeAdImage.h
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 18/08/2015.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


/**
 A SASNativeAdImage represents an image that will be displayed in a native ad.
 */

@interface SASNativeAdImage: NSObject <NSCopying, NSCoding>

/**
 The URL of the image.
 */
@property (nonatomic, readonly, nonnull, strong) NSURL *URL;

/**
 The width of the image (optional).
 */
@property (nonatomic, readonly) CGFloat width;

/**
 The height of the image (optional).
 */
@property (nonatomic, readonly) CGFloat height;

@end
