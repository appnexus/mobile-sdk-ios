/*   Copyright 2015 APPNEXUS INC
 
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

#import "ANVast+ANCategory.h"
#import "ANVASTUtil.h"

@implementation ANVast (ANCategory)

- (ANInLine *)inlineAd {
    return self.anInLine ? self.anInLine : [self.anWrappers lastObject]; //last object has the valid inline element
}

- (NSString *)getClickThroughURL {
    if (self.inlineAd) {
        for (ANCreative *creative in self.inlineAd.creatives) {
            if (creative) {
                if (creative.anLinear.anVideoClicks) {
                    if (creative.anLinear.anVideoClicks.clickThrough) {
                        return creative.anLinear.anVideoClicks.clickThrough;
                    }
                }
            }
        }
    }
    
    return nil;
}

- (float)getSkipOffSetFromVastDataModel {
    float skipOffSet = 0.0;
    
    for (ANCreative *creative in self.inlineAd.creatives) {
        if(creative.anLinear.skipOffSet.length > 0){
            NSArray *timeComponents = [creative.anLinear.skipOffSet componentsSeparatedByString:@":"];
            skipOffSet = [[timeComponents lastObject] floatValue];
        }
    }

    return skipOffSet;
}

/**
 TODO: Proper tracking for nested VAST wrappers
 [DeepakB:] Done.
 */

- (NSArray *)clickTrackingURL {
    __block NSArray *creatives = @[];
    if (self.anInLine.creatives) {
        creatives = [creatives arrayByAddingObjectsFromArray:self.anInLine.creatives];
    }
    
    [self.anWrappers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ANWrapper *wrapper = (ANWrapper *)obj;
        if (wrapper.creatives) {
            creatives = [creatives arrayByAddingObjectsFromArray:wrapper.creatives];
        }
    }];
    
    NSArray *trackingArray = @[];
    for (ANCreative *creative in creatives) {
        if (creative.anLinear.anVideoClicks.clickTracking) {
            trackingArray = [trackingArray arrayByAddingObject:creative.anLinear.anVideoClicks.clickTracking];
        }
    }
    if ([trackingArray count]) {
        return trackingArray;
    }
    return nil;
}

- (NSArray *)trackingArrayForEvent:(ANVideoEvent)event {
    __block NSArray *creatives = @[];
    if (self.anInLine.creatives) {
        creatives = [creatives arrayByAddingObjectsFromArray:self.anInLine.creatives];
    }
    
    [self.anWrappers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ANWrapper *wrapper = (ANWrapper *)obj;
        if (wrapper.creatives) {
            creatives = [creatives arrayByAddingObjectsFromArray:wrapper.creatives];
        }
    }];

    NSString *vastEventString = [ANVASTUtil eventStringForVideoEvent:event];
    if (vastEventString) {
        NSArray *trackingArray = @[];
        for (ANCreative *creative in creatives) {
            if (creative.anLinear.trackingEvents.count > 0) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"vastEvent == %@", vastEventString];
                NSArray *trackingEventsArray = [creative.anLinear.trackingEvents filteredArrayUsingPredicate:predicate];
                if (trackingEventsArray) {
                    trackingArray = [trackingArray arrayByAddingObjectsFromArray:trackingEventsArray];
                }
            }
        }
        return trackingArray;
    }
    return nil;
}

@end
