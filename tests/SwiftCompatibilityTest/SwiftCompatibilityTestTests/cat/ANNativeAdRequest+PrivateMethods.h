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

#import "ANNativeAdRequest.h"
#import "ANMultiAdRequest.h"




#pragma mark -

@interface ANNativeAdRequest (PrivateMethods)

#pragma mark Multi-Ad Request support.

@property (nonatomic, readwrite, weak, nullable)  ANMultiAdRequest                                    *marManager;


/**
 This property is only used with ANMultiAdRequest.
 It associates a unique identifier with each adunit per request, allowing ad objects in the UT Response to be
   matched with adunit elements of the UT Request.
 NB  This value is updated for each UT Request.  It does not persist across the lifecycle of the instance.
 */
@property (nonatomic, readwrite, strong, nonnull)  NSString  *utRequestUUIDString;

/*!
 * Used only in MultiAdRequest to pass ad object returned by impbus directly to the adunit though it was requested by MAR UT Request.
 */
- (void)ingestAdResponseTag: (nonnull id)tag
      totalLatencyStartTime: (NSTimeInterval)totalLatencyStartTime;

@end

