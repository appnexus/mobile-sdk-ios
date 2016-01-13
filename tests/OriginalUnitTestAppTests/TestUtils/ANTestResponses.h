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

static NSString *const OK_RESULT_CB_URL = @"http://result";

@interface ANTestResponses : NSObject

// use these functions

+ (NSString *)successfulBanner;
+ (NSString *)successfulBannerUTv2;
+ (NSString *)blankContentBanner;
+ (NSString *)mediationSuccessfulBanner;
+ (NSString *)mediationNoAdsBanner;
+ (NSString *)mediationErrorCodeBanner:(int)code;

+ (NSString *)mediationWaterfallBanners:(NSString *)firstClass
                            secondClass:(NSString *)secondClass;
+ (NSString *)mediationWaterfallBanners:(NSString *)firstClass firstResult:(NSString *)firstResult
                            secondClass:(NSString *)secondClass secondResult:(NSString *)secondResult;
+ (NSString *)mediationWaterfallBanners:(NSString *)firstClass firstResult:(NSString *)firstResult
                            secondClass:(NSString *)secondClass secondResult:(NSString *)secondResult
                             thirdClass:(NSString *)thirdClass thirdResult:(NSString *)thirdResult;


+ (NSString *)createMediatedBanner:(NSString *)className;
+ (NSString *)createMediatedBanner:(NSString *)className
                            withID:(NSString *)idString;
+ (NSString *)createMediatedBanner:(NSString *)className
                            withID:(NSString *)idString
                      withResultCB:(NSString *)resultCB;

+ (NSString *)createAdsResponse:(NSString *)type
                      withWidth:(int)width
                     withHeight:(int)height
                    withContent:(NSString *)content;

+ (NSString *)createMediatedResponse:(NSString *)type
                       withClassName:(NSString *)className
                           withParam:(NSString *)param
                           withWidth:(int)width
                          withHeight:(int)height
                              withID:(NSString *)idString
                        withResultCB:(NSString *)resultCB;

// should not ever need to use these directly

+ (NSString *)createResponseString:(NSString *)status
                           withAds:(NSString *)ads
                      withMediated:(NSString *)mediated;

+ (NSString *)createAdsString:(NSString *)type
                    withWidth:(int)width
                   withHeight:(int)height
                  withContent:(NSString *)content;

+ (NSString *)createMediatedString:(NSString *)type
                     withClassName:(NSString *)className
                         withParam:(NSString *)param
                         withWidth:(int)width
                        withHeight:(int)height
                            withID:(NSString *)idString
                      withResultCB:(NSString *)resultCB;

@end
