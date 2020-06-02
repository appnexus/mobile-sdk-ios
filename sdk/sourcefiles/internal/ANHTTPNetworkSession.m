/*   Copyright 2020 Xandr INC

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

#import "ANHTTPNetworkSession.h"
#import "ANGlobal.h"
#import "ANLogging.h"


@interface ANHTTPNetworkTaskData : NSObject

@property (nonatomic, strong, nullable) NSMutableData * responseData;
@property (nonatomic, copy, nullable) void (^responseHandler)(NSData * data, NSHTTPURLResponse * response);
@property (nonatomic, copy, nullable) void (^errorHandler)(NSError * error);

- (instancetype)initWithResponseHandler:(void (^ _Nullable)(NSData * data, NSHTTPURLResponse * response))responseHandler
                           errorHandler:(void (^ _Nullable)(NSError * error))errorHandler NS_DESIGNATED_INITIALIZER;

@end

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



@interface ANHTTPNetworkSession () <NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSession * adServerSession;

// Access to `NSMutableDictionary` is not thread-safe by default, so we will gate access
// to it using GCD to allow concurrent reads, but synchronous writes.
@property (nonatomic, strong) NSMutableDictionary<NSURLSessionTask *, ANHTTPNetworkTaskData *> * sessions;
@property (nonatomic, strong) dispatch_queue_t sessionsQueue;

@end

@implementation ANHTTPNetworkSession

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id _sharedInstance;
    dispatch_once(&once, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        _adServerSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];

        // Dictionary of all sessions currently in flight.
        _sessions = [NSMutableDictionary dictionary];
        _sessionsQueue = dispatch_queue_create("com.appnexus.mobile-ios-sdk.anhttpnetworksession.queue", DISPATCH_QUEUE_CONCURRENT);
    }

    return self;
}

#pragma mark - Session Access

- (void)appendSessionData:(ANHTTPNetworkTaskData *)data forTask:(NSURLSessionTask *)task {
    dispatch_barrier_sync(self.sessionsQueue, ^{
        self.sessions[task] = data;
    });
}

/**
 Retrieves the task data for the specified task. Accessing the data is thread
 safe, but mutating the data is not thread safe.
 @param task Task which needs a data retrieval.
 @return The task data or @c nil
 */
- (ANHTTPNetworkTaskData *)sessionDataForTask:(NSURLSessionTask *)task {
    __block ANHTTPNetworkTaskData * data = nil;
    dispatch_sync(self.sessionsQueue, ^{
        data = self.sessions[task];
    });

    return data;
}

/**
 Appends additional data to the @c responseData field of @c MPHTTPNetworkTaskData in
 a thread safe manner.
 @param data New data to append.
 @param task Task to append the data to.
 */
- (void)appendData:(NSData *)data toSessionDataForTask:(NSURLSessionTask *)task {
    // No data to append or task.
    if (data == nil || task == nil) {
        return;
    }

    dispatch_barrier_sync(self.sessionsQueue, ^{
        // Do nothing if there is no task data entry.
        ANHTTPNetworkTaskData * taskData = self.sessions[task];
        if (taskData == nil) {
            return;
        }

        // Append the new data to the task.
        if (taskData.responseData == nil) {
            taskData.responseData = [NSMutableData data];
        }

        [taskData.responseData appendData:data];
    });
}

#pragma mark - Manual Start Tasks

+ (NSURLSessionTask *)taskWithHttpRequest:(NSURLRequest *)request
                          responseHandler:(void (^ _Nullable)(NSData * data, NSHTTPURLResponse * response))responseHandler
                             errorHandler:(void (^ _Nullable)(NSError * error))errorHandler {
    // Networking task
    NSURLSessionDataTask * task = [ANHTTPNetworkSession.sharedInstance.adServerSession dataTaskWithRequest:request];

    // Initialize the task data
    ANHTTPNetworkTaskData * taskData = [[ANHTTPNetworkTaskData alloc] initWithResponseHandler:responseHandler errorHandler:errorHandler];

    // Update the sessions.
    [ANHTTPNetworkSession.sharedInstance appendSessionData:taskData forTask:task];

    return task;
}

#pragma mark - Automatic Start Tasks

+ (void)startTaskWithHttpRequest:(NSURLRequest *)request {
    [ANHTTPNetworkSession startTaskWithHttpRequest:request responseHandler:nil errorHandler:nil];
}


+ (void)startTaskWithHttpRequest:(NSURLRequest *)request
                               responseHandler:(void (^ _Nullable)(NSData * data, NSHTTPURLResponse * response))responseHandler
                                  errorHandler:(void (^ _Nullable)(NSError * error))errorHandler {
    
    
    // Generate a manual start task.
    NSURLSessionTask * task = [ANHTTPNetworkSession taskWithHttpRequest:request responseHandler:^(NSData * _Nonnull data, NSHTTPURLResponse * _Nonnull response) {
        if(responseHandler == nil){
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{

                responseHandler(data,response);

        });
    } errorHandler:^(NSError * _Nonnull error) {
        if(errorHandler == nil){
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            errorHandler(error);
        });
    }];

    // Immediately start the task.
    [task resume];
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    // Allow all responses.
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {

    // Append the new data to the task.
    [self appendData:data toSessionDataForTask:dataTask];
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
    // Retrieve the task data.
    ANHTTPNetworkTaskData * taskData = [self sessionDataForTask:task];
    if (taskData == nil) {
        return;
    }

    // Remove the task data from the currently in flight sessions.
    [self appendSessionData:nil forTask:task];

    // Validate that response is not an error.
    if (error != nil) {
        taskData.errorHandler(error);
        return;
    }

    // Validate response is a HTTP response.
    NSHTTPURLResponse * httpResponse = [task.response isKindOfClass:[NSHTTPURLResponse class]] ? (NSHTTPURLResponse *)task.response : nil;
    if (httpResponse == nil) {
        NSError *responseError = ANError(@"Network response is not of type NSHTTPURLResponse", ANAdResponseNetworkError);
        ANLogError(@"%@", responseError);
        taskData.errorHandler(responseError);
        return;
    }

    // Validate response code is not an error (>= 400)
    if (httpResponse.statusCode >= 400) {
        NSError * responseError = ANError(@"connection_failed", ANAdResponseNetworkError);
        ANLogError(@"%@", responseError);
        taskData.errorHandler(responseError);
        return;
    }

    // Validate that there is data
    if (taskData.responseData == nil) {
        NSError * noDataError = ANError(@"The ad response does not contain data", ANAdResponseNetworkError);
        ANLogError(@"%@", noDataError);
        taskData.errorHandler(noDataError);
        return;
    }

    // By this point all of the fields have been validated.
    taskData.responseHandler(taskData.responseData, httpResponse);
}
@end

