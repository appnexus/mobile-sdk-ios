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

@class ANAdFetcher;
@class ANLocation;

typedef enum _ANGender
{
    UNKNOWN,
    MALE,
    FEMALE
} ANGender;

// ANAdProtocol defines the properties and methods that are common to
// *all* ad types, whether direct descendants of UIView (like
// ANBannerAdView) or modal view controller types (like
// ANInterstitialAdView).

// This protocol can be understood as a toolkit for implementing ad
// types (It's used in the implementation of both banners and
// interstitials by the SDK).  If you wanted to, you could implement
// your own ad type using this protocol.
@protocol ANAdProtocol <NSObject>

@required
@property (nonatomic, readwrite, strong) NSString *placementId;
@property (nonatomic, readwrite, assign) CGSize adSize;
@property (nonatomic, readwrite, assign) BOOL opensInNativeBrowser;
@property (nonatomic, readwrite, strong) ANAdFetcher *adFetcher;
@property (nonatomic, readwrite, assign) BOOL shouldServePublicServiceAnnouncements;
@property (nonatomic, readwrite, strong) ANLocation *location;
@property (nonatomic, readwrite, assign) CGFloat reserve;
@property (nonatomic, readwrite, strong) NSString *age;
@property (nonatomic, readwrite, assign) ANGender gender;
@property (nonatomic, readwrite, strong) NSMutableDictionary *customKeywords;

- (NSString *)adType;
- (void)setLocationWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude
                      timestamp:(NSDate *)timestamp horizontalAccuracy:(CGFloat)horizontalAccuracy;
- (void)addCustomKeywordWithKey:(NSString *)key value:(NSString *)value;
- (void)removeCustomKeywordWithKey:(NSString *)key;

#pragma mark Deprecated Properties

// This property is deprecated; use opensInNativeBrowser instead.
@property (nonatomic, readwrite, assign) BOOL clickShouldOpenInBrowser DEPRECATED_ATTRIBUTE;

@end

@protocol ANAdDelegate <NSObject>

@optional
- (void)adDidReceiveAd:(id<ANAdProtocol>)ad;
- (void)ad:(id<ANAdProtocol>)ad requestFailedWithError:(NSError *)error;
- (void)adWasClicked:(id<ANAdProtocol>)ad;
- (void)adWillClose:(id<ANAdProtocol>)ad;
- (void)adDidClose:(id<ANAdProtocol>)ad;
- (void)adWillPresent:(id<ANAdProtocol>)ad;
- (void)adDidPresent:(id<ANAdProtocol>)ad;
- (void)adWillLeaveApplication:(id<ANAdProtocol>)ad;

@end
