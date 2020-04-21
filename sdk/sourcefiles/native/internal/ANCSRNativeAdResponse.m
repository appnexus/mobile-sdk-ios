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

#import "ANCSRNativeAdResponse.h"
#import "ANTrackerManager.h"
#import "ANOMIDImplementation.h"
#import "ANNativeAdResponse+PrivateMethods.h"



@interface ANCSRNativeAdResponse ()
@property (nonatomic, readwrite, strong) NSArray<NSString *> *impTrackers;
@property (nonatomic, readwrite, strong) NSArray<NSString *> *clickUrls;
@property (nonatomic, readwrite) BOOL impressionsHaveBeenTracked;
@property (nonatomic, readwrite) BOOL clickUrlsHaveBeenTracked;

@end

@implementation ANCSRNativeAdResponse

-(void)registerOMID {
    [super registerOMID];
}

#pragma mark - Tracking
- (void)fireImpTrackers {
    if (self.impTrackers && !self.impressionsHaveBeenTracked) {
        [ANTrackerManager fireTrackerURLArray:self.impTrackers];
    }
    if(self.omidAdSession != nil){
        [[ANOMIDImplementation sharedInstance] fireOMIDImpressionOccuredEvent:self.omidAdSession];
    }
    self.impressionsHaveBeenTracked = YES;
}

- (void)adWasClicked{
    [super adWasClicked];
    if (self.clickUrls && !self.clickUrlsHaveBeenTracked) {
        [ANTrackerManager fireTrackerURLArray:self.clickUrls];
    }
    self.clickUrlsHaveBeenTracked = YES;
}

@end
