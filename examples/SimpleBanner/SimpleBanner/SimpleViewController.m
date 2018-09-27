/*   Copyright 2014 APPNEXUS INC
 
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

#import "SimpleViewController.h"
#import "ANBannerAdView.h"
#import "ANLogManager.h"
#import <CoreLocation/CoreLocation.h>
#import "ANLocation.h"



@interface SimpleViewController () <ANBannerAdViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, readwrite, strong) CLLocationManager *locationManager;
@property (nonatomic, readwrite, strong) ANBannerAdView *banner;
@property (nonatomic, readwrite, strong) NSString *clickThroughURL;


@end

@implementation SimpleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    int adWidth  = 300;
    int adHeight = 250;
    NSString *adID = @"1281482";
    
    // We want to center our ad on the screen.
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat originX = (screenRect.size.width / 2) - (adWidth / 2);
    CGFloat originY = (screenRect.size.height / 2) - (adHeight / 2);
    
    // Needed for when we create our ad view.
    CGRect rect = CGRectMake(originX, originY, adWidth, adHeight);
    CGSize size = CGSizeMake(adWidth, adHeight);
    
    // Make a banner ad view.
    ANBannerAdView *banner = [ANBannerAdView adViewWithFrame:rect placementId:adID adSize:size];
    banner.externalUid = @"123e4567e89b12da456426655440000";
    banner.rootViewController = self;
    banner.delegate = self;
    banner.clickThroughAction = ANClickThroughActionReturnURL;
    [self.view addSubview:banner];
    
    // Since this example is for testing, we'll turn on PSAs and verbose logging.
    banner.shouldServePublicServiceAnnouncements = true;
    [ANLogManager setANLogLevel:ANLogLevelDebug];
    
    // Load an ad.
    [banner loadAd];
    
    [self locationSetup]; // If you want to pass location...
    self.banner = banner;
}

- (void)locationSetup {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
}

// We implement the delegate method from the `CLLocationManagerDelegate` protocol.  This allows
// us to update the banner's location whenever the device's location is updated.
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    CLLocation* location = [locations lastObject];
    self.banner.location = [ANLocation getLocationWithLatitude:location.coordinate.latitude
                                                     longitude:location.coordinate.longitude
                                                     timestamp:location.timestamp
                                            horizontalAccuracy:location.horizontalAccuracy];
}

- (void)adDidReceiveAd:(id)ad {
    NSLog(@"Ad did receive ad");
}


- (void)adDidClose:(id)ad {
    NSLog(@"Ad did close");
}

- (void)adWasClicked:(id)ad {
    NSLog(@"Ad was clicked");
}

- (void)adWasClicked:(id)ad withURLString:(NSString *)urlString
{
    NSLog(@"ClickThroughURL=%@", urlString);
}


- (void)ad:(id)ad requestFailedWithError:(NSError *)error {
    NSLog(@"Ad failed to load: %@", error);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
