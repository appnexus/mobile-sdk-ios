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


#import "ANNonLinear.h"
#import "ANGlobal.h"

@implementation ANNonLinear

- (instancetype)initWithXMLElement:(ANXMLElement *)element{
    self = [super init];
    if (self) {
        self.nonLinearId = [ANXML valueOfAttributeNamed:@"id" forElement:element];
        self.width = [ANXML valueOfAttributeNamed:@"width" forElement:element];
        self.height = [ANXML valueOfAttributeNamed:@"height" forElement:element];
        self.expandedWidth = [ANXML valueOfAttributeNamed:@"expandedWidth" forElement:element];
        self.expandedHeight = [ANXML valueOfAttributeNamed:@"expandedHeight" forElement:element];
        self.scalable = [ANXML valueOfAttributeNamed:@"scalable" forElement:element];
        self.maintainAspectRatio = [ANXML valueOfAttributeNamed:@"maintainAspectRatio" forElement:element];
        self.minSuggestedDuration = [ANXML valueOfAttributeNamed:@"minSuggestedDuration" forElement:element];
        self.apiFramework = [ANXML valueOfAttributeNamed:@"apiFramework" forElement:element];
        
        ANXMLElement *staticResourceElement = [ANXML childElementNamed:@"StaticResource" parentElement:element];
        if (staticResourceElement) {
            self.anStaticResource = [[ANStaticResource alloc] initWithXMLElement:staticResourceElement];
        }
        
        ANXMLElement *iFrameResourceElement = [ANXML childElementNamed:@"IFrameResource" parentElement:element];
        if (iFrameResourceElement) {
            self.iFrameResource = ANString(iFrameResourceElement->text);
        }
        
        ANXMLElement *htmlResourceElement = [ANXML childElementNamed:@"HTMLResource" parentElement:element];
        if (htmlResourceElement) {
            self.htmlResource = ANString(htmlResourceElement->text);
        }

        ANXMLElement *clickThroughElement = [ANXML nextSiblingNamed:@"ClickThrough" searchFromElement:element];
        if (clickThroughElement) {
            self.clickThroughURI = ANString(clickThroughElement->text);
        }
        
        ANXMLElement *adParametersElement = [ANXML nextSiblingNamed:@"AdParameters" searchFromElement:element];
        if (adParametersElement) {
            self.adParameters = ANString(adParametersElement->text);
        }

    }
    
    return self;
}

@end
