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

#import "ANWebView.h"

#import "ANGlobal.h"
#import "ANLogging.h"
#import "UIWebView+ANCategory.h"

@implementation ANWebView

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        self.scrollEnabled = NO;
        [self setMediaProperties];
    }
    return self;
}

@end

@implementation ANWebView (MRAIDExtensions)

- (void)fireReadyEvent {
    NSString* script = [NSString stringWithFormat:@"window.mraid.util.readyEvent();"];
    [self stringByEvaluatingJavaScriptFromString:script];
}

- (void)fireStateChangeEvent:(ANMRAIDState)state {
    NSString *stateString = @"";
    
    switch (state) {
        case ANMRAIDStateLoading:
            stateString = @"loading";
            break;
        case ANMRAIDStateDefault:
            stateString = @"default";
            break;
        case ANMRAIDStateExpanded:
            stateString = @"expanded";
            break;
        case ANMRAIDStateHidden:
            stateString = @"hidden";
            break;
        case ANMRAIDStateResized:
            stateString = @"resized";
            break;
        default:
            break;
    }
    
    NSString *script = [NSString stringWithFormat:@"window.mraid.util.stateChangeEvent('%@')", stateString];
    [self stringByEvaluatingJavaScriptFromString:script];
}

- (void)fireErrorEvent:(NSString *)errorString function:(NSString *)function {
    NSString* script = [NSString stringWithFormat:@"mraid.util.errorEvent('%@', '%@');", errorString, function];
    [self stringByEvaluatingJavaScriptFromString:script];
}

- (void)fireNewCurrentPositionEvent:(CGRect)frame {
    [self setCurrentSize:frame.size];
    [self setCurrentPosition:frame];
}

- (void)setPlacementType:(NSString *)placementType {
    NSString* script = [NSString stringWithFormat:@"window.mraid.util.setPlacementType('%@');", placementType];
    [self stringByEvaluatingJavaScriptFromString:script];
}

- (void)setIsViewable:(BOOL)viewable {
    NSString* script = [NSString stringWithFormat:@"window.mraid.util.setIsViewable(%@)",
                        viewable ? @"true" : @"false"];
    [self stringByEvaluatingJavaScriptFromString:script];
}

- (void)setCurrentSize:(CGSize)size {
    int width = floorf(size.width + 0.5f);
    int height = floorf(size.height + 0.5f);
    
    NSString *script = [NSString stringWithFormat:@"window.mraid.util.sizeChangeEvent(%i,%i);",
                        width, height];
    [self stringByEvaluatingJavaScriptFromString:script];
}

- (void)setCurrentPosition:(CGRect)frame {
    int offsetX = (frame.origin.x > 0) ? floorf(frame.origin.x + 0.5f) : ceilf(frame.origin.x - 0.5f);
    int offsetY = (frame.origin.y > 0) ? floorf(frame.origin.y + 0.5f) : ceilf(frame.origin.y - 0.5f);
    int width = floorf(frame.size.width + 0.5f);
    int height = floorf(frame.size.height + 0.5f);
    
    NSString *script = [NSString stringWithFormat:@"window.mraid.util.setCurrentPosition(%i, %i, %i, %i);",
                        offsetX, offsetY, width, height];
    [self stringByEvaluatingJavaScriptFromString:script];
}

- (void)setDefaultPosition:(CGRect)frame {
    int offsetX = (frame.origin.x > 0) ? floorf(frame.origin.x + 0.5f) : ceilf(frame.origin.x - 0.5f);
    int offsetY = (frame.origin.y > 0) ? floorf(frame.origin.y + 0.5f) : ceilf(frame.origin.y - 0.5f);
    int width = floorf(frame.size.width + 0.5f);
    int height = floorf(frame.size.height + 0.5f);
    
    NSString *script = [NSString stringWithFormat:@"window.mraid.util.setDefaultPosition(%i, %i, %i, %i);",
                        offsetX, offsetY, width, height];
    [self stringByEvaluatingJavaScriptFromString:script];
}

- (void)setScreenSize:(CGSize)size {
    int width = floorf(size.width + 0.5f);
    int height = floorf(size.height + 0.5f);
    [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.mraid.util.setScreenSize(%i, %i);", width, height]];
}

- (void)setMaxSize:(CGSize)size {
    int width = floorf(size.width + 0.5f);
    int height = floorf(size.height + 0.5f);
    [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.mraid.util.setMaxSize(%i, %i);",width, height]];
}

- (void)setSupports:(NSString *)feature isSupported:(BOOL)isSupported {
    [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.mraid.util.setSupports(\'%@\', %@);",
                                                  feature, (isSupported ? @"true" : @"false")]];
}

- (ANMRAIDState)getMRAIDState {
    NSString *state = [self stringByEvaluatingJavaScriptFromString:@"window.mraid.getState()"];
    if ([state isEqualToString:@"loading"]) {
        return ANMRAIDStateLoading;
    } else if ([state isEqualToString:@"default"]) {
        return ANMRAIDStateDefault;
    } else if ([state isEqualToString:@"expanded"]) {
        return ANMRAIDStateExpanded;
    } else if ([state isEqualToString:@"hidden"]) {
        return ANMRAIDStateHidden;
    } else if ([state isEqualToString:@"resized"]) {
        return ANMRAIDStateResized;
    }
    
    ANLogError(@"Call to mraid.getState() returned invalid state.");
    return ANMRAIDStateDefault;
}

- (void)setHidden:(BOOL)hidden animated:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:kAppNexusAnimationDuration animations:^{
            self.alpha = hidden ? 0.0f : 1.0f;
        } completion:^(BOOL finished) {
            self.hidden = hidden;
            self.alpha = 1.0f;
        }];
    }
    else {
        self.hidden = hidden;
    }
}

@end
