//
//  ANWarmupWebView.h
//  AppNexusSDK
//
//  Created by Punnaghai Puviarasu on 5/20/20.
//  Copyright © 2020 AppNexus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANWebView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ANWarmupWebView : NSObject

+ (instancetype)sharedInstance;

- (ANWebView *) fetchWarmedUpWebView;

@end

NS_ASSUME_NONNULL_END
