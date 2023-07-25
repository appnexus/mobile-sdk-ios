/*   Copyright 2013 APPNEXUS INC
 
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

#import "ANAdAdapterBannerDFP.h"
#import "ANAdAdapterBaseDFP.h"



static NSString *const kANAdAdapterBannerDFPANHB = @"anhb";
static NSString *const kANAdAdapterBannerDFPSecondPrice = @"second_price";
static CGFloat const kANWaitIntervalMilles = 0.12f;
static CGFloat const kANTotalRetries = 10;


/**
 * Local object to handle server side parameters.
 */

@interface DFPBannerServerSideParameters : NSObject
@property (nonatomic, readwrite)          BOOL       isSwipable;
@property (nonatomic, readwrite)          BOOL       isSmartBanner;
@property (nonatomic, readwrite, strong)  NSString  *secondPrice;
@end

@implementation DFPBannerServerSideParameters
@synthesize isSwipable;
@synthesize isSmartBanner;
@synthesize secondPrice;
@end




@interface ANAdAdapterBannerDFP ()

@property (nonatomic, readwrite, strong)  GAMBannerView  *dfpBanner;
@property (nonatomic, readwrite, strong)  GAMRequest     *dfpRequest;
@property (nonatomic, readwrite)          BOOL            secondPriceIsHigher;
@property (nonatomic, readwrite)          BOOL            secondPriceAvailable;
@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic) int retryCount;

@end



@implementation ANAdAdapterBannerDFP

@synthesize delegate;


#pragma mark - ANCustomAdapterBanner

- (void)requestBannerAdWithSize:(CGSize)size
             rootViewController:(nullable UIViewController *)rootViewController
                serverParameter:(nullable NSString *)parameterString
                       adUnitId:(nullable NSString *)idString
            targetingParameters:(nullable ANTargetingParameters *)targetingParameters
{
    ANLogDebug(@"Requesting DFP banner with size: %0.1fx%0.1f", size.width, size.height);
    
    DFPBannerServerSideParameters  *ssparam    = [self parseServerSide:parameterString];
    GADAdSize                       gadAdSize;
    
    // Allow server side to enable Smart Banners for this placement
    if (ssparam.isSmartBanner) {
        UIApplication *application = [UIApplication sharedApplication];
        BOOL orientationIsPortrait = UIInterfaceOrientationIsPortrait([application statusBarOrientation]);
        if(orientationIsPortrait) {
            gadAdSize = GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(size.width);
        } else {
            gadAdSize = GADLandscapeAnchoredAdaptiveBannerAdSizeWithWidth(size.height);
        }
    } else {
        gadAdSize = GADAdSizeFromCGSize(size);
    }

    self.dfpRequest  = [ANAdAdapterBaseDFP dfpRequestFromTargetingParameters:targetingParameters rootViewController:rootViewController];
    self.secondPriceAvailable     = NO;
    if (ssparam.secondPrice) {
        //NB  round() is required because [@"0.01" floatValue] approximates 1 as 0.99... which, in turn, becomes an integer of 0.
        //
        CGFloat     secondPriceAsNumber    = round([ssparam.secondPrice floatValue] * 100.0);

        if (secondPriceAsNumber >= 0) {
            self.secondPriceAvailable     = YES;
            NSString  *secondPriceAsToken  = [NSString stringWithFormat:@"%@_%@", kANAdAdapterBannerDFPANHB, @(secondPriceAsNumber)];
            self.dfpRequest.customTargeting = @{ kANAdAdapterBannerDFPANHB : secondPriceAsToken };
        }
    }

    self.dfpBanner = [[GAMBannerView alloc] initWithAdSize:gadAdSize];
    self.dfpBanner.adUnitID = idString;
    self.dfpBanner.rootViewController = rootViewController;
    self.dfpBanner.delegate = self;
    self.dfpBanner.appEventDelegate = self;
    self.secondPriceIsHigher = NO;
    self.retryCount = 0;
    //
    [self.dfpBanner loadRequest:self.dfpRequest];
}

- (DFPBannerServerSideParameters*) parseServerSide:(NSString*) serverSideParameters
{
    DFPBannerServerSideParameters *p = [DFPBannerServerSideParameters new];
    NSError *jsonParsingError = nil;

    if (serverSideParameters == nil || [ serverSideParameters length] == 0) {
        return p;
    }

    NSData          *data           = [serverSideParameters dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary    *jsonResponse   = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
    
    if (jsonParsingError == nil && jsonResponse != nil)
    {
        p.isSwipable        = [[jsonResponse valueForKey:@"swipeable"] boolValue];
        p.isSmartBanner     = [[jsonResponse valueForKey:@"smartbanner"] boolValue];
        p.secondPrice       = [jsonResponse valueForKey:kANAdAdapterBannerDFPSecondPrice];
    }

    return p;
}

-(void)adReceiveAd{
    @synchronized (self) {
        self.retryCount ++;
        if (self.retryCount<kANTotalRetries) {
            if (self.secondPriceIsHigher) {
                [self.timer invalidate];
                [self.delegate didFailToLoadAd:ANAdResponseCode.UNABLE_TO_FILL];
            }
        }else{
            [self.timer invalidate];
            [self.delegate didLoadBannerAd:self.dfpBanner];
        }
    }
}

#pragma mark - GADBannerViewDelegate
- (void)bannerViewDidReceiveAd:(GAMBannerView *)bannerView
{
    ANLogDebug(@"DFP banner did load");
    if (!self.secondPriceAvailable) {
        [self.delegate didLoadBannerAd:self.dfpBanner];
    }else{
        self.timer = [NSTimer timerWithTimeInterval:kANWaitIntervalMilles target:self selector:@selector(adReceiveAd) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer  forMode:NSRunLoopCommonModes];
    }
}

- (void)bannerView:(nonnull GADBannerView *)bannerView didFailToReceiveAdWithError:(nonnull NSError *)error{
    ANLogDebug(@"DFP banner failed to load with error: %@", [error localizedDescription]);
    [self.timer invalidate];
    [self.delegate didFailToLoadAd:[ANAdAdapterBaseDFP responseCodeFromRequestError:error]];
}

- (void)bannerViewDidRecordImpression:(nonnull GADBannerView *)bannerView{
    ANLogDebug(@"DFP banner impression recorded");
    [self.delegate adDidLogImpression];
}

- (void)bannerViewWillPresentScreen:(GAMBannerView *)adView {
    [self.delegate willPresentAd];
}

- (void)bannerViewWillDismissScreen:(nonnull GADBannerView *)bannerView {
    [self.delegate willCloseAd];
}

- (void)bannerViewDidDismissScreen:(nonnull GADBannerView *)bannerView {
    [self.delegate didCloseAd];
}

- (void)adViewWillLeaveApplication:(GAMBannerView *)adView {
    [self.delegate willLeaveApplication];
}

- (void)dealloc
{
    ANLogDebug(@"DFP banner being destroyed");
	self.dfpBanner.delegate = nil;
	self.dfpBanner = nil;
}

#pragma mark - GADAppEventDelegate

- (void)        adView: (GAMBannerView *)banner
    didReceiveAppEvent: (NSString *)name
              withInfo: (NSString *)info
{
    ANLogDebug(@"name=%@  info=%@", name, info);

    if (! ([name isEqualToString:@"nobid"] && [info isEqualToString:@"true"]) )  { return; }

    @synchronized (self) {
        self.secondPriceIsHigher = YES;
        ANLogInfo(@"DFP responds with \"no bid\" because Second Price (%@) is higher.", self.dfpRequest.customTargeting[kANAdAdapterBannerDFPANHB]);
    }
}


@end
