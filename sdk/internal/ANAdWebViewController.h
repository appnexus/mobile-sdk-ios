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

#import <Foundation/Foundation.h>
#import <EventKitUI/EventKitUI.h>
#import <UIKit/UIKit.h>
#import "ANMRAIDViewController.h"

@class ANAdFetcher;

@interface ANAdWebViewController : NSObject <UIWebViewDelegate>
{
    __weak ANAdFetcher *__adFetcher;
    UIWebView *__webView;
	BOOL __completedFirstLoad;
}

@property (nonatomic, readwrite, weak) ANAdFetcher *adFetcher;
@property (nonatomic, readwrite, strong) UIWebView *webView;

@end

@interface ANMRAIDAdWebViewController : ANAdWebViewController
{
    BOOL __expanded;
    BOOL __allowOrientationChagne;

}

@property (nonatomic, readwrite, assign) BOOL expanded;
@property (nonatomic, readwrite, strong) ANMRAIDViewController *controller;
@end

