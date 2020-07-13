/*   Copyright 2018 APPNEXUS INC
 
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

#import "ANOMIDImplementation.h"
#import "ANGlobal.h"
#import "ANLogging.h"
#import "ANSDKSettings.h"

static NSString *const kANOMIDSDKJSFilename = @"omsdk";


@interface ANOMIDImplementation()

@property (nonatomic, readwrite, strong) NSString* omidJSString;

@property (nonatomic, readwrite, strong) OMIDAppnexusPartner* partner;

@end


@implementation ANOMIDImplementation

+ (instancetype)sharedInstance {
    static dispatch_once_t omidAppnexusToken;
    static ANOMIDImplementation *omidAppnexusImplementation;
    dispatch_once(&omidAppnexusToken, ^{
        omidAppnexusImplementation = [[ANOMIDImplementation alloc] init];

        if (omidAppnexusImplementation.omidJSString != nil) {
            omidAppnexusImplementation.omidJSString = nil;
        }

        [omidAppnexusImplementation fetchOMIDJS];
    });
    return omidAppnexusImplementation;
}

- (void) activateOMIDandCreatePartner
{
    if(!ANSDKSettings.sharedInstance.enableOpenMeasurement)
        return;
    
    if(!OMIDAppnexusSDK.sharedInstance.isActive){
        NSError *error;
        [[OMIDAppnexusSDK sharedInstance] activateWithOMIDAPIVersion:OMIDSDKAPIVersionString
                                                               error:&error];
        
        // This Creates / updates a partner for each new activation of OMID SDK
        self.partner = [[OMIDAppnexusPartner alloc] initWithName: AN_OMIDSDK_PARTNER_NAME
                                                   versionString: AN_SDK_VERSION];
    }
    
    // IF partener is nil create partner
    if(!self.partner){
        self.partner = [[OMIDAppnexusPartner alloc] initWithName: AN_OMIDSDK_PARTNER_NAME
                                                   versionString: AN_SDK_VERSION];
    }
    
    // If OMID JS is empty fetch OMIDJS.
    if(!self.omidJSString){
        [self fetchOMIDJS];
    }
    
}

- (OMIDAppnexusAdSession*) createOMIDAdSessionforWebView:(WKWebView *)webView isVideoAd:(BOOL)videoAd
{
    if(!ANSDKSettings.sharedInstance.enableOpenMeasurement)
        return nil;
    
    NSError *ctxError;
    // the custom reference ID may not be relevant to your integration in which case you may pass an
    // empty string.
    NSString *customRefId = @"";

    OMIDAppnexusAdSessionContext *context = [[OMIDAppnexusAdSessionContext alloc] initWithPartner:  self.partner
                                                                                          webView:  webView
                                                                        customReferenceIdentifier:  customRefId
                                                                                            error: &ctxError];
    OMIDOwner impressionOwner = (videoAd) ? OMIDJavaScriptOwner : OMIDNativeOwner;
    OMIDOwner videoEventsOwner = (videoAd) ? OMIDJavaScriptOwner : OMIDNoneOwner;

    return [self initialseOMIDAdSessionForView:webView withSessionContext:context andImpressionOwner:impressionOwner andVideoEventsOwner:videoEventsOwner];
}


- (OMIDAppnexusAdSession*) createOMIDAdSessionforNative:(UIView *)view withScript:(NSMutableArray *)scripts
{
    if(!ANSDKSettings.sharedInstance.enableOpenMeasurement)
        return nil;    
    
    NSError *ctxError;    
    OMIDAppnexusAdSessionContext *context = [[OMIDAppnexusAdSessionContext alloc] initWithPartner:  self.partner
                                                                                          script:   self.getOMIDJS
                                                                                        resources:scripts
                                                                        customReferenceIdentifier: nil
                                                                                            error: &ctxError];
    
    return [self initialseOMIDAdSessionForView:view withSessionContext:context andImpressionOwner:OMIDNativeOwner andVideoEventsOwner:OMIDNoneOwner];
}


-(OMIDAppnexusAdSession*) initialseOMIDAdSessionForView:(id)view withSessionContext:(OMIDAppnexusAdSessionContext*)context andImpressionOwner:(OMIDOwner)impressionOwner andVideoEventsOwner:(OMIDOwner)videoEventsOwner
{
    //Note that it is important that the videoEventsOwner parameter should be set to OMIDNoneOwner for display formats. Setting to anything else will cause the mediaType parameter passed to verification scripts to be set to video.
    NSError *cfgError;
    OMIDAppnexusAdSessionConfiguration *config = [[OMIDAppnexusAdSessionConfiguration alloc]
                                                  initWithImpressionOwner:impressionOwner videoEventsOwner:videoEventsOwner
                                                  isolateVerificationScripts:NO error:&cfgError];
    // Create the session
    NSError *sessError;
    OMIDAppnexusAdSession *omidAdSession = [[OMIDAppnexusAdSession alloc] initWithConfiguration:config
                                                                               adSessionContext:context error:&sessError];
    
    // Set the view on which to track viewability
    omidAdSession.mainAdView = view;
    
    // Start session
    [omidAdSession start];
    return omidAdSession;
}

-(void) stopOMIDAdSession:(OMIDAppnexusAdSession*) omidAdSession
{
    if(!ANSDKSettings.sharedInstance.enableOpenMeasurement)
        return;
    
    if(omidAdSession){
        [omidAdSession finish];
        omidAdSession = nil;
    }
}


- (void)fireOMIDImpressionOccuredEvent:(OMIDAppnexusAdSession*) omidAdSession {
    if(!ANSDKSettings.sharedInstance.enableOpenMeasurement)
        return;

    if(omidAdSession != nil){
        NSError *adEvtsError;
        OMIDAppnexusAdEvents *adEvents = [[OMIDAppnexusAdEvents alloc] initWithAdSession:omidAdSession error:&adEvtsError];
        NSError *impError;
        [adEvents impressionOccurredWithError:&impError];
    }
}


// This might be required for Interstitials Ads
- (void)addFriendlyObstruction:(UIView *) view
               toOMIDAdSession:(OMIDAppnexusAdSession*) omidAdSession{
    if(!ANSDKSettings.sharedInstance.enableOpenMeasurement)
        return;

    if(omidAdSession != nil){
        [omidAdSession addFriendlyObstruction:view];
    }
}


- (void)removeFriendlyObstruction:(UIView *) view toOMIDAdSession:(OMIDAppnexusAdSession*) omidAdSession{
    if(!ANSDKSettings.sharedInstance.enableOpenMeasurement)
        return;
    
    if(omidAdSession != nil){
        [omidAdSession removeFriendlyObstruction:view];
    }
}


- (void)removeAllFriendlyObstructions:(OMIDAppnexusAdSession*) omidAdSession{
    if(!ANSDKSettings.sharedInstance.enableOpenMeasurement)
        return;
    
    if(omidAdSession != nil){
        [omidAdSession removeAllFriendlyObstructions];
    }
}



- (void) fetchOMIDJS
{
    if(!ANSDKSettings.sharedInstance.enableOpenMeasurement)
        return;

    NSString *omSdkJSPath = ANPathForANResource(kANOMIDSDKJSFilename, @"js");
    if (!omSdkJSPath) {
        return;
    }
    NSData      *omSdkJsData  = [NSData dataWithContentsOfFile:omSdkJSPath];
    self.omidJSString      = [[NSString alloc] initWithData:omSdkJsData encoding:NSUTF8StringEncoding];
    
}


- (NSString *)getOMIDJS
{
    if(!ANSDKSettings.sharedInstance.enableOpenMeasurement)
        return @"";
    
    NSString  *scriptContent  = nil;
    
    @synchronized (self) {
        scriptContent  = self.omidJSString;
        if (!scriptContent) {
            ANLogWarn(@"scriptContent is nil");
            scriptContent=  @"";
        }
    }
    return scriptContent;
    
}

@end
