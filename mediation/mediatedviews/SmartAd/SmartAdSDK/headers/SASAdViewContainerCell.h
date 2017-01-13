//
//  SASAdViewContainerCell.h
//  AdViewer
//
//  Created by Thomas Geley on 28/01/2016.
//  Copyright © 2016 Smart AdServer. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SASAdView;

/**
 A SASAdViewContainerCell is a dedicated UITableViewCell which facilitates UITableView integration of SASBannerViews.
 */
@interface SASAdViewContainerCell : UITableViewCell

/**
 Returns an initialized SASAdViewContainerCell object.
 
 @param adView The adView that will be displayed in the cell (mandatory).
 @param tableView The UITableView instance which contains the cell (mandatory).

 @return An initialized instance of SASAdViewContainerCell with proper reuseIdentifier, layout and autosizing.
 */
+ (SASAdViewContainerCell *)cellForAdView:(SASAdView *)adView inTableView:(UITableView *)tableView;

@end
