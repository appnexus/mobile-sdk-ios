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
#import "ANAdFetcher.h"
#import "ANLogging.h"
#import "ANAdView+PrivateMethods.h"
#import "ANOMIDImplementation.h"
#import "ANMultiAdRequest+PrivateMethods.h"



//---------------------------------------------------------- -o--
NSString * const  exceptionCategoryAPIUsageErr  = @"API usage err.";




//---------------------------------------------------------- -o--
@interface  ANInstreamVideoAd()  <ANVideoAdPlayerDelegate, ANAdFetcherFoundationDelegate, ANAdProtocol>

@property  (weak, nonatomic, readwrite, nullable)  id<ANInstreamVideoAdPlayDelegate>  playDelegate;

@property (nonatomic, strong)  ANVideoAdPlayer  *adPlayer;
@property (nonatomic, strong)  UIView           *adContainer;

//
@property (strong, nonatomic, readwrite, nullable)  NSString  *descriptionOfFailure;
@property (strong, nonatomic, readwrite, nullable)  NSError   *failureNSError;

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

@synthesize  minDuration        = __minDuration;
@synthesize  maxDuration        = __maxDuration;



#pragma mark - Lifecycle.

//--------------------- -o-
- (instancetype) initFoundation
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

    self.clickThroughAction = ANClickThroughActionOpenSDKBrowser;
    self.landingPageLoadsInBackground = YES;
    
    self.adFetcher = [[ANAdFetcher alloc] initWithDelegate:self];
    
    [self setupSizeParametersAs1x1];
    [[ANOMIDImplementation sharedInstance] activateOMIDandCreatePartner];
    
    return self;
}

- (nonnull instancetype) initWithPlacementId: (nonnull NSString *)placementId
{
    self = [self initFoundation];
    if (!self)  { return nil; }

    //
    self.placementId = placementId;

    return  self;
}

- (nonnull instancetype) initWithMemberId:(NSInteger)memberId inventoryCode:(nonnull NSString *)inventoryCode
{
    self = [self initFoundation];
    if (!self)  { return nil; }

    //
    [self setInventoryCode:inventoryCode memberId:memberId];

    return  self;
}

- (void) setupSizeParametersAs1x1
{
    self.allowedAdSizes     = [NSMutableSet setWithObject:[NSValue valueWithCGSize:kANAdSize1x1]];
    self.allowSmallerSizes  = NO;
}




//---------------------------------------------------------- -o--
#pragma mark - Instance methods.

//--------------------- -o-
- (BOOL) loadAdWithDelegate: (nullable id<ANInstreamVideoAdLoadDelegate>)loadDelegate;
{
    if (! loadDelegate) {
        ANLogWarn(@"loadDelegate is UNDEFINED.  ANInstreamVideoAdLoadDelegate allows detection of when a video ad is successfully received and loaded.");
    }
    
    self.loadDelegate = loadDelegate;
    
    if(self.adFetcher != nil){
        
        [self.adFetcher requestAd];
        
    } else {
        ANLogError(@"FAILED TO FETCH video ad.");
        return  NO;
    }
    
    return  YES;
}


//--------------------- -o-
- (void) playAdWithContainer: (nonnull UIView *)adContainer
                withDelegate: (nullable id<ANInstreamVideoAdPlayDelegate>)playDelegate;
{
    if (!playDelegate) {
        ANLogError(@"playDelegate is UNDEFINED.  ANInstreamVideoAdPlayDelegate allows the lifecycle of a video ad to be tracked, including when the video ad is completed.");
        return;
    }
    
    self.playDelegate = playDelegate;
    
    [self.adPlayer playAdWithContainer:adContainer];
}


//--------------------- -o-
- (void) pauseAd
{
    if(self.adPlayer != nil){
        [self.adPlayer pauseAdVideo];
    }
        
}

- (void) resumeAd
{
    if(self.adPlayer != nil){
        [self.adPlayer resumeAdVideo];
    }
}

- (void) removeAd
{
    if(self.adPlayer != nil){
        [self.adPlayer removePlayer];
        [self.adPlayer removeFromSuperview];
        self.adPlayer.delegate = nil;
        self.adPlayer = nil;
    }
}

-(NSUInteger) getAdDuration {
    return [self.adPlayer getAdDuration];
}

- (nullable NSString *) getCreativeURL{
    return [self.adPlayer getCreativeURL];
}

- (nullable NSString *) getVastURL {
    return [self.adPlayer getVASTURL];
}

- (nullable NSString *) getVastXML {
    return [self.adPlayer getVASTXML];
}

- (ANVideoOrientation) getVideoOrientation {
    return [self.adPlayer getVideoOrientation];
}

- (NSUInteger) getAdPlayElapsedTime {
    return [self.adPlayer getAdPlayElapsedTime];
}



//---------------------------------------------------------- -o--
#pragma mark - ANVideoAdPlayerDelegate.

-(void) videoAdReady
{
    self.isVideoTagReady = YES;
    
    if ([self.loadDelegate respondsToSelector:@selector(adDidReceiveAd:)]) {
        [self.loadDelegate adDidReceiveAd:self];
    }
}

-(void) videoAdLoadFailed:(nonnull NSError *)error withAdResponseInfo:(ANAdResponseInfo *)adResponseInfo
{
    self.didVideoTagFail = YES;
    
    self.descriptionOfFailure  = nil;
    self.failureNSError        = error;
    
    [self setAdResponseInfo:adResponseInfo];

    ANLogError(@"Delegate indicates FAILURE.");
    [self removeAd];
    
    if ([self.loadDelegate respondsToSelector:@selector(ad:requestFailedWithError:)]) {
        [self.loadDelegate ad:self requestFailedWithError:self.failureNSError];
    }
}

-(void) videoAdPlayFailed:(NSError *)error
{
    self.didVideoTagFail = YES;
    
    if ([self.playDelegate respondsToSelector:@selector(adDidComplete:withState:)])  {
        [self.playDelegate adDidComplete:self withState:ANInstreamVideoPlaybackStateError];
    }
    
    [self removeAd];
}

- (void) videoAdError:(nonnull NSError *)error
{
    self.descriptionOfFailure  = nil;
    self.failureNSError        = error;
    
    if ([self.playDelegate respondsToSelector:@selector(adDidComplete:withState:)]) {
        [self.playDelegate adDidComplete:self withState:ANInstreamVideoPlaybackStateError];
    }
}


- (void) videoAdWillPresent:(nonnull ANVideoAdPlayer *)videoAd
{
    if ([self.playDelegate respondsToSelector:@selector(adWillPresent:)]) {
        [self.playDelegate adWillPresent:self];
    }
}

- (void) videoAdDidPresent:(nonnull ANVideoAdPlayer *)videoAd
{
    if ([self.playDelegate respondsToSelector:@selector(adDidPresent:)]) {
        [self.playDelegate adDidPresent:self];
    }
}


- (void) videoAdWillClose:(nonnull ANVideoAdPlayer *)videoAd
{
    if ([self.playDelegate respondsToSelector:@selector(adWillClose:)]) {
        [self.playDelegate adWillClose:self];
    }
}

- (void) videoAdDidClose:(nonnull ANVideoAdPlayer *)videoAd
{
    if ([self.playDelegate respondsToSelector:@selector(adDidClose:)]) {
        [self removeAd];
        [self.playDelegate adDidClose:self];
    }
}


- (void) videoAdWillLeaveApplication:(nonnull ANVideoAdPlayer *)videoAd
{
    if ([self.playDelegate respondsToSelector:@selector(adWillLeaveApplication:)])  {
        [self.playDelegate adWillLeaveApplication:self];
    }
}


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
               // [self removeAd];
                [self.playDelegate adDidComplete:self withState:ANInstreamVideoPlaybackStateCompleted];
            }
            break;
        default:
            break;
    }
}


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


- (void) videoAdWasClicked {
    self.didUserClickAd = YES;

    if ([self.playDelegate respondsToSelector:@selector(adWasClicked:)])  {
        [self.playDelegate adWasClicked:self];
    }
}

- (void) videoAdWasClickedWithURL:(nonnull NSString *)urlString {
    self.didUserClickAd = YES;

    if ([self.playDelegate respondsToSelector:@selector(adWasClicked:withURL:)])  {
        [self.playDelegate adWasClicked:self withURL:urlString];
    }
}

- (BOOL) videoAdPlayerLandingPageLoadsInBackground  {
    return  self.landingPageLoadsInBackground;
}

- (ANClickThroughAction) videoAdPlayerClickThroughAction {
    return  self.clickThroughAction;
}

- (void)addOpenMeasurementFriendlyObstruction:(nonnull UIView *)obstructionView{
    [super addOpenMeasurementFriendlyObstruction:obstructionView];
    [self setFriendlyObstruction];
}

- (void)setFriendlyObstruction
{
    if(self.adPlayer != nil && self.adPlayer.omidAdSession != nil){
        for (UIView *obstructionView in self.obstructionViews){
            [[ANOMIDImplementation sharedInstance] addFriendlyObstruction:obstructionView toOMIDAdSession:self.adPlayer.omidAdSession];
        }
    }
}

- (void)removeOpenMeasurementFriendlyObstruction:(UIView *)obstructionView{
    if( [self.obstructionViews containsObject:obstructionView]){
        [super removeOpenMeasurementFriendlyObstruction:obstructionView];
        if(self.adPlayer != nil && self.adPlayer.omidAdSession != nil){
            [[ANOMIDImplementation sharedInstance] removeFriendlyObstruction:obstructionView toOMIDAdSession:self.adPlayer.omidAdSession];
        }
    }
}

- (void)removeAllOpenMeasurementFriendlyObstructions{
        [super removeAllOpenMeasurementFriendlyObstructions];
        if(self.adPlayer != nil && self.adPlayer.omidAdSession != nil){
            [[ANOMIDImplementation sharedInstance] removeAllFriendlyObstructions:self.adPlayer.omidAdSession];
        }
}


//---------------------------------------------------------- -o--
#pragma mark - ANUniversalAdFetcherDelegate.

- (void)       adFetcher: (ANAdFetcher *)fetcher
     didFinishRequestWithResponse: (ANAdFetcherResponse *)response
{
    if ([response.adObject isKindOfClass:[ANVideoAdPlayer class]]) {
        self.adPlayer = (ANVideoAdPlayer *) response.adObject;
        self.adPlayer.delegate = self;
        
        ANAdResponseInfo *adResponseInfo  = (ANAdResponseInfo *) [ANGlobal valueOfGetterProperty:kANAdResponseInfo forObject:response.adObjectHandler];
        if (adResponseInfo) {
            [self setAdResponseInfo:adResponseInfo];
        }
        
        [self setFriendlyObstruction];

        [self videoAdReady];

        
    }else if(!response.isSuccessful && (response.adObject == nil)){
        [self videoAdLoadFailed:ANError(@"video_adfetch_failed", ANAdResponseCode.BAD_FORMAT.code) withAdResponseInfo:response.adResponseInfo];
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

- (ANVideoAdSubtype) videoAdTypeForAdFetcher:(ANAdFetcher *)fetcher {
    return  ANVideoAdSubtypeInstream;
}



//---------------------------------------------------------- -o--
#pragma mark - ANAdProtocol.

/** Set the user's current location.  This allows ad buyers to do location targeting, which can increase spend.
 */
- (void)setLocationWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude
                      timestamp:(nullable NSDate *)timestamp horizontalAccuracy:(CGFloat)horizontalAccuracy {
    self.location = [ANLocation getLocationWithLatitude:latitude
                                              longitude:longitude
                                              timestamp:timestamp
                                     horizontalAccuracy:horizontalAccuracy];
}

/** Set the user's current location rounded to the number of decimal places specified in "precision".
 Valid values are between 0 and 6 inclusive. If the precision is -1, no rounding will occur.
 */
- (void)setLocationWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude
                      timestamp:(nullable NSDate *)timestamp horizontalAccuracy:(CGFloat)horizontalAccuracy
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

- (void)setInventoryCode: (nullable NSString *)newInventoryCode
                memberId: (NSInteger)newMemberID
{
    if ((newMemberID > 0) && self.marManager)
    {
        if (self.marManager.memberId != newMemberID) {
            ANLogError(@"Arguments ignored because newMemberId (%@) is not equal to memberID used in Multi-Ad Request.", @(newMemberID));
            return;
        }
    }

    //
    if (newInventoryCode && ![newInventoryCode isEqualToString:_inventoryCode]) {
        ANLogDebug(@"Setting inventory code to %@", newInventoryCode);
        _inventoryCode = newInventoryCode;
    }
    if ( (newMemberID > 0) && (newMemberID != _memberId) ) {
        ANLogDebug(@"Setting member id to %d", (int) newMemberID);
        _memberId = newMemberID;
    }
}



@end

