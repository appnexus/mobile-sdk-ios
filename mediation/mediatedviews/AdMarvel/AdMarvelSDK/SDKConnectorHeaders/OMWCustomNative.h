//
//  OMWCustomNative.h
//

#import <Foundation/Foundation.h>
#import "OMWCustomNativeDelegate.h"

@protocol OMWCustomNative <NSObject>


// This method will be invoked when there is a request for a native ad.
// Results of this method should be reported back via the @nativeAdDelegate.
// @serverParameter - the parameters configured in the map UI for the adapter.

- (void)requestNativeAdWithServerParams:(NSDictionary *)serverParams andTargetingParams:(NSDictionary *)targetParams;

// You should report the result of execution by using this delegate.
// do @synthesize of this property in your class.
// In your class's -dealloc method, remember to set this property to nil.

@property (nonatomic, weak) id <OMWCustomNativeDelegate> nativeAdDelegate;

@optional

// Report yes if particular ad type is not supported through adapter implementation
+ (BOOL)isAdNetworkDisabled;

// This method will be invoked after view is registered for automatic click and impression handling.
// Call registeration method of ad network(if any) in implementation of it.

-(void) registerContainerView:(UIView *)view;

// This method will be invoked when certain views will be registered as clickable.

-(void) registerViews:(NSArray *)clickableViews forClickEvent:(NSString *)event __deprecated_msg("Please use registerContainerView: or registerContainerView:withClickableViews:forClickEvent:");

// This method will be invoked for registering both native ad container view and clickable views.
// NOTE: One of the either "registerContainerView:" or "registerContainerView:withClickableViews:forClickEvent:" method will be invoked.
- (void)registerContainerView:(UIView *)view withClickableViews:(NSArray *)clickableViews forClickEvent:(NSString *)event;

// This method will be invoked when a view which is registered for interaction using registerContainerView: or registerViews: is being disconnected.
// Call unregister method of ad netowrk(if any) in implementation of it.

-(void) unregisterView;

// This method will be invoked when any registered view is clicked.
// Use this method to perform any click action.

-(void) handleClick;

// Ths method will be invoked after a registered view becomes visible.
// Use this method to handle impression.

-(void) handleImpression;

@end
