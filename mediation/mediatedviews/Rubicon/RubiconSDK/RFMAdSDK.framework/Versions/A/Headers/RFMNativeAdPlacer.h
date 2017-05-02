//
//  RFMNativeAdPlacer.h
//  RFMAdSDK
//
//  Created by Rubicon Project on 2/1/17.
//  Copyright © 2017 Rubicon Project. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RFMAdRequest.h"
#import "RFMNativeAdResponse.h"

@class RFMNativeAdPlacer;

/**
 * Native ad placer protocol for receiving native ad callbacks or notifications using native ad placer.
 *
 * The native ad placer delegate should conform to this protocol.
 */
@protocol RFMNativeAdPlacerDelegate <NSObject>

/**
 * **Optional** Delegate callback when native ad request using native ad placer has been sent to server.
 *
 * This callback is triggered when a native ad request using native ad placer has been successfully sent
 * to the ad server. Please note that this does not signify that a response has been received from the ad
 * server.
 *
 * @param indexPath The cell index path for which this callback has been triggered.
 * @param placer The native ad placer for which this callback has been triggered.
 */
- (void)didRequestNativeAdForIndexPath:(NSIndexPath *)indexPath placer:(RFMNativeAdPlacer *)placer;

/**
 * **Optional** Native ad has been successfully fetched from the ad server and cached using native ad placer.
 *
 * @param indexPath The cell index path for which this callback has been triggered.
 * @param placer The native ad placer for which this callback has been triggered.
 * @see didFailToReceiveNativeAdForIndexPath:placer:reason:
 */
- (void)didReceiveNativeAdResponseForIndexPath:(NSIndexPath *)indexPath placer:(RFMNativeAdPlacer *)placer;

/**
 * **Optional** SDK failed to receive and cache native ad using native ad placer.
 *
 * @param indexPath The index path for which this callback has been triggered.
 * @param placer The native ad placer for which this callback has been triggered.
 * @param errorReason The reason for failure to receive and cache native ad.
 * @see didReceiveNativeAdResponseForIndexPath:placer:
 */
- (void)didFailToReceiveNativeAdForIndexPath:(NSIndexPath *)indexPath placer:(RFMNativeAdPlacer *)placer reason:(NSString *)errorReason;

@end


/**
 * RFMNativeAdPlacer class allows you to request native ads from the RFM ad server to be placed in your
 * table view.
 *
 * After creating an instance of RFMNativeAdPlacer, make a call to request native ads. You may then request
 * a native ad response for a given index path.
 */
@interface RFMNativeAdPlacer : NSObject

@property (nonatomic, weak, setter = setDelegate:) id<RFMNativeAdPlacerDelegate> delegate;
@property (nonatomic, setter = setTableView:) UITableView *tableView;
@property (nonatomic, setter = setAdIndexPaths:) NSArray *adIndexPaths;
@property (nonatomic, setter = setAdInterval:) NSNumber *adInterval;

/**
 * Create an instance of RFMNativeAdPlacer with a table view and ad index paths.
 *
 * @param delegate The delegate that conforms to RFMNativeAdPlacerDelegate.
 * @param tableView The table view where the native ads are to be placed.
 * @param adIndexPaths A list of table view cell index paths where the native ads should be placed.
 */
- (id)initWithDelegate:(id<RFMNativeAdPlacerDelegate>)delegate tableView:(UITableView *)tableView adIndexPaths:(NSArray *)adIndexPaths;

/**
 * Create an instance of RFMNativeAdPlacer with a table view and ad index interval.
 *
 * @param delegate The delegate that conforms to RFMNativeAdPlacerDelegate.
 * @param tableView The table view where the native ads are to be placed.
 * @param adInterval The interval for which ads should be placed in the table view cells. First cell in table
 * is index 0. i.e. If you would like a native ad to be placed in every other cell then the ad interval is 2.
 */
- (id)initWithDelegate:(id<RFMNativeAdPlacerDelegate>)delegate tableView:(UITableView *)tableView adInterval:(NSNumber *)adInterval;

/**
 * Request native ads using native ad placer from RFM ad server.
 *
 * @param requestParams Request parameters for this call. Instance of RFMAdRequest.
 */
- (BOOL)requestNativePlacerAdsWithParams:(RFMAdRequest *)requestParams;

/**
 * Register native ad view to enable SDK handling of impressions and click tracking.
 *
 * @param nativeView The parent native ad view.
 * @param viewController The view controller for which you are using this method.
 */
- (BOOL)registerViewForInteraction:(UIView *)nativeView viewController:(UIViewController *)viewController;

/**
 * Retrieve a native ad response object of type RFMNativeAdResponse for a given index path.
 *
 * @param indexPath The table view cell index path for which you are requesting a native ad.
 */
- (RFMNativeAdResponse *)getNativeAdResponseForIndexPath:(NSIndexPath *)indexPath;

@end
