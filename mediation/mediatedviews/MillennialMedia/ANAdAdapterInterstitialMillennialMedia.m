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


#import "ANAdAdapterInterstitialMillennialMedia.h"
#import "MMInterstitial.h"
#import "MMRequest.h"
#import "ANGlobal.h"
#import "ANLogging.h"

@interface ANAdAdapterInterstitialMillennialMedia ()
@property (nonatomic, readwrite, strong) MMInterstitial *interstitialAd;
@end

@implementation ANAdAdapterInterstitialMillennialMedia
@synthesize delegate;
@synthesize responseURLString;

#pragma mark ANCustomAdapterInterstitial

- (void)requestInterstitialAdWithParameter:(NSString *)parameterString
                                  adUnitId:(NSString *)idString
                                  location:(ANLocation *)location
{
    ANLogDebug(@"Requesting MillennialMedia interstitial");
    
    //MMRequest object
    MMRequest *request;
    if (location) {
        CLLocation *locToSend = [[CLLocation alloc]
                     initWithCoordinate:CLLocationCoordinate2DMake(location.latitude, location.longitude)
                     altitude:0
                     horizontalAccuracy:location.horizontalAccuracy
                     verticalAccuracy:0 course:0 speed:0
                     timestamp:location.timestamp];
        
        request = [MMRequest requestWithLocation:locToSend];
    }
    else {
        request = [MMRequest request];
    }
    
    [MMInterstitial fetchWithRequest:request
                                apid:idString
                        onCompletion:^(BOOL success, NSError *error) {
                            if (success) {
                                [MMInterstitial displayForApid:idString
                                            fromViewController:AppRootViewController()
                                               withOrientation:0
                                                  onCompletion:^(BOOL success, NSError *error) {
                                                      if (success) {
                                                          ANLogDebug(@"MillennialMedia interstitial did load");
                                                          [self.delegate adapterInterstitial:self didLoadInterstitialAd:nil];
                                                      }
                                                      else {
                                                          ANLogDebug(@"MillennialMedia interstitial failed to load with error: %@", error);
                                                          NSInteger code = ANAdResponseInternalError;
                                                          
                                                          switch (error.code) {
                                                              case MMAdUnknownError:
                                                                  code = ANAdResponseInternalError;
                                                                  break;
                                                              case MMAdServerError:
                                                                  code = ANAdResponseNetworkError;
                                                                  break;
                                                              case MMAdUnavailable:
                                                                  code = ANAdResponseUnableToFill;
                                                                  break;
                                                              case MMAdDisabled:
                                                                  code = ANAdResponseInvalidRequest;
                                                                  break;
                                                              default:
                                                                  code = ANAdResponseInternalError;
                                                                  break;
                                                          }
                                                          
                                                          [self.delegate adapterInterstitial:self didFailToReceiveInterstitialAd:code];
                                                      }
                                                  }];
                            }
                        }];
    
    
}

- (void)presentFromViewController:(UIViewController *)viewController
{
    ANLogDebug(@"Showing MillennialMedia interstitial");
    AppRootViewController();
}

@end
