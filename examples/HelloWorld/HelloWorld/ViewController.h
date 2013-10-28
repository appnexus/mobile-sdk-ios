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

#import <UIKit/UIKit.h>
#import "ANBannerAdView.h"
#import "ANInterstitialAd.h"
#import "GADBannerViewDelegate.h"

@interface ViewController : UIViewController <ANAdDelegate, ANInterstitialAdDelegate, CLLocationManagerDelegate, GADBannerViewDelegate>
{

}

- (IBAction)loadInterstitialAd:(id)sender;
- (IBAction)showInterstitialAd:(id)sender;
- (IBAction)showCurrentLocation:(id)sender;

@property (nonatomic, readwrite, assign) IBOutlet UILabel *locationLabel;
@property (nonatomic, readwrite, assign) IBOutlet UIButton *loadInterstitialAd;
@property (nonatomic, readwrite, assign) IBOutlet UIButton *showInterstitialAd;
@property (nonatomic, readwrite, assign) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@end
