/*   Copyright 2015 APPNEXUS INC
 
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

#import "ANDFPBannerViewIdentifier.h"
#import "ANLogging.h"

@interface ANDFPBannerViewIdentifier ()

@end

@implementation ANDFPBannerViewIdentifier

- (instancetype)init {
    if (self = [super init]) {
        _adUnitId = @"";
        _adSize = CGSizeZero;
        _orientation = ANDFPSmartBannerOrientationNone;
    }
    return self;
}

- (NSUInteger)hash {
    return [[NSString stringWithFormat:
             @"%@%d%d%d",
             self.adUnitId,
             (int)self.adSize.width,
             (int)self.adSize.height,
             (int)self.orientation] hash];
}

- (BOOL)isEqual:(ANDFPBannerViewIdentifier *)otherIdentifier {
    return [self.adUnitId isEqualToString:otherIdentifier.adUnitId]
            && (int)self.adSize.width == (int)otherIdentifier.adSize.width
            && (int)self.adSize.height == (int)otherIdentifier.adSize.height
            && self.orientation == otherIdentifier.orientation;
}

- (id)copyWithZone:(NSZone *)zone {
    ANDFPBannerViewIdentifier *newIdentifier = [[ANDFPBannerViewIdentifier alloc] init];
    newIdentifier.adUnitId = self.adUnitId;
    newIdentifier.adSize = self.adSize;
    newIdentifier.orientation = self.orientation;
    return newIdentifier;
}

@end