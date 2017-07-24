/*   Copyright 2015 APPNEXUS INC
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import <AdColony/AdColony.h>
#import <AdColony/AdColonyAdOptions.h>
#import <AdColony/AdColonyAdRequestError.h>
#import <AdColony/AdColonyAppOptions.h>
#import <AdColony/AdColonyInterstitial.h>
#import <AdColony/AdColonyOptions.h>
#import <AdColony/AdColonyTypes.h>
#import <AdColony/AdColonyUserMetadata.h>
#import <AdColony/AdColonyZone.h>

#import "ANAdAdapterBaseAdColony.h"
#import "ANAdAdapterBaseAdColony+PrivateMethods.h"

#import "ANLogging.h"



static BOOL  isReadyToServeAds  = NO;


@implementation ANAdAdapterBaseAdColony

+ (void)configureWithAppID:(NSString *)appID
                   zoneIDs:(NSArray *)zoneIDs
{
    AdColonyAppOptions  *appOptions  = [[AdColonyAppOptions alloc] init];
    appOptions.disableLogging  = YES;
    appOptions.userID          = nil;
    appOptions.adOrientation   = AdColonyOrientationAll;
        //FIX also set defaults on appOptions.userMetadata -- or derfer to *TargetingParameters?


    [ANAdAdapterBaseAdColony setIsReadyToServeAds:NO];
                //FIX  test me

    [AdColony configureWithAppID: appID
                         zoneIDs: zoneIDs
                         options: appOptions
                      completion: ^(NSArray<AdColonyZone *> * _Nonnull zones) {
                                                  //FIX  test me
                                      [ANAdAdapterBaseAdColony setIsReadyToServeAds:YES];
                                                  //FIX -- better to set userID then test whether it is set properly to decide whther completion block has run?
                                      ANLogTrace(@"AdColony version %@ is READY to serve ads.  \n\tzones=%@", [AdColony getSDKVersion], zones);
                                  }
     ];
}

+ (BOOL) isReadyToServeAds
                    //FIX  test me
{
    return  isReadyToServeAds;
}

+ (void) setIsReadyToServeAds: (BOOL) value
{
    isReadyToServeAds = value;
}

+ (void)setAdColonyTargetingWithTargetingParameters:(ANTargetingParameters *)targetingParameters
                        //FIX test me -- prove that appOptions is being set properly
                        //x FIX What else?  custonKeywords --> user interests?
{
    AdColonyAppOptions  *appOptions  = [AdColony getAppOptions];

    if (targetingParameters.age) {
        appOptions.userMetadata.userAge = [targetingParameters.age integerValue];
    }
    
    switch (targetingParameters.gender) {
        case ANGenderMale:
            appOptions.userMetadata.userGender = ADCUserMale;
            break;
        case ANGenderFemale:
            appOptions.userMetadata.userGender = ADCUserFemale;
            break;
            
        default:
            break;
    }
    
    if (targetingParameters.location) {
        appOptions.userMetadata.userLatitude = [NSNumber numberWithFloat:targetingParameters.location.latitude];
        appOptions.userMetadata.userLongitude = [NSNumber numberWithFloat:targetingParameters.location.longitude];
    }

    if ([targetingParameters.customKeywords count] > 0)
    {
        for (NSString *key in targetingParameters.customKeywords) {
            NSString  *value  = [targetingParameters.customKeywords objectForKey:key];

            [appOptions.userMetadata setMetadataWithKey:key andStringValue:value];
        }
    }
}

@end
