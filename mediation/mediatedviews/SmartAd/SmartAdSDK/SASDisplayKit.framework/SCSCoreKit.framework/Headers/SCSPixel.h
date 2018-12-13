//
//  SCSPixel.h
//  SCSCoreKit
//
//  Created by Loïc GIRON DIT METAZ on 21/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Enum that defines the status of a pixel.
typedef NS_ENUM(NSUInteger, SCSPixelStatus) {
    /// The pixel is pending and will be saved in the store.
    SCSPixelStatusPending = 0,
    
    /// The pixel has been successfully called and will be discarded from the store.
    SCSPixelStatusSuccess = 1,
};

/**
 Represents a pixel in memory.
 
 A pixel is an object that represents an URL that has to be called until success or until it is expired. It has an
 ID to avoid issues if several pixels have the same URL and is serializable so it can be written on disk (or in
 the user preferences).
 */
@interface SCSPixel : NSObject <NSCoding>

/// The default expiration date of a pixel.
@property (class, nonatomic, readonly) NSTimeInterval DEFAULT_EXPIRATION_INTERVAL NS_SWIFT_NAME(defaultExpirationInterval);

/// The ID of the pixel.
@property (nonatomic, readonly) uint32_t ID;

/// The URL to call for this pixel.
@property (nonatomic, readonly) NSURL *url;

/// The expiration date of the pixel.
@property (nonatomic, readonly) NSDate *expirationDate;

/// The current status of the pixel (only useful if the pixel has to be kept after a successful call).
@property (nonatomic, assign) SCSPixelStatus status;

- (instancetype)init NS_UNAVAILABLE;

/**
 Initialize a pixel.
 
 Note: this initializer allows the developer to set manually all the object's properties and should be used only
 when decoding from data. Use the convenience initializers otherwise.
 
 @param ID The ID of the pixel.
 @param url The URL to call for this pixel.
 @param expirationDate The expiration date for this pixel, the pixel should not be called after it.
 @param status The current status of the pixel, the pixel should not be called if already successful.
 @return An initialized pixel.
 */
- (instancetype)initWithID:(uint32_t)ID url:(NSURL *)url expirationDate:(NSDate *)expirationDate status:(SCSPixelStatus)status NS_DESIGNATED_INITIALIZER;

/**
 Convenience initializer to create a pixel from an URL and an expiration date.
 
 @param url The URL to call for this pixel.
 @param expirationDate The expiration date for this pixel, the pixel should not be called after it.
 @return An initialized pixel.
 */
- (instancetype)initWithUrl:(NSURL *)url expirationDate:(NSDate *)expirationDate;

/**
 Convenience initializer to create a pixel from an URL.
 
 @param url The URL to call for this pixel.
 @return An initialized pixel.
 */
- (instancetype)initWithUrl:(NSURL *)url;

/**
 Tell if the pixel is expired.
 
 Note: an external object should never attempt to check if a pixel is expired from its public properties. At some point in the
 future, expiration status could become more complex (for example by adding a retry limit) and only this method should be
 updated to make everything works properly.
 
 @return true if the pixel is expired, false if the pixel is still relevant.
 */
- (BOOL)isExpired;

@end

NS_ASSUME_NONNULL_END
