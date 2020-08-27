/*   Copyright 2020 APPNEXUS INC
 
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

#import "ANSSMMediationAdViewController+ANTest.h"



@implementation ANSSMMediationAdViewController (ANTest)

#pragma mark - Lifecycle.


- (BOOL)requestForAd:(ANSSMStandardAd *)ad {
    // variables to pass into the failure handler if necessary
    NSString *errorInfo = nil;
    ANAdResponseCode *errorCode = ANAdResponseCode.DEFAULT;
    
    // check that the ad is non-nil
    if ((!ad) || (!ad.urlString)) {
        errorInfo = @"null mediated ad object";
        errorCode = ANAdResponseCode.UNABLE_TO_FILL;
        [self handleFailure:errorCode errorInfo:errorInfo];
        return NO;
    }else{
        if([ad.urlString containsString:@"https://donothing.adnxs.com"]){
            // ANAdMediationTimeoutTestCase is using this for SSM Timeout testing
            self.ssmMediatedAd = ad;
            [self startTimeout];
        }else {
            NSString *filepath = [[NSBundle mainBundle] pathForResource:@"ssmAd" ofType:@"txt"];
            NSError *error;
            NSString *fileContents = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:&error];
            
            if (error)
                NSLog(@"Error reading file: %@", error.localizedDescription);
            
            // maybe for debugging...
            NSLog(@"contents: %@", fileContents);
            
            
            [self didReceiveAd:fileContents];
        }
    }
    return true;
}

@end
