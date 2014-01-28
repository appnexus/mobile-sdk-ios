//
//  ANMRAIDTestResponses.m
//  Tests
//
//  Created by Jose Cabal-Ugaz on 1/27/14.
//
//

#import "ANMRAIDTestResponses.h"

@implementation ANMRAIDTestResponses

+ (NSString *)basicMRAIDBannerWithSelectorName:(NSString *)selector {
    return [self createAdsResponse:@"banner" withWidth:320 withHeight:50 withContent:[NSString stringWithFormat:@"<script type=\\\"text/javascript\\\" src=\\\"mraid.js\\\"></script><script type=\\\"text/javascript\\\">document.write('<div style=\\\"background-color:#EF8200;height:1000px;width:1000px;\\\"><p>%@</p></div>');</script>", selector]];
}



@end