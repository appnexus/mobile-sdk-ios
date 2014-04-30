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

#import "ANANJAMImplementation.h"

#import "ANGlobal.h"
#import "ANLogging.h"
#import "NSString+ANCategory.h"

NSString *const kANCallMayDeepLink = @"MayDeepLink";
NSString *const kANCallDeepLink = @"DeepLink";
NSString *const kANCallExternalBrowser = @"ExternalBrowser";
NSString *const kANCallInternalBrowser = @"InternalBrowser";
NSString *const kANCallRecordEvent = @"RecordEvent";
NSString *const kANCallDispatchAppEvent = @"DispatchAppEvent";
NSString *const kANCallGetDeviceID = @"GetDeviceID";

NSString *const kANKeyCaller = @"caller";

@interface ANRecordEventDelegate : NSObject <UIWebViewDelegate>
@end

@interface UIWebView (RecordEvent)
@property (nonatomic, readwrite, strong) ANRecordEventDelegate *recordEventDelegate;
@end

@implementation ANANJAMImplementation

+ (void)handleUrl:(NSURL *)url forWebView:(UIWebView *)webView
      forDelegate:(id<ANAdViewDelegate, ANBrowserViewControllerDelegate>)delegate {
    NSString *call = [url host];
    NSDictionary *queryComponents = [[url query] queryComponents];
    if ([call isEqualToString:kANCallMayDeepLink]) {
        [ANANJAMImplementation callMayDeepLink:webView query:queryComponents];
    } else if ([call isEqualToString:kANCallDeepLink]) {
        [ANANJAMImplementation callDeepLink:webView query:queryComponents];
    } else if ([call isEqualToString:kANCallExternalBrowser]) {
        [ANANJAMImplementation callExternalBrowser:webView query:queryComponents];
    } else if ([call isEqualToString:kANCallInternalBrowser]) {
        [ANANJAMImplementation callInternalBrowser:webView query:queryComponents delegate:delegate];
    } else if ([call isEqualToString:kANCallRecordEvent]) {
        [ANANJAMImplementation callRecordEvent:webView query:queryComponents];
    } else if ([call isEqualToString:kANCallDispatchAppEvent]) {
        [ANANJAMImplementation callDispatchAppEvent:webView query:queryComponents delegate:delegate];
    } else if ([call isEqualToString:kANCallGetDeviceID]) {
        [ANANJAMImplementation callGetDeviceID:webView query:queryComponents];
    } else {
        ANLogWarn(@"ANJAM called with unsupported function: %@", call);
    }
}

// Deep Link

+ (void)callMayDeepLink:(UIWebView *)webView query:(NSDictionary *)query {
    NSString *cb = [query valueForKey:@"cb"];
    NSString *urlParam = [query valueForKey:@"url"];
    BOOL mayDeepLink;
    
    if ([urlParam length] < 1) {
        mayDeepLink = NO;
    } else {
        NSURL *url = [NSURL URLWithString:urlParam];
        mayDeepLink = [[UIApplication sharedApplication] canOpenURL:url];
    }

    NSDictionary *paramsList = @{
                                 kANKeyCaller: kANCallMayDeepLink,
                                 @"mayDeepLink": mayDeepLink ? @"true" : @"false"
                                 };
    [ANANJAMImplementation loadResult:webView cb:cb paramsList:paramsList];
}

+ (void)callDeepLink:(UIWebView *)webView query:(NSDictionary *)query {
    NSString *cb = [query valueForKey:@"cb"];
    NSString *urlParam = [query valueForKey:@"url"];
    
    NSURL *url = [NSURL URLWithString:urlParam];
    if ([[UIApplication sharedApplication] canOpenURL:url]
        && [[UIApplication sharedApplication] openURL:url]) {
        // success, do nothing
        return;
    } else {
        NSDictionary *paramsList = @{
                                     kANKeyCaller: kANCallDeepLink,
                                     };
        [ANANJAMImplementation loadResult:webView cb:cb paramsList:paramsList];
    }
}

// Launch Browser

+ (void)callExternalBrowser:(UIWebView *)webView query:(NSDictionary *)query {
    NSString *urlParam = [query valueForKey:@"url"];
    
    NSURL *url = [NSURL URLWithString:urlParam];
    if (hasHttpPrefix([url scheme])
        && [[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

+ (void)callInternalBrowser:(UIWebView *)webView query:(NSDictionary *)query
                   delegate:(id<ANBrowserViewControllerDelegate>)delegate {
    NSString *urlParam = [query valueForKey:@"url"];
    
    NSURL *url = [NSURL URLWithString:urlParam];
    if (hasHttpPrefix([url scheme])) {
        [ANBrowserViewController launchURL:url withDelegate:delegate];
    }
}

// Record Event

+ (void)callRecordEvent:(UIWebView *)webView query:(NSDictionary *)query {
    NSString *urlParam = [query valueForKey:@"url"];

    NSURL *url = [NSURL URLWithString:urlParam];
    UIWebView *recordEventWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    ANRecordEventDelegate *recordEventDelegate = [ANRecordEventDelegate new];
    recordEventWebView.recordEventDelegate = recordEventDelegate;
    recordEventWebView.delegate = recordEventDelegate;
    [recordEventWebView setHidden:YES];
    [recordEventWebView loadRequest:[NSURLRequest requestWithURL:url]];
    [webView addSubview:recordEventWebView];
}

// Dispatch App Event

+ (void)callDispatchAppEvent:(UIWebView *)webView query:(NSDictionary *)query
                    delegate:(id<ANAdViewDelegate>)delegate {
    NSString *event = [query valueForKey:@"event"];
    NSString *data = [query valueForKey:@"data"];

    [delegate adDidReceiveAppEvent:event withData:data];
}

// Get Device ID

+ (void)callGetDeviceID:(UIWebView *)webView query:(NSDictionary *)query {
    NSString *cb = [query valueForKey:@"cb"];
    
    // send idName:idfa, id: idfa value
    NSDictionary *paramsList = @{
                                 kANKeyCaller: kANCallGetDeviceID,
                                 @"idname": @"idfa",
                                 @"id": ANUDID()
                                 };
    [ANANJAMImplementation loadResult:webView cb:cb paramsList:paramsList];
}


// Send the result back to JS

+ (void)loadResult:(UIWebView *)webView cb:(NSString *)cb paramsList:(NSDictionary *)paramsList {
    __block NSString *params = [NSString stringWithFormat:@"cb=%@", cb ? cb : @"-1"];

    [paramsList enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        key = convertToNSString(key);
        NSString *valueString = convertToNSString(value);
        if (([key length] > 0) && ([valueString length] > 0)) {
            params = [params stringByAppendingFormat:@"&%@=%@", key,
                      [valueString encodeAsURIComponent]];
        }
    }];
    
    NSString *url = [NSString stringWithFormat:@"javascript:window.sdkjs.client.result(\"%@\")", params];
    [webView stringByEvaluatingJavaScriptFromString:url];
}

@end

@implementation ANRecordEventDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    ANLogDebug(@"RecordEvent completed succesfully");
}

@end

@implementation UIWebView (RecordEvent)

ANRecordEventDelegate *_recordEventDelegate;


- (void)setRecordEventDelegate:(ANRecordEventDelegate *)recordEventDelegate {
    _recordEventDelegate = recordEventDelegate;
}

- (ANRecordEventDelegate *)recordEventDelegate {
    return _recordEventDelegate;
}

@end
