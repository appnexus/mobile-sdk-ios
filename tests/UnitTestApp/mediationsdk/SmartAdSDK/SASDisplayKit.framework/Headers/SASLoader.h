//
//  SASLoader.h
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 17/08/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Type of loader used before the banner can be displayed.
typedef NS_ENUM(NSInteger, SASLoader) {
    
    /// No loader.
    SASLoaderNone,
    
    /// Loader with black background.
    SASLoaderActivityIndicatorStyleBlack,
    
    /// Loader with white background.
    SASLoaderActivityIndicatorStyleWhite,
    
    /// Loader with transparent background.
    SASLoaderActivityIndicatorStyleTransparent
    
};

NS_ASSUME_NONNULL_END
