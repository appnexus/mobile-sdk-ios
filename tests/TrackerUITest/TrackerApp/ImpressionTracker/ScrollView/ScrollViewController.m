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
//#import "ANBannerAdView.h"
//#import "ANLogManager.h"
//#import "ANSDKSettings.h"

@interface ScrollViewController ()<UITableViewDataSource,UITableViewDelegate,ANBannerAdViewDelegate>

@property (strong, nonatomic)  ANBannerAdView      *bannerAd10;
@end

@implementation ScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [ANLogManager setANLogLevel:ANLogLevelAll];
    ANSDKSettings.sharedInstance.countImpressionOn1PxRendering = YES;
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    if(indexPath.row == 9){
            BannerCell *cell = (BannerCell *)[self.adView dequeueReusableCellWithIdentifier:@"BannerCell"];
            if(self.bannerAd10 == nil){
                self.bannerAd10 = [self createBannerAd];
            }
            [cell.bannerView addSubview:self.bannerAd10];
            [self.bannerAd10 loadAd];
        
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
    
    ANBannerAdView *bannerAd = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 320, 50) placementId:@"20873888" adSize:CGSizeMake(320, 50)];
    bannerAd.rootViewController =self;
    bannerAd.delegate =self;
    bannerAd.shouldResizeAdToFitContainer = YES;
    //bannerAd.countImpressionOnAdReceived = YES;
    bannerAd.autoRefreshInterval = 0;
    return bannerAd;
}

- (void)adDidReceiveAd:(id)ad
{
    NSLog(@"Banner Ad did Receive");
    
}

- (void)ad:(id)ad requestFailedWithError:(NSError *)error{
    NSLog(@"requestFailedWithError %@:",error);
    
}

@end
