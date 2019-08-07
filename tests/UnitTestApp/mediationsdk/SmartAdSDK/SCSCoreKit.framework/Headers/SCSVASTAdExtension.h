//
//  SCSVASTAdExtension.h
//  SCSCoreKit
//
//  Created by Thomas Geley on 21/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SCSVASTTrackingEvent;

@interface SCSVASTAdExtension : NSObject

@property (nonatomic, readonly) BOOL offsetIsForced;
@property (nullable, nonatomic, readonly) NSString *skipOffset;
@property (nullable, nonatomic, readonly) NSString *sortRank;
@property (nullable, nonatomic, readonly) NSString *customScript;
@property (nonatomic, readonly) NSInteger instanceCount;

@property (nullable, nonatomic, readonly) NSMutableArray <SCSVASTTrackingEvent *> *metrics;

@property (nullable, nonatomic, readonly) NSNumber *statDomainID;
@property (nullable, nonatomic, readonly) NSNumber *networkID;
@property (nullable, nonatomic, readonly) NSNumber *templateID;
@property (nullable, nonatomic, readonly) NSNumber *advertiserID;
@property (nullable, nonatomic, readonly) NSNumber *campaignID;
@property (nullable, nonatomic, readonly) NSNumber *insertionID;
@property (nullable, nonatomic, readonly) NSNumber *siteID;
@property (nullable, nonatomic, readonly) NSString *pageID;
@property (nullable, nonatomic, readonly) NSNumber *formatID;
@property (nullable, nonatomic, readonly) NSNumber *adBreakType;
@property (nullable, nonatomic, readonly) NSString *target;
@property (nullable, nonatomic, readonly) NSNumber *sessionID;
@property (nullable, nonatomic, readonly) NSURL *baseURL;
@property (nullable, nonatomic, readonly) NSNumber *instances;
@property (nullable, nonatomic, readonly) NSNumber *videoPlayerWidth;
@property (nullable, nonatomic, readonly) NSNumber *videoPlayerHeight;
@property (nullable, nonatomic, readonly) NSString *referer;
@property (nullable, nonatomic, readonly) NSString *clientIP;
@property (nullable, nonatomic, readonly) NSString *contentID;
@property (nullable, nonatomic, readonly) NSString *contentProviderID;

@property (nullable, nonatomic, readonly) NSString *rtbAdvertiserID;
@property (nullable, nonatomic, readonly) NSString *rtbDspID;
@property (nullable, nonatomic, readonly) NSString *rtbBuyerID;
@property (nullable, nonatomic, readonly) NSString *rtbDealID;
@property (nullable, nonatomic, readonly) NSString *rtbAuctionID;
@property (nullable, nonatomic, readonly) NSString *rtbPublisherID;
@property (nullable, nonatomic, readonly) NSString *rtbBidLogTimeTicks;
@property (nullable, nonatomic, readonly) NSString *rtbEnvironmentType;
@property (nullable, nonatomic, readonly) NSString *rtbImpressionHash;


- (instancetype)init NS_UNAVAILABLE;

/**
 Initializer from an XML Dictionary.
 
 @param dictionary A NSDictionary extracted from the VAST XML.
 */
- (nullable instancetype)initWithDictionary:(NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
