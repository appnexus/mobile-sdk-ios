/*   Copyright 2020 APPNEXUS INC
 
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
#import <TrackerApp-Swift.h>
#import "ViewabilityBannerNativeAdViewController.h"
#import <AppNexusSDK/AppNexusSDK.h>
#import "ANStubManager.h"
#import "ANNativeAdView.h"
#import "SDKValidationURLProtocol.h"
#import "NSURLRequest+HTTPBodyTesting.h"
#import "ANNativeAdResponse+PrivateMethods.h"
#import "Constant.h"

@interface NativeAdViewabilityTrackerTestVC () <ANBannerAdViewDelegate,ANNativeAdDelegate,SDKValidationURLProtocolDelegate,ANNativeAdResponseProtocol,ANNativeAdRequestDelegate>{
    BOOL isAdVisible;
}


@property (nonatomic, readwrite, strong) ANBannerAdView *banner;
@property (weak, nonatomic) IBOutlet UILabel *impressionTracker;
@property (weak, nonatomic) IBOutlet UILabel *clickTracker;
@property (nonatomic,readwrite,strong) ANNativeAdResponse *nativeAdResponse;
@property (nonatomic,readwrite,strong) ANNativeAdRequest *nativeAdRequest;
@property (weak, nonatomic) ANNativeAdView *nativeAdView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *eventList;

@end

@implementation NativeAdViewabilityTrackerTestVC

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    if(MockTestcase){
        [self prepareStubbing];
    }

    int adWidth  = 300;
    int adHeight = 250;
    NSString *adID = @"15215010";
    isAdVisible = true;
    
    // We want to center our ad on the screen.
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat originX = (screenRect.size.width / 2) - (adWidth / 2);
    CGFloat originY = (screenRect.size.height / 2) - (adHeight / 2);
    
    // Needed for when we create our ad view.
    CGRect rect = CGRectMake(originX, originY, adWidth, adHeight);
    CGSize size = CGSizeMake(adWidth, adHeight);
    
    // Make a banner ad view.
    
    if([self.adType isEqual:@"ViewabilityBannerNative"] || [self.adType isEqualToString:@"ViewabilityBannerNativeRenderer"]){
        self.banner = [ANBannerAdView adViewWithFrame:rect placementId:adID adSize:size];
        self.banner.rootViewController = self;
        self.banner.shouldAllowNativeDemand = YES;
        self.banner.enableNativeRendering = YES;
        self.banner.shouldAllowVideoDemand = NO;
        self.banner.delegate = self;
        self.banner.clickThroughAction = ANClickThroughActionOpenSDKBrowser;
        self.banner.accessibilityIdentifier = @"bannerAdElements";
        [self.view addSubview:self.banner];
        self.banner.shouldServePublicServiceAnnouncements = NO;
        self.banner.autoRefreshInterval = 0;
        [self.banner loadAd];
    }else if([self.adType isEqual:@"ViewabilityNative"]){
        
        self.nativeAdRequest= [[ANNativeAdRequest alloc] init];
        self.nativeAdRequest.placementId = @"19212468";
        self.nativeAdRequest.gender = ANGenderMale;
        self.nativeAdRequest.shouldLoadIconImage = YES;
        self.nativeAdRequest.shouldLoadMainImage = YES;
        self.nativeAdRequest.delegate = self;
        [self.nativeAdRequest loadAd];
    }
    
    [SDKValidationURLProtocol setDelegate:self];
    [NSURLProtocol registerClass:[SDKValidationURLProtocol class]];
    self.eventList = [[NSMutableArray alloc] init];
    self.tableView.hidden = YES;
    
    
}

-(void)prepareStubbing{
    
    [NSURLProtocol registerClass:[WebKitURLProtocol class]];
    [NSURLProtocol wk_registerWithScheme:@"https"];
    [NSURLProtocol wk_registerWithScheme:@"http"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateNetworkLog:)
                                                 name:@"didReceiveURLResponse"
                                               object:nil];
    self.title = self.adType;
    [[ANStubManager sharedInstance] disableStubbing];
    [[ANStubManager sharedInstance] enableStubbing];
    
    if([self.adType isEqualToString:@"ViewabilityBannerNative"] || [self.adType isEqualToString:@"ViewabilityNative"]){
        [[ANStubManager sharedInstance] stubRequestWithResponse:@"RTBBannerNativeAd"];
    }else if ([self.adType isEqualToString:@"ViewabilityBannerNativeRenderer"]){
        [[ANStubManager sharedInstance] stubRequestWithResponse:@"RTBBannerNativeRendererAd"];
        
    }
}

- (void)adDidReceiveAd:(id)ad {
    NSLog(@"Ad did receive ad");
}

-(void)ad:(id)ad requestFailedWithError:(NSError *)error{
    NSLog(@"Ad request Failed With Error");
}

- (void)adRequest:(ANNativeAdRequest *)request didReceiveResponse:(ANNativeAdResponse *)response {
    self.nativeAdResponse = response;
    [self renderNativeAdResponse];
}
- (void)ad:(id)loadInstance didReceiveNativeAd:(id)responseInstance{
    self.nativeAdResponse = (ANNativeAdResponse *)responseInstance;
    [self renderNativeAdResponse];
    
}

-(void)renderNativeAdResponse{
    
    UINib *adNib = [UINib nibWithNibName:@"ANNativeAdView" bundle:[NSBundle mainBundle]];
    NSArray *array = [adNib instantiateWithOwner:self options:nil];
    self.nativeAdView = [array firstObject];
    self.nativeAdView.titleLabel.text = self.nativeAdResponse.title;
    self.nativeAdView.bodyLabel.text = self.nativeAdResponse.body;
    self.nativeAdView.iconImageView.image = self.nativeAdResponse.iconImage;
    self.nativeAdView.mainImageView.image = self.nativeAdResponse.mainImage;
    self.nativeAdView.sponsoredLabel.text = self.nativeAdResponse.sponsoredBy;
    
    [self.nativeAdView.callToActionButton setTitle:self.nativeAdResponse.callToAction forState:UIControlStateNormal];
    self.nativeAdResponse.delegate = self;
    self.nativeAdResponse.clickThroughAction = ANClickThroughActionOpenSDKBrowser;
    
    [self.view addSubview:self.nativeAdView];
    
    [self.nativeAdResponse registerViewForTracking:self.nativeAdView
                            withRootViewController:self
                                    clickableViews:@[self.nativeAdView.callToActionButton,self.nativeAdView.mainImageView]
                                             error:nil];
}

- (void)adRequest:(nonnull ANNativeAdRequest *)request didFailToLoadWithError:(nonnull NSError *)error withAdResponseInfo:(nullable ANAdResponseInfo *)adResponseInfo {
    NSLog(@"Ad request Failed With Error");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


# pragma mark - Ad Server Response Stubbing

- (void) updateNetworkLog:(NSNotification *) notification
{
    //    NSDictionary *userInfo = notification.userInfo;
    //    NSURLResponse *response = [userInfo objectForKey:@"response"];
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        NSString *absoluteURLText = [response.URL.absoluteURL absoluteString];
    //        NSLog(@"absoluteURLText -> %@",absoluteURLText);
    //
    //    });
}

# pragma mark - Intercept HTTP Request Callback

- (void)didReceiveIABResponse:(NSString *)response {
    NSLog(@"OMID response %@",response);
    
    if([response containsString:@"OmidSupported%5Btrue%5D%22"]){
        [self.eventList addObject:@"OmidSupported=true"];
    }else if([response containsString:@"type%22%3A%22sessionStart%22%2C%22data%22%3A%7B%22context%22%3A%7B%22apiVersion%22%3A%221.0%22%2C%22accessMode%22%3A%22limited%22%2C%22environment%22%3A%22app%22%2C%22omidJsInfo%22%3A%7B%22omidImplementer%22%3A%22omsdk%22%2C%22serviceVersion%22%3A%221.3.7-iab2228%22%7D%2C%22omidNativeInfo%22%3A%7B%22partnerName%22%3A%22Appnexus%22%2C%22partnerVersion%22%3A%227.8%22%7D%2C%22adSessionType%22%3A%22native%22%2C%22app%22%3A%7B%22appId%22%3A%22com.xandr.SimpleIntegration%22%2C%22libraryVersion%22%3A%221.3.7-Appnexus%22%7D%2C%22deviceInfo%22%3A%7B%22deviceType%22%3A%22x86_64%22%2C%22os%22%3A%22iOS%22%2C%22osVersion%22%3A%2214.1%22%7D%2C%22supports%22%3A%5B%22clid%22%2C%22vlid%22%5D%7D%2C%22impressionType%22%3A%22viewable%22%2C%22mediaType%22%3A%22display%22%2C%22creativeType%22%3A%22nativeDisplay%22%2C%22supportsLoadedEvent%22%3Atrue%2C%22pageUrl%22%3Anull%2C%22contentUrl%22%3Anull%7D%7D"]){
        
        
        
        
        
        [self.eventList addObject:@"sessionStart"];
        [self.eventList addObject:@"accessMode=limited"];
        [self.eventList addObject:@"partnerName=Appnexus"];
        [self.eventList addObject:@"mediaType=display"];
        [self.eventList addObject:@"creativeType=nativeDisplay"];
    }
    
    else if ([response containsString:@"type%22%3A%22loaded%22%2C%22data%22%3A%7B%22impressionType%22%3A%22viewable%22%2C%22mediaType%22%3A%22display%22%2C%22creativeType%22%3A%22nativeDisplay%22%7D%7D"]){
        
        [self.eventList addObject:@"type=loaded"];
        [self.eventList addObject:@"impressionType=viewable"];
        [self.eventList addObject:@"mediaType=display"];
        [self.eventList addObject:@"creativeType=nativeDisplay"];
        
    }
    else if([response containsString:@"type%22%3A%22geometryChange%22%2C%22data%22%3A%7B%22viewport%22%3A%7B%22width%22%3A390%2C%22height%22%3A844%7D%2C%22adView%22%3A%7B%22percentageInView%22%3A77%2C%22reasons%22%3A%5B%22obstructed%22%5D%2C%22geometry%22%3A%7B%22width%22%3A320%2C%22height%22%3A400%2C%22x%22%3A0%2C%22y%22%3A0%2C%22pixels%22%3A128000%7D%2C%22onScreenGeometry%22%3A%7B%22width%22%3A320%2C%22height%22%3A400%2C%22x%22%3A0%2C%22y%22%3A0%2C%22pixels%22%3A98880%2C%22obstructions%22%3A%5B%7B%22width%22%3A390%2C%22height%22%3A91%2C%22x%22%3A0%2C%22y%22%3A0%7D%2C%7B%22width%22%3A390%2C%22height%22%3A0.3333333333333286%2C%22x%22%3A0%2C%22y%22%3A91%7D%2C%7B%22width%22%3A390%2C%22height%22%3A44%2C%22x%22%3A0%2C%22y%22%3A47%7D%5D%2C%22friendlyObstructions%22%3A%5B%5D%7D%7D%2C%22declaredFriendlyObstructions%22%3A0%7D%7D"]){
        
        [self.eventList addObject:@"impressionType=viewable"];
        [self.eventList addObject:@"mediaType=display"];
        [self.eventList addObject:@"creativeType=nativeDisplay"];
        
    }
    else if([response containsString:@"type%22%3A%22geometryChange%22%2C%22data%22%3A%7B%22viewport%22%3A%7B%22width%22%3A390%2C%22height%22%3A844%7D%2C%22adView%22%3A%7B%22percentageInView%22%3A0%2C%22reasons%22%3A%5B%22hidden%22%5D%2C%22geometry%22%3A%7B%22width%22%3A320%2C%22height%22%3A400%2C%22x%22%3A0%2C%22y%22%3A0%2C%22pixels%22%3A128000%7D%2C%22onScreenGeometry%22%3A%7B%22width%22%3A0%2C%22height%22%3A0%2C%22x%22%3A0%2C%22y%22%3A0%2C%22pixels%22%3A0%2C%22obstructions%22%3A%5B%5D%2C%22friendlyObstructions%22%3A%5B%5D%7D%7D%2C%22declaredFriendlyObstructions%22%3A0%7D%7D"] || [response containsString:@"type%22%3A%22geometryChange%22%2C%22data%22%3A%7B%22viewport%22%3A%7B%22width%22%3A390%2C%22height%22%3A844%7D%2C%22adView%22%3A%7B%22percentageInView%22%3A0%2C%22reasons%22%3A%5B%22hidden%22%5D%2C%22geometry%22%3A%7B%22width%22%3A300%2C%22height%22%3A250%2C%22x%22%3A45%2C%22y%22%3A297%2C%22pixels%22%3A75000%7D%2C%22onScreenGeometry%22%3A%7B%22width%22%3A0%2C%22height%22%3A0%2C%22x%22%3A0%2C%22y%22%3A0%2C%22pixels%22%3A0%2C%22obstructions%22%3A%5B%5D%2C%22friendlyObstructions%22%3A%5B%5D%7D%7D%2C%22declaredFriendlyObstructions%22%3A0%7D%7D"]){
        
        [self.eventList addObject:@"percentageInView=0"];
    }
    
    else if([response containsString:@"type%22%3A%22geometryChange%22%2C%22data%22%3A%7B%22viewport%22%3A%7B%22width%22%3A390%2C%22height%22%3A844%7D%2C%22adView%22%3A%7B%22percentageInView%22%3A100%2C%22reasons%22%3A%5B%5D%2C%22geometry%22%3A%7B%22width%22%3A300%2C%22height%22%3A250%2C%22x%22%3A45%2C%22y%22%3A297%2C%22pixels%22%3A75000%7D%2C%22onScreenGeometry%22%3A%7B%22width%22%3A300%2C%22height%22%3A250%2C%22x%22%3A45%2C%22y%22%3A297%2C%22pixels%22%3A75000%2C%22obstructions%22%3A%5B%5D%2C%22friendlyObstructions%22%3A%5B%5D%7D%7D%2C%22declaredFriendlyObstructions%22%3A0%7D%7D"] || [response containsString:@"type%22%3A%22impression%22%2C%22data%22%3A%7B%22viewport%22%3A%7B%22width%22%3A390%2C%22height%22%3A844%7D%2C%22adView%22%3A%7B%22percentageInView%22%3A100%2C%22reasons%22%3A%5B%5D%2C%22geometry%22%3A%7B%22width%22%3A300%2C%22height%22%3A250%2C%22x%22%3A45%2C%22y%22%3A297%2C%22pixels%22%3A75000%7D%2C%22onScreenGeometry%22%3A%7B%22width%22%3A300%2C%22height%22%3A250%2C%22x%22%3A45%2C%22y%22%3A297%2C%22pixels%22%3A75000%2C%22obstructions%22%3A%5B%5D%2C%22friendlyObstructions%22%3A%5B%5D%7D%7D%2C%22declaredFriendlyObstructions%22%3A0%2C%22impressionType%22%3A%22viewable%22%2C%22mediaType%22%3A%22display%22%2C%22creativeType%22%3A%22nativeDisplay%22%7D%7D"]){
        [self.eventList addObject:@"percentageInView=100"];
    }
    
    
    else if([response containsString:@"type%22%3A%22sessionFinish%22%7D"]){
        
        [self.eventList addObject:@"type=sessionFinish"];
        NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:self.eventList];
        self.eventList = [[orderedSet array] mutableCopy];
        
        NSLog(@"OMID Summary %@",self.eventList);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.tableView.hidden = false;
            [self.tableView reloadData];
        });
        
    }
    
}

- (IBAction)removeBannerAdAction:(id)sender {
    
    
    
  
    if([self.adType isEqualToString:@"ViewabilityBannerNative"] || [self.adType isEqualToString:@"ViewabilityNative"]){
        [self.nativeAdResponse unregisterViewFromTracking];
        self.nativeAdResponse.delegate = nil;
        self.nativeAdResponse = nil;
        
        
        self.nativeAdRequest.delegate = nil;
        self.nativeAdRequest = nil;
        
        [self.nativeAdView removeFromSuperview];
        self.nativeAdView = nil;
    }else if ([self.adType isEqualToString:@"ViewabilityBannerNativeRenderer"]){
        
        [self.banner removeFromSuperview];
        self.banner = nil;
    }
    
    
}
- (IBAction)hideShowAdAction:(id)sender {
 
    
    
    if([self.adType isEqualToString:@"ViewabilityBannerNative"] || [self.adType isEqualToString:@"ViewabilityNative"]){
        if(isAdVisible){
            self.nativeAdView.hidden = true;
        }else{
            self.nativeAdView.hidden = false;
        }
    }else if ([self.adType isEqualToString:@"ViewabilityBannerNativeRenderer"]){
        if(isAdVisible){
            self.banner.hidden = true;
        }else{
            self.banner.hidden = false;
        }
    }
    
    
    
    isAdVisible = !isAdVisible;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.eventList.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier  forIndexPath:indexPath] ;
    NSString *value = [self.eventList objectAtIndex:indexPath.row];
    cell.textLabel.text = value;
    return cell;
}
@end

