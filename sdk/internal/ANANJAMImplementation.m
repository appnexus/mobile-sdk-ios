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

+ (void)handleURL:(NSURL *)URL withWebViewController:(ANAdWebViewController *)controller {
    NSString *call = [URL host];
    NSDictionary *queryComponents = [[URL query] an_queryComponents];
    if ([call isEqualToString:kANCallMayDeepLink]) {
        [ANANJAMImplementation callMayDeepLink:controller query:queryComponents];
    } else if ([call isEqualToString:kANCallDeepLink]) {
        [ANANJAMImplementation callDeepLink:controller query:queryComponents];
    } else if ([call isEqualToString:kANCallExternalBrowser]) {
        [ANANJAMImplementation callExternalBrowser:controller query:queryComponents];
    } else if ([call isEqualToString:kANCallInternalBrowser]) {
        [ANANJAMImplementation callInternalBrowser:controller query:queryComponents];
    } else if ([call isEqualToString:kANCallRecordEvent]) {
        [ANANJAMImplementation callRecordEvent:controller query:queryComponents];
    } else if ([call isEqualToString:kANCallDispatchAppEvent]) {
        [ANANJAMImplementation callDispatchAppEvent:controller query:queryComponents];
    } else if ([call isEqualToString:kANCallGetDeviceID]) {
        [ANANJAMImplementation callGetDeviceID:controller query:queryComponents];
    } else {
        ANLogWarn(@"ANJAM called with unsupported function: %@", call);
    }
}

// Deep Link

+ (void)callMayDeepLink:(ANAdWebViewController *)controller query:(NSDictionary *)query {
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
    [ANANJAMImplementation loadResult:controller cb:cb paramsList:paramsList];
}

+ (void)callDeepLink:(ANAdWebViewController *)controller query:(NSDictionary *)query {
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
        [ANANJAMImplementation loadResult:controller cb:cb paramsList:paramsList];
    }
}

// Launch Browser

+ (void)callExternalBrowser:(ANAdWebViewController *)controller query:(NSDictionary *)query {
    NSString *urlParam = [query valueForKey:@"url"];
    
    NSURL *url = [NSURL URLWithString:urlParam];
    if (ANHasHttpPrefix([url scheme])
        && [[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

+ (void)callInternalBrowser:(ANAdWebViewController *)controller
                      query:(NSDictionary *)query {
    NSString *urlParam = [query valueForKey:@"url"];
    NSURL *url = [NSURL URLWithString:urlParam];
    [controller.browserDelegate openInAppBrowserWithURL:url];
}

// Record Event

+ (void)callRecordEvent:(ANAdWebViewController *)controller query:(NSDictionary *)query {
    NSString *urlParam = [query valueForKey:@"url"];

    NSURL *url = [NSURL URLWithString:urlParam];
    UIWebView *recordEventWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    ANRecordEventDelegate *recordEventDelegate = [ANRecordEventDelegate new];
    recordEventWebView.recordEventDelegate = recordEventDelegate;
    recordEventWebView.delegate = recordEventDelegate;
    [recordEventWebView setHidden:YES];
    [recordEventWebView loadRequest:[NSURLRequest requestWithURL:url]];
    [controller.contentView addSubview:recordEventWebView];
}

// Dispatch App Event

+ (void)callDispatchAppEvent:(ANAdWebViewController *)controller query:(NSDictionary *)query {
    NSString *event = [query valueForKey:@"event"];
    NSString *data = [query valueForKey:@"data"];

    [controller.adViewDelegate adDidReceiveAppEvent:event withData:data];
}

// Get Device ID

+ (void)callGetDeviceID:(ANAdWebViewController *)controller query:(NSDictionary *)query {
    NSString *cb = [query valueForKey:@"cb"];
    
    // send idName:idfa, id: idfa value
    NSDictionary *paramsList = @{
                                 kANKeyCaller: kANCallGetDeviceID,
                                 @"idname": @"idfa",
                                 @"id": ANUDID()
                                 };
    [ANANJAMImplementation loadResult:controller cb:cb paramsList:paramsList];
}


// Send the result back to JS

+ (void)loadResult:(ANAdWebViewController *)controller cb:(NSString *)cb paramsList:(NSDictionary *)paramsList {
    __block NSString *params = [NSString stringWithFormat:@"cb=%@", cb ? cb : @"-1"];

    [paramsList enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        key = ANConvertToNSString(key);
        NSString *valueString = ANConvertToNSString(value);
        if (([key length] > 0) && ([valueString length] > 0)) {
            params = [params stringByAppendingFormat:@"&%@=%@", key,
                      [valueString an_encodeAsURIComponent]];
        }
    }];
    
    NSString *url = [NSString stringWithFormat:@"javascript:window.sdkjs.client.result(\"%@\")", params];
    [controller fireJavaScript:url];
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
