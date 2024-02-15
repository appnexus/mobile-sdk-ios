/*   Copyright 2024 APPNEXUS INC
 
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
#import "ANDSATransparencyInfo.h"

/**
 Represents settings related to the Digital Services Act (DSA) and transparency information required for ad rendering.

 Example Usage:
 @code
 // Create an instance of ANDSASettings
 [ANDSASettings.sharedInstance setDsaRequired:1];
 [ANDSASettings.sharedInstance setPubRender:0];
 // [ANDSASettings.sharedInstance setDataToPub:1];

 // Create a list of transparency info
 NSMutableArray<ANDSATransparencyInfo *> *transparencyList = [NSMutableArray array];
 [transparencyList addObject:[[ANDSATransparencyInfo alloc] initWithDomain:@"example.com" andDSAParams:@[@1, @2, @3]]];
 [transparencyList addObject:[[ANDSATransparencyInfo alloc] initWithDomain:@"example.net" andDSAParams:@[@4, @5, @6]]];

 // Set the transparency list in ANDSASettings
 [ANDSASettings.sharedInstance setTransparencyList:transparencyList];
 @endcode
*/
@interface ANDSASettings : NSObject

/**
 * Set the DSA information requirement.
 * 0 = Not required
 * 1 = Supported, bid responses with or without DSA object will be accepted
 * 2 = Required, bid responses without DSA object will not be accepted
 * 3 = Required, bid responses without DSA object will not be accepted, Publisher is an Online Platform
 */
@property (nonatomic, readwrite, assign) NSInteger dsaRequired;

/**
 * Set if the publisher renders the DSA transparency info.
 * 0 = Publisher can't render
 * 1 = Publisher could render depending on adrender
 * 2 = Publisher will render
 */
@property (nonatomic, readwrite, assign) NSInteger pubRender;


// Publisher app should not be setting dataToPub value. This is not supported in /ut/v3
// This is here only for Testing purpose
/**
 * Set the transparency data if needed for audit purposes.
 * 0 = do not send transparency data
 * 1 = optional to send transparency data
 * 2 = send transparency data
 */
 @property (nonatomic, readwrite, assign) NSInteger dataToPub;

/**
 * Set the transparency list using the provided list of ANDSATransparencyInfo.
 */
@property (nonatomic, strong, nullable) NSArray<ANDSATransparencyInfo *> *transparencyList;

+ (nonnull instancetype)sharedInstance;

@end
