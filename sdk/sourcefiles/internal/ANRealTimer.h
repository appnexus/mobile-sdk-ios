//
//  ANRealTimer.h
//  AppNexusSDK
//
//  Created by Punnaghai Puviarasu on 2/17/21.
//  Copyright © 2021 AppNexus. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ANRealTimer : NSObject

+ (instancetype)sharedManager;
+ (void) addListenerObject: (id) adObject;
+ (void) removeListenerObject: (id) adObject;

@end

NS_ASSUME_NONNULL_END
