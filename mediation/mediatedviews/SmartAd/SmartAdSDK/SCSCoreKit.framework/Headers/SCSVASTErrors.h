//
//  SCSVASTErrors.h
//  SCSCoreKit
//
//  Created by Thomas Geley on 20/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

// NOTE: THIS CLASS IS EXCLUDED FROM CODE COVERAGE AND UNIT TESTING.

// Domain
#pragma mark - Domain

#define SCSVAST_ERROR_DOMAIN                                    @"SCSVASTErrorDomain"

// SCSVASTParsingError

#pragma mark - Parsing Errors

#define SCSVASTParsingError_ConnectionError                     @"Connection error."
#define SCSVASTParsingErrorCode_ConnectionError                 5030

#define SCSVASTParsingError_TimeoutError                        @"Connection timed out."
#define SCSVASTParsingErrorCode_TimeoutError                    5031

#define SCSVASTParsingError_BadResponseError                    @"Unexpected response."
#define SCSVASTParsingErrorCode_BadResponseError                5032

#define SCSVASTParsingError_XMLParsingError                     @"XML Parsing Error."
#define SCSVASTParsingErrorCode_XMLParsingError                 100

#define SCSVASTParsingError_VASTValidationError                 @"Invalid VAST Schema."
#define SCSVASTParsingErrorCode_VASTValidationError             101

#define SCSVASTParsingError_VASTVersionError                    @"Unsupported VAST version."
#define SCSVASTParsingErrorCode_VASTVersionError                102

#define SCSVASTParsingError_NoVASTAdTagURI                      @"Wrapper doesnt have a VASTAdTagURI."
#define SCSVASTParsingErrorCode_NoVASTAdTagURI                  5014

#define SCSVASTParsingError_NoAdInVAST                          @"No ad in VAST."
#define SCSVASTParsingErrorCode_NoAdInVAST                      5015

#define SCSVASTParsingError_NoWrapperImpression                 @"Wrapper at first level doesnt have a valid impression pixel."
#define SCSVASTParsingErrorCode_NoWrapperImpression             5016


// SCSVASTManagerError

#pragma mark - Manager Errors

#define SCSVASTManagerError_Parsing                             @"Parsing failed."
#define SCSVASTManagerErrorCode_Parsing                         10000

#define SCSVASTManagerError_Timeout                             @"VASTManager Timeout."
#define SCSVASTManagerErrorCode_Timeout                         10001

#define SCSVASTManagerError_NoInput                             @"No XML Input."
#define SCSVASTManagerErrorCode_NoInput                         10002

#define SCSVASTManagerError_UnableToDownloadXML                 @"Unable to download XML."
#define SCSVASTManagerErrorCode_UnableToDownloadXML             10003

#define SCSVASTManagerError_NoModel                             @"Unable to create VAST Model."
#define SCSVASTManagerErrorCode_NoModel                         10004

#define SCSVASTManagerError_NoMoreAds                           @"No more ads available."
#define SCSVASTManagerErrorCode_NoMoreAds                       10005

#define SCSVASTManagerError_PassbackResolutionIncomplete        @"Passback resolution incomplete."
#define SCSVASTManagerErrorCode_PassbackResolutionIncomplete    10006

#define SCSVASTManagerError_NoMorePassback                      @"No more Passback."
#define SCSVASTManagerErrorCode_NoMorePassback                  10007

#define SCSVASTManagerError_NoAd                                @"No ad available."
#define SCSVASTManagerErrorCode_NoAd                            10008

