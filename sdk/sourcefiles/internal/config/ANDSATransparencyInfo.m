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

#import "ANDSATransparencyInfo.h"

@implementation ANDSATransparencyInfo

/**
 * Initializes an ANDSATransparencyInfo instance with the specified domain and DSA params.
*/
- (instancetype)initWithDomain:(NSString *)domain andDSAParams:(NSArray<NSNumber *> *)dsaparams {
    self = [super init];
    if (self) {
        _domain = domain;
        _dsaparams = dsaparams;
    }
    return self;
}

@end
