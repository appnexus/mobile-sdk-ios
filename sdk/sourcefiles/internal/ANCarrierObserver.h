#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

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
