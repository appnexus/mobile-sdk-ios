/*   Copyright 2022 APPNEXUS INC
 
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

#import <Foundation/Foundation.h>
/*
 *  Supported Predefined Sources
 * */
typedef NS_ENUM(NSUInteger, ANUserIdSource)  {
    ANUserIdSourceLiveRamp,
    ANUserIdSourceNetId,
    ANUserIdSourceCriteo,
    ANUserIdSourceTheTradeDesk,
    ANUserIdSourceUID2
};



/**
 Defines the User Id Object from an External Third Party Source
 */
@interface ANUserId : NSObject

/**
 Source of the  User Id
 */
@property (nonatomic, readwrite, strong, nonnull) NSString *source;

/**
 The User Id String
 */
@property (nonatomic, readwrite, strong, nonnull) NSString *userId;

/**
 Publisher Provided Identifiers (PPIDs) are first party data identifiers that are created, owned and assigned by publishers. As Publisher Provided Identifiers is not the third party id so it should be send to Impbus even if the ATTrackingManagerAuthorizationStatusAuthorized is false.
 set isFirstParytId to true to send first party data identifiers
 */
@property (nonatomic) BOOL isFirstParytId;



/**
 Specifies a string that corresponds to the Publisher User ID for current application user.
 @param source for Source of the  User Id as per ANUserIdSource Enum
 @param userId for The User Id String
 */

- (nullable instancetype)initWithANUserIdSource:(ANUserIdSource)source userId:(nonnull NSString *)userId;

/**
 Specifies a string that corresponds to the Publisher User ID for current application user.
 @param  firstParytId to true to send first party data identifiers default should be send as false,  Publisher Provided Identifiers (PPIDs) are first party data identifiers that are created, owned and assigned by publishers. As Publisher Provided Identifiers is not the third party id so it should be send to Impbus even if the ATTrackingManagerAuthorizationStatusAuthorized is false.
 @param source for custom source of the  User Id as String
 @param userId for The User Id String
 */
- (nullable instancetype)initWithStringSource:(nonnull NSString *)source userId:(nonnull NSString *)userId isFirstParytId:(BOOL)firstParytId;

@end

