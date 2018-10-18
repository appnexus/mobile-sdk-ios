#import "ANCarrierObserver.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

@interface ANCarrierObserver()
@property (nonatomic, strong) CTTelephonyNetworkInfo *networkInfo;
@end

@interface ANCarrierMeta()
@property (nonatomic, copy, readwrite) NSString *name;
@property (nonatomic, copy, readwrite) NSString *countryCode;
@property (nonatomic, copy, readwrite) NSString *networkCode;

- (instancetype)initWith:(NSString *)name
             countryCode:(NSString *)countryCode
             networkCode:(NSString *)networkCode;

+ (instancetype)makeWithCarrier:(CTCarrier *)carrier;
@end

@implementation ANCarrierMeta
- (instancetype)initWith:(NSString *)name
             countryCode:(NSString *)countryCode
             networkCode:(NSString *)networkCode;
{
    if (self = [super init]) {
        self.name = name;
        self.countryCode = countryCode;
        self.networkCode = networkCode;
    }
    return self;
}

+ (instancetype)makeWithCarrier:(CTCarrier *)carrier {
    return [[ANCarrierMeta alloc] initWith:carrier.carrierName
                               countryCode:carrier.mobileCountryCode
                               networkCode:carrier.mobileNetworkCode];
}
@end

@implementation ANCarrierObserver
+ (instancetype)shared {
    static ANCarrierObserver *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ANCarrierObserver alloc] init];
    });
    return sharedInstance;
}

- (ANCarrierMeta *)carrierMeta
{
    CTCarrier *carrier = [self.networkInfo subscriberCellularProvider];
    return [ANCarrierMeta makeWithCarrier:carrier];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.networkInfo = [CTTelephonyNetworkInfo new];
    }
    return self;
}
@end
