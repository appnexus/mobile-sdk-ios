/*   Copyright 2024 APPNEXUS INC
 
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

#import "ANDSAResponseInfo.h"
#import "ANDSATransparencyInfo.h"

@implementation ANDSAResponseInfo

/**
 * Process the DSA response from ad object.
 *
 * @param dsaObject NSDictionary that contains info of DSA.
 * @return ANDSAResponseInfo if no issue happened during processing.
 */
+ (instancetype)dsaObjectFromAdObject:(NSDictionary *)dsaObject {
    if (!dsaObject || ![dsaObject isKindOfClass:[NSDictionary class]]) {
        return nil;
    }

    ANDSAResponseInfo *dsaResponseInfo = [[ANDSAResponseInfo alloc] init];

    NSString *behalf = dsaObject[@"behalf"];
    if (behalf && [behalf isKindOfClass:[NSString class]]) {
        dsaResponseInfo.behalf = behalf;
    }

    NSString *paid = dsaObject[@"paid"];
    if (paid && [paid isKindOfClass:[NSString class]]) {
        dsaResponseInfo.paid = paid;
    }

    NSArray *transparencyArray = dsaObject[@"transparency"];
    if (transparencyArray && [transparencyArray isKindOfClass:[NSArray class]]) {
        NSMutableArray<ANDSATransparencyInfo *> *transparencyList = [NSMutableArray array];

        for (NSDictionary *transparencyObject in transparencyArray) {
            if ([transparencyObject isKindOfClass:[NSDictionary class]]) {
                NSString *domain = transparencyObject[@"domain"];
                NSArray<NSNumber *> *dsaparams = transparencyObject[@"dsaparams"];
                
                ANDSATransparencyInfo *transparencyInfo = [[ANDSATransparencyInfo alloc] initWithDomain:domain andDSAParams:dsaparams];
                [transparencyList addObject:transparencyInfo];
            }
        }

        dsaResponseInfo.transparencyList = transparencyList;
    }

    NSInteger adRender = [dsaObject[@"adrender"] intValue];
    if (adRender >= 0) {
        dsaResponseInfo.adRender = adRender;
    }

    return dsaResponseInfo;
}

@end
