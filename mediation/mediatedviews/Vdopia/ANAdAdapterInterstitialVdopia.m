/*   Copyright 2015 APPNEXUS INC
 
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

#import "ANAdAdapterInterstitialVdopia.h"
#import "LVDOInterstitialView.h"
#import "ANLogging.h"
#import "UIView+ANCategory.h"

#pragma mark - ANVdopiaInterstitialAdViewController

@interface ANVdopiaInterstitialAdViewController : UIViewController

@property (nonatomic, readwrite, assign) UIInterfaceOrientation orientation;

@end

@implementation ANVdopiaInterstitialAdViewController

- (instancetype)init {
    if (self = [super init]) {
        _orientation = [[UIApplication sharedApplication] statusBarOrientation];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

#if __IPHONE_9_0
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
#else
- (NSUInteger)supportedInterfaceOrientations {
#endif
    switch (self.orientation) {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            return UIInterfaceOrientationMaskLandscape;
        case UIInterfaceOrientationPortraitUpsideDown:
        case UIInterfaceOrientationPortrait:
        default:
            return UIInterfaceOrientationMaskPortrait;
    }
}

@end

#pragma mark -
#pragma mark - ANAdAdapterInterstitialVdopia

@interface ANAdAdapterInterstitialVdopia ()

@property (nonatomic, readwrite, strong) LVDOInterstitialView *adViewController;
@property (nonatomic, readwrite, strong) ANVdopiaInterstitialAdViewController *interstitialAdViewController;
@property (nonatomic, readwrite, weak) UIViewController *rootViewController;
@property (nonatomic, readwrite, assign) BOOL isReady;

@end

@implementation ANAdAdapterInterstitialVdopia

#pragma mark ANCustomAdapterInterstitial

@synthesize delegate = _delegate;

- (void)presentFromViewController:(UIViewController *)viewController {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (self.isReady) {
        [self.adViewController showInterstitialView];
        self.rootViewController = viewController;
    } else {
        ANLogDebug(@"%@ %@ | failedToDisplayAd", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        [self.delegate failedToDisplayAd];
    }
}

- (void)requestInterstitialAdWithParameter:(NSString *)parameterString
                                  adUnitId:(NSString *)idString
                       targetingParameters:(ANTargetingParameters *)targetingParameters {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    self.adViewController = [[LVDOInterstitialView alloc] initWithAdUnitID:idString
                                                                  delegate:self];
    LVDOAdRequest *adRequest = [[self class] adRequestFromTargetingParameters:targetingParameters];
    self.interstitialAdViewController = [[ANVdopiaInterstitialAdViewController alloc] init];
    [self.interstitialAdViewController.view addSubview:self.adViewController.view];
    [self.adViewController load:adRequest];
}

#pragma mark LVDOAdViewDelegate

- (void)adViewDidReceiveAd {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    self.isReady = YES;
    [self.delegate didLoadInterstitialAd:self];
}

- (void)adViewWillPresentScreen {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (self.rootViewController) {
        [self.rootViewController presentViewController:self.interstitialAdViewController
                                              animated:YES
                                            completion:nil];
    } else {
        ANLogDebug(@"%@ %@ | failedToDisplayAd", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        [self.delegate failedToDisplayAd];
    }
}

- (void)adViewWillDismissScreen {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    __weak ANAdAdapterInterstitialVdopia *weakSelf = self;
    [self.delegate willCloseAd];
    [self.rootViewController dismissViewControllerAnimated:YES
                                                completion:^{
                                                    ANAdAdapterInterstitialVdopia *strongSelf = weakSelf;
                                                    [strongSelf.delegate didCloseAd];
                                                }];
}

- (void)adViewDidDismissScreen {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

- (void)dealloc {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    self.adViewController.delegate = nil;
}

@end