//
//  ANWarmupWebView.m
//  AppNexusSDK
//
//  Created by Punnaghai Puviarasu on 5/20/20.
//  Copyright © 2020 AppNexus. All rights reserved.
//

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
    ANWebView *removedWebView = [self.webViewQueue firstObject];
    __weak ANWarmupWebView  *weakSelf  = self;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            __strong ANWarmupWebView  *strongSelf  = weakSelf;
            if (!strongSelf)  {
                return;
            }
            
            [self prepareWebView];
        });
    });
    
    return removedWebView;
    
}

@end
