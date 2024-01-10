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

#if __has_include(<OMSDK_Microsoft/OMIDImports.h>)
    #import <OMSDK_Microsoft/OMIDImports.h>
#else

#import <OMIDImports.h>
#endif


#pragma mark - Constants

#define AN_OMIDSDK_PARTNER_NAME             @"Microsoft"

#pragma mark - Global class.


@interface ANOMIDImplementation : NSObject

+ (instancetype)sharedInstance;
- (void) activateOMIDandCreatePartner;
- (NSString *)getOMIDJS;
- (OMIDMicrosoftAdSession*) createOMIDAdSessionforWebView:(WKWebView *)webView isVideoAd:(BOOL)videoAd;
- (OMIDMicrosoftAdSession*) createOMIDAdSessionforNative:(UIView *)view withScript:(NSMutableArray *)scripts;
- (void) stopOMIDAdSession:(OMIDMicrosoftAdSession*) omidAdSession;
- (void)fireOMIDImpressionOccuredEvent:(OMIDMicrosoftAdSession*) omidAdSession;
- (void)addFriendlyObstruction:(UIView *) view toOMIDAdSession:(OMIDMicrosoftAdSession*) omidAdSession;
- (void)removeFriendlyObstruction:(UIView *) view toOMIDAdSession:(OMIDMicrosoftAdSession*) omidAdSession;
- (void)removeAllFriendlyObstructions:(OMIDMicrosoftAdSession*) omidAdSession;

@end
