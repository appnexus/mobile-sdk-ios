//
//  NSObject+ANCategory.m
//  ANSDK
//
//  Created by Punnaghai Puviarasu on 10/11/17.
//  Copyright © 2017 AppNexus. All rights reserved.
//

#import "NSObject+ANCategory.h"

@implementation NSObject(ANCategory)

- (void)runInBlock:(void (^)(void))block {
    dispatch_async(dispatch_get_main_queue(), ^{
        block();
    });
}

@end
