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

#import "TestANCSRUniversalFetcher.h"
#import "ANSDKSettings.h"
#import "ANLogging.h"

@implementation TestANCSRUniversalFetcher



-(instancetype)initWithPlacementId:(NSString *)placementId
{
    self = [super init];
    if (!self)  { return nil; }
    
    self.placementId     = placementId;
    self.allowedAdSizes  = [[NSMutableSet alloc] initWithArray:@[ [NSValue valueWithCGSize:kANAdSize1x1] ]];

    self.delegate = self;
    
    //
    return self;
}



#pragma mark - ANUniversalAdFetcherFoundationDelegate  (Partial implementation.)

- (NSArray<NSValue *> *)adAllowedMediaTypes
{
    ANLogTrace(@"");
    return  @[ @(ANAllowedMediaTypeNative) ];   //XXX
}


- (NSDictionary *) internalDelegateUniversalTagSizeParameters
{
    NSMutableDictionary  *delegateReturnDictionary  = [[NSMutableDictionary alloc] init];

    [delegateReturnDictionary setObject:[NSValue valueWithCGSize:kANAdSize1x1]  forKey:ANInternalDelgateTagKeyPrimarySize];
    [delegateReturnDictionary setObject:self.allowedAdSizes                     forKey:ANInternalDelegateTagKeySizes];
    [delegateReturnDictionary setObject:@(self.allowSmallerSizes)               forKey:ANInternalDelegateTagKeyAllowSmallerSizes];

    return  delegateReturnDictionary;
}

@end
