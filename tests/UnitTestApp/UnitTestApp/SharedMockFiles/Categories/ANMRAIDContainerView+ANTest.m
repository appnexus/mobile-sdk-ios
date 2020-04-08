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

#import "ANMRAIDContainerView+ANTest.h"
#import "ANOMIDImplementation.h"

static CGFloat const kANOMIDSessionFinishDelay = 3.0f;

@implementation ANMRAIDContainerView (ANTest)

-(void) willMoveToSuperview:(UIView *)newSuperview {
    if(!newSuperview){
        if(self.webViewController.omidAdSession){
            [[ANOMIDImplementation sharedInstance] stopOMIDAdSession:self.webViewController.omidAdSession];
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (kANOMIDSessionFinishDelay * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
                [super willMoveToSuperview:newSuperview];
                self.webViewController  = nil;
            });
        }else{
            self.webViewController  = nil;
        }
    }
    else{
        [super willMoveToSuperview:newSuperview];
    }
}

@end
