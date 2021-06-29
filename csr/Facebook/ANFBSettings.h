/*   Copyright 2020 APPNEXUS INC

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
#import <FBAudienceNetwork/FBAudienceNetwork.h>

NS_ASSUME_NONNULL_BEGIN

@interface ANFBSettings : NSObject
+ (NSString *)getBidderToken;

/**
 Set setFBAudienceNetworkInitialize to YES if Audience Network SDK is initialized, getBidderToken will return the FB BidderToken if setFBAudienceNetworkInitialize is set to YES else nil.
 */
+ (void)setFBAudienceNetworkInitialize:(BOOL)initialized;

/**
  Verify the Audience Network SDK is initialized
 */
+ (BOOL)isFBAudienceNetworkInitialized;



@end


NS_ASSUME_NONNULL_END
