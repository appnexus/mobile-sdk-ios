//
//  SASAdViewContainerCell.h
//  SmartAdServer
//
//  Created by Thomas Geley on 28/01/2016.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class SASAdView;

/**
 A SASAdViewContainerCell is a dedicated UITableViewCell which facilitates the integration of a
 SASBannerView inside a table view.
 */
@interface SASAdViewContainerCell : UITableViewCell

/**
 Returns an initialized SASAdViewContainerCell instance.
 
 @param adView The ad view that will be displayed in the cell.
 @param tableView The UITableView instance which contains the cell.

 @return An initialized instance of SASAdViewContainerCell with proper reuseIdentifier, layout and autosizing.
 */
+ (SASAdViewContainerCell *)cellForAdView:(SASAdView *)adView inTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
