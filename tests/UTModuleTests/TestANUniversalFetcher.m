//
//  TestANUniversalFetcher.m
//  NewTestApp
//
//  Created by Punnaghai Puviarasu on 3/10/17.
//  Copyright © 2017 AppNexus. All rights reserved.
//

#import "TestANUniversalFetcher.h"

@implementation TestANUniversalFetcher

-(instancetype)initWithPlacementId:(NSString *)placementId{
    
    self = [super init];
    if (!self)  { return nil; }
    
    self.placementId = placementId;
    
    self.delegate = self;
    
    //
    return self;

    
}

@end
