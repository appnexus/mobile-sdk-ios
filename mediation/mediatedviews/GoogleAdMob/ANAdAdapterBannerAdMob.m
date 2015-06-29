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

#import "ANAdAdapterBannerAdMob.h"
#import "ANAdAdapterBaseDFP.h"
#import "ANLogging.h"

@interface ANAdAdapterBannerAdMob ()
@property (nonatomic, readwrite, strong) GADBannerView *bannerView;
@end


/**
 * Server side overridable
 */
@interface AdMobBannerServerSideParameters : NSObject
@property(nonatomic, readwrite) BOOL isSmartBanner;
@end
@implementation AdMobBannerServerSideParameters
@synthesize isSmartBanner;
@end





@implementation ANAdAdapterBannerAdMob
@synthesize delegate;

#pragma mark ANCustomAdapterBanner

- (void)requestBannerAdWithSize:(CGSize)size
             rootViewController:(UIViewController *)rootViewController
                serverParameter:(NSString *)parameterString
                       adUnitId:(NSString *)idString
            targetingParameters:(ANTargetingParameters *)targetingParameters
{
    ANLogDebug(@"Requesting AdMob banner with size: %fx%f", size.width, size.height);
	GADAdSize gadAdSize;
    
    AdMobBannerServerSideParameters *ssparam = [self parseServerSide:parameterString];
    
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
    self.bannerView = [[GADBannerView alloc] initWithAdSize:gadAdSize];
    
	self.bannerView.adUnitID = idString;
	
	self.bannerView.rootViewController = rootViewController;
	self.bannerView.delegate = self;
	[self.bannerView loadRequest:[self createRequestFromTargetingParameters:targetingParameters]];
}

- (GADRequest *)createRequestFromTargetingParameters:(ANTargetingParameters *)targetingParameters {
    return [ANAdAdapterBaseDFP googleAdRequestFromTargetingParameters:targetingParameters];
}

- (AdMobBannerServerSideParameters*) parseServerSide:(NSString*) serverSideParameters
{
    AdMobBannerServerSideParameters *p = [AdMobBannerServerSideParameters new];
    NSError *jsonParsingError = nil;
    if (serverSideParameters == nil || [ serverSideParameters length] == 0) {
        return p;
    }
    NSData* data = [serverSideParameters dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
    
    if (jsonParsingError == nil && jsonResponse != nil) {
        p.isSmartBanner = [[jsonResponse valueForKey:@"smartbanner"] boolValue];
    }
    return p;
}


#pragma mark GADBannerViewDelegate

- (void)adViewDidReceiveAd:(GADBannerView *)view
{
    ANLogDebug(@"AdMob banner did load");
	[self.delegate didLoadBannerAd:view];
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error
{
    ANLogDebug(@"AdMob banner failed to load with error: %@", error);
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
        case kGADErrorMediationNoFill:
            code = ANAdResponseUnableToFill;
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
    
 	[self.delegate didFailToLoadAd:code];
}

- (void)adViewWillPresentScreen:(GADBannerView *)adView {
    [self.delegate willPresentAd];
}

- (void)adViewWillDismissScreen:(GADBannerView *)adView {
    [self.delegate willCloseAd];
}

- (void)adViewDidDismissScreen:(GADBannerView *)adView {
    [self.delegate didCloseAd];
}

- (void)adViewWillLeaveApplication:(GADBannerView *)adView {
    [self.delegate willLeaveApplication];
}

- (void)dealloc
{
    ANLogDebug(@"AdMob banner being destroyed");
	self.bannerView.delegate = nil;
	self.bannerView = nil;
}

@end
