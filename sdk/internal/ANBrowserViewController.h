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

@protocol ANBrowserViewControllerDelegate;

@interface ANBrowserViewController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate>

@property (nonatomic, readwrite, weak) IBOutlet UIBarButtonItem *forwardButton;
@property (nonatomic, readwrite, weak) IBOutlet UIBarButtonItem *backButton;
@property (nonatomic, readwrite, weak) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, readwrite, weak) IBOutlet UIBarButtonItem *openInButton;
@property (nonatomic, readwrite, weak) IBOutlet UIWebView *webView;

- (IBAction)closeAction:(id)sender;
- (IBAction)forwardAction:(id)sender;
- (IBAction)backAction:(id)sender;
- (IBAction)openInAction:(id)sender;

@property (nonatomic, readonly, assign) BOOL completedInitialLoad;
@property (nonatomic, readonly, assign, getter=isLoading) BOOL loading;
@property (nonatomic, readwrite, strong) NSURL *url;
@property (nonatomic, readwrite, weak) id<ANBrowserViewControllerDelegate> delegate;

- (instancetype)initWithURL:(NSURL *)url;
+ (void)launchURL:(NSURL *)url withDelegate:(id<ANBrowserViewControllerDelegate>)delegate;

@end

@protocol ANBrowserViewControllerDelegate <NSObject>

@optional
- (void)browserViewControllerShouldDismiss:(ANBrowserViewController *)controller;
- (void)browserViewControllerShouldPresent:(ANBrowserViewController *)controller;
- (void)browserViewControllerWillLaunchExternalApplication;
- (void)browserViewController:(ANBrowserViewController *)controller browserIsLoading:(BOOL)isLoading;

@end