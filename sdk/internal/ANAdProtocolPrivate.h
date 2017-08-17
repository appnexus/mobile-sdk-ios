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


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "ANAdConstants.h"

@class ANLocation;



/**
 ANAdProtocolPrivate extends ANAdProtocol with objects essential the lifecycle of ad entry points, 
   but which should not appear in the public facing API.
 */
@protocol ANAdProtocolPrivate <NSObject>

@required
/**
 This represents the Universal Tags (/ut/v2) field "allow_smaller_sizes".
 */
@property (nonatomic, readwrite)  BOOL  allowSmallerSizes;


@end

