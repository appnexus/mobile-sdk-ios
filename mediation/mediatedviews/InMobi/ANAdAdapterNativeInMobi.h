/*   Copyright 2015 APPNEXUS INC
 
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

#import <InMobiSDK/IMSdk.h>
#import <InMobiSDK/IMNative.h>

#import "ANNativeCustomAdapter.h"



@interface ANAdAdapterNativeInMobi : NSObject <ANNativeCustomAdapter>

+ (void)setTitleKey:(NSString *)key;
+ (void)setDescriptionTextKey:(NSString *)key;
+ (void)setCallToActionKey:(NSString *)key;
+ (void)setIconKey:(NSString *)key;
+ (void)setScreenshotKey:(NSString *)key;
+ (void)setRatingCountKey:(NSString *)key;
+ (void)setLandingURLKey:(NSString *)key;

@end
