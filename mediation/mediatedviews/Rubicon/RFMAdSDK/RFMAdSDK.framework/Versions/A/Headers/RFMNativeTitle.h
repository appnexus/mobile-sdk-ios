//
//  RFMNativeTitle.h
//  RFMAdSDK
//
//  Created by Rubicon Project on 9/14/16.
//  Copyright © 2016 Rubicon Project. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RFMNativeLink.h"

@interface RFMNativeTitle : NSObject

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) RFMNativeLink *link;

- (id)initWithText:(NSString *)text
              link:(RFMNativeLink *)link;

@end
