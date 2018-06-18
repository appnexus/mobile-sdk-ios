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
#import "ANBrowserViewController.h"
#import "ANNativeAdResponse+PrivateMethods.h"
#import "NSTimer+ANCategory.h"
#import "UIView+ANCategory.h"
#import "ANTrackerManager.h"




@interface ANNativeStandardAdResponse() <ANBrowserViewControllerDelegate>

@property (nonatomic, readwrite, strong) NSDate *dateCreated;
@property (nonatomic, readwrite, assign) ANNativeAdNetworkCode networkCode;
@property (nonatomic, readwrite, assign, getter=hasExpired) BOOL expired;
@property (nonatomic, readwrite, strong) ANBrowserViewController *inAppBrowser;

@property (nonatomic, readwrite, assign) NSUInteger viewabilityValue;
@property (nonatomic, readwrite, assign) NSUInteger targetViewabilityValue;
@property (nonatomic, readwrite, strong) NSTimer *viewabilityTimer;
@property (nonatomic, readwrite, assign) BOOL impressionHasBeenTracked;

@end




@implementation ANNativeStandardAdResponse

@synthesize title = _title;
@synthesize body = _body;
@synthesize callToAction = _callToAction;
@synthesize rating = _rating;
@synthesize mainImage = _mainImage;
@synthesize mainImageURL = _mainImageURL;
@synthesize iconImage = _iconImage;
@synthesize iconImageURL = _iconImageURL;
@synthesize socialContext = _socialContext;
@synthesize customElements = _customElements;
@synthesize networkCode = _networkCode;
@synthesize expired = _expired;
@synthesize sponsoredBy = _sponsoredBy;
@synthesize fullText = _fullText;
@synthesize creativeId = _creativeId;




#pragma mark - Lifecycle.

- (instancetype)init {
    if (self = [super init]) {
        _networkCode = ANNativeAdNetworkCodeAppNexus;
        _dateCreated = [NSDate date];
        _impressionHasBeenTracked = NO;
    }
    return self;
}

- (void)dealloc {
    [self.viewabilityTimer invalidate];
}




#pragma mark - Registration

- (BOOL)registerResponseInstanceWithNativeView:(UIView *)view
                            rootViewController:(UIViewController *)controller
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
    __weak ANNativeStandardAdResponse *weakSelf = self;
    NSInteger requiredAmountOfSimultaneousViewableEvents = lround(  kAppNexusNativeAdIABShouldBeViewableForTrackingDuration
                                                                  / kAppNexusNativeAdCheckViewabilityForTrackingFrequency) + 1;
    self.targetViewabilityValue = lround(pow(2, requiredAmountOfSimultaneousViewableEvents) - 1);
    ANLogDebug(@"\n\trequiredAmountOfSimultaneousViewableEvents=%@  \n\ttargetViewabilityValue=%@", @(requiredAmountOfSimultaneousViewableEvents), @(self.targetViewabilityValue));
    
    self.viewabilityTimer = [NSTimer an_scheduledTimerWithTimeInterval:kAppNexusNativeAdCheckViewabilityForTrackingFrequency
                                                                 block:^ {
                                                                     ANNativeStandardAdResponse *strongSelf = weakSelf;
                                                                     [strongSelf checkViewability];
                                                                 }
                                                               repeats:YES];
}

- (void)checkViewability {
    self.viewabilityValue = (self.viewabilityValue << 1 | [self.viewForTracking an_isAtLeastHalfViewable]) & self.targetViewabilityValue;
    BOOL isIABViewable = (self.viewabilityValue == self.targetViewabilityValue);
    ANLogDebug(@"\n\tviewabilityValue=%@  \n\tself.targetViewabilityValue=%@  \n\tisIABViewable=%@", @(self.viewabilityValue), @(self.targetViewabilityValue), @(isIABViewable));
    
    if (isIABViewable) {
        [self trackImpression];
    }
}

- (void)trackImpression {
    if (!self.impressionHasBeenTracked) {
        ANLogDebug(@"Firing impression trackers");
        [self fireImpTrackers];
        [self.viewabilityTimer invalidate];
        self.impressionHasBeenTracked = YES;
    }
}

- (void)fireImpTrackers {
    if (self.impTrackers) {
        [ANTrackerManager fireTrackerURLArray:self.impTrackers];
    }
}




#pragma mark - Click handling

- (void)handleClick
{
    [self fireClickTrackers];

    //
    if (ANClickThroughActionReturnURL == self.clickThroughAction)
    {
        [self adWasClickedWithURL:[self.clickURL absoluteString] fallbackURL:[self.clickFallbackURL absoluteString]];
        
        ANLogMarkMessage(@"ClickThroughURL=%@", self.clickURL);
        ANLogMarkMessage(@"ClickThroughFallbackURL=%@", self.clickFallbackURL);
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
    if (![[UIApplication sharedApplication] canOpenURL:url])  { return NO; }

    [self willLeaveApplication];
    [ANGlobal openURL:[url absoluteString]];

    return  YES;
}


- (void)fireClickTrackers
{
    [ANTrackerManager fireTrackerURLArray:self.clickTrackers];
}




#pragma mark - ANBrowserViewControllerDelegate

- (UIViewController *)rootViewControllerForDisplayingBrowserViewController:(ANBrowserViewController *)controller {
    return self.rootViewController;
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

- (void)didDismissBrowserViewController:(ANBrowserViewController *)controller {
    self.inAppBrowser = nil;
    [self didCloseAd];
}

- (void)willLeaveApplicationFromBrowserViewController:(ANBrowserViewController *)controller {
    [self willLeaveApplication];
}

@end

