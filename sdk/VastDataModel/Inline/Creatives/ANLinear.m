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

#import "ANLinear.h"

@implementation ANLinear

- (instancetype)initWithXMLElement:(ANXMLElement *)element{
    self = [super init];
    
    if (self) {
        
        NSString *skipOffSet = [ANXML valueOfAttributeNamed:@"skipoffset" forElement:element];
        if (skipOffSet) {
            self.skipOffSet = skipOffSet;
        }
        
        ANXMLElement *durationElement = [ANXML childElementNamed:@"Duration" parentElement:element];
        if (durationElement) {
            self.duration = ANString(durationElement->text);
        }
        
        ANXMLElement *trackingElements = [ANXML childElementNamed:@"TrackingEvents" parentElement:element];
        self.trackingEvents = [NSMutableArray array];
        if (trackingElements) {
            ANXMLElement *trackingElement = [ANXML childElementNamed:@"Tracking" parentElement:trackingElements];
            while (trackingElement) {
                ANTracking *tracking = [[ANTracking alloc] initWithXMLElement:trackingElement];
                if (tracking) {
                    [self.trackingEvents addObject:tracking];
                }
                trackingElement = [ANXML nextSiblingNamed:@"Tracking" searchFromElement:trackingElement];
            }
        }
        
        ANXMLElement *paramElement = [ANXML childElementNamed:@"AdParameters" parentElement:element];
        if (paramElement) {
            NSString *adParam = ANString(paramElement->text);
            if (adParam) {
                self.adParameters = adParam;
            }
        }
        
        ANXMLElement *videoClickElements = [ANXML childElementNamed:@"VideoClicks" parentElement:element];
        if (videoClickElements) {
            self.anVideoClicks = [[ANVideoClicks alloc] initWithXMLElement:videoClickElements];
        }
        
        ANXMLElement *mediaFileElements = [ANXML childElementNamed:@"MediaFiles" parentElement:element];
        self.mediaFiles = [NSMutableArray array];
        if (mediaFileElements) {
            ANXMLElement *mediaFileElement = [ANXML childElementNamed:@"MediaFile" parentElement:mediaFileElements];
            while (mediaFileElement) {
                ANMediaFile *mediaFile = [[ANMediaFile alloc] initWithXMLElement:mediaFileElement];
                if (mediaFile) {
                    [self.mediaFiles addObject:mediaFile];
                }
                mediaFileElement = [ANXML nextSiblingNamed:@"MediaFile" searchFromElement:mediaFileElement];
            }
        }
    }
    
    return self;
}

@end
