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

#import "ANOpenInExternalBrowserActivity.h"
#import "ANGlobal.h"
#import "ANLogging.h"

@interface ANOpenInExternalBrowserActivity()

@property (nonatomic, readwrite, strong) NSURL *URLToOpen;

@end

@implementation ANOpenInExternalBrowserActivity

- (NSString *)activityType {
    return @"AppNexus Open In Safari";
}

- (NSString *)activityTitle {
    return @"Open In Safari";
}

- (UIImage *)activityImage {
    NSString *iconPath = ANPathForANResource(@"compass", @"png");
    if (!iconPath) {
        ANLogError(@"Could not find compass image for 'Open in Safari' sharing option");
        return nil;
    }
    UIImage *icon = [UIImage imageWithContentsOfFile:iconPath];
    return icon;
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    id firstObject = [activityItems firstObject];
    if ([firstObject isKindOfClass:[NSURL class]]) {
        NSURL *URL = (NSURL *)firstObject;
        return URL.absoluteString.length;
    }
    return NO;
}

- (void)performActivity {
    [ANGlobal openURL:[self.URLToOpen absoluteString]];
    [self activityDidFinish:YES];
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    self.URLToOpen = [activityItems objectAtIndex:0];
}

+ (UIActivityCategory)activityCategory {
    return UIActivityCategoryAction;
}

@end
