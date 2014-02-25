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
#import <CoreLocation/CoreLocation.h>
#import "ANAdProtocol.h"

@protocol AppNexusSDKAppPreviewVCDelegate;

@interface AdPreviewTVC : UITableViewController
@property (strong, nonatomic) CLLocation *lastLocation;
@property (strong, nonatomic) id<AppNexusSDKAppPreviewVCDelegate> delegate;
@end

@protocol AppNexusSDKAppPreviewVCDelegate <NSObject>

- (void)ad:(id<ANAdProtocol>)ad requestFailedWithError:(NSError *)error;
- (void)adDidReceiveAd:(id<ANAdProtocol>)ad;

@end
