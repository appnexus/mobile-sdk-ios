//
//  SCSUIUtils.h
//  SCSCoreKit
//
//  Created by Julien Gomez on 20/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

// Note: This class will not be unit tested.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// Type of image representation.
typedef NS_ENUM(NSInteger, SCSImageRepresentation) {
    /// The image is represented as a PNG.
    SCSImageRepresentationPNG,
    
    /// The image is represented as a JPEG.
    SCSImageRepresentationJPEG
};

/**
 Provides some useful methods to handle the UI.
 */
@interface SCSUIUtils : NSObject

/**
 Captures what is currently visible on the device's screen.
 
 @return An UIImage representing was is currently visible on the device's screen
 */
+ (nullable UIImage *)screenCapture;

/**
 Transforms an UIImage into Data.
 
 @param image The UIImage to be transformed into Data
 @param representation The type of image that should be generated.
 @param compression The compression rate. Only for JPEG data representation.
 @return The image representation as Data.
 */
+ (nullable NSData *)imageToDataWithImage:(UIImage *)image representation:(SCSImageRepresentation)representation compression:(CGFloat)compression;

/**
 Captures what is currently visible on the device's screen and represents it in a Base64 encoded string.
 
 @return A Base64 encoded string of what is visible on screen.
 */
+ (nullable NSString *)base64ScreenCapture;

/**
 Configures the accessibility label of a view with a label string or an optional fallback debug string.
 
 @param view The view to configure.
 @param label The string used as accessibility label.
 @param debugLabel An optional fallback debug string that will be used in debug.
 @param debug YES if the SDK is built in debug, NO otherwise.
 */
+ (void)configureAccessibilityLabelForView:(UIView *)view withLabel:(NSString *)label debugLabel:(nullable NSString *)debugLabel debug:(BOOL)debug;

@end

NS_ASSUME_NONNULL_END
