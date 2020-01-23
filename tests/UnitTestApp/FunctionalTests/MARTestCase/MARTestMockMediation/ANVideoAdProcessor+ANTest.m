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

#import "ANVideoAdProcessor+ANTest.h"
#import "NSDictionary+ANCategory.h"
#import "ANRTBVideoAd.h"
#import "ANAdConstants.h"

@implementation ANVideoAdProcessor (ANTest)

@dynamic delegate;
@dynamic csmJsonContent;
@dynamic videoXmlContent;
@dynamic videoURLString;
@dynamic adPlayer;
- (nonnull instancetype)initWithDelegate:(nonnull id<ANVideoAdProcessorDelegate>)delegate withAdVideoContent:(nonnull id) videoAdContent{
    
    if (self = [self init]) {
        self.delegate = delegate;
        
        if([videoAdContent isKindOfClass:[ANCSMVideoAd class]]){

            self.adPlayer = [[ANVideoAdPlayer alloc] init];
                  if([self.delegate respondsToSelector:@selector(videoAdProcessor:didFinishVideoProcessing:)]){
                      [self.delegate videoAdProcessor:self didFinishVideoProcessing:self.adPlayer];
                  }else {
                      ANLogError(@"no delegate subscription found");
                  }
            
            
        }else if ([videoAdContent isKindOfClass:[ANRTBVideoAd class]]){
            
            ANRTBVideoAd *rtbVideo = (ANRTBVideoAd *) videoAdContent;
            if(rtbVideo.content.length >0){
                self.videoXmlContent = rtbVideo.content;
            }else if(rtbVideo.content.length >0){
                self.videoURLString = rtbVideo.assetURL;
            }else{
                ANLogError(@"RTBVideo content & url are empty");
            }
            [self processAdVideoContent];
        }
        
      
    }
    return self;
}

-(void) processAdVideoContent{
    
    self.adPlayer = [[ANVideoAdPlayer alloc] init];
    if(self.adPlayer != nil){
        self.adPlayer.delegate = self;
        if(self.videoURLString){
            [self.adPlayer loadAdWithVastUrl:self.videoURLString];
        }else if(self.videoXmlContent){
            [self.adPlayer loadAdWithVastContent:self.videoXmlContent];
        }else if(self.csmJsonContent){
            [self.adPlayer loadAdWithJSONContent:self.csmJsonContent];
        }else {
            ANLogError(@"no csm or rtb object content available to process");
        }
    } else {
        ANLogError(@"AdPlayer creation failed");
    }
    
}


@end
