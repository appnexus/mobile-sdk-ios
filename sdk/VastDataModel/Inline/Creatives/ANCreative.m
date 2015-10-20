/* Copyright 2015 APPNEXUS INC
 
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


#import "ANCreative.h"

@implementation ANCreative

- (instancetype)initWithXMLElement:(ANXMLElement *)element{
    self = [super init];
    
    if (self) {
        NSString *creativeId = [ANXML valueOfAttributeNamed:@"id" forElement:element];
        if (creativeId) {
            self.creativeId = creativeId;
        }
        
        NSString *sequence = [ANXML valueOfAttributeNamed:@"sequence" forElement:element];
        if (sequence) {
            self.sequence = sequence;
        }
        
        NSString *adId = [ANXML valueOfAttributeNamed:@"AdId" forElement:element];
        if (adId) {
            self.adId = adId;
        }
        
        ANXMLElement *linearElement = [ANXML childElementNamed:@"Linear" parentElement:element];
        if (linearElement) {
            self.anLinear = [[ANLinear alloc] initWithXMLElement:linearElement];
        }
        
        ANXMLElement *companionAdsElement = [ANXML childElementNamed:@"CompanionAds" parentElement:element];
        self.companionAds = [NSMutableArray array];
        if (companionAdsElement) {
            ANXMLElement *companionElement = [ANXML childElementNamed:@"Companion" parentElement:companionAdsElement];
            while (companionElement) {
                ANCompanion *companion = [[ANCompanion alloc] initWithXMLElement:companionElement];
                if (companion) {
                    [self.companionAds addObject:companion];
                }
                companionElement = [ANXML nextSiblingNamed:@"Companion" searchFromElement:companionElement];
            }
        }
        
        ANXMLElement *nonLinearElements = [ANXML childElementNamed:@"NonLinearAds" parentElement:element];
        if (nonLinearElements) {
            self.anNonLinearAds = [[ANNonLinearAds alloc] initWithXMLElement:nonLinearElements];
        }
        
    }
    
    return self;
}

@end
