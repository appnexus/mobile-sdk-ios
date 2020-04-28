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

#import <CoreLocation/CoreLocation.h>

#import "SimpleViewController.h"

#import "ANBannerAdView.h"
#import "ANMultiAdRequest.h"

#import "ANLogManager.h"
#import "ANLocation.h"



/*
    BETA -- Lazy Webview

    To use this informal test environment...

        1. See initial lines of viewDidLoad
            a. Choose one of the tests: testAdUnit, testMultiAdRequest
            b. Set the Placement ID and Member ID
        2. Run the app -- watch the console log and the Simulator
 */



#pragma mark -

@interface SimpleViewController () <ANBannerAdViewDelegate, CLLocationManagerDelegate, ANMultiAdRequestDelegate>

@property (nonatomic, readwrite, strong)  ANBannerAdView  *banner1;
@property (nonatomic, readwrite, strong)  ANBannerAdView  *banner2;

@property (nonatomic, readwrite, strong)    NSString    *placementID1;

@property (nonatomic, readwrite)            NSInteger    memberID;


@property (nonatomic, readwrite, strong)  CLLocationManager  *locationManager;
@property (nonatomic, readwrite, strong)  NSString           *clickThroughURL;

@end



#pragma mark -

@implementation SimpleViewController

#pragma mark Lifecycle.

- (void)viewDidLoad
{
    [super viewDidLoad];

    [ANLogManager setANLogLevel:ANLogLevelAll];   //DEBUG

    //
//    BOOL  testAdUnit          = YES;
    BOOL  testAdUnit          = NO;

    BOOL  testMultiAdRequest  = YES;
//    BOOL  testMultiAdRequest  = NO;

    //
    self.placementID1   = @"19065996";
    self.memberID       = 10094;


    //
    [self createAdUnits];


    // Informal test of AdUnit or MAR instance.
    //
    if (testAdUnit) {
        [self runTestAdUnit];

    } else if (testMultiAdRequest) {
        [self runTestMAR];

    } else {
        NSLog(@"APP ERROR  %s -- No tests selected.", __PRETTY_FUNCTION__);
    }
}




#pragma mark - Test methods.

- (void)runTestAdUnit
{
    NSLog(@"APP MARK  %s", __PRETTY_FUNCTION__);

    [self.view addSubview:self.banner1];

    [self.banner1 loadAd];

    [self locationSetup];  // If you want to pass location...
}

- (void)runTestMAR
{
    NSLog(@"APP MARK  %s", __PRETTY_FUNCTION__);


    ANMultiAdRequest  *mar  = [[ANMultiAdRequest alloc] initWithMemberId:self.memberID andDelegate:self];

    [mar addAdUnit:self.banner1];
    [mar addAdUnit:self.banner2];

    [mar load];




}




#pragma mark - Helper methods.

- (void)createAdUnits
{
    int  adWidth   = 300;
    int  adHeight  = 250;

    // We want to center our ad on the screen.
    CGRect   screenRect  = [[UIScreen mainScreen] bounds];
    CGFloat  originX     = (screenRect.size.width / 2) - (adWidth / 2);
    CGFloat  originY     = (screenRect.size.height / 2) - (adHeight / 2);

    // Needed for when we create our ad view.
    CGRect  rect  = CGRectMake(originX, originY, adWidth, adHeight);
    CGSize  size  = CGSizeMake(adWidth, adHeight);


    // Make some banner ad views.
    //
    self.banner1 = [ANBannerAdView adViewWithFrame:rect placementId:self.placementID1 adSize:size];

    self.banner1.delegate                 = self;
    self.banner1.rootViewController       = self;
    self.banner1.autoRefreshInterval      = 0;
    self.banner1.shouldAllowVideoDemand   = NO;      // self.banner1 is always Banner-banner.
    self.banner1.shouldAllowNativeDemand  = NO;

    self.banner1.externalUid              = @"banner-banner";

    self.banner1.enableLazyWebviewLoad    = YES;


    //
    self.banner2 = [ANBannerAdView adViewWithFrame:rect placementId:self.placementID1 adSize:size];

    self.banner2.delegate                 = self;
    self.banner2.rootViewController       = self;
    self.banner2.autoRefreshInterval      = 0;
    self.banner2.shouldAllowVideoDemand   = YES;
    self.banner2.shouldAllowNativeDemand  = YES;

    self.banner2.externalUid              = @"banner-multiformat";

    self.banner2.enableLazyWebviewLoad    = NO;
}


- (void)locationSetup
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;

    [self.locationManager startUpdatingLocation];
}

// We implement the delegate method from the `CLLocationManagerDelegate` protocol.  This allows
// us to update the banner's location whenever the device's location is updated.
//
- (void)locationManager: (CLLocationManager *)manager
     didUpdateLocations: (NSArray *)locations
{
    CLLocation* location = [locations lastObject];

    self.banner1.location = [ANLocation getLocationWithLatitude: location.coordinate.latitude
                                                      longitude: location.coordinate.longitude
                                                      timestamp: location.timestamp
                                             horizontalAccuracy: location.horizontalAccuracy];
}




#pragma mark - ANAdProtocol

- (void)adDidReceiveAd:(id)ad {
    NSLog(@"Ad did receive ad");
}

- (void)lazyAdDidReceiveAd:(id)ad
{
    NSLog(@"Lazy ad did receive ad");

    if (self.banner1.enableLazyWebviewLoad)
                //FIX  dowse class type and etset for lazy
    {
//        [NSThread sleepForTimeInterval:5.0];   //DEBUG
        [self.banner1 loadWebview];
    }
}

- (void)ad:(id)ad requestFailedWithError:(NSError *)error {
            //FIX -- note if lazy
    NSLog(@"Ad failed to load: %@", error);
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




#pragma mark - ANMultiAdRequestDelegate

- (void)multiAdRequestDidComplete:(ANMultiAdRequest *)mar
{
    NSLog(@"APP MARK  %s", __PRETTY_FUNCTION__);
}

- (void)multiAdRequest:(ANMultiAdRequest *)mar didFailWithError:(NSError *)error
{
    NSLog(@"APP MARK  %s", __PRETTY_FUNCTION__);
}


@end
