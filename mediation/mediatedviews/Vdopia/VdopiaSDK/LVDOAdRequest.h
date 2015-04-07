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
@property (nonatomic, unsafe_unretained) NSString *locationDescription;





+ (NSString *)sdkVersion;
+ (LVDOAdRequest *)request;
+(void)addGender:(NSString *)sex;
+(void)addMaritalstatus:(NSString *)status;

- (NSString *)getTargettingParam;

+ (void)setBirthdayWithMonth:(NSInteger)m day:(NSInteger)d year:(NSInteger)y;
+  (void)setLocationWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude
                       accuracy:(CGFloat)accuracyInMeters;

+ (void)setLocationWithDescription:(NSString *)locationDescription;

+ (void)tagForChildDirectedTreatment:(BOOL)childDirectedTreatment;


+ (void)addKeyword:(NSArray *)keywords;

@end

