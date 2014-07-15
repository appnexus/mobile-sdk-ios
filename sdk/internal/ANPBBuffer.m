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

#import "ANPBBuffer.h"

#import "ANGlobal.h"
#import "NSString+ANCategory.h"

#import <UIKit/UIKit.h>

@implementation ANPBBuffer

static NSMutableDictionary *pbBuffer;
static NSMutableArray *pbKeys;
NSString *const kImageKey = @"kUTTypeImage";
NSString *const kTextKey = @"kUTTypeUTF8PlainText";
NSString *const kAuctionIDKey = @"auction_id";
NSString *const kAuctionInfoKey = @"auction_info";
NSString *const kPBAppUrl = @"appnexuspb://app?";
int64_t const kPBCaptureDelay = 1; // delay in seconds

# pragma mark static initializer, called before any methods are used

+ (void) initialize {
    // make sure pitbullBuffer is initialized
    if (!pbBuffer || !pbKeys) {
        [ANPBBuffer resetBuffer];
    }
}

#pragma mark Public Interface to Modify Buffer

+ (void)handleUrl:(NSURL *)URL forView:(UIView *)view {
    
    NSString *host = [URL host];
    
    if ([host isEqualToString:@"web"]) {
        // intercept call to populate pasteboard before launching app
        [ANPBBuffer setPasteboardAndLaunch];
        
    } else if ([host isEqualToString:@"app"]) {
        // record auction_info into buffer
        NSDictionary *queryComponents = [[URL query] queryComponents];
        NSString *auctionInfo = [queryComponents objectForKey:kAuctionInfoKey];
        [ANPBBuffer saveAuctionInfo:auctionInfo];
        
    } else if ([host isEqualToString:@"capture"]) {
        // take a screenshot and attach it to the info for this auction ID
        NSDictionary *queryComponents = [[URL query] queryComponents];
        NSString *auctionID = [queryComponents objectForKey:kAuctionIDKey];
        [ANPBBuffer captureImage:view forAuctionID:auctionID];
        
    }
}

// returns the auctionID that was parsed
+ (NSString *)saveAuctionInfo:(NSString *)auctionInfo {
    // record auction_info into buffer
    if (auctionInfo) {
        NSData *data = [auctionInfo dataUsingEncoding:NSUTF8StringEncoding];
        NSError *jsonParsingError = nil;
        NSDictionary *jsonDict = [NSJSONSerialization
                                  JSONObjectWithData:data
                                  options:0
                                  error:&jsonParsingError];
        
        if (!jsonParsingError) {
            NSString *auctionID = [jsonDict objectForKey:kAuctionIDKey];
            if (auctionID && ![ANPBBuffer containsAuctionInfoForID:auctionID]) {
                [ANPBBuffer trimBuffer];
                [ANPBBuffer saveAuctionInfo:auctionInfo forAuctionID:auctionID];
                return auctionID;
            }
        }
    }
    return nil;
}

// capture image with delay
+ (void)captureDelayedImage:(UIView *)view
               forAuctionID:(NSString *)auctionID {
    [ANPBBuffer captureImage:view forAuctionID:auctionID afterDelay:kPBCaptureDelay];
}

// capture image with immediately
+ (void)captureImage:(UIView *)view
        forAuctionID:(NSString *)auctionID {
    [ANPBBuffer captureImage:view forAuctionID:auctionID afterDelay:0];
}

#pragma mark Buffer Convenience Interface (private)

/* Buffer methods */

// clears and initializes a new buffer
+ (void)resetBuffer {
    pbBuffer = [NSMutableDictionary new];
    pbKeys = [NSMutableArray new];
}

// trim the buffer if necessary
+ (void)trimBuffer {
    if ([pbBuffer count] >= kANPBBufferLimit) {
        id key = [pbKeys objectAtIndex:0];
        // remove first object and shift forward
        [pbKeys removeObjectAtIndex:0];
        [pbBuffer removeObjectForKey:key];
    }
}

+ (void)saveAuctionInfo:(NSString *)auctionInfo
           forAuctionID:(NSString *)auctionID {
    if (auctionID && auctionInfo) {
        [pbBuffer setValue:@{kTextKey:auctionInfo}
                    forKey:auctionID];
        [pbKeys addObject:auctionID];
    }
}

// if pbKeys contains an auctionID key, then auctionInfo must be present
+ (BOOL)containsAuctionInfoForID:(NSString *)auctionID {
    return [pbKeys containsObject:auctionID]; // uses isEqual validation
}

// check if the pbBuffer contains an image for auctionID
+ (BOOL)containsImageForID:(NSString *)auctionID {
    NSDictionary *item = [pbBuffer objectForKey:auctionID];
    return item && [item valueForKey:kImageKey];
}

/* Pasteboard methods */

+ (NSArray *)getPasteboardArray {
    NSMutableArray *array = [NSMutableArray new];
    for (id key in pbKeys) {
        id value = [pbBuffer objectForKey:key];
        [array addObject:value];
    }
    return array;
}

+ (void)setPasteboardAndLaunch {
    NSURL *appURL = [NSURL URLWithString:kPBAppUrl];
    
    if ([[UIApplication sharedApplication] canOpenURL:appURL]) {
        // copy buffer to pasteboard for the app
        [[UIPasteboard generalPasteboard] setItems:[ANPBBuffer getPasteboardArray]];
        
        // clear buffer
        [ANPBBuffer resetBuffer];
        
        [[UIApplication sharedApplication] openURL:appURL];
    }
}

/* Capture Image methods */

+ (void)saveImage:(UIImage *)image forAuctionID:(NSString *)auctionID {
    NSMutableDictionary *item = [[pbBuffer objectForKey:auctionID] mutableCopy];
    if (item) {
        [item setValue:[ANPBBuffer compressImage:image] forKeyPath:kImageKey];
        [pbBuffer setObject:item forKey:auctionID];
    }
}

+ (UIImage *)captureView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0);
    // iOS 7+
    if ([view respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    } else {
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (NSData *)compressImage:(UIImage *)image {
    return UIImageJPEGRepresentation(image, 1.0f);
}

+ (void)captureImage:(__weak UIView *)view
        forAuctionID:(NSString *)auctionID
          afterDelay:(int64_t)delay {
    if (view && auctionID && ![ANPBBuffer containsImageForID:auctionID]) {
        void (^takeScreenshot)() = ^() {
            UIView *strongView = view;
            if (strongView) {
                UIImage *image = [ANPBBuffer captureView:strongView];
                [ANPBBuffer saveImage:image forAuctionID:auctionID];
            }
        };
        
        if (delay > 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC),
                           dispatch_get_main_queue(), takeScreenshot);
        } else {
            takeScreenshot();
        }
    }
}

@end
