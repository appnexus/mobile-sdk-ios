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
// This protocol defines all the things that are common between *all* types of ads, whether they be direct descendants of UIView as in ANBannerAdView, or modal view controller types like ANInterstitalAd.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class ANAdFetcher;
@class ANLocation;
@protocol ANAdDelegate;

typedef enum _ANGender
{
    UNKNOWN,
    MALE,
    FEMALE
} ANGender;

@protocol ANAdProtocol <NSObject>

@required
@property (nonatomic, readwrite, strong) NSString *placementId;
@property (nonatomic, readwrite, assign) CGSize adSize;
@property (nonatomic, readwrite, assign) BOOL clickShouldOpenInBrowser;
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

@end

@protocol ANAdDelegate <NSObject>

@optional
- (void)adDidReceiveAd:(id<ANAdProtocol>)ad;
- (void)ad:(id<ANAdProtocol>)ad requestFailedWithError:(NSError *)error;
- (void)adDidClose:(id<ANAdProtocol>)ad;
- (void)adWillClose:(id<ANAdProtocol>)ad;
- (void)adWillPresent:(id<ANAdProtocol>)ad;
- (void)adWillLeaveApplication:(id<ANAdProtocol>)ad;

@end
