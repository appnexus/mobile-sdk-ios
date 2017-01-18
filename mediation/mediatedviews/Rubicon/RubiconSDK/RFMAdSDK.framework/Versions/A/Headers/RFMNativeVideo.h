//
//  RFMNativeVideo.h
//  RFMAdSDK
//
//  Created by Rubicon Project on 9/14/16.
//  Copyright © 2016 Rubicon Project. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "RFMNativeLink.h"

@class RFMNativeVideoPlayerView;

@interface RFMNativeVideo : NSObject

@property (nonatomic, strong) NSString *vastTag;
@property (nonatomic, strong) NSURL *mediaFileUrl;
@property (nonatomic, strong) RFMNativeVideoPlayerView *playerView;
@property (nonatomic, strong) RFMNativeLink *link;

- (id)initWithVastTag:(NSString *)vastTag
         mediaFileUrl:(NSURL *)mediaFileUrl
           playerView:(RFMNativeVideoPlayerView *)playerView
                 link:(RFMNativeLink *)link;

@end
