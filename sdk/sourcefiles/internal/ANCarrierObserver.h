#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//    App should be able to handle changes to the user’s cellular service provider. For example, the user could swap the device’s SIM card with one from another provider while app is running. Not applicable for macOS to know more click link https://developer.apple.com/documentation/coretelephony/cttelephonynetworkinfo

@interface ANCarrierMeta: NSObject
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *countryCode;
@property (nonatomic, copy, readonly) NSString *networkCode;
@end

@interface ANCarrierObserver: NSObject
@property (nonatomic, strong, nullable, readonly) ANCarrierMeta *carrierMeta;
+ (instancetype)shared;
@end

NS_ASSUME_NONNULL_END
