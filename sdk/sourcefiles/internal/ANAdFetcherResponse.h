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

#import <UIKit/UIKit.h>

#import "ANAdResponseInfo.h"




@interface ANAdFetcherResponse : NSObject

/**
 * There are two successful cases: 1) AdUnit loaded normally; 2) AdUnit loaded lazily.
 * All other cases are error cases, including the return of nobid instead of an ad object.
 */
@property (nonatomic, readonly, assign, getter=isSuccessful)  BOOL  successful;

/**
 * Set to YES when an AdUnit is being lazy loaded.  This happens during the first return to the AdUnit from processing UT Response.
 * NOTE  The second return to the AdUnit, when the lazy AdUnit loads the webview, the ANFetcherResponse instance is new and isLazy will be NO.
 */
@property (nonatomic, readonly)  BOOL  isLazy;

@property (nonatomic, readwrite, strong, nullable)   id  adObject;
@property (nonatomic, readonly, strong, nullable)    id  adObjectHandler;

@property (nonatomic, readwrite, strong, nullable)  ANAdResponseInfo  *adResponseInfo;

@property (nonatomic, readonly, strong, nullable) NSError *error;


//
+ (nonnull ANAdFetcherResponse *)responseWithError:(nonnull NSError *)error;

+ (nonnull ANAdFetcherResponse *)responseWithAdObject: (nonnull id)adObject
                                   andAdObjectHandler: (nullable id)adObjectHandler;

+ (nonnull ANAdFetcherResponse *)lazyResponseWithAdObject: (nonnull id)adObject
                                       andAdObjectHandler: (nonnull id)adObjectHandler;


@end
