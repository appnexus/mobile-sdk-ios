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

#import "BannerAdViewController.h"
#import <AppNexusSDK/AppNexusSDK.h>



@interface BannerAdViewController () <ANBannerAdViewDelegate>

@property (nonatomic, readwrite, strong) ANBannerAdView *banner;


@end

@implementation BannerAdViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Banner Ad";

    int adWidth  = 320;
    int adHeight = 50;
    NSString *adID = @"19065996";
    NSString *inventoryCode = @"finanzen.net-app_ios_phone-home_index-banner";
    NSInteger memberID = 7823;
    
    // We want to center our ad on the screen.
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat originX = (screenRect.size.width / 2) - (adWidth / 2);
    CGFloat originY = (screenRect.size.height / 2) - (adHeight / 2);
    
    // Needed for when we create our ad view.
    CGRect rect = CGRectMake(originX, originY, adWidth, adHeight);
    CGSize size = CGSizeMake(adWidth, adHeight);
    
    // Make a banner ad view.
    //self.banner = [ANBannerAdView adViewWithFrame:rect placementId:adID adSize:size];
    self.banner = [[ANBannerAdView alloc] initWithFrame:rect memberId:memberID inventoryCode:inventoryCode adSize:size];
    self.banner.rootViewController = self;
    self.banner.delegate = self;
    [self.view addSubview:self.banner];
    
    // Since this example is for testing, we'll turn on PSAs and verbose logging.
    self.banner.shouldServePublicServiceAnnouncements = NO;
    self.banner.autoRefreshInterval = 30;
    
    // Load an ad.
    [self.banner loadAd];
}

- (void)adDidReceiveAd:(id)ad {
    NSLog(@"Ad did receive ad");
}

-(void)ad:(id)ad requestFailedWithError:(NSError *)error{
    NSLog(@"Ad request Failed With Error");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
