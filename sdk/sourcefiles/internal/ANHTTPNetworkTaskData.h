//
//  ANHTTPNetworkTaskData.h
//  UpdatedNetworkLatency
//
//  Created by Punnaghai Puviarasu on 4/30/20.
//  Copyright © 2020 Punnaghai Puviarasu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ANHTTPNetworkTaskData : NSObject

@property (nonatomic, strong, nullable) NSMutableData * responseData;
@property (nonatomic, copy, nullable) void (^responseHandler)(NSData * data, NSHTTPURLResponse * response);
@property (nonatomic, copy, nullable) void (^errorHandler)(NSError * error);

- (instancetype)initWithResponseHandler:(void (^ _Nullable)(NSData * data, NSHTTPURLResponse * response))responseHandler
                           errorHandler:(void (^ _Nullable)(NSError * error))errorHandler NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
