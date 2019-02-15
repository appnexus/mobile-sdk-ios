//
//  SCSURLUtils.h
//  SCSCoreKit
//
//  Created by Julien Gomez on 20/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Type of URL.
typedef NS_ENUM(NSInteger, SCSURLType) {
    /// Empty URL.
    SCSURLTypeNone                                  = 0,
    
    /// HTTP URL.
    SCSURLTypeHTTP                                  = 1,
    
    /// Apple Plans / Google Maps URL.
    SCSURLTypeMap                                   = 2,
    
    /// SMS URL.
    SCSURLTypeSMS                                   = 3,
    
    /// Phone number URL.
    SCSURLTypeTel                                   = 4,
    
    /// Youtube video URL
    SCSURLTypeYouTube                               = 5,
    
    /// App Store URL.
    SCSURLTypeAppStore                              = 6,
    
    /// E-mail URL.
    SCSURLTypeMail                                  = 7,
    
    /// URL leading to a MP4 resource.
    SCSURLTypeVideo                                 = 8,
    
    /// Internal Smart AdServer URL (sas:// scheme).
    SCSURLTypeSmartAdServer                         = 9,
    
    /// Undefined URL.
    SCSURLTypeOther                                 = 10,
    
    /// Passbook URL.
    SCSURLTypePassbook                              = 11
};

/// Type of App Store URL.
typedef NS_ENUM(NSInteger, SCSAppStoreURLType) {
    /// URL leading to the App Store domain.
    SCSAppStoreURLTypeAppStore                      = 0,
    
    /// URL leading to the iTunes domain.
    SCSAppStoreURLTypeiTunes                        = 1,
    
    /// URL leading to the Phobos domain.
    SCSAppStoreURLTypePhobos                        = 2,
    
    /// Undefined URL.
    SCSAppStoreURLTypeOther                         = 3
};

/**
 Provides some methods to handle and construct URL objects.
 */
@interface SCSURLUtils : NSObject

/**
 Check if a string is ready to append an URL path.
 
 @param urlString The string to be checked.
 @return A boolean indicating whether or not a path can be added to the string.
 */
+ (BOOL)canAddPath:(NSString *)urlString;

/**
 Removes a slash at the end of a String.
 
 @param string The string to be processed.
 @return A string with the last slash stripped.
 */
+ (NSString *)removeLastSlashFromString:(NSString *)string;

/**
 Generate an URL from a baseURL, a path and a set of parameters.
 
 @param baseURLString The base URL for the URL (scheme://host).
 @param path The path after the base URL (scheme://host/path).
 @param parameters A dictionary of the query parameters to be added after the path (scheme://host/path?key=value&key=value).
 @return The final URL
 */
+ (nullable NSURL *)buildURLWithBaseURLString:(NSString *)baseURLString path:(nullable NSString *)path parameters:(nullable NSDictionary *)parameters;

/**
 Replace the given macro in the given url by the given value.
 
 @param macro The macro to be replaced
 @param url The URL where the macro should be replaced
 @param string The string to replace the macro with.
 @return An URL with the macro replaced.
 */
+ (NSURL *)replaceMacro:(NSString *)macro inURL:(NSURL *)url byString:(NSString *)string;

/**
 Explode a string into an array of URLs using the "," separator.
 
 @param string The string to be exploded.
 @return A flattened array of URLs.
 */
+ (NSArray<NSURL *> *)arrayOfURLsWithCommaSeparatedString:(NSString *)string;

/**
 Retrieve the URLType from an URL.
 
 @param url The URL for which we want to know the type.
 @return The URLType of the URL.
 */
+ (SCSURLType)URLType:(NSURL *)url;

/**
 Retrieve the AppStoreURLType from an URL.
 
 @param url The URL for which we want to know the AppStore Type.
 @return The AppStore Type of the URL.
 */
+ (SCSAppStoreURLType)appStoreURLType:(NSURL *)url;

/**
 Indicates whether or not an URL points to the Appstore / Phobos.
 
 @param url The URL to be checked.
 @return Whether or not an URL points to the Appstore / Phobos.
 */
+ (BOOL)isAppStoreURL:(NSURL *)url;

/**
 Retrieve the AppID from an Appstore / Phobos URL.
 
 @param url The URL from which we should retrieve the ID.
 @return The AppID parsed from the URL.
 */
+ (nullable NSNumber *)appStoreAppId:(NSURL *)url;

/**
 Indicates whether or not an URL is a valid AppStore URL. Valid means that it points to the store and contains
 an app id.
 
 @param url The URL to be checked.
 @return Whether or not an URL is a valid AppStore URL.
 */
+ (BOOL)isValidAppStoreURL:(NSURL *)url;

/**
 Retrieve the AppID from an AppStore/iTunes URL.
 
 @param url The URL from which we should retrieve the ID.
 @return The AppID parsed from the URL.
 */
+ (nullable NSNumber *)appIdentifierForAppStoreAndiTunesURL:(NSURL *)url;

/**
 Retrieve the AppID from a Phobos URL.
 
 @param url The URL from which we should retrieve the ID.
 @return The AppID parsed from the URL.
 */
+ (nullable NSNumber *)appIdentifierForPhobosURL:(NSURL *)url;

/**
 Indicates whether or not an URL has a scheme.
 
 @param url The URL to be checked.
 @return Whether or not an URL has a scheme.
 */
+ (BOOL)URLHasScheme:(NSURL *)url;

/**
 Indicates whether or not an URL has a HTTP (secured or not) scheme.
 
 @param URL The URL to be checked.
 @return Whether or not an URL has a HTTP scheme.
 */
+ (BOOL)URLHasHTTPScheme:(NSURL *)URL;

/**
 Adds an HTTP scheme to an URL.
 
 @param url The URL to which we want to add the http scheme.
 @param secured Should the added scheme be https or not.
 @return An URL with the http scheme.
 */
+ (NSURL *)URLByAddingHTTPSchemeTo:(NSURL *)url secured:(BOOL)secured;

/**
 Removes the query from an URL.
 
 @param url The URL from which we want to remove the query.
 @return A new URL without the query items (scheme://host/path).
 */
+ (NSURL *)URLByDeletingQuery:(NSURL *)url;

/**
 Retrieve the value for a specific key in the query items of an URL.
 
 @param key The key name of the parameter value to retrieve
 @param url The URL from which the query items must be retrieved.
 @return A string representing the value.
 */
+ (NSString *)valueForKey:(NSString *)key fromURL:(NSURL *)url;

/**
 Indicates whether or not an URL has a supported video extension.
 
 @param url The URL to be checked.
 @return Whether or not an URL has a supported video extension.
 */
+ (BOOL)URLHasVideoExtension:(NSURL *)url;

/**
 Indicates whether or not an URL has a passkit extension.
 
 @param url The URL to be checked.
 @return Whether or not an URL has passkit extension.
 */
+ (BOOL)URLHasPassbookExtension:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
