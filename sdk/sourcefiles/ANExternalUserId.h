/*   Copyright 2021 APPNEXUS INC
 
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
 *  Supported Third Party ID Sources
 * */
typedef NS_ENUM(NSUInteger, ANExternalUserIdSource) {
    ANExternalUserIdSourceLiveRamp,
    ANExternalUserIdSourceNetId,
    ANExternalUserIdSourceCriteo,
    ANExternalUserIdSourceTheTradeDesk
};



/**
 Defines the User Id Object from an External Thrid Party Source
 */
@interface ANExternalUserId : NSObject

/**
 Source of the External User Id
 */
@property (nonatomic, readwrite)  ANExternalUserIdSource  source;

/**
 The User Id String
 */
@property (nonatomic, readwrite, strong, nonnull) NSString *userId;


- (nullable instancetype)initWithSource:(ANExternalUserIdSource)source userId:(nonnull NSString *)userId;

@end
