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

#import "ANWarmupWebView.h"

@interface ANWarmupWebView()

@property (nonatomic, strong) NSMutableArray<ANWebView *> *webViewQueue;

@end

@implementation ANWarmupWebView

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id _sharedInstance;
    dispatch_once(&once, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        _webViewQueue = [[NSMutableArray alloc] init];
        
    }
    [self prepareWebView];
    return self;
}

- (void) prepareWebView {
    
    ANWebView *webView = [[ANWebView alloc] initWithSize:CGSizeZero];
    
    [webView loadHTMLString:@"" baseURL:nil];
    
    [self.webViewQueue addObject:webView];
    
}

- (ANWebView *) fetchWarmedUpWebView {
    ANWebView *removedWebView = [self.webViewQueue lastObject];
    [self.webViewQueue removeLastObject];
    
    [self prepareWebView];

    return removedWebView;
    
}

@end
