//
//  RFMReward.h
//  RFMAdSDK
//
//  Created by Rubicon Project on 6/8/16.
//  Copyright © 2016 Rubicon Project. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RFMReward : NSObject

@property (nonatomic, strong) NSDictionary *info;

- (id)initWithRewardInfo:(NSDictionary *)info;

@end
