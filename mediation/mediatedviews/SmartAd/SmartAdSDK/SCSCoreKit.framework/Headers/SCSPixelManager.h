//
//  SCSPixelManager.h
//  SCSCoreKit
//
//  Created by Loïc GIRON DIT METAZ on 21/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import "SCSPixelStore.h"
#import "SCSURLSession.h"

NS_ASSUME_NONNULL_BEGIN

/**
 The pixel manager is used to call all pixel of the SDK and to handle failures. It can store unsuccessful pixels in a
 pixel store until expiration and retry them later.
 
 There should be only one instance of pixel manager (and only one pixel store) per app: the shared singleton should
 be used in most cases.
 */
@interface SCSPixelManager : NSObject

- (instancetype)init NS_UNAVAILABLE;

/// The shared instance of the SCSPixelManager object.
@property (class, nonatomic, readonly) SCSPixelManager *sharedInstance NS_SWIFT_NAME(shared);

/**
 Initialize a new SCSPixelManager.
 
 Note: for most cases, you should use the shared instance instead of instanciating a new pixel manager.
 
 @param pixelStore The pixel store used by the pixel manager to store and retrieve its pixels.
 @param urlSession The URL session that must be used to make actual HTTP calls.
 @return An initialized instance of SCSPixelManager.
 */
- (instancetype)initWithPixelStore:(SCSPixelStore *)pixelStore urlSession:(SCSURLSession *)urlSession NS_DESIGNATED_INITIALIZER;

/**
 Add a single pixel to the pixel manager and save it. The pixel will not be added if it already exists in the
 pixel store (same ID).
 
 Note: adding a pixel to the manager does not trigger any call, use callPixels if needed.
 
 @param pixel The pixel that needs to be added.
 */
- (void)addPixel:(SCSPixel *)pixel NS_SWIFT_NAME(add(pixel:));

/**
 Add an array of pixels to the pixel manager and save them. Any pixel that already exists in the pixel store
 will be ignored (same ID).
 
 Note: adding pixels to the manager does not trigger any call, use callPixels if needed.
 
 @param pixels The array of pixels that needs to be added.
 */
- (void)addPixels:(NSArray<SCSPixel *> *)pixels NS_SWIFT_NAME(add(pixels:));

/**
 Call all non expired pixels that are stored in the pixel store.
 
 Note: call to the callPixels method on the same pixel manager instance (the shared instance for example) are
 serialized, every call will be sent to a queue and will be executed in order, to prevent some pixels from being
 called multiple time and ensure thread safety.
 */
- (void)callPixels;

/**
 Call all non expired pixels that are stored in the pixel store and call a completion handler when finished (this
 handler should only be used for testing purpose).
 
 Note: call to the callPixels method on the same pixel manager instance (the shared instance for example) are
 serialized, every call will be sent to a queue and will be executed in order, to prevent some pixels from being
 called multiple times and ensure thread safety.
 
 @param completionHandler Handler called when the callPixels operation is finished.
 */
- (void)callPixelsWithCompletionHandler:(nullable void(^)(void))completionHandler NS_SWIFT_NAME(callPixels(completionHandler:));

/**
 Returns all pixels contained in the underlying pixel store.
 
 @return an array of all pixels contained in the underlying pixel store.
 */
- (NSArray<SCSPixel *> *)allPixels;

@end

NS_ASSUME_NONNULL_END
