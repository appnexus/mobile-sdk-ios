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

#import "RootViewController.h"
#import "ANDemoAdsViewController.h"
#import "ANDemoConsoleViewController.h"

static NSUInteger kNumberOfPages = 2;

@interface RootViewController ()
{
	BOOL __rotating;
}

@property (nonatomic, readwrite, assign) BOOL pageControlUsed;
@property (nonatomic, readwrite, assign, getter = isRotating) BOOL rotating;
@property (nonatomic, readwrite, strong) CLLocationManager *locationManager;

- (void)loadScrollViewWithPage:(int)page;
- (void)scrollViewDidScroll:(UIScrollView *)sender;

@end

@implementation RootViewController

@synthesize scrollView = __scrollView, pageControl = __pageControl, viewControllers = __viewControllers, pageControlUsed = __pageControlUsed;

- (id)init
{
	self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
	
	if (self != nil)
	{
		
	}
	
	return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// view controllers are created lazily
    // in the meantime, load the array with placeholders which will be replaced on demand
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (unsigned i = 0; i < kNumberOfPages; i++) {
        [controllers addObject:[NSNull null]];
    }
    self.viewControllers = controllers;
	
	self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
	
    self.pageControl.numberOfPages = kNumberOfPages;
    self.pageControl.currentPage = 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self removeExistingViewsFromScrollView];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self redrawScrollView];
	[self updateLocation];
}

- (void)updateLocation
{
	if ([CLLocationManager locationServicesEnabled])
    {
        CLLocationManager *lm = [[CLLocationManager alloc] init];
        lm.delegate = self;
        lm.desiredAccuracy = kCLLocationAccuracyBest;
        lm.distanceFilter = kCLDistanceFilterNone;
        [lm startUpdatingLocation];
        self.locationManager = lm;
    }
}

- (void)redrawScrollView
{
	// a page is the width of the scroll view
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * kNumberOfPages, self.scrollView.frame.size.height);
	
    // pages are created on demand
    // load the visible page
    // load the page on either side to avoid flashes when the user starts scrolling
    [self loadScrollViewWithPage:self.pageControl.currentPage];
	self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width * self.pageControl.currentPage, 0);	
}

- (void)removeExistingViewsExceptCurrentFromScrollView
{
	UIViewController *currentController = [self viewControllerForPage:self.pageControl.currentPage];
	
	for (UIViewController *controller in self.viewControllers)
	{
		if ([controller isKindOfClass:[UIViewController class]] && controller != currentController)
		{
			[controller.view removeFromSuperview];
		}
	}
}

- (void)removeExistingViewsFromScrollView
{
	for (UIViewController *controller in self.viewControllers)
	{
		if ([controller isKindOfClass:[UIViewController class]])
		{
			[controller.view removeFromSuperview];
		}
	}
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	self.rotating = YES;
	
	[[self viewControllerForPage:self.pageControl.currentPage] willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	
	[UIView beginAnimations:@"rotationAnimation" context:NULL];
	[UIView setAnimationDuration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	self.rotating = NO;
	[self removeExistingViewsFromScrollView];
	[self redrawScrollView];
	[UIView commitAnimations];
	
	[[self viewControllerForPage:self.pageControl.currentPage] didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (UIViewController *)viewControllerForPage:(NSInteger)page
{
	UIViewController *controller = [self.viewControllers objectAtIndex:page];
	
	if ((NSNull *)controller == [NSNull null])
	{
		if (page == 0)
		{
			controller = [[ANDemoAdsViewController alloc] init];
		}
		else if (page == 1)
		{
			controller = [[ANDemoConsoleViewController alloc] init];
		}
		
		[self.viewControllers replaceObjectAtIndex:page withObject:controller];
    }
	
	return controller;
}

- (void)loadScrollViewWithPage:(int)page {
    if (page < 0) return;
    if (page >= kNumberOfPages) return;
	
    // replace the placeholder if necessary
    UIViewController *controller = [self viewControllerForPage:page];
	
    // add the controller's view to the scroll view
    if (nil == controller.view.superview) {
        CGRect frame = self.scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        [self.scrollView addSubview:controller.view];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
	// We also don't want rotation to cause page shift. We're going to redraw the interface when rotation is complete anyway, so disable this if rotation is happening.
    if (self.pageControlUsed || self.isRotating)
	{
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
	
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
	
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
	
    // A possible optimization would be to unload the views+controllers which are no longer visible
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.pageControlUsed = NO;
}

- (IBAction)changePage:(id)sender {
    int page = self.pageControl.currentPage;
	
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
	
    // update the scroll view to the appropriate page
    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [self.scrollView scrollRectToVisible:frame animated:YES];
	
    // Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
    self.pageControlUsed = YES;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [manager stopUpdatingLocation];
    
    CLLocation *location = [locations lastObject];
    ANLogDebug(@"Current location detected as %@", location);
}
#else
- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
    [manager stopUpdatingLocation];
    
    CLLocation *location = newLocation;
	ANLogDebug(@"Current location detected as %@", location);
}
#endif

@end
