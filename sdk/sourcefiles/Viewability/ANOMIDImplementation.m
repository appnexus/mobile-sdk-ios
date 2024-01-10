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

@property (nonatomic, readwrite, strong) OMIDMicrosoftPartner* partner;

@end


@implementation ANOMIDImplementation

+ (instancetype)sharedInstance {
    static dispatch_once_t omidMicrosoftToken;
    static ANOMIDImplementation *omidMicrosoftImplementation;
    dispatch_once(&omidMicrosoftToken, ^{
        omidMicrosoftImplementation = [[ANOMIDImplementation alloc] init];

        if (omidMicrosoftImplementation.omidJSString != nil) {
            omidMicrosoftImplementation.omidJSString = nil;
        }

        [omidMicrosoftImplementation fetchOMIDJS];
    });
    return omidMicrosoftImplementation;
}

- (void) activateOMIDandCreatePartner
{
    if(!ANSDKSettings.sharedInstance.enableOpenMeasurement)
        return;
    
    if(!OMIDMicrosoftSDK.sharedInstance.isActive){
        [[OMIDMicrosoftSDK sharedInstance] activate];
       
        
        // This Creates / updates a partner for each new activation of OMID SDK
        self.partner = [[OMIDMicrosoftPartner alloc] initWithName: AN_OMIDSDK_PARTNER_NAME
                                                   versionString: AN_SDK_VERSION];
    }
    
    // IF partener is nil create partner
    if(!self.partner){
        self.partner = [[OMIDMicrosoftPartner alloc] initWithName: AN_OMIDSDK_PARTNER_NAME
                                                   versionString: AN_SDK_VERSION];
    }
    
    // If OMID JS is empty fetch OMIDJS.
    if(!self.omidJSString){
        [self fetchOMIDJS];
    }
    
}

- (OMIDMicrosoftAdSession*) createOMIDAdSessionforWebView:(WKWebView *)webView isVideoAd:(BOOL)videoAd
{
    if(!ANSDKSettings.sharedInstance.enableOpenMeasurement)
        return nil;
    
    NSError *ctxError;
    // the custom reference ID may not be relevant to your integration in which case you may pass an
    // empty string.
    NSString *customRefId = @"";

    /*
     contentUrl : there is a new context parameter for “content URL”. This is the deep-link URL for the app screen that is displaying the ad.
     If the content URL is not known, pass null for the parameter.
     */
    OMIDMicrosoftAdSessionContext *context = [[OMIDMicrosoftAdSessionContext alloc] initWithPartner:self.partner
                                                                                          webView:webView
                                                                                       contentUrl:nil customReferenceIdentifier:customRefId error: &ctxError];
                                         
    OMIDOwner impressionOwner = (videoAd) ? OMIDJavaScriptOwner : OMIDNativeOwner;
    OMIDOwner mediaEventsOwner = (videoAd) ? OMIDJavaScriptOwner : OMIDNoneOwner;

    
    
    return [self initialseOMIDAdSessionForView:webView withSessionContext:context andImpressionOwner:impressionOwner andMediaEventsOwner:mediaEventsOwner htmlAd:(mediaEventsOwner == OMIDNoneOwner)];
}


- (OMIDMicrosoftAdSession*) createOMIDAdSessionforNative:(UIView *)view withScript:(NSMutableArray *)scripts
{
    if(!ANSDKSettings.sharedInstance.enableOpenMeasurement)
        return nil;    
    
    NSError *ctxError;

    OMIDMicrosoftAdSessionContext *context = [[OMIDMicrosoftAdSessionContext alloc] initWithPartner:self.partner
                                                                                           script:self.getOMIDJS
                                                                                            resources:scripts
                                                                                            contentUrl:nil
                                                                                            customReferenceIdentifier:nil
                                                                                            error:&ctxError];
    
    return [self initialseOMIDAdSessionForView:view withSessionContext:context andImpressionOwner:OMIDNativeOwner andMediaEventsOwner:OMIDNoneOwner htmlAd:false];
}


-(OMIDMicrosoftAdSession*) initialseOMIDAdSessionForView:(id)view withSessionContext:(OMIDMicrosoftAdSessionContext*)context andImpressionOwner:(OMIDOwner)impressionOwner andMediaEventsOwner:(OMIDOwner)mediaEventsOwner htmlAd:(BOOL)isBannerAd
{
    //Note that it is important that the mediaEventsOwner parameter should be set to OMIDNoneOwner for display formats. Setting to anything else will cause the mediaType parameter passed to verification scripts to be set to video.
    NSError *cfgError;
    
    OMIDCreativeType creativeType;
    if (mediaEventsOwner == OMIDNoneOwner) {
        creativeType = isBannerAd ? OMIDCreativeTypeHtmlDisplay : OMIDCreativeTypeNativeDisplay;
    } else {
        // let the JS session script declare creative type,
        creativeType = OMIDCreativeTypeDefinedByJavaScript;
    }
    
    OMIDMicrosoftAdSessionConfiguration *config = [[OMIDMicrosoftAdSessionConfiguration alloc]
                                                  initWithCreativeType:creativeType
                                                  impressionType:((mediaEventsOwner == OMIDNoneOwner)?OMIDImpressionTypeViewable:OMIDImpressionTypeDefinedByJavaScript)
                                                  impressionOwner:impressionOwner
                                                  mediaEventsOwner:mediaEventsOwner
                                                  isolateVerificationScripts:NO
                                                  error:&cfgError];
                                                  
                                                  
    NSError *sessError;
    OMIDMicrosoftAdSession *omidAdSession = [[OMIDMicrosoftAdSession alloc] initWithConfiguration:config
                                                                               adSessionContext:context error:&sessError];
    @try {
        // Set the view on which to track viewability
        omidAdSession.mainAdView = view;
    } @catch (NSException *ex) {
        ANLogError(@"Attempt to add view failed");
    }
    // Start session
    [omidAdSession start];
    return omidAdSession;
}

-(void) stopOMIDAdSession:(OMIDMicrosoftAdSession*) omidAdSession
{
    if(!ANSDKSettings.sharedInstance.enableOpenMeasurement)
        return;
    
    if(omidAdSession){
        [omidAdSession finish];
        omidAdSession = nil;
    }
}


- (void)fireOMIDImpressionOccuredEvent:(OMIDMicrosoftAdSession*) omidAdSession {
    if(!ANSDKSettings.sharedInstance.enableOpenMeasurement)
        return;

    if(omidAdSession != nil){
        NSError *adEvtsError;
        OMIDMicrosoftAdEvents *adEvents = [[OMIDMicrosoftAdEvents alloc] initWithAdSession:omidAdSession error:&adEvtsError];
        NSError *loadedError;
        [adEvents loadedWithError:&loadedError];
        
        NSError *impError;
        [adEvents impressionOccurredWithError:&impError];
    }
}


// This might be required for Interstitials Ads
- (void)addFriendlyObstruction:(UIView *) view
               toOMIDAdSession:(OMIDMicrosoftAdSession*) omidAdSession{
    if(!ANSDKSettings.sharedInstance.enableOpenMeasurement)
        return;

    if(omidAdSession != nil){
        [omidAdSession addFriendlyObstruction:view purpose:OMIDFriendlyObstructionOther detailedReason:nil error:nil];
    }
}


- (void)removeFriendlyObstruction:(UIView *) view toOMIDAdSession:(OMIDMicrosoftAdSession*) omidAdSession{
    if(!ANSDKSettings.sharedInstance.enableOpenMeasurement)
        return;
    
    if(omidAdSession != nil){
        [omidAdSession removeFriendlyObstruction:view];
    }
}


- (void)removeAllFriendlyObstructions:(OMIDMicrosoftAdSession*) omidAdSession{
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
