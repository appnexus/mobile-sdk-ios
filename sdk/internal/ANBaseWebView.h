//
//  ANBaseWebView.h
//  ANSDK
//
//  Created by Punnaghai Puviarasu on 5/15/19.
//  Copyright © 2019 AppNexus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface ANBaseWebView : NSObject
    
   
    
    - (void)createWebView:(CGSize)size
                             URL:(NSURL *)URL
                  webViewBaseURL:(NSURL *)baseURL;
    
    - (void)createWebView:(CGSize)size
                           HTML:(NSString *)html
                        baseURL:(NSURL *)baseURL;
    
    - (void)createWebView:(CGSize)size;

@end
