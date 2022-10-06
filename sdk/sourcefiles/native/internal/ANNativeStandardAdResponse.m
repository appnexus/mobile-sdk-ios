/*   Copyright 2014 APPNEXUS INC
 
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

#import "ANNativeStandardAdResponse.h"
#import "ANGlobal.h"
#import "ANLogging.h"
#import "ANNativeAdResponse+PrivateMethods.h"
#import "NSTimer+ANCategory.h"
#import "ANTrackerManager.h"
#import "ANAdConstants.h"
#import "ANRealTimer.h"
#import "ANAdConstants.h"

#if !APPNEXUS_NATIVE_MACOS_SDK
#import "UIView+ANCategory.h"
#import "ANOMIDImplementation.h"
#import "ANBrowserViewController.h"
#else
#import <AppKit/AppKit.h>
#import "NSView+ANCategory.h"
#endif

#import "ANSDKSettings.h"

#if !APPNEXUS_NATIVE_MACOS_SDK
@interface ANNativeStandardAdResponse() <ANBrowserViewControllerDelegate, ANRealTimerDelegate>
@property (nonatomic, readwrite, strong) ANBrowserViewController *inAppBrowser;
#else
@interface ANNativeStandardAdResponse() <ANRealTimerDelegate>
#endif
@property (nonatomic, readwrite, strong) NSDate *dateCreated;
@property (nonatomic, readwrite, assign) ANNativeAdNetworkCode networkCode;
@property (nonatomic, readwrite, assign, getter=hasExpired) BOOL expired;

@property (nonatomic, readwrite, strong) NSTimer *viewabilityTimer;
@property (nonatomic, readwrite, assign) BOOL impressionHasBeenTracked;

@property (nonatomic, readwrite)          BOOL  isAdVisible100Percent;
@end




@implementation ANNativeStandardAdResponse

@synthesize title = _title;
@synthesize body = _body;
@synthesize callToAction = _callToAction;
@synthesize rating = _rating;
@synthesize mainImage = _mainImage;
@synthesize iconImage = _iconImage;
@synthesize mainImageSize = _mainImageSize;
@synthesize mainImageURL = _mainImageURL;
@synthesize iconImageURL = _iconImageURL;
@synthesize customElements = _customElements;
@synthesize iconImageSize = _iconImageSize;
@synthesize networkCode = _networkCode;
@synthesize expired = _expired;
@synthesize sponsoredBy = _sponsoredBy;
@synthesize creativeId = _creativeId;
@synthesize additionalDescription = _additionalDescription;
@synthesize vastXML = _vastXML;
@synthesize privacyLink = _privacyLink;
@synthesize nativeRenderingUrl = _nativeRenderingUrl;
@synthesize nativeRenderingObject = _nativeRenderingObject;
@synthesize adResponseInfo = _adResponseInfo;


#pragma mark - Lifecycle.

- (instancetype)init {
    if (self = [super init]) {
        _networkCode = ANNativeAdNetworkCodeAppNexus;
        _dateCreated = [NSDate date];
        _impressionHasBeenTracked = NO;
        _isAdVisible100Percent    = NO;
        _impressionType = ANBeginToRender;

    }
    return self;
}

- (void)dealloc {
    [self.viewabilityTimer invalidate];
}




#pragma mark - Registration

- (BOOL)registerResponseInstanceWithNativeView:(XandrView *)view
                            rootViewController:(XandrViewController *)controller
                                clickableViews:(NSArray *)clickableViews
                                         error:(NSError *__autoreleasing *)error {
    [self setupViewabilityTracker];
    [self attachGestureRecognizersToNativeView:view
                            withClickableViews:clickableViews];
    
    return YES;
}


- (void)unregisterViewFromTracking {
    [super unregisterViewFromTracking];
    [self.viewabilityTimer invalidate];
}



#pragma mark - Impression Tracking

- (void)setupViewabilityTracker
{
    
#if !APPNEXUS_NATIVE_MACOS_SDK
    if ((self.impressionType == ANViewableImpression || [ANSDKSettings sharedInstance].enableOMIDOptimization)) {
#else
        if (self.impressionType == ANViewableImpression) {
#endif
        [ANRealTimer addDelegate:self];
    }
    
    if(self.impressionType == ANBeginToRender) {
            [self trackImpression];
    }
}

- (void) checkIfViewIs1pxOnScreen {

    CGRect updatedVisibleInViewRectangle = [self.viewForTracking an_visibleInViewRectangle];
#if !APPNEXUS_NATIVE_MACOS_SDK
    ANLogInfo(@"visible rectangle Native: %@", NSStringFromCGRect(updatedVisibleInViewRectangle));
#else
    ANLogInfo(@"visible rectangle Native: %@", NSStringFromRect(updatedVisibleInViewRectangle));
#endif

    if(!self.impressionHasBeenTracked){
        if(updatedVisibleInViewRectangle.size.width > 0 && updatedVisibleInViewRectangle.size.height > 0){
            ANLogInfo(@"Impression tracker fired when 1px native on screen");
            [self trackImpression];
        }
    }
#if !APPNEXUS_NATIVE_MACOS_SDK
    if([ANSDKSettings sharedInstance].enableOMIDOptimization){
        if(updatedVisibleInViewRectangle.size.width == self.viewForTracking.frame.size.width && updatedVisibleInViewRectangle.size.height ==  self.viewForTracking.frame.size.height && !self.isAdVisible100Percent){
            self.isAdVisible100Percent = YES;
        }else  if(updatedVisibleInViewRectangle.size.width == 0 && updatedVisibleInViewRectangle.size.height == 0 && self.isAdVisible100Percent){
            if (self.omidAdSession != nil){
                [[ANOMIDImplementation sharedInstance] stopOMIDAdSession:self.omidAdSession];
                [ANRealTimer removeDelegate:self];
                
                
            }
        }
    }
#endif

}

- (void)checkIfIABViewable {
  
#if !APPNEXUS_NATIVE_MACOS_SDK
    
if (self.viewForTracking.window) {
        [self trackImpression];
    }
    
#endif

}

- (void)trackImpression {
    if (!self.impressionHasBeenTracked) {

        ANLogDebug(@"Firing impression trackers");
        [self fireImpTrackers];
        [self.viewabilityTimer invalidate];
        self.impressionHasBeenTracked = YES;
       
#if !APPNEXUS_NATIVE_MACOS_SDK
        if(![ANSDKSettings sharedInstance].enableOMIDOptimization){
            [ANRealTimer removeDelegate:self];
        }
#else
        if (self.impressionType == ANViewableImpression) {
            [ANRealTimer removeDelegate:self];
        }
#endif
    }
}

- (void)fireImpTrackers {
   
    if (self.impTrackers) {
        [ANTrackerManager fireTrackerURLArray:self.impTrackers withBlock:^(BOOL isTrackerFired) {
            if (isTrackerFired) {
                [super adDidLogImpression];
            }
        }];
    }
#if !APPNEXUS_NATIVE_MACOS_SDK
    if(self.omidAdSession != nil){
        [[ANOMIDImplementation sharedInstance] fireOMIDImpressionOccuredEvent:self.omidAdSession];
    }
#endif
}

- (void) handle1SecTimerSentNotification {
    [self checkIfViewIs1pxOnScreen];
}




#pragma mark - Click handling

- (void)handleClick
{
    [self fireClickTrackers];

    if (ANClickThroughActionReturnURL == self.clickThroughAction)
    {
        [self adWasClickedWithURL:[self.clickURL absoluteString] fallbackURL:[self.clickFallbackURL absoluteString]];
        
        ANLogDebug(@"ClickThroughURL=%@", self.clickURL);
        ANLogDebug(@"ClickThroughFallbackURL=%@", self.clickFallbackURL);
        return;
    }

    //
    [self adWasClicked];

    if ([self openIntendedBrowserWithURL:self.clickURL])  { return; }
    ANLogDebug(@"Could not open click URL: %@", self.clickURL);

    if ([self openIntendedBrowserWithURL:self.clickFallbackURL])  { return; }
    ANLogError(@"Could not open click fallback URL: %@", self.clickFallbackURL);
}

- (BOOL)openIntendedBrowserWithURL:(NSURL *)URL
{
    switch (self.clickThroughAction)
    {
#if !APPNEXUS_NATIVE_MACOS_SDK
        case ANClickThroughActionOpenSDKBrowser:
            // Try to use device browser even if SDK browser was requested in cases
            //   where the structure of the URL cannot be handled by the SDK browser.
            //
            if (!ANHasHttpPrefix(URL.absoluteString) && !ANiTunesIDForURL(URL))
            {
                return  [self openURLWithExternalBrowser:URL];
            }

            if (!self.inAppBrowser) {
                self.inAppBrowser = [[ANBrowserViewController alloc] initWithURL: URL
                                                                        delegate: self
                                                        delayPresentationForLoad: self.landingPageLoadsInBackground ];
            } else {
                self.inAppBrowser.url = URL;
            }
            return  YES;
            break;

        case ANClickThroughActionOpenDeviceBrowser:
            return  [self openURLWithExternalBrowser:URL];
            break;
#endif
        case ANClickThroughActionReturnURL:
            //NB -- This case handled by calling method.
            /*NOT REACHED*/

        default:
            ANLogError(@"UNKNOWN ANClickThroughAction.  (%lu)", (unsigned long)self.clickThroughAction);
            return  NO;
    }
}

- (BOOL) openURLWithExternalBrowser:(NSURL *)url
{
    
#if !APPNEXUS_NATIVE_MACOS_SDK
    if (![[UIApplication sharedApplication] canOpenURL:url])  { return NO; }

#endif

    [self willLeaveApplication];
    [ANGlobal openURL:[url absoluteString]];

    return  YES;
}


- (void)fireClickTrackers
{
    [ANTrackerManager fireTrackerURLArray:self.clickTrackers withBlock:nil];
}




#pragma mark - ANBrowserViewControllerDelegate
#if !APPNEXUS_NATIVE_MACOS_SDK

- (UIViewController *)rootViewControllerForDisplayingBrowserViewController:(ANBrowserViewController *)controller {
    return self.rootViewController;
}


- (void)didDismissBrowserViewController:(ANBrowserViewController *)controller {
    self.inAppBrowser = nil;
    [self didCloseAd];
}

- (void)willPresentBrowserViewController:(ANBrowserViewController *)controller {
    [self willPresentAd];
}

- (void)didPresentBrowserViewController:(ANBrowserViewController *)controller {
    [self didPresentAd];
}

- (void)willDismissBrowserViewController:(ANBrowserViewController *)controller {
    [self willCloseAd];
}


- (void)willLeaveApplicationFromBrowserViewController:(ANBrowserViewController *)controller {
    [self willLeaveApplication];
}
#endif

- (void)registerAdWillExpire{
    [self registerAdAboutToExpire];
}


@end
