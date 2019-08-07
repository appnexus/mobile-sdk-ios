/*   Copyright 2016 APPNEXUS INC
 
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

#import "ANStoreProductViewController.h"

@interface ANStoreProductViewController () <SKStoreProductViewControllerDelegate>

@end

@implementation ANStoreProductViewController

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [self dismissViewControllerAnimated:YES
                             completion:^{
        
    }];
}

// Fix for iOS 7+ devices locked to landscape
- (BOOL)shouldAutorotate {
    if ([[UIDevice currentDevice].systemVersion compare:@"7.0"] != NSOrderedAscending) {
        return NO;
    } else {
        return [super shouldAutorotate];
    }
}

- (void)setDelegate:(id<SKStoreProductViewControllerDelegate>)delegate {
    if (delegate == nil) {
        // Allows dismissal of SKStoreProductViewController even if owner has been deallocated
        [super setDelegate:self];
    } else {
        [super setDelegate:delegate];
    }
}

@end