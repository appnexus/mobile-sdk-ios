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

#import "ANMRAIDUtil.h"
#import <MessageUI/MFMessageComposeViewController.h>
#import <MediaPlayer/MediaPlayer.h>
#import "ANGlobal.h"

@implementation ANMRAIDUtil

+ (ANMRAIDCustomClosePosition)customClosePositionFromCustomClosePositionString:(NSString *)customClosePositionString {
    if ([customClosePositionString isEqualToString:@"top-left"]) {
        return ANMRAIDCustomClosePositionTopLeft;
    } else if ([customClosePositionString isEqualToString:@"top-center"]) {
        return ANMRAIDCustomClosePositionTopCenter;
    } else if ([customClosePositionString isEqualToString:@"top-right"]) {
        return ANMRAIDCustomClosePositionTopRight;
    } else if ([customClosePositionString isEqualToString:@"center"]) {
        return ANMRAIDCustomClosePositionCenter;
    } else if ([customClosePositionString isEqualToString:@"bottom-left"]) {
        return ANMRAIDCustomClosePositionBottomLeft;
    } else if ([customClosePositionString isEqualToString:@"bottom-center"]) {
        return ANMRAIDCustomClosePositionBottomCenter;
    } else if ([customClosePositionString isEqualToString:@"bottom-right"]) {
        return ANMRAIDCustomClosePositionBottomRight;
    }
    return ANMRAIDCustomClosePositionUnknown;
}

+ (BOOL)supportsSMS {
    return [MFMessageComposeViewController canSendText];
}

+ (BOOL)supportsTel {
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]];
}

+ (BOOL)supportsCalendar {
    return YES;
}

+ (BOOL)supportsInlineVideo {
    return YES;
}

+ (BOOL)supportsStorePicture {
    return YES;
}

+ (ANMRAIDAction)actionForCommand:(NSString *)command {
    if ([command isEqualToString:@"expand"]) {
        return ANMRAIDActionExpand;
    } else if ([command isEqualToString:@"close"]) {
        return ANMRAIDActionClose;
    } else if ([command isEqualToString:@"resize"]) {
        return ANMRAIDActionResize;
    } else if ([command isEqualToString:@"createCalendarEvent"]) {
        return ANMRAIDActionCreateCalendarEvent;
    } else if ([command isEqualToString:@"playVideo"]) {
        return ANMRAIDActionPlayVideo;
    } else if ([command isEqualToString:@"storePicture"]) {
        return ANMRAIDActionStorePicture;
    } else if ([command isEqualToString:@"setOrientationProperties"]) {
        return ANMRAIDActionSetOrientationProperties;
    } else if ([command isEqualToString:@"setUseCustomClose"]) {
        return ANMRAIDActionSetUseCustomClose;
    } else if ([command isEqualToString:@"open"]) {
        return ANMRAIDActionOpenURI;
    } else if ([command isEqualToString:@"enable"]) {
        return ANMRAIDActionEnable;
    }
    return ANMRAIDActionUnknown;
}

+ (void)storePictureWithUri:(NSString *)uri
       withCompletionTarget:(id)target
         completionSelector:(SEL)selector {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url = [NSURL URLWithString:uri];
        NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:url]
                                             returningResponse:nil
                                                         error:nil];
        if(data){
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *image = [[UIImage alloc] initWithData:data];
                if (image) {
                    UIImageWriteToSavedPhotosAlbum(image, target, selector, nil);
                }
            });
        }
    });
}

+ (void)playVideoWithUri:(NSString *)uri
  fromRootViewController:(UIViewController *)rootViewController
    withCompletionTarget:(id)target
      completionSelector:(SEL)selector {
    NSURL *url = [NSURL URLWithString:uri];
    
    MPMoviePlayerViewController *moviePlayerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
    moviePlayerViewController.moviePlayer.fullscreen = YES;
    moviePlayerViewController.moviePlayer.shouldAutoplay = YES;
    moviePlayerViewController.moviePlayer.movieSourceType = MPMovieSourceTypeUnknown;
    moviePlayerViewController.moviePlayer.view.frame = rootViewController.view.frame;
    moviePlayerViewController.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
    [moviePlayerViewController.moviePlayer prepareToPlay];
    [rootViewController presentMoviePlayerViewControllerAnimated:moviePlayerViewController];
    [moviePlayerViewController.moviePlayer play];
    
    [[NSNotificationCenter defaultCenter] addObserver:target
                                             selector:selector
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:moviePlayerViewController.moviePlayer];
}

+ (ANMRAIDOrientation)orientationFromForceOrientationString:(NSString *)orientationString {
    if ([orientationString isEqualToString:@"portrait"]) {
        return ANMRAIDOrientationPortrait;
    } else if ([orientationString isEqualToString:@"landscape"]) {
        return ANMRAIDOrientationLandscape;
    }
    return ANMRAIDOrientationNone;
}

+ (CGSize)maxSize {
    return [[self class] screenSize];
}

+ (CGSize)screenSize {
    BOOL orientationIsPortrait = UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]);
    CGSize screenSize = ANPortraitScreenBounds().size;
    int orientedWidth = orientationIsPortrait ? screenSize.width : screenSize.height;
    int orientedHeight = orientationIsPortrait ? screenSize.height : screenSize.width;
    return CGSizeMake(orientedWidth, orientedHeight);
}

+ (ANMRAIDState)stateFromString:(NSString *)stateString {
    if ([stateString isEqualToString:@"loading"]) {
        return ANMRAIDStateLoading;
    } else if ([stateString isEqualToString:@"default"]) {
        return ANMRAIDStateDefault;
    } else if ([stateString isEqualToString:@"expanded"]) {
        return ANMRAIDStateExpanded;
    } else if ([stateString isEqualToString:@"hidden"]) {
        return ANMRAIDStateHidden;
    } else if ([stateString isEqualToString:@"resized"]) {
        return ANMRAIDStateResized;
    }
    return ANMRAIDStateUnknown;
}

+ (NSString *)stateStringFromState:(ANMRAIDState)state {
    switch (state) {
        case ANMRAIDStateLoading:
            return @"loading";
        case ANMRAIDStateDefault:
            return @"default";
        case ANMRAIDStateExpanded:
            return @"expanded";
        case ANMRAIDStateHidden:
            return @"hidden";
        case ANMRAIDStateResized:
            return @"resized";
        default:
            return nil;
    }
}

@end