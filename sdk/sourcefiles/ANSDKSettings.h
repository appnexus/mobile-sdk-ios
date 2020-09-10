/*   Copyright 2016 APPNEXUS INC
 
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




@interface ANSDKSettings : NSObject

/**
 If YES, the SDK will make all requests in HTTPS. Default is NO.
 */
@property (nonatomic) BOOL HTTPSEnabled DEPRECATED_MSG_ATTRIBUTE("All network calls are secure. HTTPSEnabled property is deprecated.");

/**
 If YES, the SDK will allow to support Open-Measurement for viewability and verification measurement for ads served. Default is YES.
 */
@property (nonatomic) BOOL enableOpenMeasurement;

/**
 Special ad sizes for which the content view should be constrained to the container view.
 */
@property (nonatomic, copy, nullable) BOOL (^shouldConstrainToSuperview)(NSValue* _Nonnull);

/**
 * Set false to block Location popup asked by Creative, Also notify creative that User denied the request for location.
 * Set True continue the default behaviour.
 * locationEnabledForCreative is turned on by default.
 */
@property (nonatomic) BOOL locationEnabledForCreative;

/**
 If provided, the SDK will use it instead of one fetched from a WebView
 */
@property (nonatomic, readwrite, strong, nullable) NSString *customUserAgent;

/**
Get AppNexus SDK Version
*/
@property (nonatomic, readonly, strong, nonnull) NSString *sdkVersion;


+ (nonnull instancetype)sharedInstance;

- (void) optionalSDKInitialization;

@end
