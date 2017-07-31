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



typedef NS_ENUM(NSUInteger, AdColonyConfigurationState) {
    AdColonyConfigurationStateUnknown,
    AdColonyConfigurationStateInProcess,
    AdColonyConfigurationStateInitialized
};



@interface  ANAdAdapterBaseAdColony()

@property (nonatomic)          AdColonyConfigurationState  configurationState;
@property (nonatomic, strong)  NSArray                     *completionActionArray;

@property (nonatomic, strong)  NSString             *appID;
@property (nonatomic, strong)  NSArray<NSString *>  *zoneIDs;


@end



@implementation ANAdAdapterBaseAdColony

#pragma mark - Instance management.

+ (ANAdAdapterBaseAdColony *)sharedInstance
{
    static dispatch_once_t           onceToken;
    static ANAdAdapterBaseAdColony  *instance = nil;

    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });

    return  instance;
}

- (instancetype)init
{
    self = [super init];
    if (!self)  { return nil; }

    self.configurationState     = AdColonyConfigurationStateUnknown;
    self.completionActionArray  = @[];

    return  self;
}



#pragma mark - Configuration lifecycle.

+ (void)configureWithAppID: (NSString *)appIDValue
                   zoneIDs: (NSArray *)zoneIDsValue
{
    ANAdAdapterBaseAdColony  *sharedInstance  = [[self class] sharedInstance];

    sharedInstance.appID    = appIDValue;
    sharedInstance.zoneIDs  = zoneIDsValue;

    ANLogTrace(@"AdColony version %@ is CONFIGURED to serve ads.", [AdColony getSDKVersion]);
}

+ (void)loadInterstitialAfterConfigAdColonySDKWithTargetingParameters: (ANTargetingParameters *)targetingParameters
                                                     completionAction: (void (^)(void))completionAction
{
    ANAdAdapterBaseAdColony  *sharedInstance  = [ANAdAdapterBaseAdColony sharedInstance];
    AdColonyAppOptions       *appOptions      = nil;

    @synchronized (sharedInstance)
    {
        if (AdColonyConfigurationStateInitialized == sharedInstance.configurationState)
        {
            if (completionAction)
            {
                appOptions = [ANAdAdapterBaseAdColony setAdColonyTargetingWithTargetingParameters:targetingParameters usingSharedInstance:NO];
                [AdColony setAppOptions:appOptions];
                completionAction();
            }

        } else {
            //NB  All cached completionActions will share the same set of appOptions,
            //    from whichever instance enters AdColonyConfigurationStateInProcess.
            //
            if (completionAction) {
                sharedInstance.completionActionArray = [sharedInstance.completionActionArray arrayByAddingObject:completionAction];
            }

            //
            if (AdColonyConfigurationStateInProcess != sharedInstance.configurationState)
            {
                sharedInstance.configurationState = AdColonyConfigurationStateInProcess;

                appOptions = [ANAdAdapterBaseAdColony setAdColonyTargetingWithTargetingParameters:targetingParameters usingSharedInstance:YES];

                [AdColony configureWithAppID: sharedInstance.appID
                                     zoneIDs: sharedInstance.zoneIDs
                                     options: appOptions
                                  completion: ^(NSArray<AdColonyZone *> * _Nonnull zones)
                                              {
                                                  @synchronized (sharedInstance) {
                                                      sharedInstance.configurationState = AdColonyConfigurationStateInitialized;
                                                      ANLogTrace(@"AdColony version %@ is READY to serve ads.  \n\tzones=%@", [AdColony getSDKVersion], zones);

                                                      for (void(^action)() in sharedInstance.completionActionArray) {
                                                          action();
                                                      }
                                                  }
                                              }
                 ];
            }
        }
    }
}

+ (AdColonyAppOptions *)setAdColonyTargetingWithTargetingParameters: (ANTargetingParameters *)targetingParameters
                                                usingSharedInstance: (BOOL)useSharedInstance
{
    // Begin building targeting parameters from shared instance (possibly created by the client)
    //   or start fresh.
    //
    AdColonyAppOptions  *appOptions  = nil;

    if (useSharedInstance) {
        appOptions = [ANAdAdapterBaseAdColony getAppOptions];
    } else {
        appOptions = [ANAdAdapterBaseAdColony makeAppOptions];
    }

    //
    if (targetingParameters)
    {
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

    return  appOptions;
}



#pragma mark - Helper methods.

+ (AdColonyAppOptions *) getAppOptions
{
    AdColonyAppOptions  *appOptions  = [AdColony getAppOptions];

    if (nil == appOptions) {
        appOptions = [[self class] makeAppOptions];
    }

    if (nil == appOptions.userMetadata) {
        appOptions.userMetadata = [[AdColonyUserMetadata alloc] init];
    }

    return  appOptions;
}

+ (AdColonyAppOptions *) makeAppOptions
{
    AdColonyAppOptions  *appOptions = [[AdColonyAppOptions alloc] init];

    appOptions.disableLogging  = YES;
    appOptions.userMetadata    = [[AdColonyUserMetadata alloc] init];

    return  appOptions;
}



@end
