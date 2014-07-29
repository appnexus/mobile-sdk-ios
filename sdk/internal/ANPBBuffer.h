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

#import "ANAdFetcher.h"

#import <Foundation/Foundation.h>

extern NSString *const kANPBBufferMediatedNetworkNameKey;
extern NSString *const kANPBBufferMediatedNetworkPlacementIDKey;
extern NSString *const kANPBBufferAdWidthKey;
extern NSString *const kANPBBufferAdHeightKey;

@interface ANPBBuffer : NSObject

+ (void)handleUrl:(NSURL *)URL forView:(UIView *)view;

// returns auction_id field for convenience
+ (NSString *)saveAuctionInfo:(NSString *)auctionInfo;
+ (void)addAdditionalInfo:(NSDictionary *)info
             forAuctionID:(NSString *)auctionID;

+ (void)captureImage:(UIView *)view forAuctionID:(NSString *)auctionID;
+ (void)captureDelayedImage:(UIView *)view forAuctionID:(NSString *)auctionID;

+ (void)launchPitbullApp;

@end
