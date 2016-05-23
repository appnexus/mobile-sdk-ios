//
//  IMStrandTableViewAdapter.h
//
//  
//  Copyright (c) 2015 InMobi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMStrandTableViewAdapterDelegate.h"

@class IMStrandPosition;

/**
 * The IMStrandTableViewAdapter class allows you to fetch and display ads in your tableview 
 */

@interface IMStrandTableViewAdapter : NSObject

/**
 * Delegate object to the IMStrandTableViewAdapter
 */

@property (nonatomic, weak) id <IMStrandTableViewAdapterDelegate> delegate;

/**
 * A free form set of keywords, separated by ',' to be sent with the ad request.
 * E.g: "sports,cars,bikes"
 */
@property (nonatomic, strong) NSString* keywords;

/**
 * Any additional information to be passed to InMobi.
 */
@property (nonatomic, strong) NSDictionary* extras;

/**
 * Initializes a IMStrandTableViewAdapter object
 * @param tableView UITableView where ad placement needs to be done
 * @param placementId long long, identifier for the ad requests
 * @param adPositioning IMStrandPosition, position object for ad positioning
 * @param tableViewCellClass Class, class of the tableViewCell
 */
+ (instancetype)adapterWithTableView:(UITableView *)tableView placementId:(long long)placementId adPositioning:(IMStrandPosition *)positioning tableViewCellClass:(Class)tableViewCellClass;

/**
 * Load the ads in the table view
 */
- (void)load;

/**
 * Clear all the ads from the table view
 */
- (void) clearAds;

@end

/**
 * Category for the UITableView to help your application with the methods to manipulate indexpaths when ads are displayed.
 * With the help of these methods you dont have to do any indexpath manipulation.
 */
@interface UITableView (IMStrandTableViewAdapter)

/**
 * Set strand adapter object for this tableview
 * @param adapter IMStrandTableViewAdapter, adapter object for this tableview
 */

- (void)im_setStrandAdapter:(IMStrandTableViewAdapter *)adapter;

/**
 * Get strand adapter of this tableview
 * @return IMStrandTableViewAdapter, adapter object for this tableview
 */
- (IMStrandTableViewAdapter *)im_strandAdapter;

- (void)im_setDataSource:(id<UITableViewDataSource>)dataSource;

- (id<UITableViewDataSource>)im_dataSource;

- (void)im_setDelegate:(id<UITableViewDelegate>)delegate;

- (id<UITableViewDelegate>)im_delegate;

- (void)im_beginUpdates;

- (void)im_endUpdates;

- (void)im_reloadData;

- (void)im_insertRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;

- (void)im_deleteRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;

- (void)im_reloadRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;

- (void)im_moveRowAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath;

- (void)im_insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation;

- (void)im_deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation;

- (void)im_reloadSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation;

- (void)im_moveSection:(NSInteger)section toSection:(NSInteger)newSection;

- (UITableViewCell *)im_cellForRowAtIndexPath:(NSIndexPath *)indexPath;

- (id)im_dequeueReusableCellWithIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath;

- (void)im_deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;

- (NSIndexPath *)im_indexPathForCell:(UITableViewCell *)cell;

- (NSIndexPath *)im_indexPathForRowAtPoint:(CGPoint)point;

- (NSIndexPath *)im_indexPathForSelectedRow;

- (NSArray *)im_indexPathsForRowsInRect:(CGRect)rect;

- (NSArray *)im_indexPathsForSelectedRows;

- (NSArray *)im_indexPathsForVisibleRows;

- (CGRect)im_rectForRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)im_scrollToRowAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated;

- (void)im_selectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition;

- (NSArray *)im_visibleCells;

@end