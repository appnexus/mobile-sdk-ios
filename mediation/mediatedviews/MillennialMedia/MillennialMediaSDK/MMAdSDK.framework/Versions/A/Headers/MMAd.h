//
//  MMAd.h
//  MMAdSDK
//
//  Copyright (c) 2015 Millennial Media, Inc. All rights reserved.
//

#ifndef MMAd_Header_h
#define MMAd_Header_h

#import <Foundation/Foundation.h>

/**
 * The base class for all ad placement types. This class should not be directly instantiated.
 */
@interface MMAd : NSObject
/**
 * Initializes a newly created ad.
 *
 * @param apid The APID (ad placement ID).
 */
-(nullable instancetype)initWithPlacementId:(nonnull NSString*)placementId;

/**
 * The APID provided at the time of ad creation. This value cannot be changed.
 */
@property (nonatomic, readonly, nonnull) NSString* placementId;
@end

#endif
