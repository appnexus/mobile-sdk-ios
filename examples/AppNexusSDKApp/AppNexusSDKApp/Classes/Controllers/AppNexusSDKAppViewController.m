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
#import "ANDocument.h"

#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>

#define DOCUMENT_NAME @"Log Document"
#define REQUEST_NOTIFICATION @"AppNexusSDKAppViewControllerUpdatedRequest"

@interface AppNexusSDKAppViewController () <UITabBarDelegate,
LoadPreviewVCDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate, AppNexusSDKAppPreviewVCDelegate>

#pragma mark Parent View Controller Items

@property (weak, nonatomic) IBOutlet UITabBar *mainTabBar;
@property (weak, nonatomic) IBOutlet UITabBarItem *previewTabBarItem;
@property (weak, nonatomic) IBOutlet UITabBarItem *settingsTabBarItem;
@property (weak, nonatomic) IBOutlet UITabBarItem *debugTabBarItem;
@property (weak, nonatomic) IBOutlet UITabBarItem *logTabBarItem;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;


#pragma mark Child View Controller Items
@property (strong, nonatomic) UIViewController *controllerInView;
@property (strong, nonatomic) AdSettingsViewController *settings;
@property (strong, nonatomic) AdPreviewTVC *preview;
@property (strong, nonatomic) UINavigationController *debug;
@property (strong, nonatomic) LogCoreDataTVC *log;

#pragma mark Logging Properties

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) ANDocument *document;
@property (strong, nonatomic) NSMutableArray *mediatedClasses;

#pragma mark Location Properties

@property (strong, nonatomic) CLLocation *lastLocation;
@property (strong, nonatomic) CLLocationManager *locationManager;

// Not necessary (swipe gesture works without them)
//@property (weak, nonatomic) IBOutlet UISwipeGestureRecognizer *leftSwipeGesture;
//@property (weak, nonatomic) IBOutlet UISwipeGestureRecognizer *rightSwipeGesture;

@end

@implementation AppNexusSDKAppViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)setup {
    [ANLogManager setANLogLevel:ANLogLevelAll];
    [self setInitialVCTabBarItem]; // Set Initially Selected Tab Bar Item
    [self registerForNotifications];
    self.mainTabBar.delegate = self; // Set Parent VC as delegate of the Tab Bar
    [self anLogoSetup]; // Fix AN Logo constraints
    [self useLogDocument]; // Create/Open Logging Document
    [self locationSetup];
    [self audioSetup];
    // Not necessary (swipe gesture works without them)
    //self.leftSwipeGesture.delegate = self;
    //self.rightSwipeGesture.delegate = self;
}

- (void)registerForNotifications {
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ANMediationNotifications:)
                                                 name:kANAdFetcherWillInstantiateMediatedClassNotification
                                               object:nil];
}

- (void)audioSetup {
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
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

- (void)locationSetup {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
}

- (NSMutableArray *)mediatedClasses {
    if (!_mediatedClasses) _mediatedClasses = [[NSMutableArray alloc] init];
    return _mediatedClasses;
}

#pragma mark Child View Controller Methods

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
        self.preview.lastLocation = self.lastLocation;
        self.preview.delegate = self;
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
    self.controllerInView.view.frame = CGRectMake(0, 0, self.containerView.frame.size.width, self.containerView.frame.size.height);
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

#pragma mark Notification Logging

// Logs ANLog Notifications
- (void)ANLoggingNotifications:(NSNotification *)notification {
    NSString *message = [[notification userInfo] objectForKey:kANLogMessageKey];
    NSInteger level = [[[notification userInfo] objectForKey:kANLogMessageLevelKey] integerValue];
    
    NSManagedObjectContext *moc = self.managedObjectContext;
    [moc performBlockAndWait:^() {
        [ANLog storeLogOutput:[message description]
                     withName:[AppNexusSDKAppViewController logClassFromLogLevel:level]
                       onDate:[NSDate date]
         withOriginatingClass:nil
                 fromAppNexus:YES
                withProcessID:[[NSProcessInfo processInfo] processIdentifier]
       inManagedObjectContext:self.managedObjectContext];
    }];
}

- (void)ANMediationNotifications:(NSNotification *)notification {
    NSString *mediatedClass = [[notification userInfo] objectForKey:kANAdFetcherMediatedClassKey];
    [self.mediatedClasses addObject:mediatedClass];
}

+ (NSString *)logClassFromLogLevel:(NSInteger)level {
    if (level <= ANLogLevelTrace) {
        return kAppNexusSDKAppLogLevelTrace;
    } else if (level <= ANLogLevelDebug) {
        return kAppNexusSDKAppLogLevelDebug;
    } else if (level <= ANLogLevelInfo) {
        return kAppNexusSDKAppLogLevelInfo;
    } else if (level <= ANLogLevelWarn) {
        return kAppNexusSDKAppLogLevelWarn;
    } else if (level <= ANLogLevelError) {
        return kAppNexusSDKAppLogLevelError;
    }
    return @"";
}

// Logs kANAdFetcherAdRequestURLKey Notifications
- (void)adFetcherWillRequestAd:(NSNotification *)notification {
	NSURL *url = [[notification userInfo] objectForKey:kANAdFetcherAdRequestURLKey];
    NSManagedObjectContext *moc = self.managedObjectContext;
    [moc performBlockAndWait:^() {
        [ANRequest storeRequestOutput:[url absoluteString]
                               onDate:[NSDate date]
               inManagedObjectContext:self.managedObjectContext];
        
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
        
        // broadcast that the response has been uploaded
        [[NSNotificationCenter defaultCenter] postNotificationName:REQUEST_NOTIFICATION object:self.managedObjectContext];
    }];
}

// Opens a managed document for logging
- (void)useLogDocument {
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:DOCUMENT_NAME];
    self.document = [[ANDocument alloc] initWithFileURL:url];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    self.document.persistentStoreOptions = options;

    if (![[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
        // file does not exist yet, create it
        [self.document saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if (success) {
                self.managedObjectContext = self.document.managedObjectContext;
            } else {
                ANLogError(@"%@ %@ | Error - could not create document for logging", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
            }
            [self loadInitialVC];
        }];
    } else if (self.document.documentState == UIDocumentStateClosed) {
        // file is closed, open it
        [self.document openWithCompletionHandler:^(BOOL success) {
            if (success) {
                self.managedObjectContext = self.document.managedObjectContext;
            } else {
                ANLogError(@"%@ %@ | Error - could not open logs", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
            }
            [self loadInitialVC];
        }];
    } else if (self.document.documentState == UIDocumentStateNormal) {
        self.managedObjectContext = self.document.managedObjectContext;
        [self loadInitialVC];
    } else {
        ANLogError(@"%@ %@ | Error - unexpected log document state: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), self.document.documentState);
        [self loadInitialVC];
    }
}

#pragma mark Location Manager

// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    // If it's a relatively recent event, turn off updates to save power.
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 30.0) {
        self.preview.lastLocation = location;
        self.lastLocation = location;
    }
}

#pragma mark Swipe Gestures

#define APPNEXUSSDKAPP_SETTINGS_TAB_INDEX 0
#define APPNEXUSSDKAPP_PREVIEW_TAB_INDEX 1
#define APPNEXUSSDKAPP_DEBUG_TAB_INDEX 2
#define APPNEXUSSDKAPP_LOG_TAB_INDEX 3

- (IBAction)swipeLeft:(UISwipeGestureRecognizer *)sender {
    NSInteger vcIndex = [self indexOfCurrentChildViewController];
    if (vcIndex == NSNotFound || vcIndex > APPNEXUSSDKAPP_LOG_TAB_INDEX) return;
    if (vcIndex == APPNEXUSSDKAPP_LOG_TAB_INDEX) vcIndex = -1; // wrap around
    [self loadChildViewControllerAtIndex:vcIndex+1];
}
    
- (IBAction)swipeRight:(UISwipeGestureRecognizer *)sender {
    NSInteger vcIndex = [self indexOfCurrentChildViewController];
    if (vcIndex == NSNotFound || vcIndex < APPNEXUSSDKAPP_SETTINGS_TAB_INDEX) return;
    if (vcIndex == APPNEXUSSDKAPP_SETTINGS_TAB_INDEX) vcIndex = APPNEXUSSDKAPP_LOG_TAB_INDEX + 1; // wrap around
    [self loadChildViewControllerAtIndex:vcIndex-1];
}

- (NSInteger)indexOfCurrentChildViewController {
    if (self.controllerInView == self.settings) return APPNEXUSSDKAPP_SETTINGS_TAB_INDEX;
    else if (self.controllerInView == self.preview) return APPNEXUSSDKAPP_PREVIEW_TAB_INDEX;
    else if (self.controllerInView == self.debug) return APPNEXUSSDKAPP_DEBUG_TAB_INDEX;
    else if (self.controllerInView == self.log) return APPNEXUSSDKAPP_LOG_TAB_INDEX;
    return -1;
}

- (void)loadChildViewControllerAtIndex:(NSInteger)index {
    switch (index) {
        case APPNEXUSSDKAPP_SETTINGS_TAB_INDEX:
            [self.mainTabBar setSelectedItem:self.settingsTabBarItem];
            [self tabBar:self.mainTabBar didSelectItem:self.settingsTabBarItem];
            break;
        case APPNEXUSSDKAPP_PREVIEW_TAB_INDEX:
            [self.mainTabBar setSelectedItem:self.previewTabBarItem];
            [self tabBar:self.mainTabBar didSelectItem:self.previewTabBarItem];
            break;
        case APPNEXUSSDKAPP_DEBUG_TAB_INDEX:
            [self.mainTabBar setSelectedItem:self.debugTabBarItem];
            [self tabBar:self.mainTabBar didSelectItem:self.debugTabBarItem];
            break;
        case APPNEXUSSDKAPP_LOG_TAB_INDEX:
            [self.mainTabBar setSelectedItem:self.logTabBarItem];
            [self tabBar:self.mainTabBar didSelectItem:self.logTabBarItem];
            break;
        default:
            break;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

#pragma mark AppNexusSDKAppPreviewVCDelegate

- (void)adDidReceiveAd:(id<ANAdProtocol>)ad {
    if ([self mediatedClasses]) {
        ANLogInfo([self prettyPrintMediatedClasses]);
    }
    self.mediatedClasses = nil;
}

- (void)ad:(id<ANAdProtocol>)ad requestFailedWithError:(NSError *)error {
    if ([self mediatedClasses]) {
        ANLogInfo([self prettyPrintMediatedClasses]);
    }
    self.mediatedClasses = nil;
}

#pragma mark Other Methods

- (NSString *)prettyPrintMediatedClasses {
    NSMutableString *ppstring = nil;
    if (self.mediatedClasses) {
        ppstring = [[NSMutableString alloc] init];
        [ppstring appendString:@"Mediating Classes:"];
        for (NSInteger index=[self.mediatedClasses count]-1; index >= 0; index--) {
            [ppstring appendFormat:@"\n%d: %@", index+1, [self.mediatedClasses objectAtIndex:index]];
        }
    }
    return [ppstring copy];
}

@end
