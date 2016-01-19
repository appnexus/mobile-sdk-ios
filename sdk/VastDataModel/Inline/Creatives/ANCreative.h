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
#import "ANLinear.h"
#import "ANCompanion.h"
#import "ANNonLinearAds.h"
#import "ANVastDataModelInterface.h"

@interface ANCreative : ANVastDataModelInterface

@property (nonatomic, strong) NSString *creativeId;
@property (nonatomic, strong) NSString *sequence;
@property (nonatomic, strong) NSString *adId;
@property (nonatomic, strong) ANLinear *anLinear;

@property (nonatomic, strong) NSMutableArray *companionAds;
@property (nonatomic, strong) ANCompanion *anCompanion;

@property (nonatomic, strong) ANNonLinearAds *anNonLinearAds;

@property (nonatomic, strong) NSMutableArray *trackingEvents;

- (instancetype)initWithXMLElement:(ANXMLElement *)element;

@end
