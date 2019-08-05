//
//  IMSdk.h
//  APIs
//  Copyright (c) 2015 InMobi. All rights reserved.
//
/**
 * Use this class to set the user specific demographic info.
 *
 * As part of the General Data Protection Regulation (“GDPR”) publishers who collect data on their apps, are required to have a legal basis for collecting and processing the personal data of users in the European Economic Area (“EEA”).
 *
 * Please ensure that you obtain appropriate consent from the user before making ad requests to InMobi for Europe and indicate the same by following our recommended SDK implementation.
 *
 * Please do not pass any demographics information of a user; if you do not have user consent from such user in Europe.
 */

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#include "IMCommonConstants.h"

@interface IMSdk : NSObject

/**
 *  Initialize the sdk. This must be called before any other API for the SDK is used.
 * @param accountID account id obtained from the InMobi portal.
 */
+(void)initWithAccountID:(NSString *)accountID;

/**
 *  Initialize the sdk. This must be called before any other API for the SDK is used.
 * @param accountID account id obtained from the InMobi portal.
 * @param consentDictionary InMobi relies on the publishers to obtain explicit consent from users for continuing business activities in EU as per GDPR . Consent dictionary allows publishers to indicate consent status as obtained from the users for InMobi services to function appropriately.
 */
+(void)initWithAccountID:(NSString *)accountID consentDictionary: (NSDictionary*) consentDictionary;

/**
 * updates the user consent for a session of the app
 * @param consentDictionary consent dicionary allows publishers to provide its consent to collect user data and use it.
 */
+(void) updateGDPRConsent:(NSDictionary *)consentDictionary;

/**
 * Use this to get the version of the SDK.
 * @return The version of the SDK.
 */
+(NSString *)getVersion;

/**
 * Set the log level for SDK's logs
 * @param desiredLogLevel The desired level of logs.
 */
+(void)setLogLevel:(IMSDKLogLevel)desiredLogLevel;

/**
 * Use this to set the global state of the SDK to mute.
 * @param shouldMute Boolean depicting the mute state of the SDK
 */
+(void)setMute:(BOOL)shouldMute;

/**
 * Provide the user's age to the SDK for targetting purposes.
 * @param age The user's age.
 */
+(void)setAge:(unsigned short)age;
/**
 * Provide the user's area code to the SDK for targetting purposes.
 * @param areaCode The user's area code.
 */
+(void)setAreaCode:(NSString*)areaCode;
/**
 * Provide the user's age group to the SDK for targetting purposes.
 * @param ageGroup The user's age group.
 */
+(void)setAgeGroup:(IMSDKAgeGroup)ageGroup;
/**
 * Provide a user's date of birth to the SDK for targetting purposes.
 * @param yearOfBirth The user's date of birth.
 */
+(void)setYearOfBirth:(NSInteger)yearOfBirth;
/**
 * Provide the user's education status to the SDK for targetting purposes.
 * @param education The user's education status.
 */
+(void)setEducation:(IMSDKEducation)education;
/**
 * Provide the user's gender to the SDK for targetting purposes.
 * @param gender The user's gender.
 */
+(void)setGender:(IMSDKGender)gender;
/**
 * Provide the user's interests to the SDK for targetting purposes.
 * @param interests The user's interests.
 */
+(void)setInterests:(NSString*)interests;
/**
 * Provide the user's preferred language to the SDK for targetting purposes.
 * @param language The user's language.
 */
+(void)setLanguage:(NSString*)language;
/**
 * Provide the user's location to the SDK for targetting purposes.
 * @param city The user's city.
 * @param state The user's state.
 * @param country The user's country.
 */
+(void)setLocationWithCity:(NSString*)city state:(NSString*)state country:(NSString*)country;

/**
 * Provide the user's location to the SDK for targetting purposes.
 * @param location The location of the user
 */
+(void)setLocation:(CLLocation*)location;
/**
 * Provide the user's postal code to the SDK for targetting purposes.
 * @param postalcode The user's postalcode.
 */
+(void)setPostalCode:(NSString*)postalcode;


@end
