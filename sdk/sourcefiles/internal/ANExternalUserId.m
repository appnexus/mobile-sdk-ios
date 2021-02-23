/*   Copyright 2021 APPNEXUS INC
 
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

#import "ANExternalUserId.h"

@implementation ANExternalUserId

@synthesize  source                            = __source;
@synthesize  userId                            = __userId;

- (nullable instancetype)initWithSource:(ANExternalUserIdSource)source userId:(NSString *)userId{
    self = [super init];
    
    if (self != nil) {
        self.source = source;
        self.userId = userId;
    }
    
    return self;
}

@end
