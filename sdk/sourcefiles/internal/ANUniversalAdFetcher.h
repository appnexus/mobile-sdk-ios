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

#import "ANVideoAdProcessor.h"
#import "ANTrackerInfo.h"
#import "ANUniversalTagAdServerResponse.h"
#import "ANAdFetcherResponse.h"
#import "ANLocation.h"
#import "ANAdConstants.h"
#import "ANAdViewInternalDelegate.h"
#import "ANAdProtocol.h"
#import "ANGlobal.h"
#import "ANAdFetcherBase+PrivateMethods.h"
#import "ANMRAIDContainerView.h"




#pragma mark -

@protocol ANUniversalAdFetcherDelegate;

@interface ANUniversalAdFetcher : ANAdFetcherBase

@property (nonatomic, readonly, strong)  ANMRAIDContainerView  *adView;

- (nonnull instancetype)initWithDelegate:(nonnull id)delegate;
- (nonnull instancetype)initWithDelegate:(nonnull id)delegate andAdUnitMultiAdRequestManager:(nonnull ANMultiAdRequest *)adunitMARManager;
- (nonnull instancetype)initWithMultiAdRequestManager:(nonnull ANMultiAdRequest *)marManager;

- (void)stopAdLoad;
- (void)startAutoRefreshTimer;
- (void)restartAutoRefreshTimer;
- (void)stopAutoRefreshTimer;

- (CGSize)getWebViewSizeForCreativeWidth:(nonnull NSString *)width
                               andHeight:(nonnull NSString *)height;

@end




#pragma mark - Ad Fetcher Delegates.

@protocol  ANUniversalRequestTagBuilderCore

// customKeywords is shared between the adunits and the fetcher.
//
// NB  This definition of customKeywords should not be confused with the public facing ANTargetingParameters.customKeywords
//       which is shared between fetcher and the mediation adapters.
//     The version here is a dictionary of arrays of strings, the public facing version is simply a dictionary of strings.
//
@property (nonatomic, readwrite, strong, nullable)  NSMutableDictionary<NSString *, NSArray<NSString *> *>  *customKeywords;

@end



@protocol  ANUniversalRequestTagBuilderDelegate <ANUniversalRequestTagBuilderCore>

@required

- (nonnull NSArray<NSValue *> *)adAllowedMediaTypes;

// NB  Represents lazy evaluation as a means to get most current value of primarySize (eg: from self.containerSize).
//     In addition, this method combines collection of all three size parameters to avoid synchronization issues.
//
- (nonnull NSDictionary *) internalDelegateUniversalTagSizeParameters;

// AdUnit internal methods to manage UUID property used during Multi-Tag Requests.
//
- (nonnull NSString *)internalGetUTRequestUUIDString;
- (void)internalUTRequestUUIDStringReset;


@optional

//   If rendererId is not set, the default is zero (0).
//   A value of zero indicates that renderer_id will not be sent in the UT Request.
//   nativeRendererId is sufficient for ANBannerAdView and ANNativeAdRequest entry point.
//
- (NSInteger) nativeAdRendererId;

//
- (void)       universalAdFetcher: (nonnull ANUniversalAdFetcher *)fetcher
     didFinishRequestWithResponse: (nonnull ANAdFetcherResponse *)response;

@end



@protocol  ANUniversalAdFetcherFoundationDelegate <ANUniversalRequestTagBuilderDelegate, ANAdProtocolFoundation>
    //EMPTY
@end




#pragma mark -

// NB  ANUniversalAdFetcherDelegate is sufficient for Banner, Interstitial entry point.
//
@protocol  ANUniversalAdFetcherDelegate <ANUniversalAdFetcherFoundationDelegate, ANAdProtocolBrowser, ANAdProtocolPublicServiceAnnouncement, ANAdViewInternalDelegate>

@required

- (CGSize)requestedSizeForAdFetcher:(nonnull ANUniversalAdFetcher *)fetcher;


@optional

// NB  autoRefreshIntervalForAdFetcher: and videoAdTypeForAdFetcher: are required for ANBannerAdView,
//       but are not used by any other adunit.
//
- (NSTimeInterval) autoRefreshIntervalForAdFetcher:(nonnull ANUniversalAdFetcher *)fetcher;
- (ANVideoAdSubtype) videoAdTypeForAdFetcher:(nonnull ANUniversalAdFetcher *)fetcher;


//   If enableNativeRendering is not set, the default is false.
//   A value of false Indicates that NativeRendering is disabled
//   enableNativeRendering is sufficient to BannerAd entry point.
-(BOOL) enableNativeRendering;

//   Set the Orientation of the Video rendered to BannerAdView taken from  ANAdWebViewController
//   setVideoAdOrientation is sufficient to BannerAd entry point.
-(void)setVideoAdOrientation:(ANVideoOrientation)videoOrientation;

@end

