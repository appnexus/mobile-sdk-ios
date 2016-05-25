//
//  VdoAdRequest.h
//  iTennis
//
//  Created by Nitish garg on 06/11/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@protocol VdoAdNetworkDelegate;

typedef enum {
    LVDOGenderUnknown,
    LVDOGenderMale,
    LVDOGenderFemale
} LVDOGender;

@interface LVDOAdRequest : NSObject
{
    BOOL isChild;
    NSString *locationString;
    CGFloat latitude_;
    CGFloat longitude_;
    CGFloat accuracy;
}
@property (nonatomic, strong) NSDictionary *mediationExtras;
@property (nonatomic, strong) NSArray *testDevices;
@property (nonatomic, assign) LVDOGender gender;
@property (nonatomic, strong) NSString *birthday;
@property (nonatomic, strong) NSArray *keywords;
@property (nonatomic, strong) NSString *sex;
@property (nonatomic, strong) NSString *MarStatus;

@property (nonatomic, strong) NSString *location;

@property (nonatomic, unsafe_unretained) NSString *sdkVersion;
@property (nonatomic, unsafe_unretained) NSString *description;
@property (nonatomic, unsafe_unretained) NSString *childTreatment;

//Newly added parameters for "normal param - manual"
@property (nonatomic, unsafe_unretained) NSString *requester;
@property (nonatomic, unsafe_unretained) NSString *appBundle;
@property (nonatomic, unsafe_unretained) NSString *appDomain;
@property (nonatomic, unsafe_unretained) NSString *appName;
@property (nonatomic, unsafe_unretained) NSString *appStoreUrl;
@property (nonatomic, unsafe_unretained) NSString *Category;
@property (nonatomic, unsafe_unretained) NSString *publisherdomain;

//Newly added parameters for "normal param - automatic"
@property (nonatomic, unsafe_unretained) NSString *dif;
@property (nonatomic, strong) NSString *deviceIpAdd;
@property (nonatomic, strong) NSString *ua;
@property (nonatomic, unsafe_unretained) NSString *cb;
@property (nonatomic, unsafe_unretained) NSString *type;
@property (nonatomic, strong) NSString *dnt;
@property (nonatomic, unsafe_unretained) NSString *pos;
@property (nonatomic, unsafe_unretained) NSString *devicemodel;
@property (nonatomic, unsafe_unretained) NSString *deviceos;
@property (nonatomic, unsafe_unretained) NSString *deviceosv;
@property (nonatomic, unsafe_unretained) NSString *container;
@property (nonatomic, unsafe_unretained) NSString *dimension;
@property (nonatomic, strong) NSString *di;

//Newly added parameters for "targeting param - manual"
@property (nonatomic, unsafe_unretained) NSString *dmacode;
@property (nonatomic, unsafe_unretained) NSString *currpostal;
@property (nonatomic, unsafe_unretained) NSString *postalcode;
@property (nonatomic, unsafe_unretained) NSString *ethnicity;
@property (nonatomic, unsafe_unretained) NSString *metro;
@property (nonatomic, unsafe_unretained) NSString *geo;

//Newly added parameters for "targeting param - automatic"
@property (nonatomic, unsafe_unretained) NSString *geoType;

//Some other parameters
@property (nonatomic, unsafe_unretained) NSString *telhash;
@property (nonatomic, unsafe_unretained) NSString *emailhash;
@property (nonatomic, unsafe_unretained) NSString *linearity;
@property (nonatomic, strong) NSString *age;
@property (nonatomic, assign) BOOL secureStatus;

+ (NSString *)sdkVersion;

+ (LVDOAdRequest *)request;

+(void)setAge:(int)age;

+(void)addGender:(NSString *)sex;

+(void)addMaritalstatus:(NSString *)status;

- (NSString *)getTargettingParam;

+ (void)setBirthdayWithMonth:(NSInteger)m day:(NSInteger)d year:(NSInteger)y;

+  (void)setLocationWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude
                       accuracy:(CGFloat)accuracyInMeters;

+ (void)tagForChildDirectedTreatment:(BOOL)childDirectedTreatment;

+ (void)addKeyword:(NSArray *)keywords;

+(void)setSecureConnection:(BOOL)secureStatus; //Shuchi

+(void)setPublisherDomain:(NSString *)publisherdomain;

+(void)setAppStoreUrl:(NSString *)appStoreUrl;

+(void)setRequester:(NSString *)requester;

+(void)setAppName:(NSString *)appName;

+(void)setCategory:(NSString *)Category;

+(void)setAppBundle:(NSString *)appBundle;

+(void)setAppDomain:(NSString *)appDomain;

+(void)setDmaCode:(NSString *)dmacode;

+(void)setCurrPostal:(NSString *)currpostal;

+(void)setPostalCode:(NSString *)postalcode;

+(void)setGeo:(NSString *)geo;

+(void)setPosWithAdPosition:(int)positionType;

+(void)setMetro:(NSString *)metro;

+(void)setEthnicity:(NSString *)ethnicity;

+(void)setTelHash:(NSString *)telhash;

+(void)setEmailHash:(NSString *)emailhash;

@end

