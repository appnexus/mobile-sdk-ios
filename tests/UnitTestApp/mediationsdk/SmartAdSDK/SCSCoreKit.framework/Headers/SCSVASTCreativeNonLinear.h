//
//  SCSVASTCreativeNonLinear.h
//  SCSCoreKit
//
//  Created by Thomas Geley on 21/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import "SCSVASTCreative.h"

NS_ASSUME_NONNULL_BEGIN

@class SCSVASTURL;

@interface SCSVASTCreativeNonLinear : SCSVASTCreative

/// The URL of the NonLinear Static Resource.
@property (nullable, nonatomic, strong) SCSVASTURL *staticResource;

/// The URL of the NonLinear IFrame Resource.
@property (nullable, nonatomic, strong) SCSVASTURL *iFrameResource;

/// The URL of the NonLinear HTML Resource.
@property (nullable, nonatomic, strong) SCSVASTURL *htmlResource;

/// The AdParameters for the NonLinear.
@property (nullable, nonatomic, strong) NSString *adParameters;

/// The ID of the NonLinear.
@property (nullable, nonatomic, strong) NSString *id;

/// The API Framework for the NonLinear.
@property (nullable, nonatomic, strong) NSString *apiFramework;

/// The minimum suggested duration for the NonLinear to be displayed.
@property (nullable, nonatomic, strong) NSString *minSuggestedDuration;

/// Indicates whether or not the NonLinear is scalable.
@property (nonatomic, assign) BOOL scalable;

/// Indicates whether or not the NonLinear should maintain its aspect ratio when scaled.
@property (nonatomic, assign) BOOL maintainAspectRatio;

/// The width of the NonLinear creative.
@property (nonatomic, assign) float width;

/// The height of the NonLinear creative.
@property (nonatomic, assign) float height;

/// The width of the NonLinear creative when expanded. This is not implemented in this SDK.
@property (nonatomic, assign) float expandedWidth;

/// The height of the NonLinear creative when expanded. This is not implemented in this SDK.
@property (nonatomic, assign) float expandedHeight; 

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
