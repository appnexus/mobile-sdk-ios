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

#import <UIKit/UIKit.h>

#import "ANAdWebViewController.h"



@protocol ANAdViewInternalDelegate;



@interface ANMRAIDContainerView : UIView

- (instancetype)initWithSize:(CGSize)size
                        HTML:(NSString *)html
              webViewBaseURL:(NSURL *)baseURL;

- (instancetype) initWithSize: (CGSize)size
                     videoXML: (NSString *)videoXML;


@property (nonatomic, readonly, assign)                         CGSize  size;
@property (nonatomic, readonly, assign, getter=isResponsiveAd)  BOOL    responsiveAd;
@property (nonatomic, readonly)                                 BOOL    isBannerVideo;

@property (nonatomic, readonly, strong)     ANAdWebViewController                       *webViewController;

@property (nonatomic, readwrite, weak)      id<ANAdWebViewControllerLoadingDelegate>     loadingDelegate;
@property (nonatomic, readwrite, weak)      id<ANAdViewInternalDelegate>                 adViewDelegate;

@property (nonatomic, readwrite, assign)    BOOL  embeddedInModalView;
@property (nonatomic , readwrite, assign)   BOOL  shouldDismissOnClick;

@end
