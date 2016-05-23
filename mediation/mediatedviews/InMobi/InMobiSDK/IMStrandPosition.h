//
//  IMStrandPosition.h
//  IMMonetization
//
//
//  Copyright (c) 2015 InMobi. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * The 'IMStrandPosition' class is a model class that allows you to specify the positioning of the ads in the table
 * or collection view. You can specify the fixed position and the repeating interval for the ads.
 */
 

@interface IMStrandPosition : NSObject <NSCopying>

/**
 * Set of fixed positions for the ad placement
 */

@property (nonatomic, strong, readonly) NSMutableOrderedSet *fixedPositions;

/**
 * Repeating interval for the ads in the list
 */

@property (nonatomic, assign, readonly) NSUInteger stride;

/**
 * Get the IMStrandPosition object
 */

+ (instancetype)positioning;

/**
 * Add fixed position to the positioning object
 * @param indexPath NSIndexPath for this fixed position
 */

- (void)addFixedIndexPath:(NSIndexPath *)indexPath;

/**
 * Enable repeating of the ads with interval
 * @param stride NSUInteger repeating interval for the ads
 */

- (void)enableRepeatingPositionsWithStride:(NSUInteger)stride;

@end
