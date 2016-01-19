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


#import <Foundation/Foundation.h>
#import "ANStaticResource.h"
#import "ANTracking.h"
#import "ANVastDataModelInterface.h"

@interface ANCompanion : ANVastDataModelInterface

@property (nonatomic, strong) NSString *companionId;
@property (nonatomic, strong) NSString *width;
@property (nonatomic, strong) NSString *height;
@property (nonatomic, strong) NSString *expandedWidth;
@property (nonatomic, strong) NSString *expandedHeight;
@property (nonatomic, strong) NSString *apiFramework;

@property (nonatomic, strong) ANStaticResource *anStaticResource;
@property (nonatomic, strong) NSString *iFrameResource;
@property (nonatomic, strong) NSString *htmlResource;

@property (nonatomic, strong) NSMutableArray *trackingEvents;

@property (nonatomic, strong) NSString *clickThroughURI;
@property (nonatomic, strong) NSString *altText;
@property (nonatomic, strong) NSString *adParameters;

- (instancetype)initWithXMLElement:(ANXMLElement *)element;

@end
