//
//  ANHTTPNetworkTaskData.m
//  UpdatedNetworkLatency
//
//  Created by Punnaghai Puviarasu on 4/30/20.
//  Copyright © 2020 Punnaghai Puviarasu. All rights reserved.
//

#import "ANHTTPNetworkTaskData.h"

@implementation ANHTTPNetworkTaskData

- (instancetype)init {
    return [self initWithResponseHandler:nil errorHandler:nil];
}

- (instancetype)initWithResponseHandler:(void (^ _Nullable)(NSData * data, NSHTTPURLResponse * response))responseHandler
                           errorHandler:(void (^ _Nullable)(NSError * error))errorHandler {
    if (self = [super init]) {
        _responseData = nil;
        _responseHandler = responseHandler;
        _errorHandler = errorHandler;
    }

    return self;
}


@end
