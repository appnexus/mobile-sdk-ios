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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface NSPointerArray (ANCategory)
/**
 *  Adds pointer to the given object to the array.
 *
 *  @param object Object whose pointer needs to be added to the array.
 *  If a pointer to this object already exists in the array, you get a duplicate.
 *  Call containsObject first if you don't want that to happen.
 */
- (void)addObject:(id)object;

/**
 *  Checks if pointer to the given object is present in the array.
 *
 *  @param object Object whose pointer's presence needs to be checked.
 *
 *  @return YES if pointer to the given object is already present in the array; NO otherwise.
 */
- (BOOL)containsObject:(id)object;

/**
 *  Removes a pointer that matches the pointer to the passed in object.
 *
 *  @param object An object that's currently in the array. No ill effects if the object is not in the array.
 */
- (void)removeObject:(id)object;

- (id)objectAtIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
