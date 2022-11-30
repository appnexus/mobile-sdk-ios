/*   Copyright 2022 XANDR INC

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

@interface ANGPPSettings : NSObject

/**
 * Get the IAB Gpp  String in the SDK.
 * Check for AN_IABGPP_HDR_GppString and return if present else return @""
 */
+ (nonnull NSString *) getGPPString;

/**
 * Get the IAB Gpp Section ID(s) considered to be in force.
 * Check for AN_IABGPP_GppSID and return if present else return @""
 */
+ (nonnull NSArray<NSNumber *> *) getGPPSIDArray;

@end
