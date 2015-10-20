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


#import "ANNonLinearAds.h"

@implementation ANNonLinearAds

- (instancetype)initWithXMLElement:(ANXMLElement *)element{
    self = [super init];

    if (self) {
        
        ANXMLElement *nonLinearElement = [ANXML childElementNamed:@"NonLinear" parentElement:element];
        if (nonLinearElement) {
            self.anNonLinear = [[ANNonLinear alloc] initWithXMLElement:nonLinearElement];

            ANXMLElement *trackingEventsElement = [ANXML childElementNamed:@"TrackingEvents" parentElement:element];
            self.trackingEvents = [NSMutableArray array];
            if (trackingEventsElement) {
                ANXMLElement *trackingElement = [ANXML childElementNamed:@"Tracking" parentElement:trackingEventsElement];
                while (trackingElement) {
                    ANTracking *tracking = [[ANTracking alloc] initWithXMLElement:trackingElement];
                    if (tracking) {
                        [self.trackingEvents addObject:tracking];
                    }
                }
            }
        }
        
    }
    
    return self;
}

@end
