/*   Copyright 2016 APPNEXUS INC
 
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

#import "ANSDKSettings.h"
#import "ANGlobal.h"
#import "ANLogManager.h"
#import "ANCarrierObserver.h"
#import "ANReachability.h"
#import "ANBaseUrlConfig.h"
#import "ANWebView.h"


@interface ANBaseUrlConfig : NSObject
    //EMPTY
@end


@implementation ANBaseUrlConfig

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static ANBaseUrlConfig *config;
    dispatch_once(&onceToken, ^{
        config = [[ANBaseUrlConfig alloc] init];
    });
    return config;
}

- (NSString *)webViewBaseUrl {
    return @"https://mediation.adnxs.com/";
}

-(NSString *) utAdRequestBaseUrl {
    return @"https://mediation.adnxs.com/ut/v3";
}

- (NSURL *) videoWebViewUrl
{
    return  [self urlForResourceWithBasename:@"vastVideo" andExtension:@"html"];
}

- (NSURL *) nativeRenderingUrl
{
    return  [self urlForResourceWithBasename:@"nativeRenderer" andExtension:@"html"];
}


#pragma mark - Helper methods.

- (NSURL *) urlForResourceWithBasename:(NSString *)basename andExtension:(NSString *)extension
{
    if (ANLogManager.getANLogLevel > ANLogLevelDebug)
    {
        return [ANResourcesBundle() URLForResource:basename withExtension:extension];
        
    } else {
        NSURL       *url                        = [ANResourcesBundle() URLForResource:basename withExtension:extension];
        NSString    *URLString                  = [url absoluteString];
        NSString    *debugQueryString           = @"?ast_debug=true";
        NSString    *URLwithDebugQueryString    = [URLString stringByAppendingString: debugQueryString];
        NSURL       *debugURL                   = [NSURL URLWithString:URLwithDebugQueryString];
        
        return debugURL;
    }
}
@end




@interface ANSDKSettings()

@property (nonatomic) ANBaseUrlConfig *baseUrlConfig;
@property (nonatomic, readwrite, strong, nonnull) NSString *sdkVersion;
@end


@implementation ANSDKSettings

+ (id)sharedInstance {
    static dispatch_once_t sdkSettingsToken;
    static ANSDKSettings *sdkSettings;
    dispatch_once(&sdkSettingsToken, ^{
        sdkSettings = [[ANSDKSettings alloc] init];
        sdkSettings.locationEnabledForCreative =  YES;
        sdkSettings.enableOpenMeasurement = YES;
        sdkSettings.auctionTimeout = 0;

    });
    return sdkSettings;
}

- (NSString *)sdkVersion{
    return AN_SDK_VERSION;
}

- (ANBaseUrlConfig *)baseUrlConfig {
    if (!_baseUrlConfig) {
        return [ANBaseUrlConfig sharedInstance];
        
    } else {
        return _baseUrlConfig;
    }
}

// In general, MobileSDK does not require initialization.
// However, MobileSDK does maintain state, some of which can be initialized early in the app lifecycle in order to save cycles later.
//
// Optionally call this method early in the app lifecycle.  For example in [AppDelegate application:didFinishLaunchingWithOptions:].
//
- (void) optionalSDKInitialization
{
    [[ANReachability sharedReachabilityForInternetConnection] start];
    [ANCarrierObserver shared];
    [ANWebView fetchWebView];
}

@end
