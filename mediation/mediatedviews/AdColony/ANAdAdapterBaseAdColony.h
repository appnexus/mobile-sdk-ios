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

#import <AdColony/AdColony.h>
#import <AdColony/AdColonyAdOptions.h>
#import <AdColony/AdColonyAdRequestError.h>
#import <AdColony/AdColonyAppOptions.h>
#import <AdColony/AdColonyInterstitial.h>
#import <AdColony/AdColonyOptions.h>
#import <AdColony/AdColonyTypes.h>
#import <AdColony/AdColonyUserMetadata.h>
#import <AdColony/AdColonyZone.h>


// Can be used to query ANNativeAdResponse customElements for native ads from AdColony
// Returns AdColonyNativeAdView
extern NSString *const kANAdAdapterNativeAdColonyVideoView;

@interface ANAdAdapterBaseAdColony : NSObject

+ (void)configureWithAppID:(NSString *)appID
                   zoneIDs:(NSArray *)zoneIDs;

@end
