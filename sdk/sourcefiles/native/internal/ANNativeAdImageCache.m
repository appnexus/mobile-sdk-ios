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

#import "ANNativeAdImageCache.h"

@implementation ANNativeAdImageCache

+ (NSCache *)sharedImageCache {
    static dispatch_once_t imageCacheToken;
    static NSCache *imageCache;
    dispatch_once(&imageCacheToken, ^{
        imageCache = [[NSCache alloc] init];
    });
    return imageCache;
}

+ (UIImage *)imageForKey:(NSString *)key {
    return [[[self class] sharedImageCache] objectForKey:key];
}

+ (void)setImage:(UIImage *)image
          forKey:(NSString *)key {
    [[[self class] sharedImageCache] setObject:image
                                        forKey:key];
}
+ (void)removeAllImages {
    [[[self class] sharedImageCache] removeAllObjects];
}

@end