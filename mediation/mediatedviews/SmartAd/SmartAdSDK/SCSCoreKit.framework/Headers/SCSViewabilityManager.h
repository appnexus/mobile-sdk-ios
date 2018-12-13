//
//  SCSViewabilityManager.h
//  SCSCoreKit
//
//  Created by Loïc GIRON DIT METAZ on 23/05/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCSViewabilityManagerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/**
 The viewability manager can track manually or automatically the viewability status of a view.
 
 It can provide information about the viewable status of the view but also on the viewability percentage on screen.
 */
@interface SCSViewabilityManager : NSObject

/// The view currently being tracked by the viewability manager.
@property (nonatomic, weak) UIView *view;

/// The delegate that should be warned if the view status changes
@property (nullable, nonatomic, weak) id<SCSViewabilityManagerDelegate> delegate;

- (instancetype)init NS_UNAVAILABLE;

/**
 Initialize a new instance of SCSViewabilityManager tied with a view.
 
 @param view The view that needs to be tracked by the viewability manager.
 @param delegate An object implementing the SCSViewabilityManagerProtocol that will be warned if the viewability status changes.
 @return An initialized instance of SCSViewabilityManager
 */
- (instancetype)initWithView:(UIView *)view delegate:(nullable id<SCSViewabilityManagerDelegate>)delegate NS_DESIGNATED_INITIALIZER;

/**
 Starts tracking for viewability status changes.
 */
- (void)startViewabilityTracking;

/**
 Stops tracking for viewability status changes.
 */
- (void)stopViewabilityTracking;

/**
 Manually retrieve the viewable status of the view (this will work even if the viewability manager is not started).
 
 A view is considered viewable if:
 
 - it is not hidden (or with an alpha equal to 0)
 - none of its parents view is hidden (or with an alpha equal to 0)
 - its viewability percentage is greater than 50%
 
 @warning This method will not detect if another view is overlapping.
 */
- (BOOL)isViewViewable;

/**
 Manually retrieve the viewability percentage of the view (this will work even if the viewability manager is not started).
 
 @warning This method will not detect if another view is overlapping.
 */
- (CGFloat)viewabilityPercentage;

@end

NS_ASSUME_NONNULL_END
