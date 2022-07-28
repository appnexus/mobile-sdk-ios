//
//  ViewController.m
//  BannerLoadPerformance
//
//  Created by Punnaghai Puviarasu on 11/3/20.
//

#import "ScrollViewController.h"
#import "BannerCell.h"
#import "ContentCell.h"
@import AppNexusSDK;
#import "Constant.h"
#import "ANStubManager.h"
#import "ANHTTPStubbingManager.h"
#import <Integration-Swift.h>
#import "ANNativeAdView.h"

@interface ScrollViewController ()<UITableViewDataSource,UITableViewDelegate,ANBannerAdViewDelegate, ANNativeAdRequestDelegate,ANNativeAdDelegate>

@property (strong, nonatomic)  ANBannerAdView      *bannerAd10;
@property (nonatomic,readwrite,strong) ANNativeAdRequest *nativeAdRequest;
@property (nonatomic,readwrite,strong) ANNativeAdResponse *nativeAdResponse;
@end

@implementation ScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // All of the placements from this test are from member 10094 and shoudl fire impression only when 1px is on screen
    [[XandrAd sharedInstance] initWithMemberID:10094 preCacheRequestObjects:YES completionHandler:^(BOOL success) {
                if(success){
                    NSLog(@"XandrAd init Complete");
                }
    }];
    [ANLogManager setANLogLevel:ANLogLevelAll];
    
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
    
    if ([[NSProcessInfo processInfo].arguments containsObject:BannerImpression1PxTrackerTest]) {
        if(self.bannerAd10 == nil){
            self.bannerAd10 = [self createBannerAd];
            [self.bannerAd10 loadAd];
        }
        
    } else if ([[NSProcessInfo processInfo].arguments containsObject:NativeImpression1PxTrackerTest]){
        self.nativeAdRequest= [[ANNativeAdRequest alloc] init];
        self.nativeAdRequest.placementId = NativePlacementId;
        self.nativeAdRequest.forceCreativeId = NativeForceCreativeId;
        self.nativeAdRequest.gender = ANGenderMale;
        self.nativeAdRequest.shouldLoadIconImage = YES;
        self.nativeAdRequest.shouldLoadMainImage = YES;
        self.nativeAdRequest.delegate = self;
        [self.nativeAdRequest loadAd];
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
    [[ANStubManager sharedInstance] disableStubbing];
    [[ANStubManager sharedInstance] enableStubbing];
    if ([[NSProcessInfo processInfo].arguments containsObject:BannerImpression1PxTrackerTest]) {
        [[ANStubManager sharedInstance] stubRequestWithResponse:@"RTBBannerAdTracker"];
        
    } else if ([[NSProcessInfo processInfo].arguments containsObject:NativeImpression1PxTrackerTest]){
        [[ANStubManager sharedInstance] stubRequestWithResponse:@"RTBNativeAd"];
    }
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
        [self.nativeAdResponse registerViewForTracking:nativeAdView
                       withRootViewController:self
                               clickableViews:@[nativeAdView.callToActionButton,nativeAdView.mainImageView]
                                        error:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            self.title = @"Not Fired";
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self.view addSubview:nativeAdView];
            });
        });
}

- (void)adRequest:(nonnull ANNativeAdRequest *)request didFailToLoadWithError:(nonnull NSError *)error withAdResponseInfo:(nullable ANAdResponseInfo *)adResponseInfo {
    NSLog(@"Ad request Failed With Error");
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
