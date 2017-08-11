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

#import <Foundation/Foundation.h>




@interface ANAdFetcherResponse : NSObject

@property (nonatomic, readonly, assign, getter=isSuccessful) BOOL successful;
@property (nonatomic, readonly, strong) id  adObject;
@property (nonatomic, readonly, strong) id  adObjectHandler;
@property (nonatomic, readonly, strong) NSError *error;

@property (nonatomic, readwrite, strong) NSString *auctionID;


//
+ (ANAdFetcherResponse *)responseWithError:(NSError *)error;

+ (ANAdFetcherResponse *)responseWithAdObject: (id)adObject
                           andAdObjectHandler: (id)adObjectHandler;

//
- (instancetype)initAdResponseFailWithError:(NSError *)error;

- (instancetype)initAdResponseSuccessWithAdObject: (id)adObject
                               andAdObjectHandler: (id)adObjectHandler;


@end
