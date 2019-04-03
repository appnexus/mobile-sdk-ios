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

#import "ViewController.h"
#import "ANBannerAdView.h"
#import "ANSDKSettings.h"
#import <CoreLocation/CoreLocation.h>


@interface ViewController ()< CLLocationManagerDelegate>
@property (nonatomic, readwrite, strong) CLLocationManager *locationManager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self hideStatusBar];
    
}
- (void)viewDidAppear:(BOOL)animated{
    [self locationSetup]; // If you want to pass location...
}

- (void)locationSetup {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        [self.locationManager requestWhenInUseAuthorization];
    
    [self.locationManager startUpdatingLocation];
    
}
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    CLLocation* location = [locations lastObject];
    NSLog(@"NewLocation %f %f", location.coordinate.latitude, location.coordinate.longitude);
}

- (void)hideStatusBar {
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self setNeedsStatusBarAppearanceUpdate];
    } else {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#if __IPHONE_9_0
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
#else
    - (NSUInteger)supportedInterfaceOrientations {
#endif
        return UIInterfaceOrientationMaskAll;
    }
    
    @end
