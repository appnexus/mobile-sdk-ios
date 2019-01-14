//
//  SCSVASTCreativeCompanion.h
//  SCSCoreKit
//
//  Created by Thomas Geley on 21/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import "SCSVASTCreative.h"

NS_ASSUME_NONNULL_BEGIN

@class SCSVASTURL;

@interface SCSVASTCreativeCompanion : SCSVASTCreative

/// The URL of the Companion Static Resource.
@property (nullable, nonatomic, readonly) SCSVASTURL *staticResource;

/// The URL of the Companion IFrame Resource.
@property (nullable, nonatomic, readonly) SCSVASTURL *iFrameResource;

/// The URL of the Companion HTML Resource.
@property (nullable, nonatomic, readonly) SCSVASTURL *htmlResource;

/// The AdParameters for the Companion.
@property (nullable, nonatomic, readonly) NSString *adParameters;

/// The ID of the Companion.
@property (nullable, nonatomic, readonly) NSString *id;

/// The Slot ID where the Companion should be displayed.
@property (nullable, nonatomic, readonly) NSString *adSlotID;

/// The width of the companion creative, in pixels.
@property (nonatomic, readonly) float width;

/// The height of the companion creative, in pixels.
@property (nonatomic, readonly) float height;

/// The width of the asset used by the companion creative, in pixels. Used only if width property is not set.
@property (nonatomic, readonly) float assetWidth;

/// The height of the asset used by the companion creative, in pixels. Used only if the height property is not set.
@property (nonatomic, readonly) float assetHeight;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
