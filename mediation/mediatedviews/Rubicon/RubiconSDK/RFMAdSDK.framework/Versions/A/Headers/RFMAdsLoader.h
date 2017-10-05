//
//  RFMAdsLoader.h
//  RFMAdSDK
//
//  Created by Rubicon Project on 2/28/17.
//  Copyright © 2017 Rubicon Project. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RFMAdsLoaderDelegate.h"

@protocol RFMPlayerControl;

/**
 * This class is responsible for the loading of ad request(s).  Currently,
 * this is only used for the loading of pre, mid and post roll video ads.
 */
@interface RFMAdsLoader : NSObject

/**
 * Delegate weak property.
 */
@property (nonatomic, weak) id<RFMAdsLoaderDelegate> delegate;
/**
 * Cacheable property, YES value indicates disk cache will be used to store ad content, 
 * NO indicates ad content will be loaded on demand.
 */
@property (nonatomic, assign, getter=isCacheable) BOOL cacheable;

/**
 * Loads the ad request by creating a network connection.
 * @param request RFMAdRequest model object that represents the ad request information
 * @param size CGSize size param that is passed into the ad request
 * @return BOOL which indicates whether the request can be queued for loading
 * @see loadRequest:size:videoPlayerAdapter:
 */
- (BOOL)loadRequest:(RFMAdRequest *)request
               size:(CGSize)size;

/**
 * Loads the ad request by creating a network connection.
 * @param request RFMAdRequest model object that represents the ad request information
 * @param size CGSize size param that is passed into the ad request
 * @param videoPlayerAdapter An object instance that conforms to the RFMPlayerControl protocol
 * @return BOOL which indicates whether the request was queued for loading
 * @see loadRequest:size:
 */
- (BOOL)loadRequest:(RFMAdRequest*)request
               size:(CGSize)size
 videoPlayerAdapter:(id <RFMPlayerControl>)videoPlayerAdapter;

@end
