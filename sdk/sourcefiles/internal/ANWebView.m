/*   Copyright 2014 APPNEXUS INC
 
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

#define AN_USER_DENIED_LOCATION_PERMISSION 1

#import "ANWebView.h"
#import "ANSDKSettings.h"
#import "ANGlobal.h"
#import "ANLogging.h"
#import "ANOMIDImplementation.h"

WKUserScript  *anjamScript = nil;

WKUserScript *mraidScript = nil;

WKUserScript *omidScript = nil;

WKWebViewConfiguration  *configuration = nil;

NSMutableArray<ANWebView *> *webViewQueue;

@interface ANWebView ()
@property (nonatomic, readwrite, assign)  BOOL          isVASTVideoAd;
@property (nonatomic, readwrite, assign)  BOOL          isNativeRenderingAd;
@end


@implementation ANWebView
    
    -(instancetype) initWithSize:(CGSize)size
    {
        [[self class] loadWebViewConfigurations];
        WKWebViewConfiguration *configuration;
        if(self.isVASTVideoAd || self.isNativeRenderingAd){
            configuration = [[self class] prepareWebConfiguration];
        }else{
            configuration = [[self class] webConfiguration];
        }
        
        self = [super initWithFrame:CGRectMake(0, 0, size.width, size.height) configuration:configuration];
        if (!self)  { return nil; }
        
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        [self loadWebViewWithUserScripts];
        return self;
    }
    
    -(instancetype) initWithSize:(CGSize)size URL:(NSURL *)URL baseURL:(NSURL *)baseURL
    {
        self = [self initWithSize:size];
        if (!self)  { return nil; }

        //
        __weak WKWebView  *weakWebView  = self;
        
        [[[NSURLSession sharedSession] dataTaskWithRequest: ANBasicRequestWithURL(URL)
                                         completionHandler: ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
          {
              __strong WKWebView  *strongWebView  = weakWebView;
              if (!strongWebView)  {
                  ANLogError(@"COULD NOT ACQUIRE strongWebView.");
                  return;
              }
              
              dispatch_async(dispatch_get_main_queue(), ^{
                  NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                  
                  if (html.length) {
                      [strongWebView loadHTMLString:html baseURL:baseURL];
                  }
              });
          }
          ] resume];

        //
        return self;
    }
    
    -(instancetype) initWithSize:(CGSize)size content:(NSString *)htmlContent baseURL:(NSURL *)baseURL
    {
        self = [self initWithSize:size];
        if (!self)  { return nil; }

        [self loadHTMLString:htmlContent baseURL:baseURL];
        return self;
    }

    -(instancetype) initWithSize:(CGSize)size content:(NSString *)htmlContent baseURL:(NSURL *)baseURL isNativeRenderingAd:(BOOL)nativeRenderingAd
    {
        self.isNativeRenderingAd = nativeRenderingAd;
        return [self initWithSize:size content:htmlContent baseURL:baseURL];
        
    }
        
    -(instancetype) initWithSize:(CGSize)size URL:(NSURL *)URL isVASTVideoAd:(BOOL)videoAd {
        self.isVASTVideoAd  = videoAd;
        return [self initWithSize:size URL:URL];
    }

    -(instancetype) initWithSize:(CGSize)size URL:(NSURL *)URL
    {
        self = [self initWithSize:size];
        if (!self)  { return nil; }

        NSURLRequest    *request  = [NSURLRequest requestWithURL:URL];
        self.navigation = [self loadRequest:request];
        
        return self;
    }

    -(void) loadWithSize:(CGSize)size content:(NSString *) contentString baseURL:(NSURL *)baseURL{
        
        self.frame = CGRectMake(0, 0, size.width, size.height);
        [self loadHTMLString:contentString baseURL:baseURL];
    
    }

    + (ANWebView *) fetchWebView {
        ANWebView *removedWebView;
        
        if(webViewQueue.count > 0){
            removedWebView = [webViewQueue lastObject];
            [webViewQueue removeLastObject];
        } else {
            removedWebView = [[ANWebView alloc] initWithSize:CGSizeZero];
        }
        [ANWebView  prepareWebView];
        return removedWebView;
    }

    + (void) prepareWebView {
        
        if(webViewQueue == nil){
                webViewQueue = [[NSMutableArray alloc] init];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            ANWebView *webView = [[ANWebView alloc] initWithSize:CGSizeZero];
            [webView loadHTMLString:@"" baseURL:nil];
                
            [webViewQueue addObject:webView];
        });
    }

    -(void) loadWebViewWithUserScripts {
    
        WKUserContentController  *controller  = self.configuration.userContentController;
    
        [controller addUserScript:self.class.anjamScript];
        [controller addUserScript:self.class.mraidScript];
        
    }
    
    
    + (void) addDefaultWebViewConfiguration
    {
        configuration = [self prepareWebConfiguration];
    }


    +(WKWebViewConfiguration *)prepareWebConfiguration {
        static dispatch_once_t   processPoolToken;
        static WKProcessPool    *anSdkProcessPool;
        
        dispatch_once(&processPoolToken, ^{
            anSdkProcessPool = [[WKProcessPool alloc] init];
        });
        
        WKWebViewConfiguration *configuration  = [[WKWebViewConfiguration alloc] init];
        
        configuration.processPool                   = anSdkProcessPool;
        configuration.allowsInlineMediaPlayback     = YES;
        
        configuration.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeAudio;

        
        WKUserContentController  *controller  = [[WKUserContentController alloc] init];
        configuration.userContentController = controller;
        
        NSString *paddingJS = @"document.body.style.margin='0';document.body.style.padding = '0'";
        
        WKUserScript *paddingScript = [[WKUserScript alloc] initWithSource: paddingJS
                                                             injectionTime: WKUserScriptInjectionTimeAtDocumentEnd
                                                          forMainFrameOnly: YES];
        [controller addUserScript:paddingScript];
        
        if(!ANSDKSettings.sharedInstance.locationEnabledForCreative){
            //The Geolocation method watchPosition() method is used to register a handler function that will be called automatically each time the position of the device changes.
            NSString *execWatchPosition =  [NSString stringWithFormat:@"navigator.geolocation.watchPosition = function(success, error, options) {};"];
            //The Geolocation.getCurrentPosition() method is used to get the current position of the device.
            NSString *execCurrentPosition = [NSString stringWithFormat:@"navigator.geolocation.getCurrentPosition('', function(){});"];
            
            // Pass user denied the request for Geolocation to Creative
            // USER_DENIED_LOCATION_PERMISSION is 1 which shows, The acquisition of the geolocation information failed because the page didn't have the permission to do it.
            NSString *execCurrentPositionDenied =  [NSString stringWithFormat:@"navigator.geolocation.getCurrentPosition = function(success, error){ error({ error: { code: %d } });};",AN_USER_DENIED_LOCATION_PERMISSION];;
            
            
            
            WKUserScript *execWatchPositionScript = [[WKUserScript alloc] initWithSource: execWatchPosition
                                                                           injectionTime: WKUserScriptInjectionTimeAtDocumentStart
                                                                        forMainFrameOnly: NO];
            
            WKUserScript *execCurrentPositionScript = [[WKUserScript alloc] initWithSource: execCurrentPosition
                                                                             injectionTime: WKUserScriptInjectionTimeAtDocumentStart
                                                                          forMainFrameOnly: NO];
            WKUserScript *execCurrentPositionDeniedScript = [[WKUserScript alloc] initWithSource: execCurrentPositionDenied
                                                                                   injectionTime: WKUserScriptInjectionTimeAtDocumentStart
                                                                                forMainFrameOnly: NO];
            [controller addUserScript:execCurrentPositionScript];
            [controller addUserScript:execWatchPositionScript];
            [controller addUserScript:execCurrentPositionDeniedScript];
            
        }
        return  configuration;
    }


+ (void) loadWebViewConfigurations {
    if(mraidScript == nil){
        mraidScript = [[WKUserScript alloc] initWithSource: [[self class] mraidJS]
                                                       injectionTime: WKUserScriptInjectionTimeAtDocumentStart
                                                    forMainFrameOnly: YES];
    }
    if(anjamScript == nil){
        anjamScript = [[WKUserScript alloc] initWithSource: [[self class] anjamJS]
                                                       injectionTime: WKUserScriptInjectionTimeAtDocumentStart
                                                    forMainFrameOnly: YES];
    }
    if(omidScript == nil){
        omidScript = [[WKUserScript alloc] initWithSource: [[ANOMIDImplementation sharedInstance] getOMIDJS]
           injectionTime: WKUserScriptInjectionTimeAtDocumentStart
        forMainFrameOnly: YES];
    }
    
    if(configuration == nil){
        [self addDefaultWebViewConfiguration];
    }
    
}

+ (WKUserScript *)mraidScript {
    return mraidScript;
}

+ (WKUserScript *)anjamScript {
    return anjamScript;
}

+ (WKUserScript *)omidScript {
    return omidScript;
}

+(nonnull WKWebViewConfiguration *) webConfiguration {
    return configuration;
}

+ (NSString *)mraidJS
{
    NSString *mraidPath = ANMRAIDBundlePath();
    if (!mraidPath) {
        return @"";
    }
    
    NSBundle    *mraidBundle    = [[NSBundle alloc] initWithPath:mraidPath];
    NSData      *data           = [NSData dataWithContentsOfFile:[mraidBundle pathForResource:@"mraid" ofType:@"js"]];
    NSString    *mraidString    = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return  mraidString;
}

+ (NSString *)anjamJS
{
    NSString *sdkjsPath = ANPathForANResource(@"sdkjs", @"js");
    NSString *anjamPath = ANPathForANResource(@"anjam", @"js");
    if (!sdkjsPath || !anjamPath) {
        return @"";
    }
    
    NSData      *sdkjsData  = [NSData dataWithContentsOfFile:sdkjsPath];
    NSData      *anjamData  = [NSData dataWithContentsOfFile:anjamPath];
    NSString    *sdkjs      = [[NSString alloc] initWithData:sdkjsData encoding:NSUTF8StringEncoding];
    NSString    *anjam      = [[NSString alloc] initWithData:anjamData encoding:NSUTF8StringEncoding];
    
    NSString  *anjamString  = [NSString stringWithFormat:@"%@ %@", sdkjs, anjam];
    
    return  anjamString;
}

@end
