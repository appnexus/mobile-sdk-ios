/*   Copyright 2018 APPNEXUS INC
 
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

#import "ANGDPRSettings.h"

NSString * const  ANGDPR_ConsentString = @"ANGDPR_ConsentString";
NSString * const  ANGDPR_ConsentRequired = @"ANGDPR_ConsentRequired";
NSString * const  ANGDPR_PurposeConsents = @"ANGDPR_PurposeConsents";

//TCF 2.0 variables
NSString * const  ANIABTCF_ConsentString = @"IABTCF_TCString";
NSString * const  ANIABTCF_SubjectToGDPR = @"IABTCF_gdprApplies";
NSString * const  ANIABTCF_PurposeConsents = @"IABTCF_PurposeConsents";

//TCF 1.1 variables
NSString * const  ANIABConsent_ConsentString = @"IABConsent_ConsentString";
NSString * const  ANIABConsent_SubjectToGDPR = @"IABConsent_SubjectToGDPR";



@interface ANGDPRSettings()

@end


@implementation ANGDPRSettings

/**
 * Set the GDPR consent string in the SDK
 */
+ (void) setConsentString:(nonnull NSString *)consentString{
    [[NSUserDefaults standardUserDefaults] setObject:consentString forKey:ANGDPR_ConsentString];
}

/**
 * Set the GDPR consent required in the SDK
 */
+ (void) setConsentRequired:(NSNumber *)consentRequired{
    
    [[NSUserDefaults standardUserDefaults] setValue:consentRequired forKey:ANGDPR_ConsentRequired];
    
}

/**
 * reset the GDPR consent string and consent required in the SDK
 */
+ (void) reset{
    NSUserDefaults *defaults= [NSUserDefaults standardUserDefaults];
    if([[[defaults dictionaryRepresentation] allKeys] containsObject:ANGDPR_ConsentString]){
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:ANGDPR_ConsentString];
    }
    if([[[defaults dictionaryRepresentation] allKeys] containsObject:ANGDPR_ConsentRequired]){
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:ANGDPR_ConsentRequired];
    }
    if([[[defaults dictionaryRepresentation] allKeys] containsObject:ANGDPR_PurposeConsents]){
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:ANGDPR_PurposeConsents];
    }
}

/**
 * Get the GDPR consent string in the SDK.
 * Check for ANGDPR_ConsentString And IABConsent_ConsentString and return if present else return @""
 */
+ (nullable NSString *) getConsentString{
    
    NSString* consentString = [[NSUserDefaults standardUserDefaults] stringForKey:ANGDPR_ConsentString];
    if(consentString.length <= 0){
        consentString = [[NSUserDefaults standardUserDefaults] stringForKey:ANIABTCF_ConsentString];
        if(consentString.length <= 0){
            consentString = [[NSUserDefaults standardUserDefaults] stringForKey:ANIABConsent_ConsentString];
        }
    }
    return consentString? consentString: @"";
}

/**
 * Get the GDPR consent required in the SDK
 * Check for ANGDPR_ConsentRequired And IABConsent_SubjectToGDPR  and return if present else return nil
 */
+ (nullable NSNumber *) getConsentRequired{
    
    NSNumber *hasConsent = [[NSUserDefaults standardUserDefaults] valueForKey:ANGDPR_ConsentRequired];
    if(hasConsent == nil){
        hasConsent = [[NSUserDefaults standardUserDefaults] valueForKey:ANIABTCF_SubjectToGDPR];
        if(hasConsent == nil){
            NSString *hasConsentStringValue = [[NSUserDefaults standardUserDefaults] stringForKey:ANIABConsent_SubjectToGDPR];
            NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
            hasConsent = [numberFormatter numberFromString:hasConsentStringValue];
        }
        
    }
    return hasConsent;
}

/**
* Get the GDPR device consent required in the SDK to pass IDFA & cookies
* Check for ANGDPR_PurposeConsents And ANIABTCF_PurposeConsents  and return if present else return nil
*/
+ (NSString *) getDeviceAccessConsent {
    
    NSString* purposeConsents = [[NSUserDefaults standardUserDefaults] objectForKey:ANGDPR_PurposeConsents];
    if(purposeConsents.length <= 0){
        purposeConsents = [[NSUserDefaults standardUserDefaults] objectForKey:ANIABTCF_PurposeConsents];
    }
    if(purposeConsents > 0){
        return [purposeConsents substringToIndex:1];
    }
    return nil;
    
}

/**
* set the GDPR device consent required in the SDK to pass IDFA & cookies
*/
+ (void) setPurposeConsents :(nonnull NSString *) purposeConsents {
    if (purposeConsents.length > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:purposeConsents forKey:ANGDPR_PurposeConsents];
    }
}

/**
* Get the GDPR device consent as a combination of purpose 1 & consent required
*/
+ (BOOL) canAccessDeviceData {
    //fetch advertising identifier based TCF 2.0 Purpose1 value
    //truth table
    /*
                            deviceAccessConsent=true   deviceAccessConsent=false  deviceAccessConsent undefined
     consentRequired=false        Yes, read IDFA             No, don’t read IDFA           Yes, read IDFA
     consentRequired=true         Yes, read IDFA             No, don’t read IDFA           No, don’t read IDFA
     consentRequired=undefined    Yes, read IDFA             No, don’t read IDFA           Yes, read IDFA
     */
        
    if((([ANGDPRSettings getDeviceAccessConsent] == nil) && ([ANGDPRSettings getConsentRequired] == nil || [[ANGDPRSettings getConsentRequired] boolValue] == NO)) || ([ANGDPRSettings getDeviceAccessConsent] != nil && [[ANGDPRSettings getDeviceAccessConsent] isEqualToString:@"1"])){
        return true;
    }
    
    return false;
}

@end
