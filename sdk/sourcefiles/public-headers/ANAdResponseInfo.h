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

#import <Foundation/Foundation.h>
#import "ANAdConstants.h"

@interface ANAdResponseInfo : NSObject
/**
 An AppNexus creativeID for the current creative that is displayed
 */
@property (nonatomic, readwrite, strong, nullable) NSString *creativeId;

/**
 Report the Ad Type of the returned ad object.
 Not available until load is complete and successful.
 */
@property (nonatomic, readwrite)  ANAdType  adType;

/**
 An AppNexus placement ID.  A placement ID is a numeric ID that's
 associated with a place where ads can be shown.  In our
 implementations of banner and interstitial ad views, we associate
 each ad view with a placement ID.
 */
@property (nonatomic, readwrite, strong, nullable) NSString *placementId;

/**
 An AppNexus member ID. A member ID is a numeric ID that's associated
 with the member that this app belongs to.
 */
@property (nonatomic, readwrite, assign) NSInteger memberId;

/**
 An AppNexus contentSource. A contentSource can be RTB , CSM or SSM
 */
@property (nonatomic, readwrite, strong, nullable) NSString *contentSource;

/**
 An AppNexus networkName. A networkName belongs to mediation adaptor class based on UTv3 response
 */
@property (nonatomic, readwrite, strong, nullable) NSString *networkName;

/**
 An AppNexus auctionId.  An auction identifier is unique id generated for the current bid.
 */
@property (nonatomic, readwrite, strong, nullable) NSString *auctionId;

/**
 An AppNexus CPM. A CPM is BidPrice.
 */
@property (nonatomic, readwrite, strong, nullable) NSNumber *cpm;

/**
 An AppNexus Publisher Currency Price.CPM Publisher Currency of bidPrice
 */
@property (nonatomic, readwrite, strong, nullable) NSNumber *cpmPublisherCurrency;

/**
 An AppNexus Currency Code. A Publisher Currency Code of bidPrice
 */
@property (nonatomic, readwrite, strong, nullable) NSString *publisherCurrencyCode;

@end

