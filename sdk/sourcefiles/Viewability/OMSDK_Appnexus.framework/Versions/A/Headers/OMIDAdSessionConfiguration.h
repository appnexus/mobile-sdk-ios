//
//  OMIDAdSessionConfiguration.h
//  AppVerificationLibrary
//
//  Created by Saraev Vyacheslav on 15/09/2017.
//

#import <UIKit/UIKit.h>

/**
 * Identifies which integration layer is responsible for sending certain events.
 */
typedef NS_ENUM(NSUInteger, OMIDOwner) {
    /** The integration will send the event from a JavaScript session script. */
    OMIDJavaScriptOwner = 1,
    /** The integration will send the event from the native layer. */
    OMIDNativeOwner = 2,
    /** The integration will not send the event. */
    OMIDNoneOwner = 3
};

/**
 * The ad session configuration supplies the owner for both the impression and video events.
 * The OMID JS service will use this information to help identify where the source of these
 * events is expected to be received.
 */
@interface OMIDAppnexusAdSessionConfiguration : NSObject

@property OMIDOwner impressionOwner;
@property OMIDOwner videoEventsOwner;
@property BOOL isolateVerificationScripts;

/**
 * Returns nil and sets error if OMID isn't active or arguments are invalid.
 * @param impressionOwner providing details of who is responsible for triggering the impression event.
 * @param videoEventsOwner providing details of who is responsible for triggering video events. This is only required for video ad sessions and should be set to videoEventsOwner:OMIDNoneOwner for display ad sessions.
 * @param isolateVerificationScripts determines whether verification scripts will be placed in a sandboxed environment. This will not have any effect for native sessions.
 */
- (nullable instancetype)initWithImpressionOwner:(OMIDOwner)impressionOwner
                                videoEventsOwner:(OMIDOwner)videoEventsOwner
                      isolateVerificationScripts:(BOOL)isolateVerificationScripts
                                           error:(NSError *_Nullable *_Nullable)error;

#pragma mark - Deprecated Methods

- (nullable instancetype)initWithImpressionOwner:(OMIDOwner)impressionOwner
                                videoEventsOwner:(OMIDOwner)videoEventsOwner
                                           error:(NSError *_Nullable *_Nullable)error __deprecated_msg("Use -initWithImpressionOwner:videoEventsOwner:isolateVerificationScripts:error: instead.");

@end

