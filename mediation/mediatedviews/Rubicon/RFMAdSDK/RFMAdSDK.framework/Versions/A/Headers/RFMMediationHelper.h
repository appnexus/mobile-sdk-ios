//
//  RFMMediationHelper.h
//  RFMAdSDK
//
//  Created by Rubicon Project on 4/8/14.
//  Copyright © 2014 Rubicon Project. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RFMMediationConstants.h"

@interface RFMMediationHelper : NSObject

+(id)JSONObjectForData:(NSData *)inputData;

+(CGRect)getApplicationFrame;

+(BOOL)isAdInInit:(adLoadingStatusTypes) status;
+(BOOL)isAdReadyForRequest:(adLoadingStatusTypes) status;
+(BOOL)isWaitingForAd:(adLoadingStatusTypes) status;
+(BOOL)isAdPrecached:(adLoadingStatusTypes) status;
+(BOOL)isAdInBannerView:(adLoadingStatusTypes) status;
+(BOOL)isAdInInterstitialView:(adLoadingStatusTypes) status;
+(BOOL)isAdRequestInterstitial:(adLoadingStatusTypes) status;

+(BOOL)isAdInLandingView:(adLoadingStatusTypes) status;
+(BOOL)isAdInModalLandingView:(adLoadingStatusTypes) status;
+(BOOL)isAdTypeInterstitial:(NSString *)adType;
+(BOOL)isAdReadyToDisplay:(adLoadingStatusTypes) status;
+(BOOL)shouldBlockAutoRedirects:(adLoadingStatusTypes) status;

@end
