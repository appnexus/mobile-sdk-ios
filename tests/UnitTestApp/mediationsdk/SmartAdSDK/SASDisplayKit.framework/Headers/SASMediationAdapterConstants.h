//
//  SASMediationAdapterConstants.h
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 19/09/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>


////////////////////////////////////////////////////////////////////////////////////////
//
//  CLIENT PARAMETERS
//
//  These constants are allowing you to get all possible information available in the
//  'clientParameters' dictionary provided during a mediation ad request.
//
//  Please note that these keys might be non available depending if the information
//  can be acquired at ad request time.
//
////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - Misc Client parameters

// The current user location, if available.
#define SASMediationClientParameterLocation                 @"location"

// The current ad view size (for banners).
//
// Please note that this value, if available, represents the size at the time of the ad call
// and might change later depending of the integration of the SASBannerView instance.
//
// This size is defined as a CGSize encoded into a NSValue.
#define SASMediationClientParameterAdViewSize               @"adViewSize"

#pragma mark - GDPR client parameters

// Boolean that states if GDPR applies for this particular app/user.
#define SASMediationClientParameterGDPRApplies              @"gdprApplies"

// Consent string associated with this user if any.
#define SASMediationClientParameterGDPRConsent              @"gdprConsent"



////////////////////////////////////////////////////////////////////////////////////////
//
//  OVERRIDABLE VIEWS
//
//  These constants are allowing you to get all possible views that can be overriden
//  during the mediation native ad views registering process.
//  For instance, you might want to add a third ad choices button over the button
//  used in the final app if the third party SDK works that way.
//
//  Please note that these keys might be non available depending if the view is
//  actually implemented in the views that are being registered.
//
////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - Overridable views

// The view used to display a video media.
#define SASMediationOverridableNativeAdMediaView            @"SASNativeAdMediaView"

// The button used to redirect the user to the privacy policy.
#define SASMediationOverridableAdChoicesView                @"SASAdChoicesView"
