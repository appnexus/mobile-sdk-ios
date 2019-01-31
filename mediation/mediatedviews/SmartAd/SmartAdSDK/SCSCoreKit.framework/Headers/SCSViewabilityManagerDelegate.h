//
//  SCSViewabilityManagerDelegate.h
//  SCSCoreKit
//
//  Created by Loïc GIRON DIT METAZ on 23/05/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class SCSViewabilityManager;

/**
 SCSViewabilityManager delegate.
 */
@protocol SCSViewabilityManagerDelegate <NSObject>

/**
 This method is called when the viewability status of the view is updated (the manager must be started).
 
 @param manager The manager that detected the viewability status update (can be used to retrieve easily the view that has been updated).
 @param viewable YES if the view is now viewable, NO otherwise.
 @param percentage The new viewability percentage of the view.
 */
- (void)viewabilityManager:(SCSViewabilityManager *)manager viewableStatus:(BOOL)viewable withPercentage:(CGFloat)percentage;

@end

NS_ASSUME_NONNULL_END
