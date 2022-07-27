/*   Copyright 2022 APPNEXUS INC
 
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

typedef void (^XandrAdInitCompletion)(BOOL);

@interface XandrAd : NSObject


+ (nonnull instancetype)sharedInstance;


/**
 * Initialize Xandr Ads SDK
 * @param memberId for initializing the Xandr SDK
 * @param preCacheRequestObjects provides flexibility to pre-cache content, such as fetch userAgent, fetch IDFA and activate OMID. Pre-caching will make future ad requests faster.
 * @param completionHandler The completion handler to call when the init request is complete
 * */
- (void)initWithMemberID:(NSInteger) memberId
        preCacheRequestObjects:(BOOL)preCacheRequestObjects
        completionHandler: (XandrAdInitCompletion _Nullable)completionHandler;


/**
 * API to check if the give Buyer Member ID is eligible for Viewable Impression or not
 * @return true / false based on, if the Buyer Member ID is same as the set memberId
 *                      OR the Buyer Member ID is contained within the cached list of member IDs
 * */
- (BOOL)isEligibleForViewableImpression:(NSInteger) buyerMemberId;


/**
 * API to check if the XandrAd is already initialised or not
 * @return true / false based on the check, if the XandrAd is initialised or not
 * */
- (BOOL)isInitialised;

@end
