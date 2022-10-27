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

#import "NSView+ANCategory.h"
#import "ANLogging.h"

#import "ANGlobal.h"

@implementation NSView (NSCategory)


//Provide a visible rectangle in more of the position within the view along with the width & height.eg (81.0,430.0,300.0,250.0)
- (CGRect)an_visibleInViewRectangle{
    CGRect visibleRectangle =  CGRectMake(0,0,0,0);
    if(self.an_isViewable){
        NSWindow *parentWindow = self.window;
        visibleRectangle = [parentWindow convertRectToScreen:self.frame];
        
    }
    
    return visibleRectangle;
    
}


- (BOOL)an_isViewable {
    BOOL isHidden = self.hidden;
    if (isHidden) return NO;
    
    BOOL isAttachedToWindow = self.window ? YES : NO;
    if (!isAttachedToWindow) return NO;
    
    BOOL isInHiddenSuperview = NO;
    NSView *ancestorView = self.superview;
    while (ancestorView) {
        if (ancestorView.hidden) {
            isInHiddenSuperview = YES;
            break;
        }
        ancestorView = ancestorView.superview;
    }
    if (isInHiddenSuperview) return NO;
    
    CGRect normalizedSelfRect = [self convertRect:self.bounds toView:nil];
    NSArray *screenList = [NSScreen screens];
    for (NSScreen *screen in screenList)
    {
        CGRect screenRect = screen.visibleFrame;
        BOOL isViewable = CGRectIntersectsRect(normalizedSelfRect, screenRect);
        if(isViewable){
            return YES;
        }
    }

    
    return NO;
}



- (void)setAnNativeAdResponse:(ANNativeAdResponse *)anNativeAdResponse {
    objc_setAssociatedObject(self, @selector(anNativeAdResponse), anNativeAdResponse, OBJC_ASSOCIATION_RETAIN);
}

- (ANNativeAdResponse *)anNativeAdResponse {
    return objc_getAssociatedObject(self, @selector(anNativeAdResponse));
}
@end
