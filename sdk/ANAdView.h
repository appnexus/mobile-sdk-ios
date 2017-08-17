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


#import "ANAdProtocol.h"
#import "ANAdProtocolPrivate.h"
#import "ANUniversalAdFetcher.h"




@interface ANAdView : UIView <ANAdProtocol, ANAdProtocolPrivate>

@property (nonatomic, readwrite, strong) ANUniversalAdFetcher  *universalAdFetcher;


- (void) universalAdFetcher: (ANUniversalAdFetcher *)fetcher
                 adResponse: (ANAdFetcherResponse *)response;

- (void) fireTrackers: (NSArray<NSString *> *)trackerURLs;

@end
