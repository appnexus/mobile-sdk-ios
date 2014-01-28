//
//  ANMRAIDTestResponses.m
//  Tests
//
//  Created by Jose Cabal-Ugaz on 1/27/14.
//
//

#import "ANMRAIDTestResponses.h"

@implementation ANMRAIDTestResponses

+ (NSString *)basicMRAIDBanner {
    return [self createAdsResponse:@"banner" withWidth:320 withHeight:50 withContent:@"<script type=\\\"text/javascript\\\" src=\\\"mraid.js\\\"></script><script type=\\\"text/javascript\\\">document.write('<div style=\\\"background-color:#EF8200;height:50px;width:320px;vertical-align:middle;\\\"><p style=\\\"text-align:center;\\\">TEST AD 320x50</p></div>');</script>"];
}

@end