/*   Copyright 2017 APPNEXUS INC
 
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

#import "TestANUniversalFetcher.h"
#import "ANSDKSettings.h"
#import "ANLogging.h"

@implementation TestANUniversalFetcher



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

-(instancetype)initWithPlacementId:(NSString *)placementId andAllowMediaType:(NSArray<NSValue *> *)mediaType
{
    self = [super init];
    if (!self)  { return nil; }
    
    self.placementId     = placementId;
    self.allowedAdSizes  = [[NSMutableSet alloc] initWithArray:@[ [NSValue valueWithCGSize:kANAdSize1x1] ]];
    self.adAllowedMediaTypes = [mediaType copy];
    self.delegate = self;
    
    //
    return self;
}




#pragma mark - ANUniversalAdFetcherFoundationDelegate  (Partial implementation.)

- (NSArray<NSValue *> *)adAllowedMediaTypes
{
    if(_adAllowedMediaTypes != nil && _adAllowedMediaTypes.count > 0 ){
        return  [_adAllowedMediaTypes copy];
    }else{
        return  @[ @(ANAllowedMediaTypeVideo) ];   //XXX
    }
    
}


- (int)minDuration
{
    ANLogTrace(@"");
    return  5;   //XXX
}
- (int)maxDuration
{
    ANLogTrace(@"");
    return  180;   //XXX
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
