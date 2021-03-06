//
//  ViewController.m
//  BannerLoadPerformance
//
//  Created by Punnaghai Puviarasu on 11/3/20.
//

#import "ScrollViewController.h"
#import "BannerCell.h"
#import "ContentCell.h"
#import <AppNexusSDK/AppNexusSDK.h>
#import "Constant.h"
//#import "ANBannerAdView.h"
//#import "ANLogManager.h"
//#import "ANSDKSettings.h"
#import "ANStubManager.h"
#import "ANHTTPStubbingManager.h"
#import <TrackerApp-Swift.h>

@interface ScrollViewController ()<UITableViewDataSource,UITableViewDelegate,ANBannerAdViewDelegate>

@property (strong, nonatomic)  ANBannerAdView      *bannerAd10;
@end

@implementation ScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [ANLogManager setANLogLevel:ANLogLevelAll];
    ANSDKSettings.sharedInstance.countImpressionOn1PxRendering = YES;
    
    if(MockTestcase){
        [self prepareStubbing];
    }
    else {
        [[ANHTTPStubbingManager sharedStubbingManager] disable];
        [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
        [[ANStubManager sharedInstance] enableStubbing];
        [[ANStubManager sharedInstance] disableStubbing];
    }
    [self registerEventListener];
    
    if(self.bannerAd10 == nil){
        self.bannerAd10 = [self createBannerAd];
        [self.bannerAd10 loadAd];
    }

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
-(void)prepareStubbing{
    
    if ([[NSProcessInfo processInfo].arguments containsObject:BannerImpressionClickTrackerTest]) {
        self.title = @"BannerAd";
    }
    [[ANStubManager sharedInstance] disableStubbing];
    [[ANStubManager sharedInstance] enableStubbing];
    [[ANStubManager sharedInstance] stubRequestWithResponse:@"RTBBannerAd"];

}



- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    if(indexPath.row == 9){
            BannerCell *cell = (BannerCell *)[self.adView dequeueReusableCellWithIdentifier:@"BannerCell"];
            if(self.bannerAd10 == nil){
                self.bannerAd10 = [self createBannerAd];
                [self.bannerAd10 loadAd];
            }
            [cell.bannerView addSubview:self.bannerAd10];
        
        return  cell;
    } else {
        ContentCell *cell = (ContentCell *)[self.adView dequeueReusableCellWithIdentifier:@"ContentCell"];

        //cell.label.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row];

        return cell;
    }
    
    
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

// Create Banner Ad Object
- (ANBannerAdView *)createBannerAd{
    
    ANBannerAdView *bannerAd = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0 ,self.navigationController.navigationBar.frame.size.height, 320, 50) placementId:@"20814126" adSize:CGSizeMake(320, 50)];
    bannerAd.rootViewController =self;
    bannerAd.delegate =self;
    bannerAd.shouldResizeAdToFitContainer = YES;
    bannerAd.forceCreativeId = BannerForceCreativeId;
    //bannerAd.countImpressionOnAdReceived = YES;
    bannerAd.autoRefreshInterval = 0;
    return bannerAd;
}

- (void)adDidReceiveAd:(id)ad
{
    NSLog(@"Banner Ad did Receive");

    // Delay execution of my block for 10 seconds.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        self.title = @"Not Fired";
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self.view addSubview:self.bannerAd10];
        });
    });
    
}

- (void)ad:(id)ad requestFailedWithError:(NSError *)error{
    NSLog(@"requestFailedWithError %@:",error);
    
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
                self.title = @"ImpressionTracker";
//                self.impressionTracker.text  = ;
            }
        }
        // Loop for Click Tracker and match with the returned URL if matched set the label to ClickTracker.
        for (NSString* url in clickTrackerURLRTB){
            if([absoluteURLText containsString:url]){
//                self.clickTracker.text  = @"ClickTracker";
            }
        }
    });
}

@end
