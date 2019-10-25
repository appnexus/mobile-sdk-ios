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

@property (nonatomic, readwrite, strong)  DFPBannerView  *dfpBanner;
@property (nonatomic, readwrite, strong)  DFPRequest     *dfpRequest;
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
            gadAdSize = kGADAdSizeSmartBannerPortrait;
        } else {
            gadAdSize = kGADAdSizeSmartBannerLandscape;
        }
    } else {
        gadAdSize = GADAdSizeFromCGSize(size);
    }


    //
    self.dfpRequest  = [ANAdAdapterBaseDFP dfpRequestFromTargetingParameters:targetingParameters ];
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


    //
    self.dfpBanner = [[DFPBannerView alloc] initWithAdSize:gadAdSize];
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
                [self.delegate didFailToLoadAd:ANAdResponseUnableToFill];
            }
        }else{
            [self.timer invalidate];
            [self.delegate didLoadBannerAd:self.dfpBanner];
        }
    }
}

#pragma mark - GADBannerViewDelegate

- (void)adViewDidReceiveAd:(DFPBannerView *)view
{
    ANLogDebug(@"DFP banner did load");
    if (!self.secondPriceAvailable) {
        [self.delegate didLoadBannerAd:self.dfpBanner];
    }else{
        self.timer = [NSTimer scheduledTimerWithTimeInterval:kANWaitIntervalMilles target:self selector:@selector(adReceiveAd) userInfo:nil repeats:YES];
    }
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error
{
    ANLogDebug(@"DFP banner failed to load with error: %@", [error localizedDescription]);
    ANAdResponseCode code = ANAdResponseInternalError;
    
    switch (error.code) {
        case kGADErrorInvalidRequest:
            code = ANAdResponseInvalidRequest;
            break;
        case kGADErrorNoFill:
            code = ANAdResponseUnableToFill;
            break;
        case kGADErrorNetworkError:
            code = ANAdResponseNetworkError;
            break;
        case kGADErrorServerError:
            code = ANAdResponseNetworkError;
            break;
        case kGADErrorOSVersionTooLow:
            code = ANAdResponseInternalError;
            break;
        case kGADErrorTimeout:
            code = ANAdResponseNetworkError;
            break;
        case kGADErrorInterstitialAlreadyUsed:
            code = ANAdResponseInternalError;
            break;
        case kGADErrorMediationDataError:
            code = ANAdResponseInvalidRequest;
            break;
        case kGADErrorMediationAdapterError:
            code = ANAdResponseInternalError;
            break;
        case kGADErrorMediationInvalidAdSize:
            code = ANAdResponseInvalidRequest;
            break;
        case kGADErrorInternalError:
            code = ANAdResponseInternalError;
            break;
        case kGADErrorInvalidArgument:
            code = ANAdResponseInvalidRequest;
            break;
        default:
            code = ANAdResponseInternalError;
            break;
    }
    [self.timer invalidate];
    [self.delegate didFailToLoadAd:code];
}

- (void)adViewWillPresentScreen:(DFPBannerView *)adView {
    [self.delegate willPresentAd];
}

- (void)adViewWillDismissScreen:(DFPBannerView *)adView {
    [self.delegate willCloseAd];
}

- (void)adViewDidDismissScreen:(DFPBannerView *)adView {
    [self.delegate didCloseAd];
}

- (void)adViewWillLeaveApplication:(DFPBannerView *)adView {
    [self.delegate willLeaveApplication];
}

- (void)dealloc
{
    ANLogDebug(@"DFP banner being destroyed");
	self.dfpBanner.delegate = nil;
	self.dfpBanner = nil;
}




#pragma mark - GADAppEventDelegate

- (void)        adView: (DFPBannerView *)banner
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
