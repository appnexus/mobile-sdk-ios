/*   Copyright 2020 APPNEXUS INC
 
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

#import "InterstitialAdTrackerTestVC.h"
@import AppNexusSDK;
#import "ANStubManager.h"
#import <Integration-Swift.h>
#import "Constant.h"
#import "ANHTTPStubbingManager.h"

@interface InterstitialAdTrackerTestVC () <ANInterstitialAdDelegate>

@property (strong, nonatomic) ANInterstitialAd *interstitialAd;
@property (weak, nonatomic) IBOutlet UILabel *impressionTracker;
@property (weak, nonatomic) IBOutlet UILabel *clickTracker;

@end

@implementation InterstitialAdTrackerTestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    //  MockTestcase is enabled(set to 1) prepare stubbing with mock response else disable stubbing
    if(MockTestcase){
        [self prepareStubbing];
    }
    else {
        [[ANHTTPStubbingManager sharedStubbingManager] disable];
        [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
        [[ANStubManager sharedInstance] enableStubbing];
        [[ANStubManager sharedInstance] disableStubbing];
    }
    
    //  registerEventListener is used to register for tracking the URL fired by Application(or SDK)
    [self registerEventListener];
    
    self.title = @"Interstitial Ad";
    dispatch_async(dispatch_get_main_queue(), ^{
        self.interstitialAd = [[ANInterstitialAd alloc] initWithPlacementId:InterstitialPlacementId];
        self.interstitialAd.delegate = self;
        // Set Creative Id if ForceCreative is enabled
       if(ForceCreative){
            self.interstitialAd.forceCreativeId = InterstitialForceCreativeId;
        }
        self.interstitialAd.clickThroughAction = ANClickThroughActionReturnURL;
        [self.interstitialAd dismissOnClick];
        [self.interstitialAd loadAd];
    });
}

#pragma mark - ANInterstitialAdDelegate

- (void)adDidReceiveAd:(id)ad {
    NSLog(@"adDidReceiveAd");
    [self.interstitialAd displayAdFromViewController:self autoDismissDelay:5];
}

-(void)ad:(id)ad requestFailedWithError:(NSError *)error{
    NSLog(@"Ad request Failed With Error");
}

//  registerEventListener is used to register for tracking the URL fired by Application(or SDK)
-(void)registerEventListener{
    [NSURLProtocol registerClass:[WebKitURLProtocol class]];
    [NSURLProtocol wk_registerWithScheme:@"https"];
    [NSURLProtocol wk_registerWithScheme:@"http"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateNetworkLog:)
                                                 name:@"didReceiveURLResponse"
                                               object:nil];
}
//  prepareStubbing if MockTestcase is enabled(set to 1) prepare stubbing with mock response else disable stubbing
-(void)prepareStubbing{
    self.title = @"Interstitial Ad";
    [[ANStubManager sharedInstance] disableStubbing];
    [[ANStubManager sharedInstance] enableStubbing];
    if ([[NSProcessInfo processInfo].arguments containsObject:InterstitialImpressionClickTrackerTest]){
        [[ANStubManager sharedInstance] stubRequestWithResponse:@"RTBBannerAdTracker"];
    }
}


- (void)adDidLogImpression:(id)ad  {
    if([[NSProcessInfo processInfo].arguments containsObject:InterstitialImpressionClickTrackerTestWithCallback]){
        self.impressionTracker.text  = @"ImpressionTracker via adDidLogImpression";
    }
}

# pragma mark - Ad Server Response Stubbing
// updateNetworkLog: Will return event in fire of URL from Application(or SDK)
- (void) updateNetworkLog:(NSNotification *) notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSURLResponse *response = [userInfo objectForKey:@"response"];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *absoluteURLText = [response.URL.absoluteURL absoluteString];
        NSLog(@"absoluteURLText -> %@",absoluteURLText);
        // Loop for Impression Tracker and match with the returned URL if matched set the label to ImpressionTracker.
        for (NSString* url in impressionTrackerURLRTB){
          
            if([absoluteURLText containsString:url]){
                if(![[NSProcessInfo processInfo].arguments containsObject:InterstitialImpressionClickTrackerTestWithCallback]){
                self.impressionTracker.text  = @"ImpressionTracker";
                }
            }
        }
        // Loop for Click Tracker and match with the returned URL if matched set the label to ClickTracker.
        for (NSString* url in clickTrackerURLRTB){
            if([absoluteURLText containsString:url]){
                self.clickTracker.text  = @"ClickTracker";
            }
        }
        
    });
}


@end
