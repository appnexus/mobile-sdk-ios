//
//  AmazonAdOptions.h
//  AmazonMobileAdsSDK
//
//  Copyright (c) 2012-2014 Amazon.com. All rights reserved.
//

#import <Foundation/Foundation.h>

// Standard Amazon Ad Sizes for phones.
extern const CGSize AmazonAdSize_320x50;
extern const CGSize AmazonAdSize_300x250;

// Standard Amazon Ad Sizes for tablets.
extern const CGSize AmazonAdSize_728x90;
extern const CGSize AmazonAdSize_1024x50;

@interface AmazonAdOptions : NSObject

// Set the isTestRequest to YES, during development/integration only. This option is turned off by default.
@property (nonatomic) BOOL isTestRequest;
// If your application is enabled to read lat/long, you can configure this option to receive geo targetted ads. 
// This option is turned off by default.
@property (nonatomic) BOOL usesGeoLocation;
// This will set the timeout of the request for the ad
//    the min for this value is 5 seconds and the max is 60 seconds
//    the default value is 10 seconds
@property (nonatomic) NSTimeInterval timeout;

// Gets an instance of options to use.
+ (instancetype)options;
- (void)setAdvancedOption:(NSString *)value forKey:(NSString *)key;
- (NSDictionary *)advancedOptions;

@end
