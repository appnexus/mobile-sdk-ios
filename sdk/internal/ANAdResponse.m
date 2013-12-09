/*   Copyright 2013 APPNEXUS INC
 
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

#import "ANAdResponse.h"

#import "ANCustomAdapter.h"
#import "ANGlobal.h"
#import "ANLogging.h"
#import "ANMediatedAd.h"

NSString *const kResponseKeyStatus = @"status";
NSString *const kResponseKeyErrorMessage = @"errorMessage";
NSString *const kResponseKeyAds = @"ads";
NSString *const kResponseKeyType = @"type";
NSString *const kResponseKeyWidth = @"width";
NSString *const kResponseKeyHeight = @"height";
NSString *const kResponseKeyContent = @"content";
NSString *const kResponseKeyMediatedAds = @"mediated";
NSString *const kResponseKeyHandler = @"handler";
NSString *const kResponseKeyClass = @"class";
NSString *const kResponseKeyId = @"id";
NSString *const kResponseKeyParam = @"param";
NSString *const kResponseKeyResultCB = @"result_cb";

NSString *const kResponseValueError = @"error";
NSString *const kResponseValueIOS = @"ios";

NSString *const kMraidJSFilename = @"mraid.js";

NSString *const kANAdFetcherDidReceiveResponseNotification = @"kANAdFetcherDidReceiveResponseNotification";
NSString *const kANAdFetcherAdResponseKey = @"kANAdFetcherAdResponseKey";

@interface ANAdResponse ()

@end

@implementation ANAdResponse

+ (ANAdResponse *)adResponseSuccessfulWithAdObject:(id)adObject;
{
    ANAdResponse *response = [[[self class] alloc] init];
    response.successful = YES;
    response.adObject = adObject;
    response.error = ANAdResponseSuccessful;
    
    return response;
}

+ (ANAdResponse *)adResponseFailWithError:(NSError *)error
{
    ANAdResponse *response = [[[self class] alloc] init];
    response.successful = NO;
    response.adObject = nil;
    response.error = error;
    
    return response;
}

+ (ANAdResponse *)parseResponse:(NSError *)error
{
    ANAdResponse *response = [[[self class] alloc] init];
    response.successful = NO;
    response.adObject = nil;
    response.error = error;
    
    return response;
}

- (ANAdResponse *)processResponseData:(NSData *)data
{
    _containsAds = false;
    NSError *jsonParsingError = nil;
    

    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    ANLogDebug(@"Processing response: %@", responseString);

    [[NSNotificationCenter defaultCenter] postNotificationName:kANAdFetcherDidReceiveResponseNotification object:self userInfo:[NSDictionary dictionaryWithObject:responseString ? responseString : @"" forKey:kANAdFetcherAdResponseKey]];
    
    if ([responseString length] < 1)
        return self;
    
    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
    
    if (jsonParsingError != nil) {
        ANLogError(ANErrorString(@"response_json_error"), jsonParsingError);
        
        return [ANAdResponse adResponseFailWithError:jsonParsingError];
    }
    
    if ([self checkStatusIsValid:jsonResponse]) {
        if (![self handleStandardAds:jsonResponse]) {
            [self handleMediatedAds:jsonResponse];
        }
        
    }
    return self;
}

// returns true if no error in status. don't fail on null or missing status
-(BOOL)checkStatusIsValid:(NSDictionary *)jsonResponse {
    NSString *status = [jsonResponse objectForKey:kResponseKeyStatus];
    if (status && ([status isEqual: kResponseValueError])) {
        ANLogError(ANErrorString(@"response_error"));
        return NO;
    }
    return YES;
}

// returns true if response contains an ad, false if not
- (BOOL)handleStandardAds:(NSDictionary *)jsonResponse
{
    NSArray *ads = [jsonResponse objectForKey:kResponseKeyAds];
    if (ads && ([ads count] > 0))
    {
        // Grab the first ad only
        NSDictionary *firstAd = [ads objectAtIndex:0];

        // Grab the type of the ad
        _type = [firstAd objectForKey:kResponseKeyType];
        // Grab the size of the ad
        _width = [firstAd objectForKey:kResponseKeyWidth];
        _height = [firstAd objectForKey:kResponseKeyHeight];
        // Grab the ad's content
        _content = [firstAd objectForKey:kResponseKeyContent];
        if (!_content || ([_content length] < 1)) {
            ANLogError(ANErrorString(@"blank_ad"));
        }
        else {
            // check for mraid.js file
            NSRange mraidJSRange = [_content rangeOfString:kMraidJSFilename];
            _isMraid = (mraidJSRange.location != NSNotFound);
            
            _containsAds = YES;
            return YES;
        }
    }
    return NO;
}


// returns true if response contains an ad, false if not
- (BOOL)handleMediatedAds:(NSDictionary *)jsonResponse
{
    NSArray *mediated = [jsonResponse objectForKey:kResponseKeyMediatedAds];
    if (mediated && ([mediated count] > 0)) {
        _mediatedAds = [[NSMutableArray alloc] initWithCapacity:0];
        for (int i = 0; i < [mediated count]; i++) {
            NSDictionary *mediatedElement = [mediated objectAtIndex:i];
            if (mediatedElement) {
                NSArray *handler = [mediatedElement objectForKey:kResponseKeyHandler];
                if (handler) {
                    for (int j = 0; j < [handler count]; j++) {
                        NSDictionary *handlerElement = [handler objectAtIndex:j];
                        if (handlerElement) {
                            NSString *type = [handlerElement objectForKey:kResponseKeyType];
                            // check that the mediated ad is for ios
                            if (type && [[type lowercaseString] isEqual: kResponseValueIOS]) {
                                // Grab the mediation network adapter's class string
                                NSString *className = [handlerElement objectForKey:kResponseKeyClass];
                                // Grab any extra user info included with the ad request
                                NSString *param = [handlerElement objectForKey:kResponseKeyParam];
                                // Grab dimensions
                                NSString *width = [handlerElement objectForKey:kResponseKeyWidth];
                                NSString *height = [handlerElement objectForKey:kResponseKeyHeight];
                                // Grab placement id associated with mediated network
                                NSString *adId = [handlerElement objectForKey:kResponseKeyId];
                                
                                NSString *resultCB = [mediatedElement objectForKey:kResponseKeyResultCB];
                                
                                ANMediatedAd *mediatedAd = [ANMediatedAd new];
                                mediatedAd.className = className;
                                mediatedAd.param = param;
                                mediatedAd.width = width;
                                mediatedAd.height = height;
                                mediatedAd.adId = adId;
                                mediatedAd.resultCB = resultCB;
                                
                                if ([mediatedAd.className length] > 0)
                                    [_mediatedAds addObject:mediatedAd];
                            }
                        }
                    }
                }
            }
        }
        
        if ([_mediatedAds count] > 0) {
            _containsAds = YES;
            return YES;
        }
    }
        return NO;
}

@end
