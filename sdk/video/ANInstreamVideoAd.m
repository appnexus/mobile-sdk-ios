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

#import "ANInstreamVideoAd.h"
#import "ANVideoAdPlayer.h"
#import "ANUniversalAdFetcher.h"
#import "ANLogging.h"
#import "ANAdView+PrivateMethods.h"




//---------------------------------------------------------- -o--
NSString * const  exceptionCategoryAPIUsageErr  = @"API usage err.";




//---------------------------------------------------------- -o--
@interface  ANInstreamVideoAd()  <ANVideoAdPlayerDelegate, ANUniversalAdFetcherFoundationDelegate, ANAdProtocol>

@property  (weak, nonatomic, readwrite)  id<ANInstreamVideoAdLoadDelegate>  loadDelegate;
@property  (weak, nonatomic, readwrite)  id<ANInstreamVideoAdPlayDelegate>  playDelegate;

@property (nonatomic, strong)  ANVideoAdPlayer  *adPlayer;
@property (nonatomic, strong)  UIView           *adContainer;

//
@property (strong, nonatomic, readwrite)  NSString  *descriptionOfFailure;
@property (strong, nonatomic, readwrite)  NSError   *failureNSError;

@property (nonatomic)  BOOL  didUserSkipAd;
@property (nonatomic)  BOOL  didUserClickAd;
@property (nonatomic)  BOOL  isAdMuted;
@property (nonatomic)  BOOL  isVideoTagReady;
@property (nonatomic)  BOOL  didVideoTagFail;
@property (nonatomic)  BOOL  isAdPlaying;

//
@property (nonatomic, strong)  NSMutableSet<NSValue *>  *allowedAdSizes;

@end




//---------------------------------------------------------- -o--
@implementation ANInstreamVideoAd

@synthesize  customKeywords  = __customKeywords;

@synthesize minDuration = __minDuration;

@synthesize maxDuration = __maxDuration;


#pragma mark - Lifecycle.

//--------------------- -o-
- (id) initWithPlacementId: (NSString *)placementId
{
    self = [super init];
    if (!self)  { return nil; }
    
    //
    self.isAdPlaying      = NO;
    self.didUserSkipAd    = NO;
    self.didUserClickAd   = NO;
    self.isAdMuted        = NO;
    self.isVideoTagReady  = NO;
    self.didVideoTagFail  = NO;
    
    self.landingPageLoadsInBackground = YES;
    self.opensInNativeBrowser = NO;
    
    self.placementId = placementId;
    
    
    self.universalAdFetcher = [[ANUniversalAdFetcher alloc] initWithDelegate:self];
    
    [self setupSizeParametersAs1x1];
    
    
    //
    return self;
}

- (void) setupSizeParametersAs1x1
{
    self.allowedAdSizes     = [NSMutableSet setWithObject:[NSValue valueWithCGSize:kANAdSize1x1]];
    self.allowSmallerSizes  = NO;
}




//---------------------------------------------------------- -o--
#pragma mark - Instance methods.

//--------------------- -o-
- (BOOL) loadAdWithDelegate: (id<ANInstreamVideoAdLoadDelegate>)loadDelegate;
{
    if (! loadDelegate) {
        ANLogWarn(@"loadDelegate is UNDEFINED.  ANInstreamVideoAdLoadDelegate allows detection of when a video ad is successfully received and loaded.");
    }
    
    self.loadDelegate = loadDelegate;
    
    if(self.universalAdFetcher != nil){
        
        [self.universalAdFetcher requestAd];
        
    } else {
        ANLogError(@"FAILED TO FETCH video ad.");
        return  NO;
    }
    
    return  YES;
}


//--------------------- -o-
- (void) playAdWithContainer: (UIView *)adContainer
                withDelegate: (id<ANInstreamVideoAdPlayDelegate>)playDelegate;
{
    if (!playDelegate) {
        ANLogError(@"playDelegate is UNDEFINED.  ANInstreamVideoAdPlayDelegate allows the lifecycle of a video ad to be tracked, including when the video ad is completed.");
        return;
    }
    
    self.playDelegate = playDelegate;
    
    [self.adPlayer playAdWithContainer:adContainer];
}


//--------------------- -o-
- (void) removeAd
{
    if(self.adPlayer != nil){
        [self.adPlayer removePlayer];
        [self.adPlayer removeFromSuperview];
        self.adPlayer = nil;
    }
}

-(NSUInteger) getAdDuration {
    return [self.adPlayer getAdDuration];
}

- (NSString *) getCreativeURL{
    return [self.adPlayer getCreativeURL];
}

- (NSString *) getVastURL {
    return [self.adPlayer getVASTURL];
}

- (NSString *) getVastXML {
    return [self.adPlayer getVASTXML];
}

- (NSUInteger) getAdPlayElapsedTime {
    return [self.adPlayer getAdPlayElapsedTime];
}



//---------------------------------------------------------- -o--
#pragma mark - ANVideoAdPlayerDelegate.

//--------------------- -o-
-(void) videoAdReady
{
    self.isVideoTagReady = YES;
    
    if ([self.loadDelegate respondsToSelector:@selector(adDidReceiveAd:)]) {
        [self.loadDelegate adDidReceiveAd:self];
    }
}


//--------------------- -o-
-(void) videoAdLoadFailed:(NSError *)error
{
    self.didVideoTagFail = YES;
    
    self.descriptionOfFailure  = nil;
    self.failureNSError        = error;
    
    ANLogError(@"Delegate indicates FAILURE.");
    [self removeAd];
    
    if ([self.loadDelegate respondsToSelector:@selector(ad:requestFailedWithError:)]) {
        [self.loadDelegate ad:self requestFailedWithError:self.failureNSError];
    }
}


//--------------------- -o-
-(void) videoAdPlayFailed:(NSError *)error
{
    self.didVideoTagFail = YES;
    
    if ([self.playDelegate respondsToSelector:@selector(adDidComplete:withState:)])  {
        [self.playDelegate adDidComplete:self withState:ANInstreamVideoPlaybackStateError];
    }
    
    [self removeAd];
}


//--------------------- -o-
- (void) videoAdError:(NSError *)error
{
    self.descriptionOfFailure  = nil;
    self.failureNSError        = error;
    
    if ([self.playDelegate respondsToSelector:@selector(adDidComplete:withState:)]) {
        [self.playDelegate adDidComplete:self withState:ANInstreamVideoPlaybackStateError];
    }
}


//--------------------- -o-
- (void) videoAdWillPresent:(ANVideoAdPlayer *)videoAd
{
    if ([self.playDelegate respondsToSelector:@selector(adWillPresent:)]) {
        [self.playDelegate adWillPresent:self];
    }
}


//--------------------- -o-
- (void) videoAdDidPresent:(ANVideoAdPlayer *)videoAd
{
    if ([self.playDelegate respondsToSelector:@selector(adDidPresent:)]) {
        [self.playDelegate adDidPresent:self];
    }
}


//--------------------- -o-
- (void) videoAdWillClose:(ANVideoAdPlayer *)videoAd
{
    if ([self.playDelegate respondsToSelector:@selector(adWillClose:)]) {
        [self.playDelegate adWillClose:self];
    }
}


//--------------------- -o-
- (void) videoAdDidClose:(ANVideoAdPlayer *)videoAd
{
    if ([self.playDelegate respondsToSelector:@selector(adDidClose:)]) {
        [self removeAd];
        [self.playDelegate adDidClose:self];
    }
}


//--------------------- -o-
- (void) videoAdWillLeaveApplication:(ANVideoAdPlayer *)videoAd
{
    if ([self.playDelegate respondsToSelector:@selector(adWillLeaveApplication:)])  {
        [self.playDelegate adWillLeaveApplication:self];
    }
}


//--------------------- -o-
-(void) videoAdImpressionListeners:(ANVideoAdPlayerTracker)tracker
{
    switch (tracker) {
        case ANVideoAdPlayerTrackerFirstQuartile:
            if ([self.playDelegate respondsToSelector:@selector(adCompletedFirstQuartile:)]) {
                [self.playDelegate adCompletedFirstQuartile:self];
            }
            break;
        case ANVideoAdPlayerTrackerMidQuartile:
            if ([self.playDelegate respondsToSelector:@selector(adCompletedMidQuartile:)]) {
                [self.playDelegate adCompletedMidQuartile:self];
            }
            break;
        case ANVideoAdPlayerTrackerThirdQuartile:
            if ([self.playDelegate respondsToSelector:@selector(adCompletedThirdQuartile:)]) {
                [self.playDelegate adCompletedThirdQuartile:self];
            }
            break;
        case ANVideoAdPlayerTrackerFourthQuartile:
            if ([self.playDelegate respondsToSelector:@selector(adDidComplete:withState:)]) {
                [self removeAd];
                [self.playDelegate adDidComplete:self withState:ANInstreamVideoPlaybackStateCompleted];
            }
            break;
        default:
            break;
    }
}


//--------------------- -o-
-(void) videoAdEventListeners:(ANVideoAdPlayerEvent)eventTrackers
{
    switch (eventTrackers) {
        case ANVideoAdPlayerEventPlay:
            self.isAdPlaying = YES;
            if ([self.playDelegate respondsToSelector:@selector(adPlayStarted:)])  {
                [self.playDelegate adPlayStarted:self];
            }
            break;
        case ANVideoAdPlayerEventSkip:
            self.didUserSkipAd = YES;
            
            if([self.playDelegate respondsToSelector:@selector(adDidComplete:withState:)]){
                [self.playDelegate adDidComplete:self withState:ANInstreamVideoPlaybackStateSkipped];
            }
            break;
            
        case ANVideoAdPlayerEventClick:
            self.didUserClickAd = YES;
            
            if ([self.playDelegate respondsToSelector:@selector(adWasClicked:)])  {
                [self.playDelegate adWasClicked:self];
            }
            break;
        case ANVideoAdPlayerEventMuteOn:
            self.isAdMuted = YES;
            
            if ([self.playDelegate respondsToSelector:@selector(adMute:withStatus:)])  {
                [self.playDelegate adMute:self withStatus:self.isAdMuted];
            }
            break;
        case ANVideoAdPlayerEventMuteOff:
            self.isAdMuted = NO;
            
            if ([self.playDelegate respondsToSelector:@selector(adMute:withStatus:)])  {
                [self.playDelegate adMute:self withStatus:self.isAdMuted];
            }
            break;
        default:
            break;
    }
}


//--------------------- -o-
- (BOOL) videoAdPlayerOpensInNativeBrowser  {
    return  self.opensInNativeBrowser;
}


//--------------------- -o-
- (BOOL) videoAdPlayerLandingPageLoadsInBackground  {
    return  self.landingPageLoadsInBackground;
}


//---------------------------------------------------------- -o--
#pragma mark - ANUniversalAdFetcherDelegate.

//--------------------- -o-
- (void)       universalAdFetcher: (ANUniversalAdFetcher *)fetcher
     didFinishRequestWithResponse: (ANAdFetcherResponse *)response
{
    if ([response.adObject isKindOfClass:[ANVideoAdPlayer class]]) {
        self.adPlayer = (ANVideoAdPlayer *) response.adObject;
        self.adPlayer.delegate = self;
        
        NSString *creativeId = (NSString *) [ANGlobal valueOfGetterProperty:@"creativeId" forObject:response.adObjectHandler];
        if(creativeId){
               [self setCreativeId:creativeId];
        }
        
        [self videoAdReady];
        
        
        
    }else if(!response.isSuccessful && (response.adObject == nil)){
        [self videoAdLoadFailed:ANError(@"video_adfetch_failed", ANAdResponseBadFormat)];
        return;
    }
}

- (NSArray<NSValue *> *)adAllowedMediaTypes
{
    ANLogTrace(@"");
    return  @[ @(ANAllowedMediaTypeVideo) ];
    
}

- (NSDictionary *) internalDelegateUniversalTagSizeParameters
{
    NSMutableDictionary  *delegateReturnDictionary  = [[NSMutableDictionary alloc] init];
    [delegateReturnDictionary setObject:[NSValue valueWithCGSize:kANAdSize1x1]  forKey:ANInternalDelgateTagKeyPrimarySize];
    [delegateReturnDictionary setObject:self.allowedAdSizes                     forKey:ANInternalDelegateTagKeySizes];
    [delegateReturnDictionary setObject:@(self.allowSmallerSizes)               forKey:ANInternalDelegateTagKeyAllowSmallerSizes];
    
    return  delegateReturnDictionary;
}

- (ANVideoAdSubtype) videoAdTypeForAdFetcher:(ANUniversalAdFetcher *)fetcher {
    return  ANVideoAdSubtypeInstream;
}



//---------------------------------------------------------- -o--
#pragma mark - ANAdProtocol.

/** Set the user's current location.  This allows ad buyers to do location targeting, which can increase spend.
 */
- (void)setLocationWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude
                      timestamp:(NSDate *)timestamp horizontalAccuracy:(CGFloat)horizontalAccuracy {
    self.location = [ANLocation getLocationWithLatitude:latitude
                                              longitude:longitude
                                              timestamp:timestamp
                                     horizontalAccuracy:horizontalAccuracy];
}

/** Set the user's current location rounded to the number of decimal places specified in "precision".
 Valid values are between 0 and 6 inclusive. If the precision is -1, no rounding will occur.
 */
- (void)setLocationWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude
                      timestamp:(NSDate *)timestamp horizontalAccuracy:(CGFloat)horizontalAccuracy
                      precision:(NSInteger)precision {
    self.location = [ANLocation getLocationWithLatitude:latitude
                                              longitude:longitude
                                              timestamp:timestamp
                                     horizontalAccuracy:horizontalAccuracy
                                              precision:precision];
}


/**
 Set the inventory code and member id for the place that ads will be shown.
 */
@synthesize  memberId       = _memberId;
@synthesize  inventoryCode  = _inventoryCode;

- (void)setInventoryCode: (NSString *)inventoryCode
                memberId: (NSInteger)memberID
{
    if (inventoryCode && (inventoryCode != _inventoryCode)) {
        ANLogDebug(@"Setting inventory code to %@", inventoryCode);
        _inventoryCode = inventoryCode;
    }
    if ( (memberID > 0) && (memberID != _memberId) ) {
        ANLogDebug(@"Setting member id to %d", (int) memberID);
        _memberId = memberID;
    }
}



@end

