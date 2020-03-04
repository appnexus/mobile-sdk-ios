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
+ (void) setConsentRequired:(BOOL)consentRequired{
    
    NSString *consentString = @"0";
    if (consentRequired) {
        consentString = @"1";
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:consentString forKey:ANGDPR_ConsentRequired];
    
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
}

/**
 * Get the GDPR consent string in the SDK.
 * Check for ANGDPR_ConsentString And IABConsent_ConsentString and return if present else return @""
 */
+ (nonnull NSString *) getConsentString{
    
    NSString* consentString = [[NSUserDefaults standardUserDefaults] objectForKey:ANGDPR_ConsentString];
    if(consentString.length <= 0){
        consentString = [[NSUserDefaults standardUserDefaults] objectForKey:ANIABTCF_ConsentString];
        if(consentString.length <= 0){
            consentString = [[NSUserDefaults standardUserDefaults] objectForKey:ANIABConsent_ConsentString];
        }
    }
    return consentString? consentString: @"";
}

/**
 * Get the GDPR consent required in the SDK
 * Check for ANGDPR_ConsentRequired And IABConsent_SubjectToGDPR  and return if present else return nil
 */
+ (nullable NSString *) getConsentRequired{
    
    NSString* subjectToGdprValue = [[NSUserDefaults standardUserDefaults] objectForKey:ANGDPR_ConsentRequired];
    if(subjectToGdprValue.length <= 0){
        subjectToGdprValue = [[NSUserDefaults standardUserDefaults] objectForKey:ANIABTCF_SubjectToGDPR];
        if(subjectToGdprValue.length <= 0){
            subjectToGdprValue = [[NSUserDefaults standardUserDefaults] objectForKey:ANIABConsent_SubjectToGDPR];
        }
        
    }
    return subjectToGdprValue;
}

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

+ (void) setPurposeConsents :(nonnull NSString *) purposeConsents {
    if (purposeConsents.length > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:purposeConsents forKey:ANGDPR_PurposeConsents];
    }
}


@end
