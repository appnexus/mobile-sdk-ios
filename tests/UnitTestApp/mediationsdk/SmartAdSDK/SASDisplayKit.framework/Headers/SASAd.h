//
//  SASAd.h
//  SmartAdServer
//
//  Created by Clémence Laurent on 03/06/14.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Represents the ad's properties, as it has been programmed in the Smart Manage interface.
 */
@interface SASAd : NSObject <NSCopying, NSCoding>

/// The original portrait creative size.
@property (nonatomic, readonly) CGSize portraitSize;

/// The original landscape creative size.
@property (nonatomic, readonly) CGSize landscapeSize; 

/// The dictionary used to add extra parameters that you can interpret in your app.
@property (nonatomic, readonly, nullable, strong) NSDictionary *extraParameters;

/// The original aspect ratio of the creative.
@property (nonatomic, readonly) CGFloat aspectRatio;

/// A string which contains useful informations about the ad.
///
/// This string can be sent to the Smart AdServer support to improve bug resolution if the issue is related
/// to a given ad, or can be used with your app crash reporting tool to analyze crash sources.
///
/// @warning The string content and format is not guaranted to stay the same: you should avoid parsing it.
@property (nonatomic, readonly) NSString *debugString;

/**
 Returns the recommanded height to display the ad in a given container, according to the creative's aspect ratio.
 
 If no size is defined for the creative, this method will compute the recommanded height using a 32:5 aspect ratio (standard iOS banner ratio).
 
 @param container The container in which the ad will be displayed (if nil, the current window will be used instead).
 @return The optimized height for the ad view.
 */
- (CGFloat)optimalAdHeightForContainer:(nullable UIView *)container;

@end

NS_ASSUME_NONNULL_END
