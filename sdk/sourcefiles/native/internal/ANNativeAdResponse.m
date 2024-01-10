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


#import <Foundation/Foundation.h>

#import "ANNativeAdResponse.h"
#import "ANLogging.h"
#import "ANGlobal.h"
#import "ANAdProtocol.h"
#import "ANAdConstants.h"

#if !APPNEXUS_NATIVE_MACOS_SDK
#import "UIView+ANNativeAdCategory.h"
#import "ANOMIDImplementation.h"
#import "ANVerificationScriptResource.h"
#else
#import "NSView+ANCategory.h"
#import "XandrNativeAdView.h"
#endif

#import "XandrView.h"
#import "XandrViewController.h"
#import "ANSDKSettings.h"

NSString * const  kANNativeElementObject                               = @"ELEMENT";
NSString * const  kANNativeCSRObject                                   = @"CSRAdObject";
NSInteger  const  kANNativeFacebookAdExpireTime                    = 3600;
NSInteger  const  kANNativeRTBAdExpireTime                         = 21600;
NSInteger  const  kANNativeRTBAdExpireTimeForMember_11217          = 300;
NSInteger  const  kANNativeRTBAdExpireTimeForMember_12085          = 600;
NSInteger  const  kANNativeRTBAdExpireTimeForMember_12317          = 3300; //InMobi
NSInteger  const  kANNativeRTBAdExpireTimeForMember_9642           = 300; //Index (ix)


#pragma mark - ANNativeAdResponseGestureRecognizerRecord

@interface ANNativeAdResponseGestureRecognizerRecord : NSObject

#if !APPNEXUS_NATIVE_MACOS_SDK
@property (nonatomic, weak) XandrView *viewWithTracking;
@property (nonatomic, weak) UIGestureRecognizer *gestureRecognizer;
#else
@property (nonatomic, weak) XandrNativeAdView *viewWithTracking;
@property (nonatomic, weak) NSClickGestureRecognizer *gestureRecognizer;
#endif
@end


@implementation ANNativeAdResponseGestureRecognizerRecord

@end




#pragma mark - ANNativeAdResponse

@interface ANNativeAdResponse()

#if !APPNEXUS_NATIVE_MACOS_SDK
@property (nonatomic, readwrite, weak) UIView *viewForTracking;
@property (nonatomic, readwrite, weak) UIViewController *rootViewController;
@property (nonatomic, readwrite, strong) OMIDMicrosoftAdSession *omidAdSession;
@property (nonatomic, readwrite, strong, nullable) NSMutableArray<UIView *> *obstructionViews;
@property (nonatomic, readwrite, strong) ANVerificationScriptResource *verificationScriptResource;
#else
@property (nonatomic, readwrite, weak) NSView *viewForTracking;
@property (nonatomic, readwrite, weak) NSViewController *rootViewController;
#endif
@property (nonatomic, readwrite, strong) NSMutableArray *gestureRecognizerRecords;
@property (nonatomic, readwrite, assign, getter=hasExpired) BOOL expired;
@property (nonatomic, readwrite, assign) ANNativeAdNetworkCode networkCode;
@property (nonatomic, readwrite, strong)  ANAdResponseInfo *adResponseInfo;
@property (nonatomic, readwrite, strong) NSTimer *adWillExpireTimer;
@property (nonatomic, readwrite, strong) NSTimer *adDidExpireTimer;
@property (nonatomic, readwrite, assign) NSInteger aboutToExpireInterval;

@end




@implementation ANNativeAdResponse

@synthesize  clickThroughAction             = _clickThroughAction;
@synthesize  landingPageLoadsInBackground   = _landingPageLoadsInBackground;
@synthesize aboutToExpireInterval               = _aboutToExpireInterval;

#pragma mark - Lifecycle.

- (instancetype) init
{
    self = [super init];
    if (!self)  { return nil; }
    
#if !APPNEXUS_NATIVE_MACOS_SDK
    self.clickThroughAction = ANClickThroughActionOpenSDKBrowser;
#else
    self.clickThroughAction = ANClickThroughActionReturnURL;
#endif
    _aboutToExpireInterval = kAppNexusNativeAdAboutToExpireInterval;
    return  self;
}

#pragma mark - Getters/setters.

- (void)setClickThroughAction:(ANClickThroughAction)clickThroughAction
{
    _clickThroughAction = clickThroughAction;
}

#pragma mark - Registration

- (BOOL)registerViewForTracking:(nonnull XandrView *)view
         withRootViewController:(nonnull XandrViewController *)controller
                 clickableViews:(nullable NSArray *)clickableViews
                          error:(NSError *__nullable*__nullable)error {
    if (!view) {
        ANLogError(@"native_invalid_view");
        if (error) {
            *error = ANError(@"native_invalid_view", ANNativeAdRegisterErrorCodeInvalidView);
        }
        return NO;
    }
    if (!controller) {
        ANLogError(@"native_invalid_rvc");
        if (error) {
            *error = ANError(@"native_invalid_rvc", ANNativeAdRegisterErrorCodeInvalidRootViewController);
        }
        return NO;
    }
    if (self.expired) {
        ANLogError(@"native_expired_response");
        if (error) {
            *error = ANError(@"native_expired_response", ANNativeAdRegisterErrorCodeExpiredResponse);
        }
        return NO;
    }
    
    ANNativeAdResponse *response = [view anNativeAdResponse];
    if (response) {
        ANLogDebug(@"Unregistering view from another response");
        [response unregisterViewFromTracking];
    }
    
    BOOL successfulResponseRegistration = [self registerResponseInstanceWithNativeView:view
                                                                    rootViewController:controller
                                                                        clickableViews:clickableViews
                                                                                 error:error];
    
    if (successfulResponseRegistration) {
        self.viewForTracking = view;
        [view setAnNativeAdResponse:self];
        self.rootViewController = controller;
// OMID is not supported by macOS
#if !APPNEXUS_NATIVE_MACOS_SDK
        [self registerOMID];
#endif
        return YES;
    }
    
    return NO;
}

- (BOOL)registerResponseInstanceWithNativeView:(XandrView *)view
                            rootViewController:(XandrViewController *)controller
                                clickableViews:(NSArray *)clickableViews
                                         error:(NSError *__autoreleasing*)error {
    // Abstract method, to be implemented by subclass
    return NO;
}

#if APPNEXUS_NATIVE_MACOS_SDK

- (BOOL)registerViewForTracking:(nonnull NSTableRowView *)view
         withRootViewController:(nonnull NSViewController *)rvc
            clickableXandrNativeAdView:(nullable NSArray<XandrNativeAdView *> *)views
                          error:(NSError *__nullable*__nullable)error{
    
    BOOL successfulResponseRegistration = [self registerViewForTracking:(XandrView *)view withRootViewController:(XandrViewController *)rvc clickableViews:nil error:error];
    
    for(XandrNativeAdView *clickableView in views){
        [self attachClickGestureRecognizerToView:clickableView];
    }
    
    if(!successfulResponseRegistration){
        ANLogError(@"Unable to register view for tracking");
        return false;
    }
    return true;
}

- (BOOL)registerViewTracking:(nonnull NSView *)view
         withRootViewController:(nonnull NSViewController *)rvc
                 clickableXandrNativeAdView:(nullable NSArray<XandrNativeAdView *> *)views
                       error:(NSError *__nullable*__nullable)error{

    BOOL successfulResponseRegistration = [self registerViewForTracking:(XandrView *)view withRootViewController:(XandrViewController *)rvc clickableViews:nil error:error];
    
    for(XandrNativeAdView *clickableView in views){
        [self attachClickGestureRecognizerToView:clickableView];
    }
    
    if(!successfulResponseRegistration){
        ANLogError(@"Unable to register view for tracking");
        return false;
    }
    return true;
}

#endif



#pragma mark - Click handling
#if !APPNEXUS_NATIVE_MACOS_SDK
- (void)attachGestureRecognizersToNativeView:(XandrView *)nativeView
                          withClickableViews:(NSArray *)clickableViews
{
    
    
    if (clickableViews.count) {
        [clickableViews enumerateObjectsUsingBlock:^(id clickableView, NSUInteger idx, BOOL *stop) {
           
            if ([clickableView isKindOfClass:[UIView class]]) {
                [self attachGestureRecognizerToView:clickableView];
            } else {
                ANLogWarn(@"native_invalid_clickable_views");
            }
            
        
        }];
    } else {
        [self attachGestureRecognizerToView:nativeView];
    }
}

- (void)attachGestureRecognizerToView:(XandrView *)view
{
    
    view.userInteractionEnabled = YES;
    ANNativeAdResponseGestureRecognizerRecord *record = [[ANNativeAdResponseGestureRecognizerRecord alloc] init];
    record.viewWithTracking = view;
    if ([view isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)view;
        [button addTarget:self
                   action:@selector(handleClick)
         forControlEvents:UIControlEventTouchUpInside];
    } else {
        UITapGestureRecognizer *clickRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                          action:@selector(handleClick)];
        [view addGestureRecognizer:clickRecognizer];
        record.gestureRecognizer = clickRecognizer;
    }
    [self.gestureRecognizerRecords addObject:record];
    
}
    
- (void)detachAllGestureRecognizers {
    [self.gestureRecognizerRecords enumerateObjectsUsingBlock:^(ANNativeAdResponseGestureRecognizerRecord *record, NSUInteger idx, BOOL *stop) {
            
            XandrView *view = record.viewWithTracking;
            if (view) {
                if ([view isKindOfClass:[UIButton class]]) {
                    [(UIButton *)view removeTarget:self
                                                    action:@selector(handleClick)
                                    forControlEvents:UIControlEventTouchUpInside];
                } else if (record.gestureRecognizer) {
                    [view removeGestureRecognizer:record.gestureRecognizer];
                }
            }
    }];
        
    [self.gestureRecognizerRecords removeAllObjects];
}
   
#else
    
-(void)attachClickGestureRecognizerToView:(XandrNativeAdView *)registerView {
    ANNativeAdResponseGestureRecognizerRecord *record = [[ANNativeAdResponseGestureRecognizerRecord alloc] init];
    record.viewWithTracking = registerView;

    [registerView attachClickableView];
    NSClickGestureRecognizer *clickRecognizer = [[NSClickGestureRecognizer alloc] initWithTarget:self action:@selector(handleClick)];
    [registerView addGestureRecognizer:clickRecognizer];
    record.gestureRecognizer = clickRecognizer;
    [self.gestureRecognizerRecords addObject:record];

}
    
- (void)detachAllGestureRecognizers {
    [self.gestureRecognizerRecords enumerateObjectsUsingBlock:^(ANNativeAdResponseGestureRecognizerRecord *record, NSUInteger idx, BOOL *stop) {
    
            XandrNativeAdView *view = record.viewWithTracking;
            if (view) {
                 if (record.gestureRecognizer) {
                    [view removeGestureRecognizer:record.gestureRecognizer];
                }
                [view detachClickableView];
            }
       
    }];
        
    [self.gestureRecognizerRecords removeAllObjects];
}

#endif



#if !APPNEXUS_NATIVE_MACOS_SDK

- (BOOL)registerViewForTracking:(nonnull UIView *)view
         withRootViewController:(nonnull UIViewController *)rvc
                 clickableViews:(nullable NSArray<UIView *> *)views
openMeasurementFriendlyObstructions:(nonnull NSArray<UIView *> *)obstructionViews
                          error:(NSError *__nullable*__nullable)error{
    self.obstructionViews = [[NSMutableArray alloc] init];
    BOOL invalidObstructionViews = NO;
    for(UIView *obstructionView in obstructionViews){
        if(obstructionView != nil){
            [self.obstructionViews addObject:obstructionView];
        }else{
            invalidObstructionViews = YES;
        }
    }
    if(invalidObstructionViews){
        ANLogError(@"Some of the views are Invalid Friendly Obstruction View. Friendly obstruction view can not be nil.");
    }
    return [self registerViewForTracking:view withRootViewController:rvc clickableViews:views error:error];
}

- (void)registerOMID{
    NSMutableArray *scripts = [NSMutableArray new];
    NSURL *url = [NSURL URLWithString:self.verificationScriptResource.url];
    NSString *vendorKey = self.verificationScriptResource.vendorKey;
    NSString *params = self.verificationScriptResource.params;
    [scripts addObject:[[OMIDMicrosoftVerificationScriptResource alloc] initWithURL:url vendorKey:vendorKey  parameters:params]];
    self.omidAdSession = [[ANOMIDImplementation sharedInstance] createOMIDAdSessionforNative:self.viewForTracking withScript:scripts];
    for (UIView *obstruction in self.obstructionViews){
        [[ANOMIDImplementation sharedInstance] addFriendlyObstruction:obstruction toOMIDAdSession:self.omidAdSession];
    }
}

#endif

- (NSMutableArray *)gestureRecognizerRecords {
    if (!_gestureRecognizerRecords) _gestureRecognizerRecords = [[NSMutableArray alloc] init];
    return _gestureRecognizerRecords;
}


- (void)handleClick {
    // Abstract method, to be implemented by subclass
}

- (void)dealloc {
    [self unregisterViewFromTracking];
}

- (void)unregisterViewFromTracking {
    [self detachAllGestureRecognizers];
    [self.viewForTracking setAnNativeAdResponse:nil];
    self.viewForTracking = nil;
    
// OMID is not supported by macOS
#if !APPNEXUS_NATIVE_MACOS_SDK
    if(self.omidAdSession != nil){
        [[ANOMIDImplementation sharedInstance] stopOMIDAdSession:self.omidAdSession];
    }
#endif
    
}



# pragma mark - ANNativeAdDelegate

- (void)adWasClicked {
    if ([self.delegate respondsToSelector:@selector(adWasClicked:)]) {
        [self.delegate adWasClicked:self];
    }
}

- (void)adWasClickedWithURL:(NSString *)clickURLString fallbackURL:(NSString *)clickFallbackURLString
{
    if ([self.delegate respondsToSelector:@selector(adWasClicked:withURL:fallbackURL:)]) {
        [self.delegate adWasClicked: self
                            withURL: clickURLString
                        fallbackURL: clickFallbackURLString];
    }
}

- (void)willPresentAd {
    if ([self.delegate respondsToSelector:@selector(adWillPresent:)]) {
        [self.delegate adWillPresent:self];
    }
}

- (void)didPresentAd {
    if ([self.delegate respondsToSelector:@selector(adDidPresent:)]) {
        [self.delegate adDidPresent:self];
    }
}

- (void)willCloseAd {
    if ([self.delegate respondsToSelector:@selector(adWillClose:)]) {
        [self.delegate adWillClose:self];
    }
}

- (void)didCloseAd {
    if ([self.delegate respondsToSelector:@selector(adDidClose:)]) {
        [self.delegate adDidClose:self];
    }
}

- (void)willLeaveApplication {
    if ([self.delegate respondsToSelector:@selector(adWillLeaveApplication:)]) {
        [self.delegate adWillLeaveApplication:self];
    }
}

- (void)adDidLogImpression {
    if ([self.delegate respondsToSelector:@selector(adDidLogImpression:)]) {
        [self.delegate adDidLogImpression:self];
    }
    [self invalidateAdExpireTimer:self.adWillExpireTimer];
    [self invalidateAdExpireTimer:self.adDidExpireTimer];
}

-(void)registerAdAboutToExpire{
    [self setAboutToExpireTimeInterval];
    [self invalidateAdExpireTimer:self.adWillExpireTimer];
    NSTimeInterval timeInterval;
    if(self.networkCode == ANNativeAdNetworkCodeFacebook){
        timeInterval =  kANNativeFacebookAdExpireTime;
    }else if ([self.adResponseInfo.contentSource isEqualToString:@"rtb"] && self.adResponseInfo.memberId == 11217 ){
        timeInterval = kANNativeRTBAdExpireTimeForMember_11217;
    }else if ([self.adResponseInfo.contentSource isEqualToString:@"rtb"] && self.adResponseInfo.memberId == 12085 ){
        timeInterval = kANNativeRTBAdExpireTimeForMember_12085;
    }else if ([self.adResponseInfo.contentSource isEqualToString:@"rtb"] && self.adResponseInfo.memberId == 12317 ){
        timeInterval = kANNativeRTBAdExpireTimeForMember_12317;
    }else if ([self.adResponseInfo.contentSource isEqualToString:@"rtb"] && self.adResponseInfo.memberId == 9642 ){
        timeInterval = kANNativeRTBAdExpireTimeForMember_9642;
    }else{
        timeInterval =  kANNativeRTBAdExpireTime;
    }
    
    typeof(self) __weak weakAdWillExpireTimerSelf = self;
    self.adWillExpireTimer = [NSTimer scheduledTimerWithTimeInterval:(timeInterval - _aboutToExpireInterval) repeats:NO block:^(NSTimer * _Nonnull timer) {
        [weakAdWillExpireTimerSelf onAdAboutToExpire];
    }];
    
    typeof(self) __weak weakAdDidExpireTimerSelf = self;
    self.adDidExpireTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval repeats:NO block:^(NSTimer * _Nonnull timer) {
        [weakAdDidExpireTimerSelf onAdExpired];
    }];
}

- (void)onAdAboutToExpire {
    if ([self.delegate respondsToSelector:@selector(adWillExpire:)] && self.adWillExpireTimer.valid) {
        [self.delegate adWillExpire:self];
    }
    [self invalidateAdExpireTimer:self.adWillExpireTimer];
}

- (void)onAdExpired {
    self.expired = YES;
    if ([self.delegate respondsToSelector:@selector(adDidExpire:)] && self.adDidExpireTimer.valid) {
        [self.delegate adDidExpire:self];
    }
    [self invalidateAdExpireTimer:self.adDidExpireTimer];
}


-(void)invalidateAdExpireTimer:(NSTimer *)timer{
    if(timer.valid){
        [timer invalidate];
    }
}


- (void)setAboutToExpireTimeInterval
{
    NSInteger aboutToExpireTimeInterval = [ANSDKSettings sharedInstance].nativeAdAboutToExpireInterval;
    
    if (aboutToExpireTimeInterval <= 0)
    {
        ANLogError(@"nativeAdAboutToExpireInterval can not be set less than or equal to zero");
        return;
    }else if(self.networkCode == ANNativeAdNetworkCodeFacebook && aboutToExpireTimeInterval >= kANNativeFacebookAdExpireTime){
        ANLogError(@"nativeAdAboutToExpireInterval can not be set greater than or equal to 60 minutes for FacebookAds");
        return;
    }else if ([self.adResponseInfo.contentSource isEqualToString:@"rtb"] && self.adResponseInfo.memberId == 11217 && aboutToExpireTimeInterval >= kANNativeRTBAdExpireTimeForMember_11217 ){
        ANLogError(@"nativeAdAboutToExpireInterval can not be set greater than or equal to 5 minutes for RTB & member 11217");
        return;
    }else if ([self.adResponseInfo.contentSource isEqualToString:@"rtb"] && self.adResponseInfo.memberId == 12085 && aboutToExpireTimeInterval >= kANNativeRTBAdExpireTimeForMember_12085 ){
        ANLogError(@"nativeAdAboutToExpireInterval can not be set greater than or equal to 10 minutes for RTB & member 12085");
        return;
    }  else if ([self.adResponseInfo.contentSource isEqualToString:@"rtb"] && self.adResponseInfo.memberId == 12317 && aboutToExpireTimeInterval >= kANNativeRTBAdExpireTimeForMember_12317 ){
        ANLogError(@"nativeAdAboutToExpireInterval can not be set greater than or equal to 55 minutes for RTB & member 12317");
        return;
    } else if ([self.adResponseInfo.contentSource isEqualToString:@"rtb"] && self.adResponseInfo.memberId == 9642 && aboutToExpireTimeInterval >= kANNativeRTBAdExpireTimeForMember_9642 ){
        ANLogError(@"nativeAdAboutToExpireInterval can not be set greater than or equal to 5 minutes for RTB & member 9642");
        return;
    }else if(aboutToExpireTimeInterval >= kANNativeRTBAdExpireTime){
        ANLogError(@"nativeAdAboutToExpireInterval can not be set greater than or equal to 6 hours");
        return;
    }
    
    ANLogDebug(@"Setting nativeAdAboutToExpireInterval to %ld", (long)aboutToExpireTimeInterval);
    _aboutToExpireInterval = aboutToExpireTimeInterval;
}

@end
