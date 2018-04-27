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
NSString * const  IABConsent_ConsentString = @"IABConsent_ConsentString";
NSString * const  IABConsent_SubjectToGDPR = @"IABConsent_SubjectToGDPR";

@interface ANGDPRSettings()

@end


@implementation ANGDPRSettings




/**
 * Set the GDPR consent string in the SDK
 */
+ (void) setConsentString:(NSString *)consentString{
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
+ (NSString *) getConsentString{
    
    NSString* consentString = [[NSUserDefaults standardUserDefaults] objectForKey:ANGDPR_ConsentString];
    if(consentString == nil){
        consentString = [[NSUserDefaults standardUserDefaults] objectForKey:IABConsent_ConsentString];
    }
    return consentString? consentString: @"";
}

/**
 * Get the GDPR consent required in the SDK
 * Check for ANGDPR_ConsentRequired And IABConsent_SubjectToGDPR  and return if present else return nil
 */
+ (NSString *) getConsentRequired{
    
    NSString* subjectToGdprValue = [[NSUserDefaults standardUserDefaults] objectForKey:ANGDPR_ConsentRequired];
    if(subjectToGdprValue == nil){
        subjectToGdprValue = [[NSUserDefaults standardUserDefaults] objectForKey:IABConsent_SubjectToGDPR];
    }
    if([subjectToGdprValue isEqualToString:@"1"] || [subjectToGdprValue isEqualToString:@"0"]){
        return subjectToGdprValue;
    }
    return nil;
}


@end
