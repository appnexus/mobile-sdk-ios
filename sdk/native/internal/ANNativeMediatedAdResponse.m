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
#import "ANNativeAdResponse+PrivateMethods.h"

@interface ANNativeMediatedAdResponse () <ANNativeCustomAdapterAdDelegate>

@property (nonatomic, readwrite, strong) id<ANNativeCustomAdapter> adapter;
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

- (BOOL)registerResponseInstanceWithNativeView:(UIView *)view
                            rootViewController:(UIViewController *)controller
                                clickableViews:(NSArray *)clickableViews
                                         error:(NSError *__autoreleasing *)error {
    return [self registerAdapterWithNativeView:view
                            rootViewController:controller
                                clickableViews:clickableViews
                                         error:error];
}

- (BOOL)registerAdapterWithNativeView:(UIView *)view
                   rootViewController:(UIViewController *)controller
                       clickableViews:(NSArray *)clickableViews
                                error:(NSError **)error {
    if ([self.adapter respondsToSelector:@selector(nativeAdDelegate)]) {
        self.adapter.nativeAdDelegate = self;
    } else {
        ANLogDebug(@"native_adapter_native_ad_delegate_missing");
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
        ANLogError(@"native_adapter_error");
        if (error) {
            *error = ANError(@"native_adapter_error", ANNativeAdRegisterErrorCodeBadAdapter);
        }
        return NO;
    }
}

#pragma mark - Unregistration

- (void)unregisterViewFromTracking {
    [super unregisterViewFromTracking];
    if ([self.adapter respondsToSelector:@selector(unregisterViewFromTracking)]) {
        [self.adapter unregisterViewFromTracking];
    }
}

#pragma mark - Click handling

- (void)handleClick {
    if ([self.adapter respondsToSelector:@selector(handleClickFromRootViewController:)]) {
        [self.adapter handleClickFromRootViewController:self.rootViewController];
    }
}

@end