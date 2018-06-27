//
// Created by Daria Sukhonosova on 19/04/16.
//

#import <UIKit/UIKit.h>
#import "OMIDPartner.h"
#import "OMIDVerificationScriptResource.h"

/*!
 * @discussion This class will provide the ad session both details of the partner and whether this is considered HTML or native.
 */
@interface OMIDAppnexusAdSessionContext : NSObject

- (null_unspecified instancetype)init NS_UNAVAILABLE;

/*!
 * @abstract Initializes a new ad session context providing reference to partner and web view where OMID JS has been injected.
 *
 * @discussion Calling this method will set the ad session type to “html”.
 * <p>
 * NOTE: any attempt to create a new ad session will fail if OMID has not been activated (see {@link OMIDSDK} class for more information).
 *
 * @param partner Details of the integration partner responsible for the ad session.
 * @param webView The webView responsible for serving the ad content. Must be a UIWebView or WKWebView instance. The receiver holds a weak reference only.
 * @return A new HTML context instance. Returns nil if OMID has not been activated or if any of the parameters are nil.
 * @see OMIDSDK
 */
- (nullable instancetype)initWithPartner:(nonnull OMIDAppnexusPartner *)partner
                                 webView:(nonnull UIView *)webView
               customReferenceIdentifier:(nullable NSString *)customReferenceIdentifier
                                   error:(NSError *_Nullable *_Nullable)error;

/*!
 * @abstract Initializes a new ad session context providing reference to partner and a list of script resources which should be managed by OMID.
 *
 * @discussion Calling this method will set the ad session type to “native”.
 * <p>
 * NOTE: any attempt to create a new ad session will fail if OMID has not been activated (see {@link OMIDSDK} class for more information).
 *
 * @param partner Details of the integration partner responsible for the ad session.
 * @param resources The array of all verification providers who expect to receive OMID event data. Must contain at least one verification script. The receiver creates a deep copy of the array.
 * @return A new native context instance. Returns nil if OMID has not been activated or if any of the parameters are invalid.
 * @see OMIDSDK
 */
- (nullable instancetype)initWithPartner:(nonnull OMIDAppnexusPartner *)partner
                                  script:(nonnull NSString *)script
                               resources:(nonnull NSArray<OMIDAppnexusVerificationScriptResource *> *)resources
               customReferenceIdentifier:(nullable NSString *)customReferenceIdentifier
                                   error:(NSError *_Nullable *_Nullable)error;

@end
