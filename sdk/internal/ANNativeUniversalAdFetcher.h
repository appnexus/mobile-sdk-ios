#import <Foundation/Foundation.h>
#import "ANNativeAdResponse.h"
#import "ANAdFetcherResponse.h"
#import "ANAdProtocol.h"
#import "ANGlobal.h"

@interface ANNativeUniversalAdFetcher : NSObject

-(instancetype) initWithDelegate:(id)delegate;
-(void)requestAd;
-(void)cancelRequest;

- (NSTimeInterval)getTotalLatency:(NSTimeInterval)stopTime;
- (void)fireResponseURL:(NSString *)responseURLString
                 reason:(ANAdResponseCode)reason
               adObject:(id)adObject
              auctionID:(NSString *)auctionID;
@end

#pragma mark - ANUniversalAdFetcherDelegate partitions.

@protocol ANNativeUniversalAdFetcherDelegate <ANAdProtocolFoundation>
@property (nonatomic, readwrite, strong)  NSMutableDictionary<NSString *, NSArray<NSString *> *>  *customKeywords;
-(void)didFinishRequestWithResponse: (ANAdFetcherResponse *)response;

@end
