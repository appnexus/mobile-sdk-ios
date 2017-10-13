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

#import "ANVideoAdProcessor.h"
#import "NSDictionary+ANCategory.h"
#import "ANRTBVideoAd.h"
#import "ANAdConstants.h"

@interface ANVideoAdProcessor()
    @property (nonatomic, readwrite, strong) id<ANVideoAdProcessorDelegate> delegate;
    @property (nonatomic, strong)   NSString        *csmJsonContent;
    @property (nonatomic, strong)   NSString        *videoXmlContent;
    @property (nonatomic, strong)   NSString        *videoURLString;
    @property  (nonatomic, strong)  ANVideoAdPlayer *adPlayer;
@end

@implementation ANVideoAdProcessor

- (instancetype)initWithDelegate:(id<ANVideoAdProcessorDelegate>)delegate withAdVideoContent:(id) videoAdContent{
    
    
    if (self = [self init]) {
        self.delegate = delegate;
        
        if([videoAdContent isKindOfClass:[ANCSMVideoAd class]]){
        
           ANCSMVideoAd *csmVideoAd = (ANCSMVideoAd *)videoAdContent;
           self.csmJsonContent = [csmVideoAd.adDictionary an_jsonStringWithPrettyPrint:YES];
        
        }else if ([videoAdContent isKindOfClass:[ANRTBVideoAd class]]){
        
            ANRTBVideoAd *rtbVideo = (ANRTBVideoAd *) videoAdContent;
            if(rtbVideo.content.length >0){
                self.videoXmlContent = rtbVideo.content;
            }else if(rtbVideo.content.length >0){
                self.videoURLString = rtbVideo.assetURL;
            }else{
                ANLogError(@"RTBVideo content & url are empty");
            }
        }
        
        [self processAdVideoContent];
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


#pragma mark ANVideoAdPlayerDelegate methods

-(void) videoAdReady {
    
    [self.adPlayer setDelegate:nil];
    
    if([self.delegate respondsToSelector:@selector(videoAdProcessor:didFinishVideoProcessing:)]){
        [self.delegate videoAdProcessor:self didFinishVideoProcessing:self.adPlayer];
    }else {
        ANLogError(@"no delegate subscription found");
    }
    
    
}
-(void) videoAdLoadFailed:(NSError *)error{
    
    [self.adPlayer setDelegate:nil];
    
    if([self.delegate respondsToSelector:@selector(videoAdProcessor:didFailVideoProcessing:)]){
        NSError *error = ANError(@"Error parsing video tag", ANAdResponseInternalError);
        [self.delegate videoAdProcessor:self didFailVideoProcessing:error];
    }else {
        ANLogError(@"no delegate subscription found");
    }
    
}



@end
