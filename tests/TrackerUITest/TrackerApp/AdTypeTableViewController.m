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

#import "AdTypeTableViewController.h"
#import "BannerNativeVideoTrackerTestVC.h"
#import "InterstitialAdTrackerTestVC.h"
#import "Constant.h"
#import "MARBannerNativeRendererAdTrackerTestVC.h"
#import "BannerNativeVideoTrackerTestVC.h"
#import "ANHTTPStubbingManager.h"

@interface AdTypeTableViewController ()
@property (nonatomic, readwrite, strong) NSString *adType;

@end

@implementation AdTypeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Disable mocking based on MockTestcase is set to false(0)
    if(!MockTestcase){
        [[ANHTTPStubbingManager sharedStubbingManager] disable];
        [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    }


    
    
    // Open BannerNativeVideoTrackerTestVC if arguments contain the BannerAd, BannerNativeAd, BannerVideoAd or BannerNativeRenderer Ad for Impression and Click Tracker
    if ([[NSProcessInfo processInfo].arguments containsObject:BannerImpressionClickTrackerTest] || [[NSProcessInfo processInfo].arguments containsObject:BannerNativeImpressionClickTrackerTest] || [[NSProcessInfo processInfo].arguments containsObject:BannerNativeRendererImpressionClickTrackerTest] || [[NSProcessInfo processInfo].arguments containsObject:BannerVideoImpressionClickTrackerTest] ) {
        [self openViewController:@"BannerNativeVideoTrackerTestVC"];
    }
    // Open InterstitialAdTrackerTestVC if arguments contain the Interstitial Ad for Impression and Click Tracker
    else if ([[NSProcessInfo processInfo].arguments containsObject:InterstitialImpressionClickTrackerTest]){
        [self openViewController:@"InterstitialAdTrackerTestVC"];
    }
    // Open VideoAdTrackerTestVC if arguments contain the Video Ad for Impression and Click Tracker
    else if([[NSProcessInfo processInfo].arguments containsObject:VideoImpressionClickTrackerTest] ){
        [self openViewController:@"VideoAdTrackerTestVC"];
    }
    // Open NativeAdTrackerTestVC if arguments contain the Native Ad for Impression and Click Tracker
    else if( [[NSProcessInfo processInfo].arguments containsObject:NativeImpressionClickTrackerTest] ){
        [self openViewController:@"NativeAdTrackerTestVC"];
    }
    // Open MARBannerNativeRendererAdTrackerTestVC if arguments contain the BannerNative Ad, BannerNativeRenderer Ad,Native Ad for Impression and Click Tracker
    else if( [[NSProcessInfo processInfo].arguments containsObject:MARBannerImpressionClickTrackerTest] ||  [[NSProcessInfo processInfo].arguments containsObject:MARNativeImpressionClickTrackerTest] ||[[NSProcessInfo processInfo].arguments containsObject:MARBannerNativeRendererImpressionClickTrackerTest]  ){
        [self openViewController:@"MARBannerNativeRendererAdTrackerTestVC"];
    }
     
    
    // Open BannerAdViewabilityTrackerTestVC if arguments contain the Banner Ad for Viewability Tracker [OMID]
    if( [[NSProcessInfo processInfo].arguments containsObject:BannerViewabilityTrackerTest]){
        [self openViewController:@"BannerAdViewabilityTrackerTestVC"];
    }
    // Open InterstitialAdViewabilityTrackerTestVC if arguments contain the InterstitialAd for Viewability Tracker [OMID]
    else if( [[NSProcessInfo processInfo].arguments containsObject:InterstitialViewabilityTrackerTest]){
        [self openViewController:@"InterstitialAdViewabilityTrackerTestVC"];
    }
    // Open BannerNativeAdViewabilityTrackerTestVC if arguments contain the BannerNative Ad, BannerNativeRenderer Ad,Native Ad for Viewability Tracker [OMID]
    else if( [[NSProcessInfo processInfo].arguments containsObject:NativeViewabilityTrackerTest] ||  [[NSProcessInfo processInfo].arguments containsObject:BannerNativeRendererViewabilityTrackerTest] || [[NSProcessInfo processInfo].arguments containsObject:BannerNativeViewabilityTrackerTest]  ){
        [self openViewController:@"BannerNativeAdViewabilityTrackerTestVC"];
    }
    
    else if( [[NSProcessInfo processInfo].arguments containsObject:NativeAdExpiry] ){
        [self openViewController:@"NativeAdExpiryTestVC"];
    }
    // Open BannerVideoAdViewabilityTrackerTestVC if arguments contain the BannerVideo Ad for Viewability Tracker [OMID]
    else if( [[NSProcessInfo processInfo].arguments containsObject:BannerVideoViewabilityTrackerTest]){
        [self openViewController:@"BannerVideoAdViewabilityTrackerTestVC"];
    }
    // Open VideoAdViewabilityTrackerTestVC if arguments contain the Video Ad for Viewability Tracker [OMID]
    else if( [[NSProcessInfo processInfo].arguments containsObject:VideoViewabilityTrackerTest]){
        [self openViewController:@"VideoAdViewabilityTrackerTestVC"];
    }else if( [[NSProcessInfo processInfo].arguments containsObject:BannerImpression1PxTrackerTest] || [[NSProcessInfo processInfo].arguments containsObject:NativeImpression1PxTrackerTest]){
        [self openViewController:@"ScrollViewController"];
    } 
}

// navigation to desire viewController using storyboard Name & ViewController's Identifier
-(void)openViewController:(NSString *)viewController{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:viewController bundle:nil];
    UIViewController *vc = [sb instantiateViewControllerWithIdentifier:viewController];
    [vc setModalPresentationStyle: UIModalPresentationFullScreen];
    [self.navigationController pushViewController:vc animated:YES];
    
}

@end
