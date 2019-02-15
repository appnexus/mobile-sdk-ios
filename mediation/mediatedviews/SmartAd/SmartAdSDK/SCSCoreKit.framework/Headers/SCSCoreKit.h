//
//  SCSCoreKit.h
//  SCSCoreKit
//
//  Created by Loïc GIRON DIT METAZ on 11/01/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

// Components
#import "SCSVASTErrors.h"
#import "SCSVASTURL.h"
#import "SCSVASTTrackingEvent.h"
#import "SCSVASTClickEvent.h"

#import "SCSVASTModel.h"
#import "SCSVASTAd.h"
#import "SCSVASTAdInline.h"
#import "SCSVASTAdWrapper.h"
#import "SCSVASTCreative.h"
#import "SCSVASTCreativeLinear.h"
#import "SCSVASTCreativeNonLinear.h"
#import "SCSVASTCreativeCompanion.h"
#import "SCSVASTCreativeIcon.h"
#import "SCSVASTMediaFile.h" 
#import "SCSVASTAdExtension.h"
#import "SCSVASTMediaFileSelector.h"

#import "SCSVASTParser.h"
#import "SCSVASTParserResponse.h"
#import "SCSVASTModelGenerator.h"

#import "SCSVideoAdProtocol.h"
#import "SCSVASTAdAdapterProtocol.h"
#import "SCSVASTManagerProtocol.h"
#import "SCSVASTManagerDelegate.h"
#import "SCSVASTManager.h"
#import "SCSVASTManagerResponse.h"
#import "SCSVASTTrackingEventFactory.h"

#import "SCSTrackingEvent.h"
#import "SCSTrackingEventFactory.h"
#import "SCSTrackingEventDefaultFactory.h"
#import "SCSTrackingEventManager.h"
#import "SCSTrackingEventManagerDelegate.h"
#import "SCSVideoTrackingEvent.h"
#import "SCSVideoTrackingEventManager.h"
#import "SCSViewabilityTrackingEvent.h"
#import "SCSViewabilityTrackingEventManager.h"

#import "SCSViewabilityManagerDelegate.h"
#import "SCSViewabilityManager.h"

#import "SCSPostClickManagerDelegate.h"
#import "SCSPostClickManager.h"

// System
#import "SCSAppInfo.h"

#import "SCSIdentity.h"
#import "SCSIdentityProviderProtocol.h"
#import "SCSTransientID.h"

#import "SCSDeviceInfo.h"
#import "SCSDeviceInfoProviderProtocol.h"

#import "SCSFrameworkInfo.h"

#import "SCSLocation.h"
#import "SCSLocationManager.h"
#import "SCSLocationManagerDataSource.h"
#import "SCSLocationProviderDelegate.h"
#import "SCSLocationProviderProtocol.h"

// Maths
#import "SCSQuaternion.h"
#import "SCSAxis3.h"
#import "SCSAngleUtils.h"

// Config Manager
#import "SCSRemoteConfigManager.h"
#import "SCSRemoteConfigManagerDelegate.h"

// Model
#import "SCSConfiguration.h"

// Logger
#import "SCSRemoteLogger.h"
#import "SCSRemoteLog.h"

// Network
#import "SCSAdRequestManager.h"
#import "SCSAdRequestValidatorProtocol.h"
#import "SCSAdRequestErrors.h"

#import "SCSNetworkInfo.h"

#import "SCSPixel.h"
#import "SCSPixelManager.h"
#import "SCSPixelStore.h"
#import "SCSPixelStoreProviderProtocol.h"

#import "SCSURLSession.h"
#import "SCSURLSessionResponse.h"
#import "SCSURLSessionProviderProtocol.h"
#import "SCSURLSessionTask.h"

// Utils
#import "SCSUtils.h"
#import "SCSUIUtils.h"
#import "SCSURLUtils.h"
#import "SCSTimeUtils.h"
#import "SCSHash.h"
#import "SCSRandom.h"
#import "SCSLog.h"
#import "SCSLogDataSource.h"
#import "SCSProdURL.h"
#import "SCSTimer.h"
#import "SCSTimerInterval.h"
#import "SCSTimerDelegate.h"
#import "SCSFuture.h"

//! Project version number for SCSCoreKit.
FOUNDATION_EXPORT double SCSCoreKitVersionNumber;

//! Project version string for SCSCoreKit.
FOUNDATION_EXPORT const unsigned char SCSCoreKitVersionString[];
