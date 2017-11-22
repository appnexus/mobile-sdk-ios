//
//  TestANUniversalFetcher.m
//  NewTestApp
//
//  Created by Punnaghai Puviarasu on 3/10/17.
//  Copyright © 2017 AppNexus. All rights reserved.
//

#import "TestANUniversalFetcher.h"

@implementation TestANUniversalFetcher



-(instancetype)initWithPlacementId:(NSString *)placementId
{
    self = [super init];
    if (!self)  { return nil; }

    self.placementId     = placementId;
    self.allowedAdSizes  = [[NSMutableSet alloc] initWithArray:@[ [NSValue valueWithCGSize:kANAdSize1x1] ]];

    self.delegate = self;
    
    //
    return self;
}



#pragma mark - ANUniversalAdFetcherFoundationDelegate  (Partial implementation.)

- (NSArray<NSValue *> *)adAllowedMediaTypes
{
    ANLogTrace(@"");
    return  @[ @(ANAllowedMediaTypeVideo) ];   //XXX
}

- (NSDictionary *) internalDelegateUniversalTagSizeParameters
{
    NSMutableDictionary  *delegateReturnDictionary  = [[NSMutableDictionary alloc] init];

    [delegateReturnDictionary setObject:[NSValue valueWithCGSize:kANAdSize1x1]  forKey:ANInternalDelgateTagKeyPrimarySize];
    [delegateReturnDictionary setObject:self.allowedAdSizes                     forKey:ANInternalDelegateTagKeySizes];
    [delegateReturnDictionary setObject:@(self.allowSmallerSizes)               forKey:ANInternalDelegateTagKeyAllowSmallerSizes];

    return  delegateReturnDictionary;
}


@end
