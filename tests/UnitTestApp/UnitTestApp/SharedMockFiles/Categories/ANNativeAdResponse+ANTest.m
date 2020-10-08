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

#import "ANNativeAdResponse+ANTest.h"
#import <objc/runtime.h>
#import "ANNativeAdResponse+PrivateMethods.h"
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wprotocol"
@implementation ANNativeAdResponse (ANTest)
#pragma clang diagnostic pop



-(void)registerAdAboutToExpire{
    
    [self setAboutToExpireTimeInterval];
    [self invalidateAdExpireTimer:self.adWillExpireTimer];
    
    self.adWillExpireTimer = [NSTimer scheduledTimerWithTimeInterval:10
                                                              target:self
                                                            selector:@selector(onAdAboutToExpire)
                                                            userInfo:nil
                                                             repeats:NO];
}

@end
