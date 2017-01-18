//
//  RFMSupportedMediations.h
//  RFMAdSDK
//
//  Created by Rubicon Project on 4/8/14.
//  Copyright © 2014 Rubicon Project. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "RFMPartnerMediator.h"

#define RFM_MEDIATOR_CLASSNAME_DFP_BANNER @"RFMMediatorAdmDFPBanner"
#define RFM_MEDIATOR_CLASSNAME_DFP_INTERSTITIAL @"RFMMediatorAdmDFPInterstitial"
#define RFM_MEDIATOR_CLASSNAME_MoPub_BANNER @"RFMMediatorMoPubBanner"
#define RFM_MEDIATOR_CLASSNAME_MoPub_INTERSTITIAL @"RFMMediatorMoPubInterstitial"
#define RFM_MEDIATOR_CLASSNAME_MiM_BANNER @"RFMMediatorMiMBanner"
#define RFM_MEDIATOR_CLASSNAME_MiM_INTERSTITIAL @"RFMMediatorMiMInterstitial"
#define RFM_MEDIATOR_CLASSNAME_InMobi_BANNER @"RFMMediatorInMobiBanner"
#define RFM_MEDIATOR_CLASSNAME_InMobi_INTERSTITIAL @"RFMMediatorInMobiInterstitial"
#define RFM_MEDIATOR_CLASSNAME_FBAN_BANNER @"RFMMediatorFBANBanner"
#define RFM_MEDIATOR_CLASSNAME_FBAN_INTERSTITIAL @"RFMMediatorFBANInterstitial"
#define RFM_MEDIATOR_CLASSNAME_IAD_BANNER @"RFMMediatorIAdBanner"
#define RFM_MEDIATOR_CLASSNAME_IAD_INTERSTITIAL @"RFMMediatorIAdInterstitial"

/**
 * RFMSupportedMediations contains methods to register and unregister mediators, as
 * well as provide all supported mediations.
 */
@interface RFMSupportedMediations : NSObject

+ (RFMSupportedMediations *)sharedInstance;

/**
 * Returns a list of all currently registered partner mediator classes
 *
 * @return array of currently registered mediatior classes
 */

- (NSArray*)supportedMediations;

/**
 * Unregisters all partner mediator subclasses
 *
 * Calling this method will disable partner mediation
 */

- (void)unregisterMediation;

/**
 * Register a custom partner mediator subclass
 *
 * @param mediationInfo NSDictionary where classnames are keys and tags are the values
 */

- (void)registerCustomMediationInfo:(NSDictionary*)mediationInfo;

/**
 * Unregisters a partner mediator subclass
 *
 * @param mediatorClass the subclass of RFMPartnerMediator
 */

- (void)unregisterMediator:(Class)mediatorClass;

/**
 * Unregisters a list of specific partner mediator subclasses
 *
 * @param mediationClasses the array of subclasses of RFMPartnerMediator
 */

- (void)unregisterMediators:(NSArray*)mediationClasses;

@end

