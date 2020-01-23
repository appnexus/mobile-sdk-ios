/*   Copyright 2019 APPNEXUS INC

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

#import "ANUSPrivacySettings.h"

NSString * const  AN_USPrivacy_String = @"ANUSPrivacy_String";
NSString * const  AN_IAB_USPrivacy_String = @"IABUSPrivacy_String";

@implementation ANUSPrivacySettings

/**
 * Set the IAB US Privacy String in the SDK
 */
+ (void) setUSPrivacyString:(nonnull NSString *)privacyString{
    [[NSUserDefaults standardUserDefaults] setObject:privacyString forKey:AN_USPrivacy_String];
}

/**
 * Reset the value of IAB US Privacy String that was previously set using setUSPrivacyString
*/
+ (void) reset{
    NSUserDefaults *defaults= [NSUserDefaults standardUserDefaults];
    if([[[defaults dictionaryRepresentation] allKeys] containsObject:AN_USPrivacy_String]){
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:AN_USPrivacy_String];
    }
}

/**
 * Get the IAB US Privacy String in the SDK.
 * Check for AN_USPrivacy_String And IAB_USPrivacy_String and return if present else return @""
 */
+ (nonnull NSString *) getUSPrivacyString{
    NSString* privacyString = [[NSUserDefaults standardUserDefaults] objectForKey:AN_USPrivacy_String];
    if(privacyString == nil){
        privacyString = [[NSUserDefaults standardUserDefaults] objectForKey:AN_IAB_USPrivacy_String];
    }
    return privacyString? privacyString: @"";
}
@end
