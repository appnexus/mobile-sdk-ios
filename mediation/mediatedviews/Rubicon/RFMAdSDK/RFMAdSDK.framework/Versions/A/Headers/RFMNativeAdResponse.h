//
//  RFMNativeAdResponse.h
//  RFMAdSDK
//
//  Created by Rubicon Project on 8/16/16.
//  Copyright © 2016 Rubicon Project. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RFMNativeAdChoices.h"
#import "RFMNativeAssets.h"
#import "RFMNativeLink.h"

@interface RFMNativeAdResponse : NSObject

@property (nonatomic, strong) RFMNativeAssets *assets;
@property (nonatomic, strong) RFMNativeAdChoices *adChoices;
@property (nonatomic, strong) RFMNativeLink *link;
@property (nonatomic, strong) NSArray *impTrackers;

- (id)initWithAssets:(RFMNativeAssets *)assets
           adChoices:(RFMNativeAdChoices *)adChoices
                link:(RFMNativeLink *)link
         impTrackers:(NSArray *)impTrackers;

@end
