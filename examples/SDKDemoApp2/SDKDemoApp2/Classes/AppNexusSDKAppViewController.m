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

#import "AppNexusSDKAppViewController.h"

// Tab Bar Item View Controllers
#import "AdSettingsViewController.h"
#import "AdPreviewTVC.h"
#import "DebugSettingsViewController.h"
#import "LogCoreDataTVC.h"

// Notification Logging
#import "ANRequest+Make.h"
#import "ANLog+Make.h"
#import "ANResponse.h"
#import "ANAdFetcher.h"
#import "ANLogging.h"

#define DOCUMENT_NAME @"Log Document"
#define REQUEST_NOTIFICATION @"AppNexusSDKAppViewControllerUpdatedRequest"

@interface AppNexusSDKAppViewController () <UITabBarDelegate, LoadPreviewVCDelegate>

// Parent View Controller Items
@property (weak, nonatomic) IBOutlet UITabBar *mainTabBar;
@property (weak, nonatomic) IBOutlet UITabBarItem *previewTabBarItem;
@property (weak, nonatomic) IBOutlet UITabBarItem *settingsTabBarItem;
@property (weak, nonatomic) IBOutlet UITabBarItem *debugTabBarItem;
@property (weak, nonatomic) IBOutlet UITabBarItem *logTabBarItem;
@property (weak, nonatomic) IBOutlet UIView *containerView;

// Tab Bar Item Child View Controllers
@property (strong, nonatomic) UIViewController *controllerInView;
//@property (strong, nonatomic) UINavigationController *settings;
//@property (strong, nonatomic) UINavigationController *preview;
@property (strong, nonatomic) AdSettingsViewController *settings;
@property (strong, nonatomic) AdPreviewTVC *preview;
@property (strong, nonatomic) UINavigationController *debug;
@property (strong, nonatomic) LogCoreDataTVC *log;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@end

@implementation AppNexusSDKAppViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)setup {
    [self setInitialVCTabBarItem]; // Set Initially Selected Tab Bar Item
    // Register for the log notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adFetcherWillRequestAd:)
                                                 name:kANAdFetcherWillRequestAdNotification
                                               object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adFetcherDidReceiveResponse:)
                                                 name:kANAdFetcherDidReceiveResponseNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ANLoggingNotifications:)
                                                 name:kANLoggingNotification
                                               object:nil];
    self.mainTabBar.delegate = self; // Set Parent VC as delegate of the Tab Bar
    [self anLogoSetup]; // Fix AN Logo constraints
    [self useLogDocument]; // Create/Open Logging Document
}

/*
    Sets width == height constraint for AN Logo in upper left corner of parent view controller.
    This isn't possible to do in the storyboard, so I'm doing it here.
    This is necessary to support loading on devices with varying tab bar heights (i.e. iPad vs. iPhone)
 */
- (void)anLogoSetup {
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.iconImageView
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.iconImageView
                                                                  attribute:NSLayoutAttributeWidth
                                                                 multiplier:1.0
                                                                   constant:0.0];
    [self.view addConstraint:constraint];
}

/*
    Child View Controller Methods
 */

- (void)loadInitialVC {
    [self setInitialVCTabBarItem];
    [self loadPreviewVC];
}

- (void)setInitialVCTabBarItem {
    if ([self.mainTabBar selectedItem] != self.previewTabBarItem) {
        [self.mainTabBar setSelectedItem:self.previewTabBarItem];
    }
}

- (void)loadSettingsVC {
    if (!self.settings) {
        self.settings = [self.storyboard instantiateViewControllerWithIdentifier:@"AdSettingsViewController"];
        self.settings.previewLoader = self;
    }
    if (self.controllerInView != self.settings) {
        [self bringChildViewControllerIntoView:self.settings];
    }
}

- (void)loadPreviewVC {
    if (!self.preview) {
        self.preview = [self.storyboard instantiateViewControllerWithIdentifier:@"AdPreviewTVC"];
    }
    if (self.controllerInView != self.preview) {
        [self bringChildViewControllerIntoView:self.preview];
    }
}

- (void)loadDebugVC {
    if (!self.debug) {
        self.debug = [self.storyboard instantiateViewControllerWithIdentifier:@"DebugAuctionNavigationController"];
        if ([[self.debug.viewControllers objectAtIndex:0] isKindOfClass:[DebugSettingsViewController class]]) {
            DebugSettingsViewController *dsvc = (DebugSettingsViewController *)[self.debug.viewControllers objectAtIndex:0];
            dsvc.managedObjectContext = self.managedObjectContext;
        }
    }
    if (self.controllerInView != self.debug) {
        [self bringChildViewControllerIntoView:self.debug];
    }
}

- (void)loadLogVC {
    if (!self.log) {
        self.log = [self.storyboard instantiateViewControllerWithIdentifier:@"LogViewController"];
        self.log.managedObjectContext = self.managedObjectContext;
    }
    if (self.controllerInView != self.log) {
        [self bringChildViewControllerIntoView:self.log];
    }
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if ([item isEqual:self.previewTabBarItem]) {
        [self loadPreviewVC];
    } else if ([item isEqual:self.settingsTabBarItem]) {
        [self loadSettingsVC];
    } else if ([item isEqual:self.debugTabBarItem]) {
        [self loadDebugVC];
    } else if ([item isEqual:self.logTabBarItem]) {
        [self loadLogVC];
    } else {
        [self bringChildViewControllerIntoView:[[UIViewController alloc] init]];
    }
}

- (void)bringChildViewControllerIntoView:(UIViewController *)newController {
    if (self.controllerInView) { // removing current view controller from the view
        [self.controllerInView willMoveToParentViewController:nil];
        [self.controllerInView.view removeFromSuperview];
        [self.controllerInView removeFromParentViewController];
    }
    
    // setting the new view controller with same bounds as current container view.
    // This is necessary in case VC was instantiated in one orientation, then user moves away and rotates device before moving back.
    newController.view.frame = CGRectMake(0, 0, self.containerView.frame.size.width, self.containerView.frame.size.height);
    
    // Add new controller as child view controller, and new view as container view subview
    [self addChildViewController:newController];
    [self.containerView addSubview:newController.view];
    
    // notify new controller that its parent view controller has changed
    [newController didMoveToParentViewController:self];
    
    // keeping a strong pointer to the current controller
    self.controllerInView = newController;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (self.controllerInView == self.settings) {
        self.settings.view.frame = CGRectMake(0, 0, self.containerView.frame.size.width, self.containerView.frame.size.height);
    }
}

/*
    Blind communication for AdSettingsViewController to communicate back to its parent view controller, in order for
    it to switch to the preview tab. When "Show Ad" button is clicked, AdSettingsViewController will call this method 
    through LoadPreviewVCDelegate. This parent class implements that delegate, which consists of this one method.
 */
- (void)forceLoadPreviewVCWithReset {
    [self.mainTabBar setSelectedItem:self.previewTabBarItem];
    self.preview = nil;
    [self loadPreviewVC];
}


/*
    Notification Logging
 */

// Logs ANLog Notifications
- (void)ANLoggingNotifications:(NSNotification *)notification {
    id output = [[notification userInfo] objectForKey:kANLogMessageKey];
    
    NSManagedObjectContext *moc = self.managedObjectContext;
    [moc performBlockAndWait:^() {
        [ANLog storeLogOutput:[output description]
                     withName:nil
                       onDate:[NSDate date]
         withOriginatingClass:nil
                 fromAppNexus:YES
                withProcessID:[[NSProcessInfo processInfo] processIdentifier]
       inManagedObjectContext:self.managedObjectContext];
    }];
}

// Logs kANAdFetcherAdRequestURLKey Notifications
- (void)adFetcherWillRequestAd:(NSNotification *)notification {
	NSURL *url = [[notification userInfo] objectForKey:kANAdFetcherAdRequestURLKey];
    NSManagedObjectContext *moc = self.managedObjectContext;
    [moc performBlockAndWait:^() {
        [ANRequest storeRequestOutput:[url absoluteString]
                               onDate:[NSDate date]
               inManagedObjectContext:self.managedObjectContext];
        
        [ANRequest lastRequestMadeInManagedObjectContext:self.managedObjectContext];
        ANLogDebug(@"%@ %@ | Stored request URL: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), request.text);
        // broadcast that request has been uploaded
        [[NSNotificationCenter defaultCenter] postNotificationName:REQUEST_NOTIFICATION object:self.managedObjectContext];
    }];
}

// Logs kANAdFetcherAdResponseKey Notifications
- (void)adFetcherDidReceiveResponse:(NSNotification *)notification {
	id response = [[notification userInfo] objectForKey:kANAdFetcherAdResponseKey];
    NSManagedObjectContext *moc = self.managedObjectContext;
    [moc performBlockAndWait:^() {
        [ANRequest storeResponseOutput:[response description]
                                onDate:[NSDate date]
                inManagedObjectContext:self.managedObjectContext];
        
        [ANRequest lastRequestMadeInManagedObjectContext:self.managedObjectContext];
        ANLogDebug(@"%@ %@ | Stored response from server: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), request.response.text);
        // broadcast that the response has been uploaded
        [[NSNotificationCenter defaultCenter] postNotificationName:REQUEST_NOTIFICATION object:self.managedObjectContext];
    }];
}

// Opens a managed document for logging
- (void)useLogDocument {
    ANLogDebug(@"%@ %@ | Called", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:DOCUMENT_NAME];
    UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:url];
    ANLogDebug(@"%@ %@ | Document initialized: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), document);
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    document.persistentStoreOptions = options;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
        [document saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if (success) {
                self.managedObjectContext = document.managedObjectContext;
                ANLogDebug(@"%@ %@ | Created managed object context: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), self.managedObjectContext);
            } else {
                ANLogDebug(@"%@ %@ | Error - could not create document", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
            }
            [self loadInitialVC];
        }];
    } else if (document.documentState == UIDocumentStateClosed) {
        [document openWithCompletionHandler:^(BOOL success) {
            if (success) {
                self.managedObjectContext = document.managedObjectContext;
                ANLogDebug(@"%@ %@ | Opened managed object context: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), self.managedObjectContext);
            } else {
                ANLogDebug(@"%@ %@ | Error - could not open document", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
            }
            [self loadInitialVC];
        }];
    } else {
        self.managedObjectContext = document.managedObjectContext;
        ANLogDebug(@"%@ %@ | Loaded managed object context: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), self.managedObjectContext);
        [self loadInitialVC];
    }
}



@end
