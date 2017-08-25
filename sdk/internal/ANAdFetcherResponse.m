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

#import "ANAdFetcherResponse.h"

#import "ANLogging.h"



@interface ANAdFetcherResponse ()

@property (nonatomic, readwrite, assign, getter=isSuccessful) BOOL successful;
@property (nonatomic, readwrite, strong) id adObject;
@property (nonatomic, readwrite, strong) id adObjectHandler;
@property (nonatomic, readwrite, strong) NSError *error;

@end



@implementation ANAdFetcherResponse

#pragma mark - Lifecycle.

- (instancetype)initAdResponseFailWithError:(NSError *)error {
    self = [super init];
    if (self) {
        _error = error;
    }
    return self;
}

- (instancetype)initAdResponseSuccessWithAdObject: (id)adObject
                               andAdObjectHandler: (id)adObjectHandler
{
    self = [super init];
    if (self) {
        _successful = YES;
        _adObject = adObject;
        _adObjectHandler = adObjectHandler;
    }
    return self;
}



#pragma mark - Class methods.

+ (ANAdFetcherResponse *)responseWithError:(NSError *)error {
    return [[ANAdFetcherResponse alloc] initAdResponseFailWithError:error];
}

+ (ANAdFetcherResponse *)responseWithAdObject: (id)adObject
                           andAdObjectHandler: (id)adObjectHandler
{
    return [[ANAdFetcherResponse alloc] initAdResponseSuccessWithAdObject: adObject
                                                       andAdObjectHandler: adObjectHandler];
}


@end
