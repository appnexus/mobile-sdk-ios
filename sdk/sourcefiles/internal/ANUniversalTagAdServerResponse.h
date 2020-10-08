/*   Copyright 2015 APPNEXUS INC
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import <Foundation/Foundation.h>

#import "ANBaseAdObject.h"

#import "ANStandardAd.h"
#import "ANRTBVideoAd.h"



#pragma mark - Global contants.

extern NSString * _Nonnull const  kANUniversalTagAdServerResponseKeyAdsTagId;
extern NSString * _Nonnull const  kANUniversalTagAdServerResponseKeyNoBid;
extern NSString * _Nonnull const  kANUniversalTagAdServerResponseKeyTagNoAdUrl;
extern NSString * _Nonnull const  kANUniversalTagAdServerResponseKeyTagUUID;
extern NSString * _Nonnull const  kANUniversalTagAdServerResponseKeyAdsAuctionId;



#pragma mark -

@interface ANUniversalTagAdServerResponse : NSObject

+ (nullable ANStandardAd *)generateStandardAdUnitFromHTMLContent: (nonnull NSString *)htmlContent
                                                           width: (NSInteger)width
                                                          height: (NSInteger)height;

+ (nullable ANRTBVideoAd *)generateRTBVideoAdUnitFromVASTObject: (nonnull NSString *)vastContent
                                                          width: (NSInteger)width
                                                         height: (NSInteger)height;


+ (nullable NSArray<NSDictionary<NSString *, id> *> *)generateTagsFromResponseData:(nullable NSData *)data;

+ (nonnull NSMutableArray<id> *)generateAdObjectInstanceFromJSONAdServerResponseTag:(nonnull NSDictionary<NSString *, id> *)tag;

@end
