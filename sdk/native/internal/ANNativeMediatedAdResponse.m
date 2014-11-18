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

#import "ANNativeMediatedAdResponse.h"
#import "ANNativeCustomAdapter.h"
#import "ANLogging.h"
#import "ANGlobal.h"
#import "UIView+ANNativeAdCategory.h"

@interface ANNativeAdResponse (ANNativeMediatedAdResponse)

@property (nonatomic, readwrite, strong) UIView *viewForTracking;

- (void)unregisterViewFromTracking;

@end

@interface ANNativeMediatedAdResponse () <ANNativeCustomAdapterAdDelegate>

@property (nonatomic, readwrite, strong) id<ANNativeCustomAdapter> adapter;
@property (nonatomic, readwrite, weak) UIViewController *rootViewController;
@property (nonatomic, readwrite, strong) NSMutableDictionary *viewToGestureRecognizerMapping;
@property (nonatomic, readwrite, assign, getter=hasExpired) BOOL expired;
@property (nonatomic, readwrite, assign) ANNativeAdNetworkCode networkCode;

@end

@implementation ANNativeMediatedAdResponse

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
@synthesize expired = _expired;
@synthesize networkCode = _networkCode;

- (BOOL)hasExpired {
    if (_expired == YES) {
        return YES;
    }
    if (!self.adapter || [self.adapter hasExpired]) {
        _expired = YES;
    }
    return _expired;
}

- (instancetype)initWithCustomAdapter:(id<ANNativeCustomAdapter>)adapter
                          networkCode:(ANNativeAdNetworkCode)networkCode {
    if (!adapter) {
        return nil;
    }
    if (self = [super init]) {
        _adapter = adapter;
        _networkCode = networkCode;
        _adapter.nativeAdDelegate = self;
    }
    return self;
}

#pragma mark - Registration

- (BOOL)registerViewForTracking:(UIView *)view
         withRootViewController:(UIViewController *)controller
                 clickableViews:(NSArray *)clickableViews
                          error:(NSError **)error {
    if (!view) {
        ANLogError(ANErrorString(@"native_invalid_view"));
        if (error) {
            *error = ANError(@"native_invalid_view", ANNativeAdRegisterErrorCodeInvalidView);
        }
        return NO;
    }
    if (!controller) {
        ANLogError(ANErrorString(@"native_invalid_rvc"));
        if (error) {
            *error = ANError(@"native_invalid_rvc", ANNativeAdRegisterErrorCodeInvalidRootViewController);
        }
        return NO;
    }
    if (self.hasExpired) {
        ANLogError(ANErrorString(@"native_expired_response"));
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
    
    BOOL successfulAdapterRegistration = [self registerAdapterWithNativeView:view
                                                          rootViewController:controller
                                                              clickableViews:clickableViews
                                                                       error:error];
    if (successfulAdapterRegistration) {
        self.viewForTracking = view;
        [view setAnNativeAdResponse:self];
        self.rootViewController = controller;
        self.expired = YES;
        return YES;
    }
    
    return NO;
}

- (BOOL)registerAdapterWithNativeView:(UIView *)view
                   rootViewController:(UIViewController *)controller
                       clickableViews:(NSArray *)clickableViews
                                error:(NSError **)error {
    if ([self.adapter respondsToSelector:@selector(nativeAdDelegate)]) {
        self.adapter.nativeAdDelegate = self;
    } else {
        ANLogDebug(ANErrorString(@"native_adapter_native_ad_delegate_missing"));
    }
    if ([self.adapter respondsToSelector:@selector(registerViewForImpressionTrackingAndClickHandling:withRootViewController:clickableViews:)]) {
        [self.adapter registerViewForImpressionTrackingAndClickHandling:view
                                                 withRootViewController:controller
                                                         clickableViews:clickableViews];
        return YES;
    } else if ([self.adapter respondsToSelector:@selector(registerViewForImpressionTracking:)] && [self.adapter respondsToSelector:@selector(handleClickFromRootViewController:)]) {
        [self.adapter registerViewForImpressionTracking:view];
        [self attachGestureRecognizersToNativeView:view
                                withClickableViews:clickableViews];
        return YES;
    } else {
        ANLogError(ANErrorString(@"native_adapter_error"));
        if (error) {
            *error = ANError(@"native_adapter_error", ANNativeAdRegisterErrorCodeBadAdapter);
        }
        return NO;
    }
}

#pragma mark - Unregistration

- (void)unregisterViewFromTracking {
    if ([self.adapter respondsToSelector:@selector(unregisterViewFromTracking)]) {
        [self.adapter unregisterViewFromTracking];
    }
    [self detachAllGestureRecognizers];
    [self.viewForTracking setAnNativeAdResponse:nil];
    self.viewForTracking = nil;
}

- (void)dealloc {
    ANLogDebug(@"Deallocating %@", NSStringFromClass([self class]));
    [self unregisterViewFromTracking];
}

#pragma mark - Click handling

- (void)attachGestureRecognizersToNativeView:(UIView *)nativeView
                          withClickableViews:(NSArray *)clickableViews {
    // We don't know that clickableViews contains only views, we would have to validate this.
    if (clickableViews.count) {
        [clickableViews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
            [self attachGestureRecognizerToView:view];
        }];
    } else {
        [self attachGestureRecognizerToView:nativeView];
    }
}

- (void)attachGestureRecognizerToView:(UIView *)view {
    view.userInteractionEnabled = YES;
    NSValue *key = [NSValue valueWithNonretainedObject:view];
    NSValue *value;
    
    if ([view isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)view;
        [button addTarget:self
                   action:@selector(handleClick)
         forControlEvents:UIControlEventTouchUpInside];
        value = [NSValue valueWithNonretainedObject:[NSNull null]];
    } else {
        UITapGestureRecognizer *clickRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                          action:@selector(handleClick)];
        [view addGestureRecognizer:clickRecognizer];
        value = [NSValue valueWithNonretainedObject:clickRecognizer];
    }
    self.viewToGestureRecognizerMapping[key] = value;
}

- (void)detachAllGestureRecognizers {
    [self.viewToGestureRecognizerMapping enumerateKeysAndObjectsUsingBlock:^(NSValue *viewValue, NSValue *gestureRecognizerValue, BOOL *stop) {
        UIView *view = (UIView *)[viewValue nonretainedObjectValue];
        if (view) {
            if ([view isKindOfClass:[UIButton class]]) {
                [(UIButton *)view removeTarget:self
                                        action:@selector(handleClick)
                              forControlEvents:UIControlEventTouchUpInside];
            } else {
                UIGestureRecognizer *recognizer = (UIGestureRecognizer *)[gestureRecognizerValue nonretainedObjectValue];
                if (recognizer) {
                    [view removeGestureRecognizer:recognizer];
                }
            }
        }
    }];
    [self.viewToGestureRecognizerMapping removeAllObjects];
}

- (void)handleClick {
    if ([self.adapter respondsToSelector:@selector(handleClickFromRootViewController:)]) {
        [self.adapter handleClickFromRootViewController:self.rootViewController];
    }
}

- (NSMutableDictionary *)viewToGestureRecognizerMapping {
    if (!_viewToGestureRecognizerMapping) _viewToGestureRecognizerMapping = [[NSMutableDictionary alloc] init];
    return _viewToGestureRecognizerMapping;
}

#pragma mark - ANNativeCustomAdapterAdDelegate

- (void)adWasClicked {
    [self.delegate adWasClicked:self];
}

- (void)willPresentAd {
    [self.delegate adWillPresent:self];
}

- (void)didPresentAd {
    [self.delegate adDidPresent:self];
}

- (void)willCloseAd {
    [self.delegate adWillClose:self];
}

- (void)didCloseAd {
    [self.delegate adDidClose:self];
}

- (void)willLeaveApplication {
    [self.delegate adWillLeaveApplication:self];
}

@end