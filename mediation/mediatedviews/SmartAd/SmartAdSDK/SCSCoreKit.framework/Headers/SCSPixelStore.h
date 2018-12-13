//
//  SCSPixelStore.h
//  SCSCoreKit
//
//  Created by Loïc GIRON DIT METAZ on 21/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import "SCSPixel.h"
#import "SCSPixelStoreProviderProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Store pixels that are used by the pixel manager and handle disk read/write.
 
 There should be only one instance of pixel store per app: the shared singleton should be used in most cases.
 */
@interface SCSPixelStore : NSObject

/// The shared instance of the SCSPixelStore object.
@property (class, nonatomic, readonly) SCSPixelStore *sharedInstance NS_SWIFT_NAME(shared);

- (instancetype)init NS_UNAVAILABLE;

/**
 Initialize a new pixel store.
 
 @param provider The provider that will be used to save pixels on disk.
 @return An initialized instance of SCSPixelStore.
 */
- (instancetype)initWithProvider:(id<SCSPixelStoreProviderProtocol>)provider NS_DESIGNATED_INITIALIZER;

/**
 Trigger a save to disk: every pixel no matter its status will be saved using the pixel store provider
 declared at init.
 
 @return true if the save was successful, false otherwise.
 */
- (BOOL)saveToDisk;

/**
 Add a pixel to the store if it does not exists yet (ie, if no pixel with the same ID is already in the store).
 
 @param pixel The pixel to be added in the store.
 @return true if the pixel was added, false if it was already in the store.
 */
- (BOOL)addPixel:(SCSPixel *)pixel NS_SWIFT_NAME(add(pixel:));

/**
 Replace an already existing pixel in the store by its updated version (provided in parameter).
 
 @param pixel The updated pixel.
 @return true If the pixel was updated, false if the previous version of the pixel can't be found in the store (ie, a pixel with the same ID).
 */
- (BOOL)updatePixel:(SCSPixel *)pixel NS_SWIFT_NAME(update(pixel:));

/**
 Delete a pixel from the store.
 
 @param pixel The pixel that needs to be deleted.
 @return true if the pixel was deleted, false if the pixel can't be found in the store (ie, a pixel with the same ID).
 */
- (BOOL)deletePixel:(SCSPixel *)pixel NS_SWIFT_NAME(delete(pixel:));

/**
 Delete all obsolete pixels, ie all expired pixels or pixels that have already been called successfully.
 */
- (void)deleteObsoletePixels;

/**
 Find a pixel by id.
 
 @param ID The id of the pixel that must be found.
 @return The pixel that has been found, or nil otherwise.
 */
- (nullable SCSPixel *)pixelWithID:(uint32_t)ID NS_SWIFT_NAME(pixel(withId:));

/**
 Returns all pixels contained in the store.
 
 @return an array of all pixels contained in the store.
 */
- (NSArray<SCSPixel *> *)allPixels;

/**
 Returns all valid pending pixels, ie all non expired pixels with the pending status.
 
 @return An array of all valid pending pixels in the store.
 */
- (NSArray<SCSPixel *> *)validPendingPixels;

@end

NS_ASSUME_NONNULL_END
