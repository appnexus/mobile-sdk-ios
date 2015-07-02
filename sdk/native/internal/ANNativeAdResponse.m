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

#import "ANNativeAdResponse.h"
#import "ANLogging.h"
#import "UIView+ANNativeAdCategory.h"
#import "ANGlobal.h"

#pragma mark - ANNativeAdResponseGestureRecognizerRecord

@interface ANNativeAdResponseGestureRecognizerRecord : NSObject

@property (nonatomic, weak) UIView *viewWithTracking;
@property (nonatomic, weak) UIGestureRecognizer *gestureRecognizer;

@end

@implementation ANNativeAdResponseGestureRecognizerRecord

@end

#pragma mark - ANNativeAdResponse

@interface ANNativeAdResponse ()

@property (nonatomic, readwrite, strong) UIView *viewForTracking;
@property (nonatomic, readwrite, strong) NSMutableArray *gestureRecognizerRecords;
@property (nonatomic, readwrite, weak) UIViewController *rootViewController;
@property (nonatomic, readwrite, assign, getter=hasExpired) BOOL expired;
@property (nonatomic, readwrite, assign) ANNativeAdNetworkCode networkCode;

@end

@implementation ANNativeAdResponse

#pragma mark - Registration

- (BOOL)registerViewForTracking:(UIView *)view
         withRootViewController:(UIViewController *)controller
                 clickableViews:(NSArray *)clickableViews
                          error:(NSError **)error {
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
    if (self.hasExpired) {
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
        self.expired = YES;
        return YES;
    }
    
    return NO;
}

- (BOOL)registerResponseInstanceWithNativeView:(UIView *)view
                            rootViewController:(UIViewController *)controller
                                clickableViews:(NSArray *)clickableViews
                                         error:(NSError *__autoreleasing*)error {
    // Abstract method, to be implemented by subclass
    return NO;
}

#pragma mark - Unregistration

- (void)unregisterViewFromTracking {
    [self detachAllGestureRecognizers];
    [self.viewForTracking setAnNativeAdResponse:nil];
    self.viewForTracking = nil;
}

#pragma mark - Click handling

- (void)attachGestureRecognizersToNativeView:(UIView *)nativeView
                          withClickableViews:(NSArray *)clickableViews {
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

- (void)attachGestureRecognizerToView:(UIView *)view {
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
        UIView *view = record.viewWithTracking;
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

# pragma mark - ANNativeAdDelegate

- (void)adWasClicked {
    if ([self.delegate respondsToSelector:@selector(adWasClicked:)]) {
        [self.delegate adWasClicked:self];
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

@end