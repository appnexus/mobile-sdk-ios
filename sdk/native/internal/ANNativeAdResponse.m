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

#import "ANNativeAdResponse.h"
#import "ANLogging.h"
#import "UIView+ANNativeAdCategory.h"

@interface ANNativeAdResponse ()

@property (nonatomic, readwrite, strong) UIView *viewForTracking;

- (void)unregisterViewFromTracking;

@end

@implementation ANNativeAdResponse

- (BOOL)registerViewForTracking:(UIView *)view
         withRootViewController:(UIViewController *)controller
                 clickableViews:(NSArray *)clickableViews
                          error:(NSError **)error {
    // Abstract
    return NO;
}

- (void)unregisterViewFromTracking {
    // Abstract
}

@end