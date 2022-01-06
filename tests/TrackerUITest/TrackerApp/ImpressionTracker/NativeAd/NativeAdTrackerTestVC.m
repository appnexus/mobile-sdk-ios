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

#import "NativeAdTrackerTestVC.h"
@import AppNexusSDK;
#import "ANNativeAdView.h"
#import "ANStubManager.h"
#import <Integration-Swift.h>
#import "Constant.h"
#import "ANHTTPStubbingManager.h"

@interface NativeAdTrackerTestVC () <ANNativeAdRequestDelegate,ANNativeAdDelegate>
@property (nonatomic,readwrite,strong) ANNativeAdRequest *nativeAdRequest;
@property (nonatomic,readwrite,strong) ANNativeAdResponse *nativeAdResponse;
@property (weak, nonatomic) IBOutlet UILabel *impressionTracker;
@property (weak, nonatomic) IBOutlet UILabel *clickTracker;
@property (nonatomic,readwrite) int impressionCount;

@end

@implementation NativeAdTrackerTestVC


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Native Ad";
    
    self.impressionCount = 0;
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
    self.nativeAdRequest= [[ANNativeAdRequest alloc] init];
    self.nativeAdRequest.placementId = NativePlacementId;
    self.nativeAdRequest.forceCreativeId = NativeForceCreativeId;
    self.nativeAdRequest.gender = ANGenderMale;
    self.nativeAdRequest.shouldLoadIconImage = YES;
    self.nativeAdRequest.shouldLoadMainImage = YES;
    self.nativeAdRequest.delegate = self;
    [self.nativeAdRequest loadAd];
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

- (void)adRequest:(ANNativeAdRequest *)request didReceiveResponse:(ANNativeAdResponse *)response {
    // (code which loads the view)
    self.nativeAdResponse = response;
    
    UINib *adNib = [UINib nibWithNibName:@"ANNativeAdView" bundle:[NSBundle mainBundle]];
    NSArray *array = [adNib instantiateWithOwner:self options:nil];
    ANNativeAdView *nativeAdView = [array firstObject];
    nativeAdView.titleLabel.text = self.nativeAdResponse.title;
    nativeAdView.bodyLabel.text = self.nativeAdResponse.body;
    nativeAdView.iconImageView.image = self.nativeAdResponse.iconImage;
    nativeAdView.mainImageView.image = self.nativeAdResponse.mainImage;
    nativeAdView.sponsoredLabel.text = self.nativeAdResponse.sponsoredBy;
    
    nativeAdView.callToActionButton.accessibilityIdentifier = @"clickElements";

    
    [nativeAdView.callToActionButton setTitle:self.nativeAdResponse.callToAction forState:UIControlStateNormal];
    self.nativeAdResponse.delegate = self;
    self.nativeAdResponse.clickThroughAction = ANClickThroughActionOpenSDKBrowser;
    
    [self.view addSubview:nativeAdView];
    
    [self.nativeAdResponse registerViewForTracking:nativeAdView
                   withRootViewController:self
                           clickableViews:@[nativeAdView.callToActionButton,nativeAdView.mainImageView]
                                    error:nil];
    
}

- (void)adRequest:(nonnull ANNativeAdRequest *)request didFailToLoadWithError:(nonnull NSError *)error withAdResponseInfo:(nullable ANAdResponseInfo *)adResponseInfo {
    NSLog(@"Ad request Failed With Error");
}


//  prepareStubbing if MockTestcase is enabled(set to 1) prepare stubbing with mock response else disable stubbing
-(void)prepareStubbing{
    
    [[ANStubManager sharedInstance] disableStubbing];
    [[ANStubManager sharedInstance] enableStubbing];
    
    if([[NSProcessInfo processInfo].arguments containsObject:NativeImpressionClickTrackerTest] ){
        [[ANStubManager sharedInstance] stubRequestWithResponse:@"RTBNativeAd"];
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
        
        // Loop for Impression Tracker and match with the returned URL if matched set the label to ImpressionTracker.
        for (NSString* url in impressionTrackerURLRTB){
             if([absoluteURLText containsString:url]){
                 self.impressionTracker.text  = @"ImpressionTracker";
                 self.impressionCount = self.impressionCount + 1;
             }
         }
        
        if([[NSProcessInfo processInfo].arguments containsObject:NativeMultiImpressionTrackerTest] ){
            if([absoluteURLText containsString:@"https://www.xandr.com/webappng/sites/xandr/dashboard?siteurl=xandr"]){
                self.impressionCount = self.impressionCount + 1;
            }else if([absoluteURLText containsString:@"https://www.xandr.com/about/"]){
                self.impressionCount = self.impressionCount + 1;
            }
         
        }
        
        if(self.impressionCount == 3 && [[NSProcessInfo processInfo].arguments containsObject:NativeMultiImpressionTrackerTest]){
         
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (10 * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
             
                self.impressionTracker.text  = @"MultiImpressionTracker";

            });
            
            
        }
       
        
        // Loop for Click Tracker and match with the returned URL if matched set the label to ClickTracker.
         for (NSString* url in clickTrackerURLRTB){
             if([absoluteURLText containsString:url]){
                 self.clickTracker.text  = @"ClickTracker";
                 self.impressionCount = self.impressionCount + 1;
             }
         }
        
        
        if(self.impressionCount == 3 && [[NSProcessInfo processInfo].arguments containsObject:NativeMultiClickTrackerTest]){
            
            
               dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (10 * NSEC_PER_SEC));
               dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
                
                   self.impressionTracker.text  = @"MultiClickTracker";

               });
               
        }
        
    });
}
@end
