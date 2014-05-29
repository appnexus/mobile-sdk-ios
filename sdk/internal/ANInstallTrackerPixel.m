/*   Copyright 2013 APPNEXUS INC
 
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

#import "ANInstallTrackerPixel.h"

#import "ANLogging.h"
#import "NSString+ANCategory.h"

#define AN_INSTALL_TRACKER_PIXEL_MAX_ATTEMPTS 5
#define AN_INSTALL_TRACKER_PIXEL_ATTEMPT_DURATION 30.0

@interface ANInstallTrackerPixel ()
{
	NSUInteger __attempt;
	NSTimeInterval __lastAttemptInterval;
}

@property (nonatomic, readwrite, strong) NSMutableURLRequest *request;
@property (nonatomic, readwrite, strong) NSURLConnection *connection;
@property (nonatomic, readwrite, strong) NSMutableData *data;
@property (nonatomic, readwrite, strong) NSString *trackingID;
@property (nonatomic, readwrite, strong) NSString *ANHostnameInstallURL;
@property (nonatomic, readwrite, assign, getter = isLoading) BOOL loading;
@end

@implementation ANInstallTrackerPixel
@synthesize request = __request;
@synthesize connection = __connection;
@synthesize data = __data;
@synthesize trackingID = __trackingID;
@synthesize loading = __loading;

- (id)initWithTrackingID:(NSString *)trackingID
{
	self = [super init];
	
	if (self != nil)
	{
		self.trackingID = trackingID;
		self.data = [NSMutableData data];
        self.ANHostnameInstallURL = AN_MOBILE_HOSTNAME_INSTALL;
		__lastAttemptInterval = 0;
		
        self.request = [[NSMutableURLRequest alloc] initWithURL:nil
                                                     cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                 timeoutInterval:kAppNexusRequestTimeoutInterval];
        [self.request setValue:ANUserAgent() forHTTPHeaderField:@"User-Agent"];
	}
	
	return self;
}

- (void)setEndpoint:(ANMobileEndpoint)endpoint {
    _endpoint = endpoint;
    switch (endpoint) {
        case ANMobileEndpointClientTesting:
            self.ANHostnameInstallURL = AN_MOBILE_HOSTNAME_INSTALL_CTEST;
            break;
        case ANMobileEndpointSandbox:
            self.ANHostnameInstallURL = AN_MOBILE_HOSTNAME_INSTALL_SAND;
            break;
        default:
            self.ANHostnameInstallURL = AN_MOBILE_HOSTNAME_INSTALL;
            break;
    }
}

- (NSString *)trackingIDParameter
{
	NSString *trackingID = self.trackingID ? self.trackingID : @"";
	NSString *trackingIDParameter = [NSString stringWithFormat:@"&id=%@", trackingID];
	
	return trackingIDParameter;
}

- (NSString *)dontTrackEnabledParameter
{
    NSString *donttrackEnabled = @"";
    
    if (!ANAdvertisingTrackingEnabled()) {
        donttrackEnabled = @"&dnt=1";
    }
    
    return donttrackEnabled;
}

- (NSString *)applicationIdParameter
{
    NSString *appId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    return [NSString stringWithFormat:@"&appid=%@", appId];
}

- (NSURL *)pixelURL
{
	NSString *urlString = [NSString stringWithFormat:@"http://%@?", AN_MOBILE_HOSTNAME_INSTALL];

	urlString = [urlString stringByAppendingString:[self trackingIDParameter]];
	urlString = [urlString stringByAppendingString:[self dontTrackEnabledParameter]];
	urlString = [urlString stringByAppendingString:[self applicationIdParameter]];
	urlString = [urlString stringByAppendingUrlParameter:@"idfa" value:ANUDID()];
	
	return [NSURL URLWithString:urlString];
}

- (void)fireInstallTrackerPixel
{
	if (!self.isLoading)
	{		
		NSURL *url = [self pixelURL];
		self.request.URL = url;
		self.connection = [NSURLConnection connectionWithRequest:self.request delegate:self];
	}
	else
	{
		ANLogWarn(@"Already fired install tracker pixel. Please wait for this call to finish before firing another.");
	}
}

#pragma mark NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	if ([response isKindOfClass:[NSHTTPURLResponse class]])
	{
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
		NSInteger status = [httpResponse statusCode];
        
		if (status >= 400)
		{
			[connection cancel];
			NSDictionary *errorInfo = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:
																		  NSLocalizedString(@"Request failed with status code %d", @"Error Description: server request came back with error code."),
																		  status]
																  forKey:NSLocalizedDescriptionKey];
			NSError *statusError = [NSError errorWithDomain:AN_ERROR_DOMAIN
													   code:status
												   userInfo:errorInfo];
			[self connection:connection didFailWithError:statusError];
			return;
		}
	}
	
	self.data = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	ANLogWarn(@"Install tracker pixel connection %@ failed with error %@", connection, error);
	
	self.loading = NO;
	
	// If we failed, check to see if we're still within our max number of attempts
	if (__attempt <= AN_INSTALL_TRACKER_PIXEL_MAX_ATTEMPTS)
	{
		ANLogDebug(@"Attempt number %d to fire install tracker pixel again. Firing after %f seconds.", __attempt, AN_INSTALL_TRACKER_PIXEL_ATTEMPT_DURATION);
		// If we are, then fire it again after our old time + x * 30 seconds, where x is the attempt number. This will result in us trying after 0, 30, 90, 210, and 360 seconds.
		__lastAttemptInterval = __lastAttemptInterval + AN_INSTALL_TRACKER_PIXEL_ATTEMPT_DURATION * __attempt;
		[self performSelector:@selector(fireInstallTrackerPixel) withObject:nil afterDelay:__lastAttemptInterval];
		__attempt++;
	}
	else
	{
		ANLogWarn(@"Install tracker pixel failed to convert after %d tries. Stopping attempts.", AN_INSTALL_TRACKER_PIXEL_MAX_ATTEMPTS);
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)d
{
	[self.data appendData:d];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	self.loading = NO;
    
    NSString *response = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
    ANLogDebug(@"Install tracker pixel %@ received response: %@", self, response);
}

@end
