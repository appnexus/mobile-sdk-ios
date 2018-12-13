//
//  SCSVASTAdWrapper.h
//  SCSCoreKit
//
//  Created by Thomas Geley on 21/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import "SCSVASTAd.h"

NS_ASSUME_NONNULL_BEGIN

@interface SCSVASTAdWrapper : SCSVASTAd

@property (nullable, nonatomic, readonly) SCSVASTURL *adTagURL;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
