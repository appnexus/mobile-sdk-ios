//
//  SCSUtils.h
//  SCSCoreKit
//
//  Created by Thomas Geley on 20/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Useful static methods.
 */
@interface SCSUtils : NSObject

/**
 Indicates whether or not a string is empty or only whitespaces.
 
 @param string the string to be checked.
 @return Whether or not a string is empty or only whitespaces.
 */
+ (BOOL)stringIsEmptyOrWhiteSpace:(NSString *)string;

/**
 Removes whitespaces from a string.
 
 @param string The string to transformed.
 @return A string with all whitespaces removed.
 */
+ (NSString *)stringByRemovingWhiteSpace:(NSString *)string;

/**
 Returns the localized string with the given key, for a given file, in a given bundle.
 
 @param key The key for the string resource.
 @param stringFile The file where the string resource should be searched.
 @param bundle The bundle where the localized file should be searched.
 @return A localized string if found, key otherwise.
 */
+ (NSString *)localizedStringForKey:(NSString *)key stringFile:(NSString *)stringFile bundle:(NSBundle *)bundle;

/**
 Returns whether or not a string is a valid Consent String as per IAB Transparency and Consent Framework specifications.
 https://github.com/InteractiveAdvertisingBureau/GDPR-Transparency-and-Consent-Framework
 
 @param consentString the string to be validated.
 @return whether or not a string is a valid Consent String as per IAB Transparency and Consent Framework specifications.
 */
+ (BOOL)isValidGDPRConsentString:(NSString *)consentString;

/**
 Transforms an hexadecimal color string to an UIColor.
 
 @param colorString The string to be transformed into an UIColor. Could be in one of those formats: #RGB, #ARGB, #RRGGBB, #AARRGGBB.
 @return An UIColor corresponding to the hexadecimal string if possible, nil if the string is invalid.
 */
+ (nullable UIColor *)colorFromString:(NSString *)colorString;

/**
 Transforms an hexadecimal color string to an UIColor.
 
 @param colorString The string to be transformed into an UIColor. Could be in one of those formats: RGB, ARGB, RRGGBB, AARRGGBB.
 @param prefix The prefix that will be found before the color string.
 @return An UIColor corresponding to the hexadecimal string if possible, nil if the string is invalid.
 */
+ (nullable UIColor *)colorFromString:(NSString *)colorString withPrefix:(NSString *)prefix;

/**
 Transforms an UIColor to its corresponding hexadecimal string.
 
 @param color The color to be transformed into an hexadecimal string.
 @param includeAlpha Whether or not the alpha component should be integrated into the result.
 @return An hexadecimal string corresponding to the inputed color followed by the prefix '#'.
 */
+ (NSString *)colorStringFromColor:(UIColor *)color includeAlpha:(BOOL)includeAlpha;

/**
 Transforms an UIColor to its corresponding hexadecimal string.
 
 @param color The color to be transformed into an hexadecimal string.
 @param prefix The prefix that will be found before the color string.
 @param includeAlpha Whether or not the alpha component should be integrated into the result.
 @return An hexadecimal string corresponding to the inputed color.
 */
+ (NSString *)colorStringFromColor:(UIColor *)color withPrefix:(NSString *)prefix includeAlpha:(BOOL)includeAlpha;

/**
 Generate a NSError with proper domain, code and description.
 
 @param domain The error's domain.
 @param code The error's code.
 @param description The error's description.
 @return A NSError instance with given domain, code and description.
 */
+ (NSError *)errorWithDomain:(NSString *)domain code:(NSInteger)code description:(nullable NSString *)description;

@end

NS_ASSUME_NONNULL_END
