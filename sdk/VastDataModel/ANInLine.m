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


#import "ANInLine.h"

@implementation ANInLine

- (instancetype)initWithXMLElement:(ANXMLElement *)element{
    self = [super init];
    
    if (self) {

        ANXMLElement *adSystemElement = [ANXML childElementNamed:@"AdSystem" parentElement:element];
        if (adSystemElement) {
            self.anAdSystem = [[ANAdSystem alloc] initWithXMLElement:adSystemElement];
        }
        
        ANXMLElement *adTitleElement = [ANXML childElementNamed:@"AdTitle" parentElement:element];
        if (adTitleElement) {
            self.adTitle = ANString(adTitleElement->text);
        }
        
        ANXMLElement *descElement = [ANXML childElementNamed:@"Description" parentElement:element];
        if (descElement) {
            self.adDescription = ANString(descElement->text);
        }
        
        ANXMLElement *surveyElement = [ANXML childElementNamed:@"Survey" parentElement:element];
        if (surveyElement) {
            self.adSurvey = ANString(surveyElement->text);
        }
        
        ANXMLElement *errorElement = [ANXML childElementNamed:@"Error" parentElement:element];
        if (errorElement) {
            self.adError = ANString(errorElement->text);
        }
        
        ANXMLElement *impressionElement = [ANXML childElementNamed:@"Impression" parentElement:element];
        self.impressions = [NSMutableArray array];
        while (impressionElement) {
            ANImpression *anImpression = [[ANImpression alloc] initWithXMLElement:impressionElement];
            if (anImpression) {
                [self.impressions addObject:anImpression];
            }
            impressionElement = [ANXML nextSiblingNamed:@"Impression" searchFromElement:impressionElement];
        }
        
        ANXMLElement *creativesElement = [ANXML childElementNamed:@"Creatives" parentElement:element];
        if (creativesElement) {
            ANXMLElement *creativeElement = [ANXML childElementNamed:@"Creative" parentElement:creativesElement];
            self.creatives = [NSMutableArray array];
            while (creativeElement) {
                ANCreative *anCreative = [[ANCreative alloc] initWithXMLElement:creativeElement];
                if (anCreative) {
                    [self.creatives addObject:anCreative];
                }
                creativeElement = [ANXML nextSiblingNamed:@"Creative" searchFromElement:creativeElement];
            }
        }
        
    }
    
    return self;
}

@end
