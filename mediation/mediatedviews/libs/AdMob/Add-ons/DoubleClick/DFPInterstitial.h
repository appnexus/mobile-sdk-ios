//
//  DFPInterstitial.h
//  Google Ads iOS SDK
//
//  Copyright (c) 2012 Google Inc. All rights reserved.
//

#import "GADInterstitial.h"

@protocol GADAppEventDelegate;

@interface DFPInterstitial : GADInterstitial

@property(nonatomic, weak) NSObject<GADAppEventDelegate> *appEventDelegate;

@end
