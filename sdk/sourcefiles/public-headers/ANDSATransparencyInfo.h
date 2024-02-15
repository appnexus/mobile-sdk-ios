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

/**
Represents transparency information for Digital Services Act (DSA).
This class encapsulates an array of objects representing entities that applied user parameters along with the parameters they applied.

Example Usage:
@code
// Create an instance of ANDSATransparencyInfo
ANDSATransparencyInfo *transparency = [[ANDSATransparencyInfo alloc] initWithDomain:@"example.com" andDSAParams:@[@1, @2, @3]];

// Retrieve transparency information
NSString *domain = transparency.domain;
NSArray<NSNumber *> *dsaparams = transparency.dsaparams;
@endcode
*/
@interface ANDSATransparencyInfo : NSObject

/**
 * Retrieves the transparency user parameters, i.e., the domain of the entity that applied user parameters.
 */
@property (nonatomic, readonly, strong, nullable) NSString *domain;

/**
 * Retrieves the transparency user parameters, i.e., the list of user parameters used for the platform or sell-side.
 */
@property (nonatomic, readonly, strong, nullable) NSArray<NSNumber *> *dsaparams;

/**
 * Initializes an ANDSATransparencyInfo instance with the specified domain and DSA params.
*/
- (nonnull instancetype)initWithDomain:(nonnull NSString *)domain andDSAParams:(nonnull NSArray<NSNumber *> *)dsaparams;

@end
