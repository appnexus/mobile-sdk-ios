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
#import "InterstitialAdViewabilityTrackerTestVC.h"
#import <AppNexusSDK/AppNexusSDK.h>
#import "ANStubManager.h"
#import "ANNativeAdView.h"
#import "Constant.h"
#import "ANHTTPStubbingManager.h"

@interface InterstitialAdViewabilityTrackerTestVC () <ANInterstitialAdDelegate>{
    BOOL isAdVisible;
}
@property (nonatomic, readwrite, strong) ANInterstitialAd *interstitialAd;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *eventList;
@property (strong, nonatomic) NSArray *uiTestList;
@end

@implementation InterstitialAdViewabilityTrackerTestVC

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    // store the list of argument passed  by UI test by UI Test
    self.uiTestList = [NSProcessInfo processInfo].arguments;
    //  MockTestcase is enabled(set to 1) prepare stubbing with mock response else disable stubbing
    if(MockTestcase){
        [self prepareStubbing];
    } else {
        [[ANHTTPStubbingManager sharedStubbingManager] disable];
        [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
        [[ANStubManager sharedInstance] enableStubbing];
        [[ANStubManager sharedInstance] disableStubbing];
    }
    //  registerEventListener is used to register for tracking the URL fired by Application(or SDK)
   [self registerEventListener];

    isAdVisible = true;
    
    // Make a banner ad view.
    self.interstitialAd = [[ANInterstitialAd alloc] initWithPlacementId:BannerPlacementId];
    self.interstitialAd.delegate = self;
    self.interstitialAd.clickThroughAction = ANClickThroughActionReturnURL;
    // Set Creative Id if ForceCreative is enabled
    if(ForceCreative){
        self.interstitialAd.forceCreativeId = BannerForceCreativeId;
    }
    [self.interstitialAd loadAd];
    self.eventList = [[NSMutableArray alloc] init];
    self.tableView.hidden = YES;

}
//  registerEventListener is used to register for tracking the URL fired by Application(or SDK)
-(void)registerEventListener{
    [NSURLProtocol registerClass:[WebKitURLProtocol class]];
    [NSURLProtocol wk_registerWithScheme:@"https"];
    [NSURLProtocol wk_registerWithScheme:@"http"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateNetworkLog:)
                                                 name:@"didReceiveURLResponse"
                                               object:nil];
}
//  prepareStubbing if MockTestcase is enabled(set to 1) prepare stubbing with mock response else disable stubbing
-(void)prepareStubbing{
   
    self.title = self.adType;
    [[ANStubManager sharedInstance] disableStubbing];
    [[ANStubManager sharedInstance] enableStubbing];
    
    if( [self.uiTestList containsObject:InterstitialViewabilityTrackerTest]){
        [[ANStubManager sharedInstance] stubRequestWithResponse:@"OMID_BannerAd"];
    }
    [[ANStubManager sharedInstance] stubRequestWithResponse:@"OMID_BannerAd"];
}

- (void)adDidReceiveAd:(id)ad {
    NSLog(@"Ad did receive ad");
    [self.interstitialAd displayAdFromViewController:self autoDismissDelay:10];
}
- (void)adDidClose:(id)ad{
    [self removeInterstitialAdAdAction];
}



- (void)removeInterstitialAdAdAction {
    self.interstitialAd = nil;
    
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.tableView.hidden = NO;
        [self.tableView reloadData];
    });
    
    
}

-(void)ad:(id)ad requestFailedWithError:(NSError *)error{
    NSLog(@"Ad request Failed With Error");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


# pragma mark - Ad Server Response Stubbing
// updateNetworkLog: Will return event in fire of URL from Application(or SDK)
- (void) updateNetworkLog:(NSNotification *) notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSURLResponse *response = [userInfo objectForKey:@"response"];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *absoluteURLText = [response.URL.absoluteURL absoluteString];
        NSLog(@"absoluteURLText -> %@",absoluteURLText);
        
        
        if([absoluteURLText containsString:@"version="]){
            if( [self.uiTestList containsObject:@"VersionEvent"]){
                [self.eventList addObject:@"version="];
            }
        }else  if([absoluteURLText containsString:@"sendmessage?supported=yes"]){            
            if( [self.uiTestList containsObject:@"SupportedIsYes"]){
                [self.eventList addObject:@"supported=yes"];
            }
        }else  if([absoluteURLText containsString:@"percentageInView%5D=0"]){
          
            if( [self.uiTestList containsObject:@"Viewable0Percentage"]){
                [self.eventList addObject:@"percentageInView=0"];
                [self.eventList addObject:@"type=geometryChange"];
            }
            
            
        }else  if([absoluteURLText containsString:@"type=impression&data%5BimpressionType%5D=viewable&data%5BmediaType%5D=display&data%5BcreativeType%5D=htmlDisplay"]){
            
            if( [self.uiTestList containsObject:@"TypeImpression"]){
                [self.eventList addObject:@"type=impression"];
                [self.eventList addObject:@"impressionType=viewable"];
                [self.eventList addObject:@"mediaType=display"];
                [self.eventList addObject:@"creativeType=htmlDisplay"];
            }
            
        }else   if( [self.uiTestList containsObject:@"SessionStart"]){
            
            
            [self.eventList addObject:@"sessionStart"];
            if([absoluteURLText containsString:@"environment%5D=app"]){
                [self.eventList addObject:@"environment=app"];
            }
            if([absoluteURLText containsString:@"adSessionType%5D=html"]){
                [self.eventList addObject:@"adSessionType=html"];
            }
            if([absoluteURLText containsString:@"supports%5D%5B0%5D=clid&data%5Bcontext%5D%5Bsupports%5D%5B1%5D=vlid"]){
                [self.eventList addObject:@"supports=[clid,vlid]"];
            }
            if([absoluteURLText containsString:@"mediaType%5D=display"]){
                [self.eventList addObject:@"mediaType=display"];
            }
            if([absoluteURLText containsString:@"partnerName%5D=Appnexus"]){
                [self.eventList addObject:@"partnerName=Appnexus"];
            }
            if([absoluteURLText containsString:@"deviceInfo%5D%5BdeviceType"]){
                [self.eventList addObject:@"deviceInfo=iOS"];
            }
            if([absoluteURLText containsString:@"impressionType%5D=viewable"]){
                [self.eventList addObject:@"impressionType=viewable"];
            }
            if([absoluteURLText containsString:@"creativeType%5D=htmlDisplay"]){
                [self.eventList addObject:@"creativeType=htmlDisplay"];
            }
            if([absoluteURLText containsString:@"omidJsInfo%5D%5BserviceVersion"]){
                [self.eventList addObject:@"omidJsInfo=serviceVersion,omidImplementer:omsdk"];
            }
            if([absoluteURLText containsString:@"app%5D%5BappId"]){
                [self.eventList addObject:@"app={appId,libraryVersion}"];
            }
            if([absoluteURLText containsString:@"libraryVersion"]){
                [self.eventList addObject:@"verificationParameters=undefined"];
            }
            
            if([absoluteURLText containsString:@"accessMode%5D=limited"]){
                [self.eventList addObject:@"accessMode=limited"];
            }
            
        }else  if( [absoluteURLText containsString:@"percentageInView%5D=100"]){
            if( [self.uiTestList containsObject:@"Viewable100Percentage"]){
                [self.eventList addObject:@"percentageInView=100"];
                [self.eventList addObject:@"type=geometryChange"];
            }
        }
        
        
        else  if([absoluteURLText containsString:@"type=sessionFinish"]){
                [self.eventList addObject:@"type=sessionFinish"];
            NSLog(@"%@",self.eventList);
        }
        
        
        
        
    });
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier   forIndexPath:indexPath] ;
    NSString *value = [self.eventList objectAtIndex:indexPath.row];
    cell.textLabel.text = value;
    return cell;
}

@end
