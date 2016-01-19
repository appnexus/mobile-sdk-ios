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


#import "ANMediaFile.h"
#import "ANGlobal.h"

@implementation ANMediaFile

- (instancetype)initWithXMLElement:(ANXMLElement *)element{
    self = [super init];
    
    if (self) {
        self.fileURI = ANString(element->text);
        self.fileId = [ANXML valueOfAttributeNamed:@"id" forElement:element];
        self.deliveryMethod = [ANXML valueOfAttributeNamed:@"delivery" forElement:element];
        self.fileType = [ANXML valueOfAttributeNamed:@"type" forElement:element];
        self.bitRate = [ANXML valueOfAttributeNamed:@"bitrate" forElement:element];
        self.width = [ANXML valueOfAttributeNamed:@"width" forElement:element];
        self.height = [ANXML valueOfAttributeNamed:@"height" forElement:element];
        self.scalable = [ANXML valueOfAttributeNamed:@"scalable" forElement:element];
        self.maintainAspectRatio = [ANXML valueOfAttributeNamed:@"maintainAspectRatio" forElement:element];
        self.apiFramework = [ANXML valueOfAttributeNamed:@"apiFramework" forElement:element];
    }
    
    return self;
}

@end
