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

@interface ANAdResponse ()
@end

@implementation ANAdResponse
@synthesize successful = __successful;
@synthesize error = __error;
@synthesize adView = __adView;

+ (ANAdResponse *)adResponseSuccessfulWithView:(UIView *)view
{
    ANAdResponse *response = [[[self class] alloc] init];
    response.successful = YES;
    response.adView = view;
    response.error = nil;
    
    return response;
}

+ (ANAdResponse *)adResponseFailWithError:(NSError *)error
{
    ANAdResponse *response = [[[self class] alloc] init];
    response.successful = NO;
    response.adView = nil;
    response.error = error;
    
    return response;
}

@end
