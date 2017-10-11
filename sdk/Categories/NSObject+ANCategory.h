//
//  NSObject+ANCategory.h
//  ANSDK
//
//  Created by Punnaghai Puviarasu on 10/11/17.
//  Copyright © 2017 AppNexus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject(ANCategory)

- (void)runInBlock:(void (^)(void))block;

@end
