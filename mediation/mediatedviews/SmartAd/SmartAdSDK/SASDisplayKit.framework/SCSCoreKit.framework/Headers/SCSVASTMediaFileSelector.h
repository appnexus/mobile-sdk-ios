//
//  SCSVASTMediaFileSelector.h
//  SCSCoreKit
//
//  Created by Thomas Geley on 22/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IOS || (TARGET_OS_IPHONE && !TARGET_OS_TV)
    #import "SCSNetworkInfo.h"
#elif TARGET_OS_TV
    #import "SCSEnums.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@class SCSVASTMediaFile;

/**
 This class select the most appropriate media file in a mediaFiles array.
 
 - if the phone is using a wifi connection, the better videos are first
 - if the phone is using a cellular connection, the worst videos are first.
 
 The array is traversed from first to last and the first video that is between the min and the max
 authorized values is selected.
 
 If a video greater than the maximum condition is reached, no other video in the array will match
 authorized values (since the array is sorted) so we immediately select the current video.
 If we reach the end of the array, we select the video last video.
 
 Note: media files without bitrate are excluded from the selection algorithm except if there is no
 media file with a bitrate, in the case, the first video of the array is selected.
 */
@interface SCSVASTMediaFileSelector : NSObject

/// The minimum bitrate for media files selection.
@property (nonatomic, assign) float minBitrate;

/// The maximum bitrate for media files selection.
@property (nonatomic, assign) float maxBitrate;

/// An array of all available media files.
@property (nonatomic, strong) NSArray <SCSVASTMediaFile *> *media;

/// The network access technology type.
@property (nonatomic, assign) SCSNetworkInfoNetworkAccessType networkAccessType;

- (instancetype)init NS_UNAVAILABLE;

/**
 Initialize a new instance of the media file selector class.
 
 @param minBitrate The lowest bitrate that should be use to select a video.
 @param maxBitrate The biggest bitrate that should be use to select a video.
 @param media The array of candidates media files.
 @param networkAccessType The network access technology type.
 */
- (instancetype)initWithMinBitrate:(float)minBitrate maxBitrate:(float)maxBitrate media:(NSArray <SCSVASTMediaFile *> *)media networkAccessType:(SCSNetworkInfoNetworkAccessType)networkAccessType NS_DESIGNATED_INITIALIZER;

/**
 Convenience initializer for SCSVASTMediaFileSelector that defines the wifiConnection parameter from the actual phone state using SCSNetworkInfo.
 
 @param minBitrate The lowest bitrate that should be use to select a video.
 @param maxBitrate The biggest bitrate that should be use to select a video.
 @param media The array of candidates media files.
 */
- (instancetype)initWithMinBitrate:(float)minBitrate maxBitrate:(float)maxBitrate media:(NSArray <SCSVASTMediaFile *> *)media;

/**
 Returns the selected mediaFile according to initialization parameters. Can be nil.
 
 @return The selected mediaFile.
 */
- (nullable SCSVASTMediaFile *)mediaFile;

@end

NS_ASSUME_NONNULL_END
