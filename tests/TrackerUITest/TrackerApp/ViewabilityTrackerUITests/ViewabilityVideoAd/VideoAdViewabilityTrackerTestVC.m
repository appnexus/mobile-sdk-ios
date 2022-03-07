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
#import "VideoAdViewabilityTrackerTestVC.h"
#import <AppNexusSDK/AppNexusSDK.h>
#import "ANStubManager.h"
#import "Constant.h"
#import "ANHTTPStubbingManager.h"

@interface VideoAdViewabilityTrackerTestVC () <ANInstreamVideoAdLoadDelegate, ANInstreamVideoAdPlayDelegate>{
    BOOL isAdVisible;
}
@property (weak, nonatomic) IBOutlet UIView *videoPlayerAd;

@property (nonatomic, readwrite, strong) ANInstreamVideoAd *videoAd;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *eventList;
@property (strong, nonatomic) NSArray *uiTestList;

@end

@implementation VideoAdViewabilityTrackerTestVC

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    // store the list of argument passed  by UI test by UI Test
    self.uiTestList = [NSProcessInfo processInfo].arguments;
    
    //  MockTestcase is enabled(set to 1) prepare stubbing with mock response else disable stubbing
    if(MockTestcase){
        [self prepareStubbing];
    }   else {
        [[ANHTTPStubbingManager sharedStubbingManager] disable];
        [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
        [[ANStubManager sharedInstance] enableStubbing];
        [[ANStubManager sharedInstance] disableStubbing];
    }
    isAdVisible = true;
    //  registerEventListener is used to register for tracking the URL fired by Application(or SDK)
    [self registerEventListener];

    
    
    // Make a banner ad view.
    self.videoAd = [[ANInstreamVideoAd alloc] init];
    self.videoAd = [[ANInstreamVideoAd alloc] initWithPlacementId:VideoPlacementId];
    // Set Creative Id if ForceCreative is enabled
  if(ForceCreative){
        self.videoAd.forceCreativeId = VideoForceCreativeId;
    }
    [self.videoAd loadAdWithDelegate:self];
    self.videoAd.clickThroughAction = ANClickThroughActionOpenSDKBrowser;
    self.tableView.hidden = YES;
    
    self.eventList = [[NSMutableArray alloc] init];
    
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
    
    if( [self.uiTestList containsObject:VideoViewabilityTrackerTest]){
        [[ANStubManager sharedInstance] stubRequestWithResponse:@"OMID_VideoAd"];
    }
    
    
}


- (void)adDidReceiveAd:(id)ad {
    NSLog(@"Ad did receive ad");
    [self.videoAd playAdWithContainer:self.videoPlayerAd withDelegate:self];
    // To Hide add after 2 second so that we can track the Viewablity zero
    [NSTimer scheduledTimerWithTimeInterval:2.0
                                     target:self
                                   selector:@selector(hideShowAdAction)
                                   userInfo:nil
                                    repeats:NO];
}

// To Hide/Show add after 2 second so that we can track the Viewablity 0% & 100%
-(void) hideShowAdAction {
    
    if( [self.uiTestList containsObject:VideoViewabilityTrackerTest]  ){
        if(isAdVisible){
            self.videoPlayerAd.hidden = true;
            [NSTimer scheduledTimerWithTimeInterval:5.0
                                             target:self
                                           selector:@selector(hideShowAdAction)
                                           userInfo:nil
                                            repeats:NO];
        }else{
            self.videoPlayerAd.hidden = false;
        }
    }
    isAdVisible = !isAdVisible;
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
            if( [[NSProcessInfo processInfo].arguments containsObject:@"SupportedIsYes"]){
                [self.eventList addObject:@"version="];
            }
        }else  if([absoluteURLText containsString:@"supported=yes"]){
            if( [[NSProcessInfo processInfo].arguments containsObject:@"SupportedIsYes"]){
                [self.eventList addObject:@"supported=yes"];
            }
            
        
    }else  if([absoluteURLText containsString:@"type=sessionStart"] ||
              [absoluteURLText containsString:@"apiVersion%5D=1"] ||
              [absoluteURLText containsString:@"accessMode%5D=limited"] ||
              [absoluteURLText containsString:@"environment%5D=app"] ||
              [absoluteURLText containsString:@"omidJsInfo%5D%5BomidImplementer%5D=omsdk"] ||
              [absoluteURLText containsString:@"serviceVersion"] ||
              [absoluteURLText containsString:@"partnerName%5D=Appnexus"]){

            
            if( [[NSProcessInfo processInfo].arguments containsObject:@"SessionStart"]){
                
                [self.eventList addObject:@"sessionStart"];
                [self.eventList addObject:@"partnerName=Appnexus"];
                [self.eventList addObject:@"omidImplementer=omsdk"];
                [self.eventList addObject:@"accessMode=limited"];
                [self.eventList addObject:@"partnerVersion"];
                [self.eventList addObject:@"supports=[clid,vlid]"];
                [self.eventList addObject:@"adSessionType=html"];
                [self.eventList addObject:@"impressionType=definedByJavaScript"];
                [self.eventList addObject:@"mediaType=video"];
                [self.eventList addObject:@"creativeType=definedByJavaScript"];
                [self.eventList addObject:@"supportsLoadedEvent=true"];
                [self.eventList addObject:@"verificationParameters=iabtechlab-appnexus"];
                [self.eventList addObject:@"deviceInfo=iOS"];
                [self.eventList addObject:@"environment=app"];
                [self videoAdTestCompletionAction];
            }
            
            
            
        }else  if([absoluteURLText containsString:@"percentageInView%5D=0"]){
            
            if( [[NSProcessInfo processInfo].arguments containsObject:@"OmidPercentageInView"]){
                
                [self.eventList addObject:@"percentageInView=0"];
            }
            
        }else  if([absoluteURLText containsString:@"type=loaded"]){
//            &data%5Bskippable%5D=true&data%5BautoPlay%5D=true&data%5Bposition%5D=In-Video&data%5BskipOffset%5D=0&data%5BimpressionType%5D=beginToRender&data%5BmediaType%5D=video&data%5BcreativeType%5D=video
            
            
            if( [[NSProcessInfo processInfo].arguments containsObject:@"OMIDBeginToRenderer"]){
                [self.eventList addObject:@"type=loaded"];
                [self.eventList addObject:@"skippable=true"];
                [self.eventList addObject:@"position=In-Video"];
                [self.eventList addObject:@"autoPlay=true"];
                [self.eventList addObject:@"impressionType=beginToRender"];
                [self.eventList addObject:@"mediaType=video"];
                [self.eventList addObject:@"creativeType=video"];
            }
            
        }
        
        // Next
        
        else  if([absoluteURLText containsString:@"type=start"] &&  [absoluteURLText containsString:@"duration%5D=32.23"] && [absoluteURLText containsString:@"mediaPlayerVolume%5D=1"]&&   [absoluteURLText containsString:@"deviceVolume"] &&  [absoluteURLText containsString:@"videoPlayerVolume%5D=1"]){
                        
            if( [[NSProcessInfo processInfo].arguments containsObject:@"OMIDBeginToRenderer"]){
                [self.eventList addObject:@"type=start"];
                [self.eventList addObject:@"duration=32.23"];
                [self.eventList addObject:@"mediaPlayerVolume=1"];
                [self.eventList addObject:@"deviceVolume"];
                [self.eventList addObject:@"videoPlayerVolume"];
            }
            
        }
        else  if([absoluteURLText containsString:@"type=volumeChange"] && [absoluteURLText containsString:@"mediaPlayerVolume%5D=1"] && [absoluteURLText containsString:@"videoPlayerVolume%5D=1"]){
            
            
            if( [[NSProcessInfo processInfo].arguments containsObject:@"OMIDVolumeChange"]){
                
                
                [self.eventList addObject:@"type=volumeChange"];
                [self.eventList addObject:@"mediaPlayerVolume=1"];
                [self.eventList addObject:@"videoPlayerVolume =1"];

            }
            
            
        }
        
        
        else  if([absoluteURLText containsString:@"type=volumeChange"] || [absoluteURLText containsString:@"videoPlayerVolume%5D=0"]){

            if( [[NSProcessInfo processInfo].arguments containsObject:@"OMIDVolumeChange"]){
                [self.eventList addObject:@"type=volumeChange"];
                [self.eventList addObject:@"mediaPlayerVolume=1"];
                [self.eventList addObject:@"videoPlayerVolume =0"];
                
            }
            
        }
        
        
//        type=impression&data%5BimpressionType%5D=beginToRender&data%5BmediaType%5D=video&data%5BcreativeType%5D=video
        else  if([absoluteURLText containsString:@"type=impression"]){
            if( [[NSProcessInfo processInfo].arguments containsObject:@"OMIDBeginToRenderer"]){
                
                [self.eventList addObject:@"type=impression"];
                [self.eventList addObject:@"impressionType=beginToRender"];
                [self.eventList addObject:@"creativeType=video"];
                [self.eventList addObject:@"mediaType=video"];
            }
        }
    
        else  if([absoluteURLText containsString:@"type=pause&data=undefined"]){
            if( [[NSProcessInfo processInfo].arguments containsObject:@"OMIDScreenEvent"]){
                
                [self.eventList addObject:@"type=pause"];
            }
        }
        else  if([absoluteURLText containsString:@"type=resume&data=undefined"]){
            if( [[NSProcessInfo processInfo].arguments containsObject:@"OMIDScreenEvent"]){
                [self.eventList addObject:@"type=resume"];
            }
        }
        else  if([absoluteURLText containsString:@"percentageInView"] || [absoluteURLText containsString:@"100"]){
            if( [[NSProcessInfo processInfo].arguments containsObject:@"OmidPercentageInView"]){
                
                [self.eventList addObject:@"percentageInView=100"];
            }
        }
        else  if([absoluteURLText containsString:@"type=firstQuartile&data=undefined"]){
            if( [[NSProcessInfo processInfo].arguments containsObject:@"QuartileEvent"]){
                [self.eventList addObject:@"type=firstQuartile"];
            }
        }
     
        else  if([absoluteURLText containsString:@"type=midpoint&data=undefined"]){
            if( [[NSProcessInfo processInfo].arguments containsObject:@"QuartileEvent"]){
                [self.eventList addObject:@"type=midpoint"];
            }
        }
        else  if([absoluteURLText containsString:@"type=thirdQuartile&data=undefined"]){
            if( [[NSProcessInfo processInfo].arguments containsObject:@"QuartileEvent"]){
                
                [self.eventList addObject:@"type=thirdQuartile"];
            }
        }
        else  if([absoluteURLText containsString:@"type=complete&data=undefined"]){
            
            if( [[NSProcessInfo processInfo].arguments containsObject:@"QuartileEvent"]){
                
                [self.eventList addObject:@"type=complete"];
            }
         
            [self videoAdTestCompletionAction];

            
        }
        else  if([absoluteURLText containsString:@"type=sessionFinish&data=undefined"]){
            if( [[NSProcessInfo processInfo].arguments containsObject:@"SessionFinish"]){
                [self.eventList addObject:@"type=sessionFinish"];
            }
            [self videoAdTestCompletionAction];
 
        }
        else  if([absoluteURLText containsString:@"type=skipped"]){
            if([[NSProcessInfo processInfo].arguments containsObject:@"SKIP"]){
                [self.eventList addObject:@"type=skipped"];
                [self videoAdTestCompletionAction];
            }
        }
    });
}

// videoAdTestCompletionAction: Called when SDK capture the needed URL
- (void)videoAdTestCompletionAction{
    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:self.eventList];
    self.eventList = [[orderedSet array] mutableCopy];
    [self.tableView reloadData];
    self.tableView.hidden = NO;
    [self.videoAd pauseAd];
    [self.videoAd removeFromSuperview];
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
