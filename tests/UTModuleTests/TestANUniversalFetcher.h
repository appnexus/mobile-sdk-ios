//
//  TestANUniversalFetcher.h
//  NewTestApp
//
//  Created by Punnaghai Puviarasu on 3/10/17.
//  Copyright © 2017 AppNexus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANUniversalAdFetcher.h"
#import "ANAdView.h"
#import "ANAdView+PrivateMethods.h"
#import "ANGlobal.h"
#import "ANTestGlobal.h"



@interface TestANUniversalFetcher : ANAdView<ANUniversalAdFetcherDelegate>

@property (nonatomic, strong)  NSMutableSet<NSValue *>  *allowedAdSizes;

@property (nonatomic, readwrite, weak) id<ANUniversalAdFetcherDelegate> delegate;


- (instancetype)initWithPlacementId:(NSString *)placementId;


@end
