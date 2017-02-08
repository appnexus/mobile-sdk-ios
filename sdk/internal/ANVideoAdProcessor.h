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

#import <Foundation/Foundation.h>
#import "ANLogging.h"
#import "ANCSMVideoAd.h"
#import "ANGlobal.h"
#import "ANVideoAdPlayer.h"


@protocol ANVideoAdProcessorDelegate;

@interface ANVideoAdProcessor : NSObject<ANVideoAdPlayerDelegate>

- (instancetype)initWithDelegate:(id<ANVideoAdProcessorDelegate>)delegate withAdVideoContent:(id) videoAdContent;

@end


@protocol  ANVideoAdProcessorDelegate<NSObject>

    - (void) videoAdProcessor:(ANVideoAdProcessor *)videoAdProcessor didFinishVideoProcessing: (ANVideoAdPlayer *)adVideoPlayer;
    - (void) videoAdProcessor:(ANVideoAdProcessor *)videoAdProcessor didFailVideoProcessing: (NSError *)error;

@end
