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
#import "ANLogging.h"

NSString * const  ANGDPR_ConsentString = @"ANGDPR_ConsentString";
NSString * const  ANGDPR_ConsentRequired = @"ANGDPR_ConsentRequired";
NSString * const  ANGDPR_PurposeConsents = @"ANGDPR_PurposeConsents";

//TCF 2.0 variables
NSString * const  ANIABTCF_ConsentString = @"IABTCF_TCString";
NSString * const  ANIABTCF_SubjectToGDPR = @"IABTCF_gdprApplies";
NSString * const  ANIABTCF_PurposeConsents = @"IABTCF_PurposeConsents";
// Gpp TCF 2.0 variabled
NSString * const  ANIABGPP_TCFEU2_PurposeConsents = @"IABGPP_TCFEU2_PurposeConsents";
NSString * const  ANIABGPP_TCFEU2_SubjectToGDPR = @"IABGPP_TCFEU2_gdprApplies";


//TCF 1.1 variables
NSString * const  ANIABConsent_ConsentString = @"IABConsent_ConsentString";
NSString * const  ANIABConsent_SubjectToGDPR = @"IABConsent_SubjectToGDPR";

// Google ACM consent parameter
NSString * const  ANIABTCF_ADDTL_CONSENT = @"IABTCF_AddtlConsent";



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
 * Check for ANIABTCF_ConsentString or ANGDPR_ConsentString or ANIABConsent_ConsentString in that order and return if present else return @""
 */
+ (nullable NSString *) getConsentString{
    NSString* consentString = [[NSUserDefaults standardUserDefaults] stringForKey:ANIABTCF_ConsentString];
    if(consentString.length <= 0){
        consentString = [[NSUserDefaults standardUserDefaults] stringForKey:ANGDPR_ConsentString];
        if(consentString.length <= 0){
            consentString = [[NSUserDefaults standardUserDefaults] stringForKey:ANIABConsent_ConsentString];
        }
    }
    return consentString? consentString: @"";
}

/**
 * Get the GDPR consent required in the SDK
 * Check for ANIABTCF_SubjectToGDPR ,  ANGDPR_ConsentRequired ,  ANIABConsent_SubjectToGDPR and ANIABGPP_TCFEU2_SubjectToGDPR in that order  and return if present else return nil
 */
+ (nullable NSNumber *) getConsentRequired{
    
    NSNumber *hasConsent = [[NSUserDefaults standardUserDefaults] valueForKey:ANIABTCF_SubjectToGDPR];
    if(hasConsent == nil){
        hasConsent = [[NSUserDefaults standardUserDefaults] valueForKey:ANGDPR_ConsentRequired];
        if(hasConsent == nil){
            NSString *hasConsentStringValue = [[NSUserDefaults standardUserDefaults] stringForKey:ANIABConsent_SubjectToGDPR];
            NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
            hasConsent = [numberFormatter numberFromString:hasConsentStringValue];
        }
        if(hasConsent == nil){
            hasConsent = [[NSUserDefaults standardUserDefaults] valueForKey:ANIABGPP_TCFEU2_SubjectToGDPR];
        }
    }
    return hasConsent;
}

  // pull Google Ad Tech Provider (ATP) IDs ids from the Addtional Consent(AC)string and convert them to JSONArray of integers.
  // for example if addtlConsentString = '1~7.12.35.62.66.70.89.93.108', then we need to return [7,12,35,62,66,70,89,93,108] this is the format impbus understands.
+ (nonnull NSArray *) getGoogleACMConsentArray{
    NSString* addtlConsentString = [[NSUserDefaults standardUserDefaults] stringForKey:ANIABTCF_ADDTL_CONSENT];
    NSMutableArray *consentedATPIntegerArray = [NSMutableArray array];
    
    // Only if a valid Additional consent string is present proceed further.
    // The string has to start with 1~ (we support only version 1 of the ACM spec)
    if(addtlConsentString && addtlConsentString.length >2 && [addtlConsentString hasPrefix:@"1~"]){
        // From https://support.google.com/admanager/answer/9681920
        // An AC string contains the following three components:
        // Part 1: A specification version number, such as "1"
        // Part 2: A separator symbol "~"
        // Part 3: A dot-separated list of user-consented Google Ad Tech Provider (ATP) IDs. Example: "1.35.41.101"
        // For example, the AC string 1~1.35.41.101 means that the user has consented to ATPs with IDs 1, 35, 41 and 101, and the string is created using the format defined in the v1.0 specification.
        @try {
            NSArray *parsedACString = [addtlConsentString componentsSeparatedByString:@"~"];
            NSArray *consentedATPStringArray = [parsedACString[1] componentsSeparatedByString:@"."];
            for ( int i = 0; i < consentedATPStringArray.count; ++i ){
                [consentedATPIntegerArray addObject:[NSNumber numberWithInt:[consentedATPStringArray[i] intValue]]];
            }
        } @catch (NSException *ex) {
            ANLogError(@"Exception while processing Google addtlConsentString");
        }
    }
    return consentedATPIntegerArray;
}

/**
* Get the GDPR device consent required in the SDK to pass IDFA & cookies
* Check for ANIABTCF_PurposeConsents ,  ANGDPR_PurposeConsents and ANIABGPP_TCFEU2_PurposeConsents in that order  and return if present else return nil
*/
+ (NSString *) getDeviceAccessConsent {
    
    NSString* purposeConsents = [[NSUserDefaults standardUserDefaults] objectForKey:ANIABTCF_PurposeConsents];
    if(purposeConsents.length <= 0){
        purposeConsents = [[NSUserDefaults standardUserDefaults] objectForKey:ANGDPR_PurposeConsents];
    }
    if(purposeConsents.length <= 0){
        purposeConsents = [[NSUserDefaults standardUserDefaults] objectForKey:ANIABGPP_TCFEU2_PurposeConsents];
    }
    if(purposeConsents != nil && purposeConsents.length > 0){
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
