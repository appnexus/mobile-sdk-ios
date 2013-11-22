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

#import "AdPreviewTVC.h"
#import "AdSettings.h"
#import "ANBannerAdView.h"
#import "ANInterstitialAd.h"
#import <CoreLocation/CoreLocation.h>

#define SV_BACKGROUND_COLOR_RED 77.0
#define SV_BACKGROUND_COLOR_BLUE 83.0
#define SV_BACKGROUND_COLOR_GREEN 78.0
#define SV_BACKGROUND_COLOR_ALPHA 1.0 // On a scale from 0 -> 1

@interface AdPreviewTVC () <ANInterstitialAdDelegate, ANBannerAdViewDelegate, UIScrollViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) ANBannerAdView *bannerAdView;
@property (strong, nonatomic) ANInterstitialAd *interstitialAd;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) CLLocation *lastLocation;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation AdPreviewTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.bannerAdView.rootViewController = self.parentViewController;
}

- (void)setup {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    
    [self.refreshControl addTarget:self action:@selector(reloadAd) forControlEvents:UIControlEventValueChanged];
    self.scrollView.backgroundColor = [UIColor colorWithRed:SV_BACKGROUND_COLOR_RED/255.0
                                                      green:SV_BACKGROUND_COLOR_GREEN/255.0
                                                       blue:SV_BACKGROUND_COLOR_BLUE/255.0
                                                      alpha:SV_BACKGROUND_COLOR_ALPHA];
    [self loadAd];
}

- (void)loadAd {
    AdSettings *settings = [[AdSettings alloc] init]; // New settings on every load. This could be easily modified to support recycling the settings on every load.

    if (settings.adType == AD_TYPE_BANNER) {
        ANLogDebug(@"%@ %@ | loading banner", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        [self clearInterstitialAd];
        [self loadBannerAdWithSettings:settings];
    } else if (settings.adType == AD_TYPE_INTERSTITIAL) {
        ANLogDebug(@"%@ %@ | loading interstitial", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        [self clearBannerAdView];
        [self loadInterstitialAdWithSettings:settings];
    }
}

- (void)reloadAd {
    [self.refreshControl beginRefreshing];
    [self loadAd];
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (void)loadBannerAdWithSettings:(AdSettings *)settings {
    CGFloat settingsBannerWidth = (CGFloat)settings.bannerWidth;
    CGFloat settingsBannerHeight = (CGFloat)settings.bannerHeight;
    NSString *settingsPlacementID = [NSString stringWithFormat:@"%d", settings.placementID];
    BOOL settingsAllowPSA = settings.allowPSA;
    BOOL settingsClickShouldOpenInBrowser = (settings.browserType == BROWSER_TYPE_DEVICE);
    CGFloat settingsAutoRefreshInterval = (CGFloat)settings.refreshRate;
    
    CGFloat centerX = 0.0;
    CGFloat centerY = 0.0;
    if (settingsBannerWidth < self.tableView.frame.size.width) {
        centerX = (self.tableView.frame.size.width / 2.0) - (settingsBannerWidth / 2.0);
    }
    
    if (settingsBannerHeight < self.tableView.frame.size.height) {
        centerY = (self.tableView.frame.size.height / 2.0) - (settingsBannerHeight / 2.0);
    }
    
    [self clearBannerAdView]; // Clear old banner ad view
                              // Make New BannerAdView
    self.bannerAdView = [[ANBannerAdView alloc] initWithFrame:CGRectMake(centerX, centerY, settingsBannerWidth, settingsBannerHeight)];
    self.bannerAdView.delegate = self;
    self.bannerAdView.rootViewController = self.parentViewController;
    self.bannerAdView.adSize = CGSizeMake(settingsBannerWidth, settingsBannerHeight);
    self.bannerAdView.placementId = settingsPlacementID;
    self.bannerAdView.shouldServePublicServiceAnnouncements = settingsAllowPSA;
    self.bannerAdView.clickShouldOpenInBrowser = settingsClickShouldOpenInBrowser;
    if (self.lastLocation) {
        [self.bannerAdView setLocationWithLatitude:self.lastLocation.coordinate.latitude
                                         longitude:self.lastLocation.coordinate.longitude
                                         timestamp:self.lastLocation.timestamp
                                horizontalAccuracy:self.lastLocation.horizontalAccuracy];
    }
    
    [self.bannerAdView setAutoRefreshInterval:settingsAutoRefreshInterval];
    [self.scrollView addSubview:self.bannerAdView];
    
    if(!settings.refreshRate) { // If there's no refresh rate, then manually load one ad
        ANLogDebug(@"%@ %@ | no refresh rate, manually loading ad", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        [self.bannerAdView loadAd];
    }
}

- (void)loadInterstitialAdWithSettings:(AdSettings *)settings {
    NSString *settingsPlacementID = [NSString stringWithFormat:@"%d", settings.placementID];
    BOOL settingsAllowPSA = settings.allowPSA;
    BOOL settingsClickShouldOpenInBrowser = (settings.browserType == BROWSER_TYPE_DEVICE);
    NSString *backgroundColor = settings.backgroundColor;

    [self clearInterstitialAd];
    
    self.interstitialAd = [[ANInterstitialAd alloc] initWithPlacementId:settingsPlacementID];
    self.interstitialAd.delegate = self;
    self.interstitialAd.shouldServePublicServiceAnnouncements = settingsAllowPSA;
    self.interstitialAd.clickShouldOpenInBrowser = settingsClickShouldOpenInBrowser;
    self.interstitialAd.backgroundColor = [self interstitialBackgroundColorFromString:backgroundColor];
    if (self.lastLocation) {
        [self.interstitialAd setLocationWithLatitude:self.lastLocation.coordinate.latitude
                                           longitude:self.lastLocation.coordinate.longitude
                                           timestamp:self.lastLocation.timestamp
                                  horizontalAccuracy:self.lastLocation.horizontalAccuracy];
    }
    
    [self.interstitialAd loadAd];
}

- (UIColor *)interstitialBackgroundColorFromString:(NSString *)backgroundColor {
    NSScanner *scanner = [NSScanner scannerWithString:backgroundColor];
    unsigned int scannedValue;
    [scanner scanHexInt:&scannedValue];
    
    int alpha = (scannedValue & 0xFF000000) >> 24;
    int red = (scannedValue & 0xFF0000) >> 16;
    int green = (scannedValue & 0xFF00) >> 8;
    int blue = (scannedValue & 0xFF);

    UIColor *color = [UIColor colorWithRed:red/255.0
                                     green:green/255.0
                                      blue:blue/255.0
                                     alpha:alpha/255.0];
    
    ANLogDebug(@"%@ %@ | interstitial background color: Red %d, Green %d, Blue %d, Alpha %d",
          NSStringFromClass([self class]), NSStringFromSelector(_cmd), red, green, blue, alpha);
    
    return color;
}

- (void)clearBannerAdView {
    if (self.bannerAdView) {
        [self.bannerAdView removeFromSuperview];
    }
    self.bannerAdView.delegate = nil;
    self.bannerAdView = nil;
}

- (void)clearInterstitialAd {
    self.interstitialAd.delegate = nil;
    self.interstitialAd = nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Everytime the tableView asks for the cell height, it's because it needs the information to lay itself out.
    // In theory, this method should be called *exactly* each time the subviews needs to be positioned/repositioned
    
    if (self.bannerAdView) {
        // ScrollView width should be the banner width or the tableView width, whichever is greater
        CGSize bannerSize = self.bannerAdView.frame.size;
        CGFloat svWidth = (bannerSize.width > self.tableView.frame.size.width) ? bannerSize.width : self.tableView.frame.size.width;
        // ScrollView height should be the banner height or the tableView height, whichever is greater. This will also correspond to the cell height (which is returned).
        CGFloat svHeight = (bannerSize.height > self.tableView.frame.size.height) ? bannerSize.height : self.tableView.frame.size.height;
        
        ANLogDebug(@"%@ %@ | adjusting scroll view", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        self.scrollView.contentSize = CGSizeMake(svWidth, svHeight); // Set content size to cell dimensions
        
        ANLogDebug(@"%@ %@ | adjusting banner ad view frame", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        
        CGFloat centerX = (self.tableView.frame.size.width - bannerSize.width) / 2.0;
        CGFloat centerY = (self.tableView.frame.size.height - bannerSize.height) / 2.0;
        
        // Center banner in window, with equal whitespace on either side
        [self.bannerAdView setFrame:CGRectMake(centerX,
                                               centerY,
                                             bannerSize.width, bannerSize.height)];
        
        return svHeight;
    } else { // Not a banner, so scrollview size should be the visible table view size
        CGFloat svWidth = self.tableView.frame.size.width;
        CGFloat svHeight = self.tableView.frame.size.height;
        self.scrollView.contentSize = CGSizeMake(svWidth, svHeight); // Set content size to cell dimensions
        return svHeight; // cell height equal to tableView height
    }
}

/*
 Delegate Methods
 */

- (void)adFailedToDisplay:(ANInterstitialAd *)ad {
    ANLogDebug(@"adFailedToDisplay");
}

- (void)ad:(id<ANAdProtocol>)ad requestFailedWithError:(NSError *)error {
    ANLogDebug(@"adFailed");
}

- (void)adDidReceiveAd:(id<ANAdProtocol>)ad {
    ANLogDebug(@"adDidReceiveAd");
    if (self.interstitialAd && self.interstitialAd == ad) {
        [self.interstitialAd displayAdFromViewController:self.parentViewController]; // on load, immediately display interstitial
    }
}

- (void)adWasClicked:(id<ANAdProtocol>)ad {
    ANLogDebug(@"adWasClicked");
}

- (void)adDidClose:(id<ANAdProtocol>)ad {
    ANLogDebug(@"adDidClose");
}

- (void)adWillClose:(id<ANAdProtocol>)ad {
    ANLogDebug(@"adWillClose");
}

- (void)adWillPresent:(id<ANAdProtocol>)ad {
    ANLogDebug(@"adWillPresent");
}

- (void)adDidPresent:(id<ANAdProtocol>)ad {
    ANLogDebug(@"adDidPresent");
}

- (void)adWillLeaveApplication:(id<ANAdProtocol>)ad {
    ANLogDebug(@"adWillLeaveApplication");
}

/*
    Explictly deallocating ad views on controller deallocation to avoid a memory leak.
 */
- (void)dealloc {
    ANLogDebug(@"%@ %@ | deallocating ad views", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self clearBannerAdView];
    [self clearInterstitialAd];
}

// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    // If it's a relatively recent event, turn off updates to save power.
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 30.0) {
        self.lastLocation = location;
    }
}

@end
