//
//  RFMBaseMediator.h
//  RFMAdSDK
//
//  Created by Rubicon Project on 3/6/14.
//  Copyright © 2014 Rubicon Project. All rights reserved.
//


@protocol RFMBaseMediatorDelegate;

@interface RFMBaseMediator : NSObject

@property (nonatomic, weak) id<RFMBaseMediatorDelegate> mediationDelegate;

-(id)initWithMediationDelegate:(id<RFMBaseMediatorDelegate>)delegate;

-(void)loadAd;
-(void)loadAdWithParams:(NSDictionary *)adParams;

-(BOOL)supportsCachedAd;
-(void)unregisterDelegate;
-(void)rotatedToNewOrientation:(UIInterfaceOrientation)newOrientation;
-(void)stopLoadingAd;
-(BOOL)isPartner;

@end
