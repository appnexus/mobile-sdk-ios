/* Copyright 2015 APPNEXUS INC
 
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


#import "ANVast.h"
#import "ANXML+HTTP.h"
#import "ANXML.h"
#import "ANLogging.h"
#import "ANReachability.h"

NSString *const kANVideoSupportedFormats = @"video/mp4"; //,video/x-flv";
NSString *const kANVideoBitrateCapOverWAN = @"1200"; //this should be set to 460, temporarily been set to 1200 to enable ad display

@implementation ANVast

static NSString *XML_URL = @"http://oasc-training7.247realmedia.com/2/VastVideoAd.com/@Bottom";
static ANVast *sharedInstance;
static dispatch_semaphore_t waitForVastParsingCompletion;
static int releaseCounter;

- (void) parseResponseWithURL:(NSURL *)xmlURL error:(NSError *__autoreleasing *)error{
    
    NSURL *url = xmlURL?xmlURL:[NSURL URLWithString:XML_URL];
    
    ANXML *xmlParser = [ANXML newANXMLWithURL:url success:^(ANXML *tbxml) {
        [self parseRootElement:tbxml.rootXMLElement];
    } failure:^(ANXML *tbxml, NSError *error) {
        NSLog(@"XML Error: %@", error.localizedDescription);
    }];

    //mark for release - the unused object
    xmlParser = nil;
}

- (void)parseVastResponseWithURL:(NSURL *)xmlURL error:(NSError *__autoreleasing *)error{
    waitForVastParsingCompletion = dispatch_semaphore_create(0);
    
    releaseCounter = 0;
    [self parseResponseWithURL:xmlURL error:error];
    
    dispatch_semaphore_wait(waitForVastParsingCompletion, dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC));
    
}

- (void) parseRootElement:(ANXMLElement *)rootElement{

    if (rootElement) {
        
        NSString *version = [ANXML valueOfAttributeNamed:@"version" forElement:rootElement];
        if (version) {
            [self setVersion:version];
        }
        
        ANXMLElement *ad = [ANXML childElementNamed:@"Ad" parentElement:rootElement];
        
        while(ad){
            
            NSString *adId = [ANXML valueOfAttributeNamed:@"id" forElement:ad];
            
            if (adId) {
                [self setAdId:adId];
            }
            
            ANXMLElement *inlineElement = [ANXML childElementNamed:@"InLine" parentElement:ad];
            if (inlineElement) {
                self.anInLine = [[ANInLine alloc] initWithXMLElement:inlineElement];
            }else{
                ANXMLElement *wrapperElement = [ANXML childElementNamed:@"Wrapper" parentElement:ad];
                if (wrapperElement) {
                    self.anWrapper = [[ANWrapper alloc] initWithXMLElement:wrapperElement];
                    if (self.anWrapper.vastAdTagURI) {
                        NSURL *vastURL = [NSURL URLWithString:self.anWrapper.vastAdTagURI];
                        NSError *error = [[NSError alloc] init];
                        releaseCounter++;
                        [self parseResponseWithURL:vastURL error:&error];
                    }
                }
            }
            
            ad = [ANXML nextSiblingNamed:@"Ad" searchFromElement:ad];
        }
    }
    
    if (releaseCounter == 0) {
        dispatch_semaphore_signal(waitForVastParsingCompletion);
    }else{
        releaseCounter--;
    }
}

- (NSURL *) getMediaFileURL{
    ANInLine *inLine = (self.anInLine)?self.anInLine:self.anWrapper;
    NSString *fileURI = @"";
    for (ANCreative *creative in inLine.creatives) {
        
        //Sort array on bitRate = Ascending
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"bitRate" ascending:YES];
        NSArray *mediaFiles = [creative.anLinear.mediaFiles sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        
        //get mediafiles based on the supported file formats
        NSPredicate *predicateFileType = [NSPredicate predicateWithFormat:@"%@ beginswith fileType or %@ contains fileType", kANVideoSupportedFormats, [NSString stringWithFormat:@",%@", kANVideoSupportedFormats]];
        mediaFiles = [mediaFiles filteredArrayUsingPredicate:predicateFileType];
        
        //Now that we have a sorted array based on supported file formates, we need to now get mediafiles based on the screen size.
        mediaFiles = [self getPreferredMediaFileBasedOnSizeFromMediaFiles:mediaFiles];
        
        ANReachability *reachability = [ANReachability reachabilityForInternetConnection];
        ANNetworkStatus networkStatus = [reachability currentReachabilityStatus];
        
        if (networkStatus == ANNetworkStatusReachableViaWWAN) {
            NSPredicate *predicateBitRate = [NSPredicate predicateWithFormat:@"bitRate.intValue <= %d", [kANVideoBitrateCapOverWAN intValue]];
            NSArray *filteredArray = [mediaFiles filteredArrayUsingPredicate:predicateBitRate];
            
            if (filteredArray.count) {
                //pick the highest bit rate satisfying the WAN capping
                fileURI = ((ANMediaFile *)[filteredArray lastObject]).fileURI;
            }else{
                //NO files found satisfying the WAN Capping, so pick the next highest bitrate file.
                fileURI = ((ANMediaFile *)[mediaFiles firstObject]).fileURI;
            }
        }else if(networkStatus == ANNetworkStatusReachableViaWiFi){
            //pick the file with highest bit rate
            ANMediaFile *mediaFile = [mediaFiles lastObject];
            fileURI = mediaFile.fileURI;
        }else{
            //Log info for No Network Status.
            ANLogInfo(@"Network not available. Failed to run video.");
        }
    }
    
    NSURL *fileURL = [NSURL URLWithString:fileURI];
    
    return fileURL;
}

- (NSArray *) getPreferredMediaFileBasedOnSizeFromMediaFiles:(NSArray *)mediaFiles{
    CGRect screenBounds = ANPortraitScreenBounds();
    
    int iDividingFactor = 1;
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] == YES) {
        if ([[UIScreen mainScreen] scale] == 2) {
            iDividingFactor = 2;
        }else if([[UIScreen mainScreen] scale] == 3){
            iDividingFactor = 3;
        }
    }
    
    //since the bounds are in portrait mode, width <= height always. Hence reversed. Video size is in pixel. So no need to convert to points.
    NSPredicate *predicateSize = [NSPredicate predicateWithFormat:@"width.intValue >= %d AND height.intValue >= %d", iDividingFactor, screenBounds.size.height, iDividingFactor, screenBounds.size.width];
    NSArray *fileteredArray = [mediaFiles filteredArrayUsingPredicate:predicateSize];
    
    if (fileteredArray.count) {
        //Best match found for the screen size.
        return fileteredArray;
    }
    
    //No match found, return the original collection.
    return mediaFiles;
    
}

@end
