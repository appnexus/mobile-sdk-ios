//
//  SCSPixelProviderProtocol.h
//  SCSCoreKit
//
//  Created by Loïc GIRON DIT METAZ on 21/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SCSPixel;

/**
 Protocol that must be implemented by all classes that want to act as a data store for a pixel store.
 */
@protocol SCSPixelStoreProviderProtocol <NSObject>

/**
 Load an array of pixels from disk.
 
 @return An array of pixels if available, nil otherwise.
 */
- (nullable NSArray<SCSPixel *> *)loadPixels;

/**
 Save an array of pixels on disk.
 
 @param pixels An array of pixels that must be saved on disk.
 @return true if save operation is successful, false otherwise.
 */
- (BOOL)savePixels:(NSArray<SCSPixel *> *)pixels NS_SWIFT_NAME(save(pixels:));

@end

NS_ASSUME_NONNULL_END
