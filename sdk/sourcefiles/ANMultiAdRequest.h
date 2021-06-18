/*   Copyright 2019 APPNEXUS INC

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

#import "ANAdProtocol.h"



#pragma mark - ANMultiAdRequestDelegate.

@class ANMultiAdRequest;

@protocol  ANMultiAdRequestDelegate  <NSObject>

@optional

/**
 * Signal successful completion of load.
 *
 * PARAMETERS
 *
 *   mar: Pointer to the instance of ANMultiAdRequest that has succesfully completed load.
 */
- (void) multiAdRequestDidComplete:(nonnull ANMultiAdRequest *)mar;

/**
* Signal failure of instance load.
*
* PARAMETERS
*
*   mar: Pointer to the instance of ANMultiAdRequest that has succesfully completed load.
*
*   error: Error describing the load failure.
*/
- (void) multiAdRequest:(nonnull ANMultiAdRequest *)mar didFailWithError:(nonnull NSError *)error;

@end




#pragma mark - ANMultiAdRequest.

@interface  ANMultiAdRequest  :NSObject<ANAdProtocolFoundationCore>

/**
 * Contains the current count of AdUnits encapsulated by this instance.
 */
@property (nonatomic, readonly)  NSUInteger  countOfAdUnits;


/**
 * Initializer for ANMultiAdRequest.  This method takes all essential arguments and returns a new instance on success.
 *
 * PARAMETERS
 *
 *   memberId: Member ID common to all encapsulated AdUnits.
 *   publisherID: Publisher ID common to all encapsulated AdUnits.
 *
 *   delegate: Used to receive notification of success or failure from this instance and all encapsulated AdUnits.
 *
 *   firstAdUnit, ...: A list of one or more AdUnits to be encapsulated by this instance.
 */
- (nullable instancetype)initWithMemberId: (NSInteger)memberId
                                 delegate: (nullable id<ANMultiAdRequestDelegate>)delegate
                                  adUnits: (nonnull id<ANAdProtocolFoundationCore>) firstAdUnit, ... NS_REQUIRES_NIL_TERMINATION;

- (nullable instancetype)initWithMemberId: (NSInteger)memberId
                              publisherId: (NSInteger)publisherId
                                 delegate: (nullable id<ANMultiAdRequestDelegate>)delegate
                                  adUnits: (nonnull id<ANAdProtocolFoundationCore>) firstAdUnit, ... NS_REQUIRES_NIL_TERMINATION;

/**
 * Initializer for ANMultiAdRequest.  This method takes all essential arguments and invokes load method.  Returns a new instance upon success.
 *
 * PARAMETERS
 *
 *   memberId: Member ID common to all encapsulated AdUnits.
 *   publisherID: Publisher ID common to all encapsulated AdUnits.
 *
 *   delegate: Used to receive notification of success or failure from this instance and all encapsulated AdUnits.
 *
 *   firstAdUnit, ...: A list of one or more AdUnits to be encapsulated by this instance.
 */
- (nullable instancetype)initAndLoadWithMemberId: (NSInteger)memberId
                                        delegate: (nullable id<ANMultiAdRequestDelegate>)delegate
                                         adUnits: (nonnull id<ANAdProtocolFoundationCore>) firstAdUnit, ... NS_REQUIRES_NIL_TERMINATION;

- (nullable instancetype)initAndLoadWithMemberId: (NSInteger)memberId
                                     publisherId: (NSInteger)publisherId
                                        delegate: (nullable id<ANMultiAdRequestDelegate>)delegate
                                         adUnits: (nonnull id<ANAdProtocolFoundationCore>) firstAdUnit, ... NS_REQUIRES_NIL_TERMINATION;

/**
 * Initializer for ANMultiAdRequest.  This method takes the minimum required arguments and returns a new instance on success.
 *
 * PARAMETERS
 *
 *   memberId: Member ID common to all encapsulated AdUnits.
 *   publisherID: Publisher ID common to all encapsulated AdUnits.
 *
 *   delegate: Used to receive notification of success or failure from this instance and all encapsulated AdUnits.
 */
- (nullable instancetype)initWithMemberId: (NSInteger)memberId
                              andDelegate: (nullable id<ANMultiAdRequestDelegate>)delegate;

- (nullable instancetype)initWithMemberId: (NSInteger)memberId
                              publisherId: (NSInteger)publisherId
                              andDelegate: (nullable id<ANMultiAdRequestDelegate>)delegate;


/**
 * Encapsulate the given AdUnit.
 *
 * PARAMETERS
 *
 *   adunit: An AdUnit to be loaded by this instance.
 */
- (BOOL)addAdUnit:(nonnull id<ANAdProtocolFoundationCore>)adunit;

/**
 * Unencapsulate the given AdUnit.
 *
 * PARAMETERS
 *
 *   adunit: Remove the given AdUnit from the list of encapsulated AdUnits.
 */
- (BOOL)removeAdUnit:(nonnull id<ANAdProtocolFoundationCore>)adunit;



/**
 * Load all encapsulated AdUnits via a single UTv3 Request to the Impression Bus.
 */
- (BOOL)load;

/**
 * To stop Multi Ad Request, before the request is completed.
*/
- (void)stop;

@end
