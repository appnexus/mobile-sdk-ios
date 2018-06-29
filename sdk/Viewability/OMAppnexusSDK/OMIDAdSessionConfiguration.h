//
//  OMIDAdSessionConfiguration.h
//  AppVerificationLibrary
//
//  Created by Saraev Vyacheslav on 15/09/2017.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, OMIDOwner) {
    OMIDJavaScriptOwner = 1, // will translate into "JAVASCRIPT" when published to the OMID JS service.
    OMIDNativeOwner = 2, // will translate into "NATIVE" when published to the OMID JS service.
    OMIDNoneOwner = 3 // will translate into "NONE" when published to the OMID JS service.
};

@interface OMIDAppnexusAdSessionConfiguration : NSObject

@property OMIDOwner impressionOwner;
@property OMIDOwner videoEventsOwner;
@property BOOL isolateVerificationScripts;

/// Returns nil and sets error if OMID isn't active or arguments are invalid.
/// @param impressionOwner providing details of who is responsible for triggering the impression event.
/// @param videoEventsOwner providing details of who is responsible for triggering video events. This is only required for video ad sessions and should be set to videoEventsOwner:OMIDNoneOwner for display ad sessions.
/// @param isolateVerificationScripts determines whether verification scripts will be placed in a sandboxed environment. This will not have any effect for native sessions.
- (nullable instancetype)initWithImpressionOwner:(OMIDOwner)impressionOwner
                                videoEventsOwner:(OMIDOwner)videoEventsOwner
                      isolateVerificationScripts:(BOOL)isolateVerificationScripts
                                           error:(NSError *_Nullable *_Nullable)error;

#pragma mark - Deprecated Methods

- (nullable instancetype)initWithImpressionOwner:(OMIDOwner)impressionOwner
                                videoEventsOwner:(OMIDOwner)videoEventsOwner
                                           error:(NSError *_Nullable *_Nullable)error __deprecated_msg("Use -initWithImpressionOwner:videoEventsOwner:isolateVerificationScripts:error: instead.");

@end

