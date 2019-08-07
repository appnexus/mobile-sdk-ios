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

#import "ANMRAIDJavascriptUtil.h"

@implementation ANMRAIDJavascriptUtil

+ (NSString *)readyEvent {
    return @"window.mraid.util.readyEvent();";
}

+ (NSString *)stateChange:(ANMRAIDState)state {
    NSString *stateString = [ANMRAIDUtil stateStringFromState:state];
    if (!stateString) {
        stateString = @"";
    }
    return [NSString stringWithFormat:@"window.mraid.util.stateChangeEvent('%@');", stateString];
}

+ (NSString *)error:(NSString *)error
        forFunction:(NSString *)function {
    return [NSString stringWithFormat:@"window.mraid.util.errorEvent('%@', '%@');", error, function];
}

+ (NSString *)placementType:(NSString *)placementType {
    return [NSString stringWithFormat:@"window.mraid.util.setPlacementType('%@');", placementType];
}

+ (NSString *)isViewable:(BOOL)isViewable {
    return [NSString stringWithFormat:@"window.mraid.util.setIsViewable(%@);",
            isViewable ? @"true" : @"false"];
}

+ (NSString *)currentSize:(CGSize)size {
    int width = floorf(size.width + 0.5f);
    int height = floorf(size.height + 0.5f);
    return [NSString stringWithFormat:@"window.mraid.util.sizeChangeEvent(%i,%i);", width, height];
}

+ (NSString *)currentPosition:(CGRect)position {
    int offsetX = (position.origin.x > 0) ? floorf(position.origin.x + 0.5f) : ceilf(position.origin.x - 0.5f);
    int offsetY = (position.origin.y > 0) ? floorf(position.origin.y + 0.5f) : ceilf(position.origin.y - 0.5f);
    int width = floorf(position.size.width + 0.5f);
    int height = floorf(position.size.height + 0.5f);
    return [NSString stringWithFormat:@"window.mraid.util.setCurrentPosition(%i, %i, %i, %i); %@",
            offsetX, offsetY, width, height, [[self class] currentSize:CGSizeMake(width, height)]];
}

+ (NSString *)defaultPosition:(CGRect)position {
    int offsetX = (position.origin.x > 0) ? floorf(position.origin.x + 0.5f) : ceilf(position.origin.x - 0.5f);
    int offsetY = (position.origin.y > 0) ? floorf(position.origin.y + 0.5f) : ceilf(position.origin.y - 0.5f);
    int width = floorf(position.size.width + 0.5f);
    int height = floorf(position.size.height + 0.5f);
    return [NSString stringWithFormat:@"window.mraid.util.setDefaultPosition(%i, %i, %i, %i);",
            offsetX, offsetY, width, height];
}

+ (NSString *)screenSize:(CGSize)size {
    int width = floorf(size.width + 0.5f);
    int height = floorf(size.height + 0.5f);
    return [NSString stringWithFormat:@"window.mraid.util.setScreenSize(%i, %i);", width, height];
}

+ (NSString *)maxSize:(CGSize)size {
    int width = floorf(size.width + 0.5f);
    int height = floorf(size.height + 0.5f);
    return [NSString stringWithFormat:@"window.mraid.util.setMaxSize(%i, %i);", width, height];
}

+ (NSString *)feature:(NSString *)feature
          isSupported:(BOOL)supported {
    return [NSString stringWithFormat:@"window.mraid.util.setSupports(\'%@\', %@);",
            feature, (supported ? @"true" : @"false")];
}

+ (NSString *)getState {
    return @"window.mraid.getState()";
}


// Occulusion Rectangle is always null we donot support OcculusionRetangle Calculation.
+ (NSString *)exposureChangeExposedPercentage:(CGFloat)exposedPercentage
                             visibleRectangle:(CGRect)visibleRect {
    if(exposedPercentage <=0 ){
        // If exposure percentage is 0 then send visibleRectangle as null.
        NSString *exposureVal = [NSString stringWithFormat:@"{\"exposedPercentage\":0.0,\"visibleRectangle\":null,\"occlusionRectangles\":null}"];
        return [NSString stringWithFormat:@"window.mraid.util.exposureChangeEvent(%@);",exposureVal];
    }else{
        int offsetX = (visibleRect.origin.x > 0) ? floorf(visibleRect.origin.x + 0.5f) : ceilf(visibleRect.origin.x - 0.5f);
        int offsetY = (visibleRect.origin.y > 0) ? floorf(visibleRect.origin.y + 0.5f) : ceilf(visibleRect.origin.y - 0.5f);
        int width = floorf(visibleRect.size.width + 0.5f);
        int height = floorf(visibleRect.size.height + 0.5f);
        
        NSString *exposureVal = [NSString stringWithFormat:@"{\"exposedPercentage\":%.01f,\"visibleRectangle\":{\"x\":%i,\"y\":%i,\"width\":%i,\"height\":%i},\"occlusionRectangles\":null}",exposedPercentage,offsetX,offsetY,width,height];
        return [NSString stringWithFormat:@"window.mraid.util.exposureChangeEvent(%@);",exposureVal];
    }
}

@end
