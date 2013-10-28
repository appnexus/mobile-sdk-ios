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

#import "ViewController.h"
#import "GADBannerView.h"

@interface ViewController ()
@property (nonatomic, readwrite, strong) ANBannerAdView *bannerAdView;
@property (nonatomic, readwrite, strong) ANInterstitialAd *interstitialAd;
@property (nonatomic, readwrite, strong) CLLocationManager *locationManager;
@property (nonatomic, readwrite, strong) GADBannerView *gadBannerView;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    CGFloat centerx = 0.0;
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        centerx = self.view.center.y - self.bannerAdView.bounds.size.width / 2;
    }
    else
    {
        centerx = self.view.center.x - self.bannerAdView.bounds.size.width / 2;
    }
    
    self.bannerAdView = [ANBannerAdView adViewWithFrame:CGRectMake(centerx - 300/2, 0, 300, 50) placementId:@"656561"];
    
    [self.view addSubview:self.bannerAdView];
    self.bannerAdView.autorefreshInterval = 10.0;
    
    self.interstitialAd = [[ANInterstitialAd alloc] initWithPlacementId:@"1326299"];
    self.interstitialAd.delegate = self;
    
    self.showInterstitialAd.enabled = NO;
    
    self.gadBannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner origin:CGPointMake(centerx - kGADAdSizeBanner.size.width / 2, 50)];
    self.gadBannerView.adUnitID = @"c51029d5d4574253";
    self.gadBannerView.rootViewController = self;
    self.gadBannerView.delegate = self;
    GADRequest *request = [GADRequest request];
    [self.gadBannerView loadRequest:request];
    
    [self.view addSubview:self.gadBannerView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    [UIView animateWithDuration:duration animations:^{
        CGRect adViewFrame = self.bannerAdView.frame;
        CGFloat centerx = 0.0;
        if (UIInterfaceOrientationIsLandscape(interfaceOrientation))
        {
            centerx = self.view.center.y - self.bannerAdView.bounds.size.width / 2;
        }
        else
        {
            centerx = self.view.center.x - self.bannerAdView.bounds.size.width / 2;
        }
        self.bannerAdView.frame = CGRectMake(centerx, adViewFrame.origin.y, adViewFrame.size.width, adViewFrame.size.height);
        
        CGRect gadBannerViewFrame = self.gadBannerView.frame;
        self.gadBannerView.frame = CGRectMake(centerx, gadBannerViewFrame.origin.y, gadBannerViewFrame.size.width, gadBannerViewFrame.size.height);
    }];
}

- (IBAction)loadInterstitialAd:(id)sender
{
    [self.interstitialAd loadAd];
}

- (IBAction)showInterstitialAd:(id)sender
{
    [self.interstitialAd displayAdFromViewController:self];
}

- (IBAction)showCurrentLocation:(id)sender
{
    if ([CLLocationManager locationServicesEnabled])
    {
        [self.activityIndicatorView startAnimating];
        CLLocationManager *lm = [[CLLocationManager alloc] init];
        lm.delegate = self;
        lm.desiredAccuracy = kCLLocationAccuracyBest;
        lm.distanceFilter = kCLDistanceFilterNone;
        [lm startUpdatingLocation];
        self.locationManager = lm;
    }
}

#pragma mark ANAdDelegate
- (void)adDidReceiveAd:(id<ANAdProtocol>)ad
{
    if (ad == self.interstitialAd)
    {
        self.showInterstitialAd.enabled = YES;
    }
}

- (void)ad:(id<ANAdProtocol>)ad requestFailedWithError:(NSError *)error
{
    
}

#pragma mark ANInterstitialAdDelegate

- (void)adNoAdToShow:(ANInterstitialAd *)ad
{
    self.showInterstitialAd.enabled = NO;
}

#pragma mark CLLocationManagerDelegate

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [manager stopUpdatingLocation];
    
    CLLocation *location = [locations lastObject];
    self.locationLabel.text = [location description];
    
    self.locationManager = nil;
    [self.activityIndicatorView stopAnimating];
}
#else
- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
    [manager stopUpdatingLocation];
    
    CLLocation *location = newLocation;
    self.locationLabel.text = [location description];
    
    self.locationManager = nil;
    [self.activityIndicatorView stopAnimating];
}
#endif

@end
