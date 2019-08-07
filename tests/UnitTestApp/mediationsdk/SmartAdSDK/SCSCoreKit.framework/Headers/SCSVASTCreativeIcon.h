//
//  SCSVASTCreativeIcon.h
//  SCSCoreKit
//
//  Created by Thomas Geley on 21/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import "SCSVASTCreative.h"

NS_ASSUME_NONNULL_BEGIN

@class SCSVASTURL;

@interface SCSVASTCreativeIcon : SCSVASTCreative

/// The URL of the Icon Static Resource.
@property (nullable, nonatomic, strong) SCSVASTURL *staticResource;

/// The URL of the Icon IFrame Resource.
@property (nullable, nonatomic, strong) SCSVASTURL *iFrameResource;

/// The URL of the Icon HTML Resource.
@property (nullable, nonatomic, strong) SCSVASTURL *htmlResource;

/// The Program of the Icon.
@property (nullable, nonatomic, strong) NSString *program;

/// The Duration for which the icon should be displayed.
@property (nullable, nonatomic, strong) NSString *duration;

/// The Offset since when the Icon should be displayed.
@property (nullable, nonatomic, strong) NSString *offset;

/// The API Framework for the Icon.
@property (nullable, nonatomic, strong) NSString *apiFramework;

/// The width of the Icon.
@property (nonatomic, assign) float width;

/// The height of the Icon.
@property (nonatomic, assign) float height;

/// The horizontal coordinate of the top right corner of the Icon.
@property (nonatomic, assign) float xPosition;

/// The vertical coordinate of the top right corner of the Icon.
@property (nonatomic, assign) float yPosition;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
