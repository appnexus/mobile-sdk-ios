//
//  OMIDVASTProperties.h
//  AppVerificationLibrary
//
//  Created by Daria Sukhonosova on 30/06/2017.
//

#import <UIKit/UIKit.h>

/**
 *  List of supported video player positions.
 */
typedef NS_ENUM(NSUInteger, OMIDPosition) {
    OMIDPositionPreroll,
    OMIDPositionMidroll,
    OMIDPositionPostroll,
    OMIDPositionStandalone
};

/**
 *  This object is used to capture key VAST properties so this can be shared with all registered verification providers.
 */
@interface OMIDAppnexusVASTProperties : NSObject

@property(nonatomic, readonly, getter = isSkippable) BOOL skippable;
@property(nonatomic, readonly) CGFloat skipOffset;
@property(nonatomic, readonly, getter = isAutoPlay) BOOL autoPlay;
@property(nonatomic, readonly) OMIDPosition position;

/**
 *  This method enables the video player to create a new VAST properties instance for skippable video ad placement.
 *
 * @param skipOffset The number of seconds before the skip button is presented.
 * @param autoPlay Determines whether the video will auto-play content.
 * @param position The position of the video in relation to other content.
 * @return A new instance of VAST properties.
 */
- (nonnull instancetype)initWithSkipOffset:(CGFloat)skipOffset
                                  autoPlay:(BOOL)autoPlay
                                  position:(OMIDPosition)position;

/**
 *  This method enables the video player to create a new VAST properties instance for non-skippable video ad placement.
 *
 * @param autoPlay Determines whether the video will auto-play content.
 * @param position The position of the video in relation to other content.
 * @return A new instance of VAST properties.
 */
- (nonnull instancetype)initWithAutoPlay:(BOOL)autoPlay
                                position:(OMIDPosition)position;

- (null_unspecified instancetype)init NS_UNAVAILABLE;

@end
