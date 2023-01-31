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
#import "ANTrackerInfo.h"
#import "ANUniversalTagAdServerResponse.h"
#import "ANAdFetcherResponse.h"
#import "ANLocation.h"
#import "ANAdConstants.h"
#import "ANAdViewInternalDelegate.h"
#import "ANAdProtocol.h"
#import "ANGlobal.h"
#import "ANAdFetcherBase+PrivateMethods.h"
#import "ANAdFetcherBase.h"



@interface ANAdFetcher : ANAdFetcherBase

- (nonnull instancetype)initWithDelegate:(nonnull id)delegate;

- (void)startAutoRefreshTimer;
- (void)restartAutoRefreshTimer;
- (void)stopAutoRefreshTimer;

- (CGSize)getWebViewSizeForCreativeWidth:(nonnull NSString *)width
                               andHeight:(nonnull NSString *)height;

- (BOOL)allocateAndSetWebviewWithSize: (CGSize)webviewSize
                              content: (nonnull NSString *)webviewContent
                        isXMLForVideo: (BOOL)isContentXMLForVideo;

- (BOOL)allocateAndSetWebviewFromCachedAdObjectHandler;

// fire impression trackers for Begin To Render cases
- (void) checkifBeginToRenderAndFireImpressionTracker:(nonnull ANBaseAdObject *) ad;

@end


#pragma mark -

// NB  ANAdFetcherFoundationDelegate is used in ANInstreamVideoAd entry point.
@protocol  ANAdFetcherFoundationDelegate <ANRequestTagBuilderCore, ANAdProtocolFoundation>


@optional
//
- (void)       adFetcher: (nonnull ANAdFetcherBase *)fetcher
     didFinishRequestWithResponse: (nonnull ANAdFetcherResponse *)response;
@end



#pragma mark -

// NB  ANAdFetcherDelegate is used for Banner, Interstitial entry point.
//
@protocol  ANAdFetcherDelegate <ANAdFetcherFoundationDelegate, ANAdProtocolBrowser, ANAdProtocolPublicServiceAnnouncement, ANAdViewInternalDelegate>

@required

- (CGSize)requestedSizeForAdFetcher:(nonnull ANAdFetcherBase *)fetcher;


@optional

// NB  autoRefreshIntervalForAdFetcher: and videoAdTypeForAdFetcher: are required for ANBannerAdView,
//       but are not used by any other adunit.
//
- (NSTimeInterval) autoRefreshIntervalForAdFetcher:(nonnull ANAdFetcher *)fetcher;
- (ANVideoAdSubtype) videoAdTypeForAdFetcher:(nonnull ANAdFetcher *)fetcher;


//   If enableNativeRendering is not set, the default is false.
//   A value of false Indicates that NativeRendering is disabled
//   enableNativeRendering is sufficient to BannerAd entry point.
-(BOOL) enableNativeRendering;

//   Set the Orientation of the Video rendered to BannerAdView taken from  ANAdWebViewController
//   setVideoAdOrientation is sufficient to BannerAd entry point.
-(void)setVideoAdOrientation:(ANVideoOrientation)videoOrientation;

-(void)setVideoAdWidth:(NSInteger)videoAdWidth;

-(void)setVideoAdHeight:(NSInteger)videoAdHeight;

@end


