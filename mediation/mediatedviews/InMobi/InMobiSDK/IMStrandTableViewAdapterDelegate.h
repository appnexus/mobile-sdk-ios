//
//  IMStrandTableViewAdapterDelegate.h
//  IMMonetization
//
//  Copyright (c) 2015 InMobi. All rights reserved.
//

#import <Foundation/Foundation.h>


@class IMStrandTableViewAdapter;
@class IMRequestStatus;
@protocol IMStrandTableViewAdapterDelegate <NSObject>

/**
 * Notifies the delegate that the strandTableViewAdapter ad has finished loading
 */
-(void)strandTableViewAdapter:(IMStrandTableViewAdapter*)strandTableViewAdapter adDidFinishLoadingAtIndexPath:(NSIndexPath*)indexPath;
/**
 * Notifies the delegate that the strandTableViewAdapter ad has been removed
 */
-(void)strandTableViewAdapter:(IMStrandTableViewAdapter*)strandTableViewAdapter adsRemovedFromIndexPaths:(NSArray*)indexPaths;
/**
 * Notifies the delegate that the strandTableViewAdapter ad has failed to load with error.
 */
-(void)strandTableViewAdapter:(IMStrandTableViewAdapter*)strandTableViewAdapter adDidFailToLoadAtIndexPath:(NSIndexPath*)indexPath withError:(IMRequestStatus*)error;
/**
 * Notifies the delegate that the strandTableViewAdapter ad would be presenting a full screen content.
 */
-(void)strandTableViewAdapter:(IMStrandTableViewAdapter*)strandTableViewAdapter adAtIndexPathWillPresentScreen:(NSIndexPath*)indexPath;
/**
 * Notifies the delegate that the strandTableViewAdapter ad has presented a full screen content.
 */
-(void)strandTableViewAdapter:(IMStrandTableViewAdapter*)strandTableViewAdapter adAtIndexPathDidPresentScreen:(NSIndexPath*)indexPath;
/**
 * Notifies the delegate that the strandTableViewAdapter ad would be dismissing the presented full screen content.
 */
-(void)strandTableViewAdapter:(IMStrandTableViewAdapter*)strandTableViewAdapter adAtIndexPathWillDismissScreen:(NSIndexPath*)indexPath;
/**
 * Notifies the delegate that the strandTableViewAdapter ad has dismissed the presented full screen content.
 */
-(void)strandTableViewAdapter:(IMStrandTableViewAdapter*)strandTableViewAdapter adAtIndexPathDidDismissScreen:(NSIndexPath*)indexPath;
/**
 * Notifies the delegate that the user will be taken outside the application context.
 */
-(void)strandTableViewAdapter:(IMStrandTableViewAdapter*)strandTableViewAdapter userWillLeaveApplicationFromAdAtIndexPath:(NSIndexPath*)indexPath;

@end
