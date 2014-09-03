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

#import "ANBasicConfig.h"
#import "ANAdResponse.h"

#import ANCUSTOMADAPTERHEADER
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
NSString *const kResponseKeyAuctionInfo = @"auction_info";

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
    if (!responseString) {
        responseString = @"";
    }
    ANLogDebug(@"Processing response: %@", responseString);

    ANPostNotifications(kANAdFetcherDidReceiveResponseNotification, self,
                        @{kANAdFetcherAdResponseKey: responseString});
    
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
    NSString *status = jsonResponse[kResponseKeyStatus];
    if (status && ([status isEqual: kResponseValueError])) {
        ANLogError(ANErrorString(@"response_error"));
        return NO;
    }
    return YES;
}

// returns true if response contains an ad, false if not
- (BOOL)handleStandardAds:(NSDictionary *)jsonResponse
{
    NSArray *ads = jsonResponse[kResponseKeyAds];
    NSDictionary *firstAd = [ads firstObject]; // nil if there is no first ad
    if (firstAd) {
        // Grab the type of the ad
        _type = firstAd[kResponseKeyType];
        // Grab the size of the ad
        // response width, height could be NSNumber, use description to extract string. If string, returns itself.
        _width = [firstAd[kResponseKeyWidth] description];
        _height = [firstAd[kResponseKeyHeight] description];
        // Grab the ad's content
        _content = firstAd[kResponseKeyContent];
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
    NSArray *mediated = jsonResponse[kResponseKeyMediatedAds];
    if (mediated && ([mediated count] > 0)) {
        _mediatedAds = [[NSMutableArray alloc] initWithCapacity:[mediated count]]; // Capacity is a performance hint
        for (NSDictionary *mediatedElement in mediated) {
            NSArray *handler = mediatedElement[kResponseKeyHandler];
            for (NSDictionary *handlerElement in handler) {
                NSString *type = handlerElement[kResponseKeyType];
                // check that the mediated ad is for ios
                if (type && [[type lowercaseString] isEqual: kResponseValueIOS]) {
                    // Grab the mediation network adapter's class string
                    NSString *className = handlerElement[kResponseKeyClass];
                    // Grab any extra user info included with the ad request
                    NSString *param = handlerElement[kResponseKeyParam];
                    // Grab dimensions
                    NSString *width = [handlerElement[kResponseKeyWidth] description];
                    NSString *height = [handlerElement[kResponseKeyHeight] description];
                    // Grab placement id associated with mediated network
                    NSString *adId = handlerElement[kResponseKeyId];
                    
                    NSString *resultCB = mediatedElement[kResponseKeyResultCB];
                    
                    NSString *auctionInfo = mediatedElement[kResponseKeyAuctionInfo];
                    
                    ANMediatedAd *mediatedAd = [ANMediatedAd new];
                    mediatedAd.className = className;
                    mediatedAd.param = param;
                    mediatedAd.width = width;
                    mediatedAd.height = height;
                    mediatedAd.adId = adId;
                    mediatedAd.resultCB = resultCB;
                    mediatedAd.auctionInfo = auctionInfo;
                    
                    if ([mediatedAd.className length] > 0)
                        [_mediatedAds addObject:mediatedAd];
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
