/*   Copyright 2013 APPNEXUS INC
 
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

#import "ANAdProtocol.h"
#import "ANLocation.h"



/**
 Define the object that is passed into each mediation adapter to retrieve
 additional targeting parameters from the app.
 */
@interface ANTargetingParameters : NSObject

/**
 Custom targeting keywords from the app.
 */
@property (nonatomic, readwrite, strong) NSDictionary<NSString *, NSString *>  *customKeywords;

@property (nonatomic, readwrite, strong) NSString *age;
@property (nonatomic, readwrite, assign) ANGender gender;
@property (nonatomic, readwrite, strong) NSString *externalUid;
/**
 location may be nil if not specified by app.
 */
@property (nonatomic, readwrite, strong) ANLocation *location;

/**
 The IDFA.
 */
@property (nonatomic, readwrite, strong) NSString *idforadvertising;

@end

