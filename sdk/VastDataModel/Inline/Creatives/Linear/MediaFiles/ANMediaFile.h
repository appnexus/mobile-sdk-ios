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
#import "ANVastDataModelInterface.h"

@interface ANMediaFile : ANVastDataModelInterface

@property (nonatomic, strong) NSString *fileURI;
@property (nonatomic, strong) NSString *fileId;
@property (nonatomic) NSString *deliveryMethod;
@property (nonatomic, strong) NSString *fileType;
@property (nonatomic, strong) NSString *bitRate;
@property (nonatomic, strong) NSString *width;
@property (nonatomic, strong) NSString *height;
@property (nonatomic, strong) NSString *scalable;
@property (nonatomic, strong) NSString *maintainAspectRatio;
@property (nonatomic, strong) NSString *apiFramework;

- (instancetype)initWithXMLElement:(ANXMLElement *)element;

@end
