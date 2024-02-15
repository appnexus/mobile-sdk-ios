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

#import <Foundation/Foundation.h>
#import "ANDSATransparencyInfo.h"

/**
 Represents the response information for Digital Services Act (DSA) related data and transparency information.
 This class includes fields for information such as on whose behalf the ad is displayed, who paid for the ad,
 ad rendering information, and a list of transparency information.

 @code
 NSString *behalf = adResponseInfo.dsaResponseInfo.behalf;
 NSString *paid = adResponseInfo.dsaResponseInfo.paid;
 for (ANDSATransparencyInfo *transparencyInfo in adResponseInfo.dsaResponseInfo.transparencyList) {
      NSString *domain = transparencyInfo.domain;
      NSArray<NSNumber *> *params = transparencyInfo.dsaparams;
 }
 NSInteger adRender = adResponseInfo.dsaResponseInfo.adRender;
 @endcode
 */
@interface ANDSAResponseInfo : NSObject

/**
 * Retrieve on whose behalf the ad is displayed.
 */
@property (nonatomic, readwrite, strong, nullable) NSString *behalf;

/**
 * Retrieve who paid for the ad.
 */
@property (nonatomic, readwrite, strong, nullable) NSString *paid;

/**
 * Retrieve indicating if the buyer/advertiser will render DSA transparency info.
 * 0 = buyer/advertiser will not render
 * 1 = buyer/advertiser will render
 */
@property (nonatomic, readwrite, assign) NSInteger adRender;

/**
 * Retrieve the transparency user parameters info
 */
@property (nonatomic, strong, nullable) NSMutableArray<ANDSATransparencyInfo *> *transparencyList;

/**
 * Process the DSA response from ad object.
 *
 * @param dsaObject NSDictionary that contains info of DSA.
 * @return ANDSAResponseInfo if no issue happened during processing.
 */
+ (nullable instancetype)dsaObjectFromAdObject:(nullable NSDictionary *)dsaObject;

@end
