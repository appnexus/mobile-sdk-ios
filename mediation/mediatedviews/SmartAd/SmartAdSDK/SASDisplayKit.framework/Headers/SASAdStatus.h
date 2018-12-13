//
//  SASAdStatus.h
//  SASDisplayKit
//
//  Created by Loïc GIRON DIT METAZ on 07/11/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

/// Status of an ad.
typedef NS_ENUM(NSUInteger, SASAdStatus) {
    
    /// No ad available.
    SASAdStatusNotAvailable,
    
    /// An ad is currently being loaded.
    SASAdStatusLoading,
    
    /// Ad ready to be displayed.
    SASAdStatusReady,
    
    /// Ad is currently being displayed.
    SASAdStatusShowing,
    
    /// Ad loaded but expired.
    SASAdStatusExpired,
    
};

NS_ASSUME_NONNULL_END
