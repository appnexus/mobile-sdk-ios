//
//  SCSPostClickManagerDelegate.h
//  SCSCoreKit
//
//  Created by Thomas Geley on 06/09/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class SCSPostClickManager;

/// Enum that defines all the possible destination type when opening a modal.
typedef NS_ENUM(NSInteger, SCSPostClickModalType) {
    /// The click opened SFSafariViewController
    SCSPostClickModalTypeSFSafariViewController     = 0,
    
    /// The click opened SKStoreViewController
    SCSPostClickModalTypeSKStoreViewController      = 1,
    
    /// The click opened Another modal
    SCSPostClickModalTypeOther                      = 2,
};

@protocol SCSPostClickManagerDelegate <NSObject>
@required
- (nullable UIViewController *)postClickManagerRequestsPresentationController:(SCSPostClickManager *)postClickManager;
- (void)postClickManagerDidCountClick:(SCSPostClickManager *)postClickManager;
- (void)postClickManagerWillExitApplication:(SCSPostClickManager *)postClickManager;
- (void)postClickManager:(SCSPostClickManager *)postClickManager willOpenModalControllerWithType:(SCSPostClickModalType)type;
- (void)postClickManager:(SCSPostClickManager *)postClickManager didOpenModalControllerWithType:(SCSPostClickModalType)type;
- (void)postClickManager:(SCSPostClickManager *)postClickManager willCloseModalControllerWithType:(SCSPostClickModalType)type;
- (void)postClickManager:(SCSPostClickManager *)postClickManager didCloseModalControllerWithType:(SCSPostClickModalType)type;
- (void)postClickManager:(SCSPostClickManager *)postClickManager didFailToOpenURL:(NSURL *)url error:(nullable NSError *)error;

@optional
// Methods for unit testing purpose only
// It is interesting to know about the type of post click modal we are trying to open because with unit test the modal will not actually open.
// Plus storekit is not available on simulator, so the whole logic cannot be tested.
- (void)postClickManager:(SCSPostClickManager *)postClickManager willTryToOpenModalWithType:(SCSPostClickModalType)type;

@end

NS_ASSUME_NONNULL_END
