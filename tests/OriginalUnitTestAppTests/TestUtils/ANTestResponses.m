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

#import "ANTestResponses.h"
#import "ANMediatedAd.h"
#import "ANTestGlobal.h"



#pragma mark - Response templates.
                //fix -- FXI FIX -- removed unused templates...

NSString *const RESPONSE_TEMPLATE = @"{\"status\":\"%@\",\"ads\": %@,\"mediated\": %@}";
NSString *const ADS_ARRAY_TEMPLATE = @"[{ \"type\": \"%@\", \"width\": %i, \"height\": %i, \"content\": \"%@\" }]";

NSString *const MEDIATED_ARRAY_TEMPLATE = @""
                         "[{ \"handler\":"
                                "[{\"type\":\"%@\",\"class\":\"%@\",\"param\":\"%@\",\"width\":\"%i\",\"height\":\"%i\",\"id\":\"%@\"}],"
                            "\"result_cb\":\"%@\""
                         "}]"
                ;

NSString *const MEDIATED_AD_TEMPLATE = @"{\"type\":\"%@\",\"class\":\"%@\",\"param\":\"%@\",\"width\":\"%@\",\"height\":\"%@\",\"id\":\"%@\"}";


//
        //FIX -- better way to represent JSON string templates, possibly requiring preprocessing step.

NSString *const  UT_TEMPLATE  = @""
                        "{ \"tags\": [ { "
                            "\"no_ad_url\": \"MOCK__no_ad_url\", "
                            "\"ads\": [ "
                                "%@"                                    //ad object(s)
                            "] "
                        "} ] }"
                    ;

NSString *const  UT_TEMPLATE_BANNER_INTERSTITIAL  = @""
                        "{ "
                            "\"content_source\": \"rtb\", "
                            "\"ad_type\": \"banner\", "
                            "\"media_type_id\": 0, "                                                                    //XXX
                            "\"media_subtype_id\": 0, "                                                                 //XXX

                            "\"rtb\": { "
                                "\"banner\": { \"content\": \"%@\", \"width\": 320, \"height\": 50 }, "                 //XXX + content:?
                                "\"trackers\": [ { \"impression_urls\": [ \"MOCK__impression_url\" ], \"video_events\": {} } ] "
                            "} "
                        "} "
                    ;

NSString *const  UT_TEMPLATE_CSM  = @""
                        "{ "
                            "\"content_source\": \"csm\", "
                            "\"ad_type\": \"banner\", "
                            "\"media_type_id\": 0, "                                                                    //XXX
                            "\"media_subtype_id\": 0, "                                                                 //XXX
                            "\"viewability\": { \"config\": \"MOCK__config\", }, "

                            "\"csm\": { "
                                "\"banner\": { \"content\": \"MOCK__content\", \"width\": 320, \"height\": 50 }, "
                                "\"handler\": [ "                                                                       //XXX + iOS class:?
                                    "{ \"param\": \"#{PARAM}\", \"class\": \"%@\", \"width\": \"320\", \"height\": \"50\", \"type\": \"ios\", \"id\": \"MOCK__id\" }, "
                                    "{ \"param\": \"#{PARAM}\", \"class\": \"com.appnexus.opensdk.mediatedviews.MOCK__androidClass\", \"width\": \"320\", \"height\": \"50\", \"type\": \"android\", \"id\": \"MOCK__id\" } "
                                "], "
                                "\"trackers\": [ { \"impression_urls\": [ \"MOCK__impression_url\" ], \"video_events\": {} } ], "
                                "\"response_url\": \"MOCK__response_url\" "
                            "} "
                        "} "
                    ;



#pragma mark - ANMediatedAd (TestResponse)

@interface ANMediatedAd (TestResponses)

@property (nonatomic, readwrite, strong) NSString *type;

- (NSString *)toJSON;
+ (ANMediatedAd *)dummy;

@end



@implementation ANMediatedAd (TestResponses)

NSString *_type;

- (NSString *)toJSON {
    return [NSString stringWithFormat:MEDIATED_AD_TEMPLATE, self.type, self.className, self.param, self.width, self.height, self.adId];
}

- (void)setType:(NSString *)type {
    _type = type;
}

- (NSString *)type {
    return _type;
}

+ (ANMediatedAd *)dummy {
    ANMediatedAd *mediatedAd = [ANMediatedAd new];
    mediatedAd.type = @"ios";
    mediatedAd.param = @"";
    mediatedAd.className = @"MOCK__className";
    mediatedAd.width = @"320";
    mediatedAd.height = @"50";
    mediatedAd.adId = @"124";
    return mediatedAd;
}

@end




#pragma mark - ANTestResponse

@implementation ANTestResponses

#pragma mark View-specific Convenience functions

+ (NSString *)successfulBanner
{
    NSString  *utResponse      = nil;
    NSString  *bannerAdObject  = nil;

    bannerAdObject = [NSString stringWithFormat:UT_TEMPLATE_BANNER_INTERSTITIAL, @"MOCK__content"];
    utResponse = [NSString stringWithFormat:UT_TEMPLATE, bannerAdObject];

    return  utResponse;

//    return  [NSString stringWithFormat:UT_BANNER_INTERSTITIAL_TEMPLATE, @"MOCK__content"];
//    return  [ANTestResponses createAdsResponse:@"banner" withWidth:320 withHeight:50 withContent:@"HelloWorld"];   //FIX -- was
}

+ (NSString *)blankContentBanner
        //FIX -- generalize with successfulBanner?
{
    NSString  *utResponse      = nil;
    NSString  *bannerAdObject  = nil;

    bannerAdObject = [NSString stringWithFormat:UT_TEMPLATE_BANNER_INTERSTITIAL, @""];
    utResponse = [NSString stringWithFormat:UT_TEMPLATE, bannerAdObject];

    return  utResponse;

//    return  [NSString stringWithFormat:UT_BANNER_INTERSTITIAL_TEMPLATE, @""];
//    return [ANTestResponses createAdsResponse:@"banner" withWidth:320 withHeight:50 withContent:@""];   //fix --FIX -- was
}

            /* FIX -- toss
+ (NSString *)mediationSuccessfulBanner
                    //FIX -- use mediationWaterfallWithMockClassNames:
{
    NSString  *csmAdObject  = [NSString stringWithFormat:UT_TEMPLATE_CSM, @"ANMockMediationAdapterSuccessfulBanner"];
    NSString  *utResponse   = [NSString stringWithFormat:UT_TEMPLATE, csmAdObject];

    return  utResponse;

//    return  [NSString stringWithFormat:UT_MEDIATED_TEMPLATE, @"ANMockMediationAdapterSuccessfulBanner"];
//    return [ANTestResponses createMediatedBanner:@"ANMockMediationAdapterSuccessfulBanner"];   //FIX -- was
}
                         */

+ (NSString *)mediationNoAdsBanner {
    return [ANTestResponses createMediatedBanner:@"ANAdAdapterBannerNoAds"];
}

+ (NSString *)mediationErrorCodeBanner:(int)code {
    return [ANTestResponses createMediatedBanner:@"ANAdAdapterErrorCode" withID:[NSString stringWithFormat:@"%i", code]];
}

+ (NSString *)mediationWaterfallBanners:(NSString *)firstClass secondClass:(NSString *)secondClass {
    ANMediatedAd *firstAd = [ANMediatedAd dummy];
    firstAd.className = firstClass;
    NSString *firstHandler = [ANTestResponses createHandlerObjectFromMediatedAds:
                              [[NSMutableArray alloc] initWithObjects:firstAd, nil]
                                                                    withResultCB:OK_RESULT_CB_URL];
    
    ANMediatedAd *secondAd = [ANMediatedAd dummy];
    secondAd.className = secondClass;
    NSString *secondHandler = [ANTestResponses createHandlerObjectFromMediatedAds:
                               [[NSMutableArray alloc] initWithObjects:secondAd, nil]
                                                                     withResultCB:OK_RESULT_CB_URL];
    
    NSString *mediatedField = [ANTestResponses createMediatedArrayFromHandlers:
                               [[NSMutableArray alloc] initWithObjects:firstHandler,
                                secondHandler, nil]];
    return [ANTestResponses createMediatedResponse:mediatedField];
}

+ (NSString *)mediationWaterfallBanners: (NSString *)firstClass
                            firstResult: (NSString *)firstResult
                            secondClass: (NSString *)secondClass
                           secondResult: (NSString *)secondResult
                                //FIX -- refactor signature: result arguments are always emptystring
{
TESTMARK();
    ANMediatedAd *firstAd = [ANMediatedAd dummy];
    ANMediatedAd *secondAd = [ANMediatedAd dummy];

    firstAd.className = firstClass;
    secondAd.className = secondClass;

    NSString *firstHandler = [ANTestResponses createHandlerObjectFromMediatedAds: [[NSMutableArray alloc] initWithObjects:firstAd, nil]
                                                                    withResultCB: firstResult];
TESTMARKJSON(firstHandler);

    NSString *secondHandler = [ANTestResponses createHandlerObjectFromMediatedAds: [[NSMutableArray alloc] initWithObjects:secondAd, nil]
                                                                     withResultCB: secondResult];
TESTMARKJSON(secondHandler);

    NSString *mediatedField = [ANTestResponses createMediatedArrayFromHandlers:[[NSMutableArray alloc] initWithObjects:firstHandler, secondHandler, nil]];
TESTMARKJSON(mediatedField);

    return [ANTestResponses createMediatedResponse:mediatedField];
}

+ (NSString *)mediationWaterfallWithMockClassNames:(NSArray<NSString *> *)arrayOfMockClassObjects
{
    NSString  *utResponse          = nil;
    NSString  *listOfCSMAdObjects  = nil;

    for (NSString *classObject in arrayOfMockClassObjects)
    {
        NSString  *csmAdObject  = [NSString stringWithFormat:UT_TEMPLATE_CSM, classObject];

        if (!listOfCSMAdObjects) {
            listOfCSMAdObjects = csmAdObject;
        } else {
            listOfCSMAdObjects = [NSString stringWithFormat:@"%@, %@", listOfCSMAdObjects, csmAdObject];
        }
    }

    utResponse = [NSString stringWithFormat:UT_TEMPLATE, listOfCSMAdObjects];

    return  utResponse;
}

+ (NSString *)mediationWaterfallBanners:(NSString *)firstClass firstResult:(NSString *)firstResult
                            secondClass:(NSString *)secondClass secondResult:(NSString *)secondResult
                             thirdClass:(NSString *)thirdClass thirdResult:(NSString *)thirdResult {                 //FIX
    ANMediatedAd *firstAd = [ANMediatedAd dummy];
    firstAd.className = firstClass;
    NSString *firstHandler = [ANTestResponses createHandlerObjectFromMediatedAds:
                              [[NSMutableArray alloc] initWithObjects:firstAd, nil]
                                                                    withResultCB:firstResult];
    
    ANMediatedAd *secondAd = [ANMediatedAd dummy];
    secondAd.className = secondClass;
    NSString *secondHandler = [ANTestResponses createHandlerObjectFromMediatedAds:
                               [[NSMutableArray alloc] initWithObjects:secondAd, nil]
                                                                     withResultCB:secondResult];
    
    ANMediatedAd *thirdAd = [ANMediatedAd dummy];
    thirdAd.className = thirdClass;
    NSString *thirdHandler = [ANTestResponses createHandlerObjectFromMediatedAds:
                               [[NSMutableArray alloc] initWithObjects:thirdAd, nil]
                                                                     withResultCB:thirdResult];
    
    NSString *mediatedField = [ANTestResponses createMediatedArrayFromHandlers:
                               [[NSMutableArray alloc] initWithObjects:firstHandler,
                                secondHandler, thirdHandler, nil]];
    return [ANTestResponses createMediatedResponse:mediatedField];
}




#pragma mark - Response Construction Convenience functions

+ (NSString *)createAdsResponse: (NSString *)type
                      withWidth: (int)width
                     withHeight: (int)height
                    withContent: (NSString *)content
{                 //FIX
    NSString *statusField = @"ok";
    NSString *adsField = [NSString stringWithFormat:ADS_ARRAY_TEMPLATE, type, width, height, content];
    NSString *mediatedField = @"[]";
    return [ANTestResponses createResponseString:statusField withAds:adsField withMediated:mediatedField];
}

+ (NSString *)createMediatedBanner:(NSString *)className {
    return [ANTestResponses createMediatedBanner:className withID:@"" withResultCB:OK_RESULT_CB_URL];
}

+ (NSString *)createMediatedBanner:(NSString *)className
                            withID:(NSString *)idString {
    return [ANTestResponses createMediatedBanner:className withID:idString withResultCB:OK_RESULT_CB_URL];
}

+ (NSString *)createMediatedBanner:(NSString *)className
                            withID:(NSString *)idString
                      withResultCB:(NSString *)resultCB
{
    ANMediatedAd *mediatedAd = [ANMediatedAd dummy];
    mediatedAd.className = className;
    mediatedAd.adId = idString;
    
    NSMutableArray *mediatedAdsArray = [[NSMutableArray alloc] initWithObjects:mediatedAd, nil];
    NSString *handler = [ANTestResponses createHandlerObjectFromMediatedAds:mediatedAdsArray withResultCB:resultCB];

    NSString *mediatedField = [ANTestResponses createMediatedArrayFromHandlers:[[NSMutableArray alloc] initWithObjects:handler, nil]];
    return [ANTestResponses createMediatedResponse:mediatedField];
}

+ (NSString *)createMediatedResponse:(NSString *)type
                       withClassName:(NSString *)className
                           withParam:(NSString *)param
                           withWidth:(int)width
                          withHeight:(int)height
                              withID:(NSString *)idString
                        withResultCB:(NSString *)resultCB {                 //FIX
    NSString *statusField = @"ok";
    NSString *adsField = @"[]";
    NSString *mediatedField = [NSString stringWithFormat:MEDIATED_ARRAY_TEMPLATE, type, className,
            param, width, height, idString, resultCB];
    return [ANTestResponses createResponseString:statusField withAds:adsField withMediated:mediatedField];
}

+ (NSString *)createMediatedResponse:(NSString *)mediatedField
{
TESTMARKJSON(mediatedField);

    NSString *statusField = @"ok";
    NSString *adsField = @"[]";
    return [ANTestResponses createResponseString:statusField withAds:adsField withMediated:mediatedField];
}




#pragma mark - Base functions

+ (NSString *)createResponseString:(NSString *)status
                           withAds:(NSString *)ads
                      withMediated:(NSString *)mediated
{
    return [NSString stringWithFormat:RESPONSE_TEMPLATE, status, ads, mediated];
}

+ (NSString *)createAdsString:(NSString *)type
                    withWidth:(int)width
                   withHeight:(int)height
                  withContent:(NSString *)content {
    return [NSString stringWithFormat:ADS_ARRAY_TEMPLATE, type, width, height, content];
}

+ (NSString *)createMediatedString:(NSString *)type
                     withClassName:(NSString *)className
                         withParam:(NSString *)param
                         withWidth:(int)width
                         withHeight:(int)height
                            withID:(NSString *)idString
                      withResultCB:(NSString *)resultCB {
    return [NSString stringWithFormat:MEDIATED_ARRAY_TEMPLATE, type, className,
            param, width, height, idString, resultCB];
}

+ (NSString *)createMediatedArrayFromHandlers:(NSMutableArray *)handlers {
    NSString *mediatedArrayString = @"[";
    if ([handlers count] > 0) {
        NSString *handler = [handlers objectAtIndex:0];
        mediatedArrayString = [mediatedArrayString stringByAppendingString:handler];
        [handlers removeObjectAtIndex:0];
    }
    
    while ([handlers count] > 0) {
        mediatedArrayString = [mediatedArrayString stringByAppendingString:@","];
        NSString *handler = [handlers objectAtIndex:0];
        mediatedArrayString = [mediatedArrayString stringByAppendingString:handler];
        [handlers removeObjectAtIndex:0];
    }
    mediatedArrayString = [mediatedArrayString stringByAppendingString:@"]"];
    return mediatedArrayString;
}

+ (NSString *)createHandlerObjectFromMediatedAds:(NSMutableArray *)mediatedAds
                                    withResultCB:(NSString *)resultCB
{
TESTMARK();
    NSString *mediatedAdString = @"{ \"handler\": [";
    while ([mediatedAds count] > 1) {
        ANMediatedAd *mediatedAd = [mediatedAds objectAtIndex:0];
        mediatedAdString = [mediatedAdString stringByAppendingString:[mediatedAd toJSON]];
        mediatedAdString = [mediatedAdString stringByAppendingString:@", "];
        [mediatedAds removeObjectAtIndex:0];
    }
    
    if ([mediatedAds count] > 0) {
        ANMediatedAd *mediatedAd = (ANMediatedAd *)[mediatedAds objectAtIndex:0];
        mediatedAdString = [mediatedAdString stringByAppendingString:[mediatedAd toJSON]];
        [mediatedAds removeObjectAtIndex:0];
    }
    
    mediatedAdString = [mediatedAdString stringByAppendingString:@"]"];
    
    if (resultCB) {
        NSString *resultCBString = [NSString stringWithFormat:@", \"result_cb\":\"%@\"", resultCB];
        mediatedAdString = [mediatedAdString stringByAppendingString:resultCBString];
    }
    
    mediatedAdString = [mediatedAdString stringByAppendingString:@"}"];

    return mediatedAdString;
}


@end

