/*   Copyright 2017 APPNEXUS INC
 
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

#import "ANResponseURL.h"
#import "ANLogging.h"
#import "ANGlobal.h"
#import "NSString+ANCategory.h"

@implementation ANResponseURL


+ (ANResponseURL *)initWithURL:(NSString *)baseUrl
                    reasonCode:(int)reasonCode
                       latency:(NSTimeInterval)latency
                 totoalLatency:(NSTimeInterval) totalLatency{
    
    ANLogMark();
    ANResponseURL *anResponseURL = [[ANResponseURL alloc] init];
    
    if ([baseUrl length] < 1) {
        return nil;
    }
    
    // append reason code
    NSString *urlString = [baseUrl an_stringByAppendingUrlParameter: @"reason"
                                                              value: [NSString stringWithFormat:@"%d",reasonCode]];
    
    // append idfa
    urlString = [urlString an_stringByAppendingUrlParameter: @"idfa"
                                                      value: ANUDID()];
    
    if (latency > 0) {
        urlString = [urlString an_stringByAppendingUrlParameter: @"latency"
                                                          value: [NSString stringWithFormat:@"%.0f", latency]];
    }
    if (totalLatency > 0) {
        urlString = [urlString an_stringByAppendingUrlParameter: @"total_latency"
                                                         value :[NSString stringWithFormat:@"%.0f", totalLatency]];
    }
    
    ANLogMarkMessage(@"responseURLString=%@", urlString);
    
    anResponseURL.responseURL = [NSURL URLWithString:urlString];
    return anResponseURL;
    
}



// Need to update so that the request is performed in background queue. + there also is retry if failure
- (void) performRequest{
    if(self.responseURL){
        ANLogDebug(@"(response_url, %@)", self.responseURL);
        
        
        
        NSURLSessionDataTask  *dataTask =
        [[NSURLSession sharedSession] dataTaskWithRequest: ANBasicRequestWithURL(self.responseURL)
                                        completionHandler: ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                            ANLogMarkMessage(@"\nRespons URL Fired\tdata=%@ \n\tresponse=%@ \n\terror=%@", data, response, error);   //DEBUG
                                            // TODO  Retry if Failure.
                                        }];
        [dataTask resume];
    }
    
}


@end
