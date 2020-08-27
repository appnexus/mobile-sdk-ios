/*   Copyright 2020 APPNEXUS INC

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

#import "ANAdResponseCode.h"

static const NSInteger DEFAULT = -1 ;
static const NSInteger SUCCESS = 0 ;
static const NSInteger INVALID_REQUEST = 1 ;
static const NSInteger UNABLE_TO_FILL = 2 ;
static const NSInteger MEDIATED_SDK_UNAVAILABLE = 3 ;
static const NSInteger NETWORK_ERROR = 4 ;
static const NSInteger INTERNAL_ERROR = 5 ;
static const NSInteger REQUEST_TOO_FREQUENT = 6 ;
static const NSInteger BAD_FORMAT = 7 ;
static const NSInteger BAD_URL = 8 ;
static const NSInteger BAD_URL_CONNECTION = 9 ;
static const NSInteger NON_VIEW_RESPONSE = 10 ;
static const NSInteger CUSTOM_ADAPTER_ERROR = 11 ;


@interface ANAdResponseCode ()

@property (nonatomic, readwrite, assign) NSInteger code;
@property (nonatomic, readwrite, strong, nonnull) NSString *message;

@end

@implementation ANAdResponseCode

#pragma mark - Class methods

+ (nonnull ANAdResponseCode *)DEFAULT{
    ANAdResponseCode *responseCode = [ANAdResponseCode new];
    responseCode.code = DEFAULT;
    responseCode.message = @"DEFAULT";
    return responseCode;
}

+ (nonnull ANAdResponseCode *)SUCCESS{
    ANAdResponseCode *responseCode = [ANAdResponseCode new];
    responseCode.code = SUCCESS;
    responseCode.message = @"SUCCESS";
    return responseCode;
}

+ (nonnull ANAdResponseCode *)INVALID_REQUEST{
    ANAdResponseCode *responseCode = [ANAdResponseCode new];
    responseCode.code = INVALID_REQUEST;
    responseCode.message = @"invalid_request_error";
    return responseCode;
}

+ (nonnull ANAdResponseCode *)UNABLE_TO_FILL{
    ANAdResponseCode *responseCode = [ANAdResponseCode new];
    responseCode.code = UNABLE_TO_FILL;
    responseCode.message = @"response_no_ads";
    return responseCode;
}

+ (nonnull ANAdResponseCode *)MEDIATED_SDK_UNAVAILABLE{
    ANAdResponseCode *responseCode = [ANAdResponseCode new];
    responseCode.code = MEDIATED_SDK_UNAVAILABLE;
    responseCode.message = @"MEDIATED_SDK_UNAVAILABLE";
    return responseCode;
}

+ (nonnull ANAdResponseCode *)NETWORK_ERROR{
    ANAdResponseCode *responseCode = [ANAdResponseCode new];
    responseCode.code = NETWORK_ERROR;
    responseCode.message = @"ad_network_error";
    return responseCode;
}

+ (nonnull ANAdResponseCode *)INTERNAL_ERROR{
    ANAdResponseCode *responseCode = [ANAdResponseCode new];
    responseCode.code = INTERNAL_ERROR;
    responseCode.message = @"ad_internal_error";
    return responseCode;
}

+ (nonnull ANAdResponseCode *)REQUEST_TOO_FREQUENT{
    ANAdResponseCode *responseCode = [ANAdResponseCode new];
    responseCode.code = REQUEST_TOO_FREQUENT;
    responseCode.message = @"ad_request_too_frequent_error";
    return responseCode;
}

+ (nonnull ANAdResponseCode *)BAD_FORMAT{
    ANAdResponseCode *responseCode = [ANAdResponseCode new];
    responseCode.code = BAD_FORMAT;
    responseCode.message = @"BAD_FORMAT";
    return responseCode;
}

+ (nonnull ANAdResponseCode *)BAD_URL{
    ANAdResponseCode *responseCode = [ANAdResponseCode new];
    responseCode.code = BAD_URL;
    responseCode.message = @"BAD_URL";
    return responseCode;
}

+ (nonnull ANAdResponseCode *)BAD_URL_CONNECTION{
    ANAdResponseCode *responseCode = [ANAdResponseCode new];
    responseCode.code = BAD_URL_CONNECTION;
    responseCode.message = @"BAD_URL_CONNECTION";
    return responseCode;
}

+ (nonnull ANAdResponseCode *)NON_VIEW_RESPONSE{
    ANAdResponseCode *responseCode = [ANAdResponseCode new];
    responseCode.code = NON_VIEW_RESPONSE;
    responseCode.message = @"NON_VIEW_RESPONSE";
    return responseCode;
}

+ (nonnull ANAdResponseCode *)CUSTOM_ADAPTER_ERROR:(nonnull NSString *) message{
    ANAdResponseCode *responseCode = [ANAdResponseCode new];
    responseCode.code = CUSTOM_ADAPTER_ERROR;
    responseCode.message = message;
    return responseCode;
}

@end
