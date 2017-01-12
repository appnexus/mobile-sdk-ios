//
//  RFMNativeDataAsset.h
//  RFMAdSDK
//
//  Created by Rubicon Project on 9/14/16.
//  Copyright © 2016 Rubicon Project. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RFMNativeLink.h"

@interface RFMNativeDataAsset : NSObject

@property (nonatomic, strong) NSString *value;
@property (nonatomic, strong) RFMNativeLink *link;

- (id)initWithValue:(NSString *)value
               link:(RFMNativeLink *)link;

@end
