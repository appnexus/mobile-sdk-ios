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

- (OMIDAppnexusAdSession*) createOMIDAdSessionforHTMLBannerWebView: webView
{
    NSError *ctxError;
    // the custom reference ID may not be relevant to your integration in which case you may pass an
    // empty string.
    NSString *customRefId = @"";
    OMIDAppnexusAdSessionContext *context = [[OMIDAppnexusAdSessionContext alloc] initWithPartner:  self.partner
                                                                                          webView:  webView
                                                                        customReferenceIdentifier:  customRefId
                                                                                            error: &ctxError];
    
    //Note that it is important that the videoEventsOwner parameter should be set to OMIDNoneOwner for display formats. Setting to anything else will cause the mediaType parameter passed to verification scripts to be set to video.
    NSError *cfgError;
    OMIDAppnexusAdSessionConfiguration *config;
    
    config = [[OMIDAppnexusAdSessionConfiguration alloc]
              initWithImpressionOwner:OMIDNativeOwner videoEventsOwner:OMIDNoneOwner
              isolateVerificationScripts:NO error:&cfgError];
    
    OMIDAppnexusAdSession *omidAdSession = [[OMIDAppnexusAdSession alloc] initWithConfiguration:config
                                                                               adSessionContext:context error:nil];
    
    // Set the view on which to track viewability
    omidAdSession.mainAdView = webView;
    
    // Start session
    [omidAdSession start];
    return omidAdSession;
}



-(void) stopOMIDAdSession:(OMIDAppnexusAdSession*) omidAdSession
{
    if(omidAdSession){
        [omidAdSession finish];
        omidAdSession = nil;
    }
}


- (void)fireOMIDImpressionOccuredEvent:(OMIDAppnexusAdSession*) omidAdSession {
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
    if(omidAdSession != nil){
        [omidAdSession addFriendlyObstruction:view];
    }
}




- (void) fetchOMIDJS
{
    NSURL                           *url        = [NSURL URLWithString:@"https://acdn.adnxs.com/mobile/omsdk/v1/omsdk.js"];

    __weak ANOMIDImplementation     *weakSelf   = self;

    NSURLSessionDataTask            *dataTask   =
            [[NSURLSession sharedSession] dataTaskWithURL: url
                                        completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error)
                                            {
                                                if (error) {
                                                    ANLogError(@"fetchOMIDJS FAILED.  NSError: userInfo=%@  code=%@  domain=%@", error.userInfo, @(error.code), error.domain);
                                                    return;
                                                }

                                                __strong ANOMIDImplementation  *strongSelf  = weakSelf;
                                                if (!strongSelf) {
                                                    ANLogError(@"FAILED to acquire strongSelf.");
                                                    return;
                                                }

                                                @synchronized (self) {
                                                    strongSelf.omidJSString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                                }
                                             }];
    [dataTask resume];
}


- (NSString *)prependOMIDJSToHTML:(NSString *)htmlOriginal
{
    NSString  *htmlInjected   = nil;
    NSString  *scriptContent  = nil;
    NSError   *error;

    @synchronized (self) {
        scriptContent  = self.omidJSString;

        if (!scriptContent) {
            ANLogWarn(@"scriptContent is nil.  Returning ORIGINAL html input.");
            return  htmlOriginal;
        }
    }

    //
    htmlInjected = [OMIDAppnexusScriptInjector injectScriptContent:  scriptContent
                                                          intoHTML:  htmlOriginal
                                                             error: &error];

    if (error) {
        ANLogWarn(@"OMIDAppnexusScriptInjector FAILED.  Returning ORIGINAL html input.");
        ANLogWarn(@"NSError: userInfo=%@  code=%@  domain=%@", error.userInfo, @(error.code), error.domain);

        return  htmlOriginal;
    }

    //
    return htmlInjected;
    
}

@end
