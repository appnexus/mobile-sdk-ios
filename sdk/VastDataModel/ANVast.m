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

@interface ANVast ()

@property (nonatomic) NSString *version;
@property (nonatomic) NSString *AdId;
@property (nonatomic) ANInLine *anInLine;
@property (nonatomic) NSMutableArray *anWrappers;
@property (nonatomic) NSURL *mediaFileURL;

@end

@implementation ANVast
{
    dispatch_semaphore_t waitForVastParsingCompletion;
    int releaseCounter;
}

- (instancetype)initWithContent:(NSString *)vast {
    if (self = [super init]) {
        NSError *error;
        [self parseVastResponse:vast
                          error:&error];
        if (error) {
            ANLogDebug(@"Error parsing VAST response: %@", error);
            return nil;
        }
        if (!self.anInLine) {
            ANLogDebug(@"No linear ad found in VAST content, unable to use");
            return nil;
        }
        self.mediaFileURL = [self optimalMediaFileURL];
        if (!self.mediaFileURL) {
            ANLogDebug(@"No valid media URL found in VAST content, unable to use");
            return nil;
        }
    }
    return self;
}

- (BOOL)parseVastResponse:(NSString *)response
                    error:(NSError **)error {
    ANXML *xml = [ANXML newANXMLWithXMLString:response
                                        error:error];
    BOOL errorOcurred = (*error != nil);
    if (!errorOcurred) {
        waitForVastParsingCompletion = dispatch_semaphore_create(0);
        releaseCounter = 0;
        [self parseRootElement:xml.rootXMLElement];
        long result = dispatch_semaphore_wait(waitForVastParsingCompletion, dispatch_time(DISPATCH_TIME_NOW,
                                                                            kAppNexusMediationNetworkTimeoutInterval * NSEC_PER_SEC));
        if (result != 0) {
            ANLogDebug(@"Timeout reached while parsing VAST");
            errorOcurred = YES;
            *error = ANError(@"Timeout reached while parsing VAST", ANAdResponseNetworkError);
        }
    }
    return errorOcurred;
}

- (void)parseResponseWithURL:(NSURL *)xmlURL {
    [ANXML newANXMLWithURL:xmlURL
                   success:^(ANXML *tbxml) {
        [self parseRootElement:tbxml.rootXMLElement];
    }
                   failure:^(ANXML *tbxml, NSError *error) {
        ANLogError(@"XML Error: %@", error.localizedDescription);
    }];
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

                    ANWrapper *wrapper = [[ANWrapper alloc] initWithXMLElement:wrapperElement];

                    if (wrapper) {
                        
                        if (wrapper.vastAdTagURI) {
                            
                            if (!self.anWrappers) {
                                //initialize wrapper array if not alreay done.
                                self.anWrappers = [NSMutableArray array];
                            }
                            
                            //wrappers can get into infinite loop. there should be a system to break out of the infinite loop.
                            __block BOOL isVastTagURIAlreadyExists = NO;
                            
                            [self.anWrappers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                ANWrapper *anWrapper = (ANWrapper *)obj;
                                if ([anWrapper.vastAdTagURI isEqualToString:wrapper.vastAdTagURI]) {
                                    isVastTagURIAlreadyExists = YES;
                                    *stop = YES;
                                }
                            }];

                            if (!isVastTagURIAlreadyExists) {
                                [self.anWrappers addObject:wrapper];
                                NSURL *vastURL = [NSURL URLWithString:wrapper.vastAdTagURI];
                                releaseCounter++;
                                [self parseResponseWithURL:vastURL];
                            }
                        }
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

- (NSURL *)optimalMediaFileURL {
    ANInLine *inLine = (self.anInLine)?self.anInLine:[self.anWrappers lastObject]; //last object will be the valid inline element
    NSString *fileURI = @"";
    for (ANCreative *creative in inLine.creatives) {
        // SDK only supports linear
        if (!creative.anLinear) {
            continue;
        }
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
