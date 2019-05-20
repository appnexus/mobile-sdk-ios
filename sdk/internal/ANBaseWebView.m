//
//  ANBaseWebView.m
//  ANSDK
//
//  Created by Punnaghai Puviarasu on 5/15/19.
//  Copyright © 2019 AppNexus. All rights reserved.
//

#define AN_USER_DENIED_LOCATION_PERMISSION 1

#import "ANBaseWebView.h"
#import "ANLogging.h"
#import "ANGlobal.h"
#import "ANBaseWebView+PrivateMethods.h"
#import "ANSDKSettings+PrivateMethods.h"


@interface ANBaseWebView()
    @property (nonatomic, readwrite, strong)  WKWebView  *webView;
@end

@implementation ANBaseWebView

@synthesize webView = _webView;
 
#pragma mark - Initialization
    
- (instancetype)init {
    self = [super init];
    
    return self;
}
    
- (void)createWebView:(CGSize)size {
    self.webView = [[self class] defaultWebViewWithSize:size];
}

- (void)createWebView:(CGSize)size
                       URL:(NSURL *)URL
            baseURL:(NSURL *)baseURL{
    
    [self createWebView:size];
    
    
    __weak WKWebView  *weakWebView  = self.webView;
    
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
    
}

- (void)createWebView:(CGSize)size
                      HTML:(NSString *)html
                   baseURL:(NSURL *)baseURL
    {
        [self createWebView:size];
        
        [self.webView loadHTMLString:html
                        baseURL:baseURL];
        
        
        
    }
    
    - (void)createVideoWebView:(CGSize)size {
        [self createWebView:size];
        
        NSURL           *url      = [[[ANSDKSettings sharedInstance] baseUrlConfig] videoWebViewUrl];
        NSURLRequest    *request  = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
        
    }
    
    + (WKWebView *)defaultWebViewWithSize:(CGSize)size
    {
        WKWebViewConfiguration *configuration = [[self class] setDefaultWebViewConfiguration];
        WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)
                                                configuration:configuration];
       
        
        webView.backgroundColor = [UIColor clearColor];
        webView.opaque = NO;
        
        if (@available(iOS 11.0, *)) {
            webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        return webView;
    }
    
    + (WKWebViewConfiguration *)setDefaultWebViewConfiguration
    {
        static dispatch_once_t   processPoolToken;
        static WKProcessPool    *anSdkProcessPool;
        
        dispatch_once(&processPoolToken, ^{
            anSdkProcessPool = [[WKProcessPool alloc] init];
        });
        
        WKWebViewConfiguration  *configuration  = [[WKWebViewConfiguration alloc] init];
        
        configuration.processPool                   = anSdkProcessPool;
        configuration.allowsInlineMediaPlayback     = YES;
        
        // configuration.allowsInlineMediaPlayback = YES is not respected
        // on iPhone on WebKit versions shipped with iOS 9 and below, the
        // video always loads in full-screen.
        // See: https://bugs.webkit.org/show_bug.cgi?id=147512
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            configuration.requiresUserActionForMediaPlayback = NO;
            
        } else {
            if (    [[NSProcessInfo processInfo] respondsToSelector:@selector(isOperatingSystemAtLeastVersion:)]
                && [[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){10,0,0}] )
            {
                configuration.requiresUserActionForMediaPlayback = NO;
            } else {
                configuration.requiresUserActionForMediaPlayback = YES;
            }
        }
        
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
        return configuration;
    }
    
@end
