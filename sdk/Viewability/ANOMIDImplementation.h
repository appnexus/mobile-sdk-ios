/*   Copyright 2018 APPNEXUS INC
 
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
#import "OMIDImports.h"

#pragma mark - Constants

#define AN_OMIDSDK_PARTNER_NAME             @"appnexus.com-omios"
#define AN_OMIDSDKAPIVersionString             @"{\"v\":\"1.2.5\",\"a\":\"1\"}"

#pragma mark - Global class.


@interface ANOMIDImplementation : NSObject

+ (instancetype)sharedInstance;
- (void) activateOMIDandCreatePartner;
- (NSString *)prependOMIDJSToHTML:(NSString *)html;
- (OMIDAppnexusAdSession*) createOMIDAdSessionforWebView: webView isVideoAd:(BOOL)videoAd;
- (void) stopOMIDAdSession:(OMIDAppnexusAdSession*) omidAdSession;
- (void)fireOMIDImpressionOccuredEvent:(OMIDAppnexusAdSession*) omidAdSession;

@end
