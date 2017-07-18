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


#import "ANAdAdapterBannerAdMarvel.h"
#import "ANAdAdapterAdMarvelBase+PrivateMethods.h"
#import "AdMarvelView.h"
#import "ANLogging.h"

@interface ANAdAdapterBannerAdMarvel () <AdMarvelDelegate>

    @property (nonatomic, strong) AdMarvelView *adMarvelView;
    @property (nonatomic, assign) CGSize size;

@end

@implementation ANAdAdapterBannerAdMarvel

@synthesize delegate;

- (void)requestBannerAdWithSize:(CGSize)size
             rootViewController:(UIViewController *)rootViewController
                serverParameter:(NSString *)parameterString
                       adUnitId:(NSString *)idString
            targetingParameters:(ANTargetingParameters *)targetingParameters {
    
    [self setSiteAndPartnerIdParameters:idString];
    [self setRootViewController:rootViewController];
   
    [self setTargetingParameters:targetingParameters];
    self.size = size;
    self.adMarvelView = [AdMarvelView createAdMarvelViewWithDelegate:self];

    [self startAdRequest];
    
}

- (void)dealloc {
    
    self.adMarvelView.delegate = nil;
}

#pragma mark Private methods

-(void) startAdRequest{
    [self.adMarvelView getAdWithNotification];
}

#pragma -

#pragma mark Callback methods

- (void) getAdSucceeded:(AdMarvelView *)adMarvelView
{
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate didLoadBannerAd:adMarvelView];
    
}

- (void) getAdFailed:(AdMarvelView *)adMarvelView
{
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate didFailToLoadAd:ANAdResponseUnableToFill];
    
}

- (void) adMarvelViewWasClicked:(AdMarvelView *)adMarvelView
{
    // Callback to let app know that a special banner has been clicked.  This method is provided to help track if an ad click is respondible for sending the user out of the app.
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate adWasClicked];
}

#pragma mark - 

#pragma mark AdMarvelDelegate methods

- (CGRect)adMarvelViewFrame:(AdMarvelView *)adMarvelView {
    return CGRectMake(0, 0, self.size.width, self.size.height);
}

@end
