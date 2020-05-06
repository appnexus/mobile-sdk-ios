//
//  ANWarmupSDKObjects.m
//  AppNexusSDK
//
//  Created by Punnaghai Puviarasu on 5/6/20.
//  Copyright © 2020 AppNexus. All rights reserved.
//

#import "ANWarmupSDKObjects.h"
#import <WebKit/WebKit.h>
#import "ANGlobal.h"
#import "ANSDKSettings+PrivateMethods.h"

NSURLSession *sharedSession = nil;

NSMutableURLRequest  *utMutableRequest = nil;

@implementation ANWarmupSDKObjects

+ (void)load {
    
    // No need for "dispatch once" since `load` is called only once during app launch.
    [self constructAdServerRequestURL];
    
    sharedSession = [NSURLSession sharedSession];
}

+(NSMutableURLRequest *) adServerRequestURL {
    return utMutableRequest;
}

+ (void) constructAdServerRequestURL {
    NSString      *urlString  = [[[ANSDKSettings sharedInstance] baseUrlConfig] utAdRequestBaseUrl];
    NSURL                *URL             = [NSURL URLWithString:urlString];
    
    utMutableRequest  = [[NSMutableURLRequest alloc] initWithURL: URL
                                                                         cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
                                                                     timeoutInterval: kAppNexusRequestTimeoutInterval];

    // Set header fields for HTTP request.
    // NB  Content-Type needs to be set explicity else will default to "application/x-www-form-urlencoded".
    //
    [utMutableRequest setValue:[ANGlobal getUserAgent] forHTTPHeaderField:@"User-Agent"];
    [utMutableRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [utMutableRequest setHTTPMethod:@"POST"];
}

@end
