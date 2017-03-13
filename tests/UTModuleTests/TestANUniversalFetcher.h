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

@interface TestANUniversalFetcher : ANAdView<ANUniversalAdFetcherDelegate>

@property (nonatomic, readwrite, weak) id<ANUniversalAdFetcherDelegate> delegate;

- (instancetype)initWithPlacementId:(NSString *)placementId;



@end
