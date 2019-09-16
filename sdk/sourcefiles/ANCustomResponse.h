/*   Copyright 2019 APPNEXUS INC
 
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
#import "ANAdConstants.h"

@interface ANCustomResponse : NSObject
/**
 An AppNexus creativeID for the current creative that is displayed
 */
@property (nonatomic, readwrite, strong, nullable) NSString *creativeId;

/**
 Report the Ad Type of the returned ad object.
 Not available until load is complete and successful.
 */
@property (nonatomic, readwrite)  ANAdType  adType;

/**
 An AppNexus tagId for the current ad object which is placementID that is displayed
 */
@property (nonatomic, readwrite, strong, nullable)  NSString  *tagId;

@end

