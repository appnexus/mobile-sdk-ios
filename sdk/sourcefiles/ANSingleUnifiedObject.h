//
//  ANSingleUnifiedObject.h
//  AppNexusSDK
//
//  Created by Akash Verma on 13/09/19.
//  Copyright © 2019 AppNexus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANAdConstants.h"

NS_ASSUME_NONNULL_BEGIN

@interface ANSingleUnifiedObject : NSObject
/**
 An AppNexus creativeID for the current creative that is displayed
 */
@property (nonatomic, readwrite, strong, nullable) NSString *creativeId;

/**
 Report the Ad Type of the returned ad object.
 Not available until load is complete and successful.
 */
@property (nonatomic, readwrite)  ANAdType  adType;

@property (nonatomic, readwrite)  NSString  *tagId;

@end

NS_ASSUME_NONNULL_END
