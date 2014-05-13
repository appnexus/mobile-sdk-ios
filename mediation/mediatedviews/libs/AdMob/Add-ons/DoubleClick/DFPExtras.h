//
//  DFPExtras.h
//  Google Ads iOS SDK
//
//  Copyright (c) 2012 Google Inc. All rights reserved.
//
//  To add DFP extras to an ad request:
//    DFPExtras *extras = [[[DFPExtras alloc] init] autorelease];
//    extras.additionalParameters = @{
//      @"key" : @"value"
//    };
//    GADRequest *request = [GADRequest request];
//    [request registerAdNetworkExtras:extras];
//

#import "GADAdMobExtras.h"

@interface DFPExtras : GADAdMobExtras

/// Content URL for targeting information.
@property(nonatomic, copy) NSString *contentURL;
/// Publisher provided user ID.
@property(nonatomic, copy) NSString *publisherProvidedID;

@end
