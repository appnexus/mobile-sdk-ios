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

#import <Foundation/Foundation.h>

@class ANDFPBannerViewIdentifier;
@class DFPBannerView;
@class GADRequestError;

typedef NS_ENUM(NSInteger, ANDFPBannerViewLoadingState) {
    ANDFPBannerViewLoadingStatePending = 0,
    ANDFPBannerViewLoadingStateStarted,
    ANDFPBannerViewLoadingStateSucceeded,
    ANDFPBannerViewLoadingStateFailed
};

@interface ANDFPBannerViewCacheInstance : NSObject

@property (nonatomic, readonly) ANDFPBannerViewIdentifier *identifier;

- (instancetype)initWithIdentifier:(ANDFPBannerViewIdentifier *)identifier;
- (void)startLoading;

@property (nonatomic, readonly) ANDFPBannerViewLoadingState loadingState;
@property (nonatomic, readonly) DFPBannerView *bannerView;
@property (nonatomic, readonly) GADRequestError *requestError;

@end