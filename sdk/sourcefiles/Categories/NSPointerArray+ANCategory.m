/*   Copyright 2021 Xandr INC
 
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

#import "NSPointerArray+ANCategory.h"

@implementation NSPointerArray(ANCategory)

- (void)addObject:(id)object
{
    [self addPointer:(__bridge void *)object];
}

- (BOOL)containsObject:(id)object
{
    // get passed in object's pointer
    void * objPtr = (__bridge void *)object;
    for (NSUInteger i = 0; i < [self count]; i++) {
        void * ptr = [self pointerAtIndex:i];
        
        if (ptr == objPtr) {
            return YES;
        }
    }
    
    return NO;
}

- (void)removeObject:(id)object
{
    // get pointer to the passed in object
    void * objPtr = (__bridge void *)object;
    int objIndex = -1;
    for (NSUInteger i = 0; i < [self count]; i++) {
        void * ptr = [self pointerAtIndex:i];
        
        if (ptr == objPtr) {
            // pointers equal, found our object!
            objIndex = i;
            break;
        }
    }
    
    // make sure index is non-nil and not outside bounds
    if (objIndex >= 0 && objIndex < [self count]) {
        [self removePointerAtIndex:objIndex];
    }
}

- (id)objectAtIndex:(NSUInteger)index {
    return [self pointerAtIndex:index];
}


@end
