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

#import "ANAdFetcherResponse.h"

#import "ANLogging.h"




#pragma mark -

@interface ANAdFetcherResponse ()

@property (nonatomic, readwrite, assign, getter=isSuccessful)  BOOL  successful;
@property (nonatomic, readwrite)                               BOOL  isLazy;

@property (nonatomic, readwrite, strong, nonnull) id adObject;
@property (nonatomic, readwrite, strong, nullable) id adObjectHandler;

@property (nonatomic, readwrite, strong, nullable)  NSString  *adContent;
@property (nonatomic, readwrite)                    CGSize     sizeOfWebview;
@property (nonatomic, readwrite, strong, nullable)  NSURL     *baseURL;
@property (nonatomic, readwrite, strong, nullable)  id         anjamDelegate;

@property (nonatomic, readwrite, strong, nullable) NSError *error;

@end



#pragma mark -

@implementation ANAdFetcherResponse

#pragma mark Lifecycle.

- (nonnull instancetype)initAdResponseFailWithError:(nonnull NSError *)error {
    self = [super init];
    if (self) {
        _error = error;
    }
    return self;
}


- (nonnull instancetype)initAdResponseWithAdObject: (nonnull id)adObject
                                andAdObjectHandler: (nullable id)adObjectHandler
{
    self = [super init];

    if (!self)  { return nil; }


    //
    _successful             = YES;

    _adObject               = adObject;
    _adObjectHandler        = adObjectHandler;

    return self;
}

- (nonnull instancetype)initLazyResponseWithAdContent: (nonnull NSString *)adContent
                                               adSize: (CGSize)sizeOfWebview
                                              baseURL: (nonnull NSURL *)baseURL
                                   andAdObjectHandler: (nonnull id)adObjectHandler
{
    self = [super init];

    if (!self)  { return nil; }


    //
    _successful             = YES;
    _isLazy                 = YES;

    _adContent              = adContent;
    _sizeOfWebview          = sizeOfWebview;
    _baseURL                = baseURL;

    _adObjectHandler        = adObjectHandler;

    return self;
}




#pragma mark - Class methods.

+ (nonnull ANAdFetcherResponse *)responseWithError:(nonnull NSError *)error {
    return [[ANAdFetcherResponse alloc] initAdResponseFailWithError:error];
}


+ (nonnull ANAdFetcherResponse *)responseWithAdObject: (nonnull id)adObject
                                   andAdObjectHandler: (nullable id)adObjectHandler
{
    return [[ANAdFetcherResponse alloc] initAdResponseWithAdObject: adObject
                                                andAdObjectHandler: adObjectHandler ];
}

+ (nonnull ANAdFetcherResponse *)lazyResponseWithAdContent: (nonnull NSString *)adContent
                                                    adSize: (CGSize)sizeOfWebview
                                                   baseURL: (nonnull NSURL *)baseURL
                                        andAdObjectHandler: (nonnull id)adObjectHandler
{
    return [[ANAdFetcherResponse alloc] initLazyResponseWithAdContent: adContent
                                                               adSize: sizeOfWebview
                                                              baseURL: baseURL
                                                   andAdObjectHandler: adObjectHandler ];
}

@end
