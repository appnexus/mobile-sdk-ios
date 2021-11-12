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

#import "VideoAdTrackerTestVC.h"
#import <AVFoundation/AVFoundation.h>
#import "ANStubManager.h"
#import <Integration-Swift.h>
#import "Constant.h"
#import "ANHTTPStubbingManager.h"

@import AVFoundation;
@import AppNexusSDK;
//#import <AppNexusSDK/AppNexusSDK.h>

@interface VideoAdTrackerTestVC ()<ANInstreamVideoAdLoadDelegate, ANInstreamVideoAdPlayDelegate>

@property(nonatomic, weak) IBOutlet UIView *videoView;
@property (strong, nonatomic)  ANInstreamVideoAd  *videoAd;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UILabel *impressionTracker;
@property (weak, nonatomic) IBOutlet UILabel *clickTracker;
@property (weak, nonatomic) IBOutlet UILabel *adLoaded;


@end



@implementation VideoAdTrackerTestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Video Ad";
    //  MockTestcase is enabled(set to 1) prepare stubbing with mock response else disable stubbing
    if(MockTestcase){
        [self prepareStubbing];
    } else {
        [[ANHTTPStubbingManager sharedStubbingManager] disable];
        [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
        [[ANStubManager sharedInstance] enableStubbing];
        [[ANStubManager sharedInstance] disableStubbing];
    }
    //  registerEventListener is used to register for tracking the URL fired by Application(or SDK)
    [self registerEventListener];

    self.playButton.hidden = YES;
    self.playButton.layer.zPosition = MAXFLOAT;
    [ANLogManager setANLogLevel:ANLogLevelAll];
    // Fix iPhone issue of log text starting in the middle of the UITextView
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    
    [self setupContentPlayer];
    self.videoAd = [[ANInstreamVideoAd alloc] initWithPlacementId:VideoPlacementId];
    self.videoAd.clickThroughAction = ANClickThroughActionOpenSDKBrowser;
    // Set Creative Id if ForceCreative is enabled
    if(ForceCreative){
        self.videoAd.forceCreativeId = VideoForceCreativeId;
    }
    [self.videoAd loadAdWithDelegate:self];
    
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)playButton_Touch:(id)sender {
    self.playButton.hidden = true;
    [self.videoAd playAdWithContainer:self.videoView withDelegate:self];
    
}


-(void) setupContentPlayer {
    [self.videoView setNeedsLayout];
    self.videoView.translatesAutoresizingMaskIntoConstraints = YES;
    
}

#pragma mark Utility methods

-(void)itemDidFinishPlaying:(NSNotification *) notification {
    NSLog(@"finished playing content");
    //cleanup the player & start again
    [self setupContentPlayer];
    self.playButton.hidden = NO;
}

- (void)logMessage:(NSString *)log {
    NSString *logString = [NSString stringWithFormat:@"%@\n", log];
    NSLog(@"%@\n", logString);
}

-(void)getAdPlayElapsedTime{
    
    // To get AdPlayElapsedTime
    NSUInteger getAdPlayElapsedTime = [self.videoAd getAdPlayElapsedTime];
    [self logMessage:[NSString stringWithFormat:@"AdPlayElapsedTime : %lu",(unsigned long)getAdPlayElapsedTime]];
    
}
#pragma mark - ANInstreamVideoAdDelegate.

//----------------------------- -o-
- (void) adDidReceiveAd: (id<ANAdProtocol>)ad
{
    self.adLoaded.text = @"adDidReceiveAd";
    //    self.playButton.hidden = NO;
    [self.videoAd playAdWithContainer:self.videoView withDelegate:self];
    
    
}

- (void)                ad: (id<ANAdProtocol>)ad
    requestFailedWithError: (NSError *)error
{
    [self logMessage:@"adRequestFailedWithError"];
}


//  prepareStubbing if MockTestcase is enabled(set to 1) prepare stubbing with mock response else disable stubbing
-(void)prepareStubbing{
    [[ANStubManager sharedInstance] disableStubbing];
    [[ANStubManager sharedInstance] enableStubbing];
    [[ANStubManager sharedInstance] stubRequestWithResponse:@"RTBVideoAd"];
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
