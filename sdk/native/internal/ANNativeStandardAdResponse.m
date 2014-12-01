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

#import "ANNativeStandardAdResponse.h"

@interface ANNativeStandardAdResponse()

@property (nonatomic, readwrite, strong) NSDate *dateCreated;
@property (nonatomic, readwrite, assign) ANNativeAdNetworkCode networkCode;
@property (nonatomic, readwrite, assign, getter=hasExpired) BOOL expired;

@end

@implementation ANNativeStandardAdResponse

@synthesize title = _title;
@synthesize body = _body;
@synthesize callToAction = _callToAction;
@synthesize rating = _rating;
@synthesize mainImage = _mainImage;
@synthesize mainImageURL = _mainImageURL;
@synthesize iconImage = _iconImage;
@synthesize iconImageURL = _iconImageURL;
@synthesize socialContext = _socialContext;
@synthesize customElements = _customElements;
@synthesize networkCode = _networkCode;
@synthesize expired = _expired;

- (instancetype)init {
    if (self = [super init]) {
        _networkCode = ANNativeAdNetworkCodeAppNexus;
        _dateCreated = [NSDate date];
    }
    return self;
}

@end