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
        //FIX also set default appOptions.userMetadata -- or derfer to *TargetingParameters?


    [ANAdAdapterBaseAdColony setIsReadyToServeAds:NO];
                //FIX  test me

    [AdColony configureWithAppID: appID
                         zoneIDs: zoneIDs
                         options: appOptions
                      completion: ^(NSArray<AdColonyZone *> * _Nonnull zones) {
                                                  //FIX  test me
                                      [ANAdAdapterBaseAdColony setIsReadyToServeAds:YES];
                                                  //FIX -- better to set userID then test whether it is set properly to decide whther completion block has run?
                                      ANLogTrace(@"AdColony version %@ -- is READY to serve ads.  \n\tzones=%@", [AdColony getSDKVersion], zones);
                                  }                                      //(FIX happilly repelacesd dekeltate?
                                                                         //(FIX  note when fired -- ready to receive ads?
                                                                         //FIX -- need startegey for handling other delegates.
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
{
    AdColonyAppOptions  *appOptions  = [AdColony getAppOptions];

    if (targetingParameters.age) {
//        [appOptions.userMetadata setUserAge:targetingParameters.age];
                //FIX  NB wants Integer
                //FIX  use hidden apis for usermetadata?

        [appOptions.userMetadata setMetadataWithKey:@"userAge" andStringValue:targetingParameters.age];
    }
    
    switch (targetingParameters.gender) {
        case ANGenderMale:
            [appOptions.userMetadata setMetadataWithKey:@"userGender" andStringValue:ADCUserMale];
            break;
        case ANGenderFemale:
            [appOptions.userMetadata setMetadataWithKey:@"userGender" andStringValue:ADCUserFemale];
            break;
        default:
            break;
    }
    
    if (targetingParameters.location) {
        NSString *latitude = [NSString stringWithFormat:@"%f", targetingParameters.location.latitude];
        NSString *longitude = [NSString stringWithFormat:@"%f", targetingParameters.location.longitude];

        [appOptions.userMetadata setMetadataWithKey:@"userLatitude" andStringValue:latitude];
        [appOptions.userMetadata setMetadataWithKey:@"userLongitude" andStringValue:longitude];
    }
}

@end
