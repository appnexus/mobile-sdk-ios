//
//  SCSVASTMediaFile.h
//  SCSCoreKit
//
//  Created by Thomas Geley on 21/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SCSVASTURL;

@interface SCSVASTMediaFile : NSObject

/// The ID of the media file.
@property (nullable, nonatomic, readonly) NSString *id;

/// The Delivery Type of the media file.
@property (nullable, nonatomic, readonly) NSString *delivery;

/// The content type of the media file.
@property (nullable, nonatomic, readonly) NSString *type;

/// The bitrate of the media file.
@property (nonatomic, readonly) float bitrate;

/// The maximum bitrate matched by the media file.
@property (nonatomic, readonly) float minBitrate;

/// The minimum bitrate matched by the media file.
@property (nonatomic, readonly) float maxBitrate;

/// The media file's video width.
@property (nonatomic, readonly) float width;

/// The media file's video height.
@property (nonatomic, readonly) float height;

/// true if the media file is scalable.
@property (nonatomic, readonly) BOOL scalable;

/// true if the media file should maintain its aspect ratio when scaled.
@property (nonatomic, readonly) BOOL maintainAspectRatio;

/// The codec of the media file.
@property (nullable, readonly, strong) NSString *codec;

/// The API framework of the media file.
@property (nullable, readonly, strong) NSString *apiFramework;

/// The URL of the media file.
@property (nullable, readonly, strong) SCSVASTURL *url;

- (instancetype)init NS_UNAVAILABLE;

/**
 Initializer from a dictionary.
 
 @param dictionary a dictionary from the parsed XML.
 */
- (nullable instancetype)initWithDictionary:(NSDictionary *)dictionary;

/**
 Indicates whether or not the media is valid, ie: it has all required properties.
 
 @return true if the media is valid and can be played.
 */
- (BOOL)isValid;

/**
 Indicates whether or not the media is a VPAID.
 
 @return true if the media is a VPAID. False for regular video medias.
 */
- (BOOL)isVPAID;

/**
 Indicates whether or not the media is supported.
 
 @return true if the media is supported.
 */
- (BOOL)isSupported;

@end

NS_ASSUME_NONNULL_END
