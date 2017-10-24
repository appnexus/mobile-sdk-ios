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
#import "ANTestGlobal.h"



#pragma mark - Response templates.

//NB  All hardwired values in the NSString templates below are arbitrary.
//    Values that must be changed are replaced with %@.
//
NSString *const  UT_TEMPLATE_COMPLETE  = @""
                        "{ \"tags\": [ { "
                            "\"no_ad_url\": \"MOCK__no_ad_url\", "
                            "\"ads\": [ "
                                "%@"                                    //ad object(s)
                            "] "
                        "} ] }"
                    ;

NSString *const  UT_TEMPLATE_ADOBJECT_BANNER_INTERSTITIAL  = @""
                        "{ "
                            "\"content_source\": \"rtb\", "
                            "\"ad_type\": \"banner\", "
                            "\"media_type_id\": 0, "
                            "\"media_subtype_id\": 0, "

                            "\"rtb\": { "
                                "\"banner\": { \"content\": \"%@\", \"width\": %@, \"height\": %@ }, "                 //PARAMETERS: content, width, height
                                "\"trackers\": [ { \"impression_urls\": [ \"MOCK__impression_url\" ], \"video_events\": {} } ] "
                            "} "
                        "} "
                    ;

NSString *const  UT_TEMPLATE_ADOBJECT_CSM  = @""
                        "{ "
                            "\"content_source\": \"csm\", "
                            "\"ad_type\": \"banner\", "
                            "\"media_type_id\": 0, "
                            "\"media_subtype_id\": 0, "
                            "\"viewability\": { \"config\": \"MOCK__config\", }, "

                            "\"csm\": { "
                                "\"banner\": { \"content\": \"MOCK__content\", \"width\": 320, \"height\": 50 }, "
                                "\"handler\": [ "                                                                       //PARAMETERS: iOS class
                                    "{ \"param\": \"#{PARAM}\", \"class\": \"%@\", \"width\": \"320\", \"height\": \"50\", \"type\": \"ios\", \"id\": \"MOCK__id\" }, "
                                    "{ \"param\": \"#{PARAM}\", \"class\": \"com.appnexus.opensdk.mediatedviews.MOCK__androidClass\", \"width\": \"320\", \"height\": \"50\", \"type\": \"android\", \"id\": \"MOCK__id\" } "
                                "], "
                                "\"trackers\": [ { \"impression_urls\": [ \"MOCK__impression_url\" ], \"video_events\": {} } ], "
                                "\"response_url\": \"MOCK__response_url\" "
                            "} "
                        "} "
                    ;




@implementation ANTestResponses

#pragma mark - Responses for Media Type Banner.

+ (NSString *)successfulBanner
{
    return  [self createResponseForBannerMediaTypeWithContent:@"MOCK__content" width:320 height:50];
}

+ (NSString *)blankContentBanner
{
    return  [self createResponseForBannerMediaTypeWithContent:@"" width:320 height:50];
}

+ (NSString *) createResponseForBannerMediaTypeWithContent: (NSString *)content
                                                     width: (NSUInteger)width
                                                    height: (NSUInteger)height
{
    NSString  *utResponse      = nil;
    NSString  *bannerAdObject  = nil;

    bannerAdObject  = [NSString stringWithFormat:UT_TEMPLATE_ADOBJECT_BANNER_INTERSTITIAL, content, @(width), @(height)];
    utResponse      = [NSString stringWithFormat:UT_TEMPLATE_COMPLETE, bannerAdObject];

    return  utResponse;
}



#pragma mark - Responses for Content Source CSM.

+ (NSString *)mediationWaterfallWithMockClassNames:(NSArray<NSString *> *)arrayOfMockClassObjects
{
    NSString  *utResponse          = nil;
    NSString  *listOfCSMAdObjects  = nil;

    for (NSString *classObject in arrayOfMockClassObjects)
    {
        NSString  *csmAdObject  = [NSString stringWithFormat:UT_TEMPLATE_ADOBJECT_CSM, classObject];

        if (!listOfCSMAdObjects) {
            listOfCSMAdObjects = csmAdObject;
        } else {
            listOfCSMAdObjects = [NSString stringWithFormat:@"%@, %@", listOfCSMAdObjects, csmAdObject];
        }
    }

    utResponse = [NSString stringWithFormat:UT_TEMPLATE_COMPLETE, listOfCSMAdObjects];

    return  utResponse;
}


@end
