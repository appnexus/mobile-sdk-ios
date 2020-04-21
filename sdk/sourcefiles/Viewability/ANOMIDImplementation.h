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
#import <WebKit/WebKit.h>
#import <OMSDK_Appnexus/OMIDImports.h>

#pragma mark - Constants

#define AN_OMIDSDK_PARTNER_NAME             @"Appnexus"

#pragma mark - Global class.


@interface ANOMIDImplementation : NSObject

+ (instancetype)sharedInstance;
- (void) activateOMIDandCreatePartner;
- (NSString *)getOMIDJS;
- (OMIDAppnexusAdSession*) createOMIDAdSessionforWebView:(WKWebView *)webView isVideoAd:(BOOL)videoAd;
- (OMIDAppnexusAdSession*) createOMIDAdSessionforNative:(UIView *)view withScript:(NSMutableArray *)scripts;
- (void) stopOMIDAdSession:(OMIDAppnexusAdSession*) omidAdSession;
- (void)fireOMIDImpressionOccuredEvent:(OMIDAppnexusAdSession*) omidAdSession;
- (void)addFriendlyObstruction:(UIView *) view toOMIDAdSession:(OMIDAppnexusAdSession*) omidAdSession;
- (void)removeFriendlyObstruction:(UIView *) view toOMIDAdSession:(OMIDAppnexusAdSession*) omidAdSession;
- (void)removeAllFriendlyObstructions:(OMIDAppnexusAdSession*) omidAdSession;

@end
