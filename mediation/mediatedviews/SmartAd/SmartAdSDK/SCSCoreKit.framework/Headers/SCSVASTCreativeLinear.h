//
//  SCSVASTCreativeLinear.h
//  SCSCoreKit
//
//  Created by Thomas Geley on 21/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import "SCSVASTCreative.h"

NS_ASSUME_NONNULL_BEGIN

@class SCSVASTMediaFile, SCSVASTCreativeIcon;

@interface SCSVASTCreativeLinear : SCSVASTCreative

/// The Duration of this Linear Creative.
@property (nullable, nonatomic, strong) NSString *duration;

/// The SkipOffset for this Linear Creative.
@property (nullable, nonatomic, strong) NSString *skipOffset;

/// The AdParameters for this Linear Creative.
@property (nullable, nonatomic, strong) NSString *adParameters;

/// The Media Files for this Linear Creative.
@property (nonatomic, strong) NSMutableArray <SCSVASTMediaFile *> *mediaFiles;

/// The Icons for this Linear Creative.
@property (nonatomic, strong) NSMutableArray <SCSVASTCreativeIcon *> *icons;

- (instancetype)init NS_UNAVAILABLE;

/**
 Returns the most appropriate media file for this linear creative.
 
 @return The most appropriate media file for this linear creative.
 */
- (nullable SCSVASTMediaFile *)mostAppropriateMediaFile;

@end

NS_ASSUME_NONNULL_END
