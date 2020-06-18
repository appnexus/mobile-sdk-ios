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



#import "ANWebView.h"
#import "ANSDKSettings.h"
#import "ANGlobal.h"
#import "ANLogging.h"

@implementation ANWebView
    
    -(instancetype) initWithSize:(CGSize)size {
        
        WKWebViewConfiguration *configuration = ANGlobal.webConfiguration;
        
        self = [super initWithFrame:CGRectMake(0, 0, size.width, size.height) configuration:configuration];
        if (!self)  { return nil; }
        
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        
        if (@available(iOS 11.0, *)) {
            self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
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
    
    -(instancetype) initWithSize:(CGSize)size URL:(NSURL *)URL
    {
        self = [self initWithSize:size];
        if (!self)  { return nil; }

        NSURLRequest    *request  = [NSURLRequest requestWithURL:URL];
        [self loadRequest:request];
        
        return self;
    }

@end
