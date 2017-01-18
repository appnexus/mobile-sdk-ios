//
//  RFMNativeLink.h
//  RFMAdSDK
//
//  Created by Rubicon Project on 9/14/16.
//  Copyright © 2016 Rubicon Project. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RFMNativeLink : NSObject

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSArray *clickTrackers;
@property (nonatomic, strong) NSURL *fallback;

- (id)initWithUrl:(NSURL *)url
    clickTrackers:(NSArray *)clickTrackers
         fallback:(NSURL *)fallback;

@end
