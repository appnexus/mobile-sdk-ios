/*   Copyright 2020 APPNEXUS INC

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



#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


// Network
#define  PERFORMANCESTATSRTB_NETWORK_FIRST_LOAD  1500
#define  PERFORMANCESTATSRTB_NETWORK_SECOND_LOAD  500


//Banner
#define  PERFORMANCESTATSRTBBANNERAD_FIRST_LOAD  8000
#define  PERFORMANCESTATSRTBBANNERAD_SECOND_LOAD  3000

//BannerWebview
#define  PERFORMANCESTATSRTBBANNERAD_WEBVIEW_FIRST_LOAD  6000
#define  PERFORMANCESTATSRTBBANNERAD_WEBVIEW_SECOND_LOAD  2000

#define  PERFORMANCESTATSRTBBANNERAD_WEBVIEW  2500

//Native Renderer
#define  PERFORMANCESTATSRTBBANNERNATIVERENDERERAD_FIRST_LOAD  5000
#define  PERFORMANCESTATSRTBBANNERNATIVERENDERERAD_SECOND_LOAD  2000

//NativeWebview
#define  PERFORMANCESTATSRTBBANNERNATIVERENDERERADAD_WEBVIEW_FIRST_LOAD  4500
#define  PERFORMANCESTATSRTBBANNERNATIVERENDERERADAD_WEBVIEW_SECOND_LOAD  1000


////Native
//#define  PERFORMANCESTATSRTBBANNERNATIVEAD_FIRST_LOAD  500
//#define  PERFORMANCESTATSRTBBANNERNATIVEAD_SECOND_LOAD  400

//BannerVideo
//#define  PERFORMANCESTATSRTBBANNERVIDEOAD_FIRST_LOAD  6000
//#define  PERFORMANCESTATSRTBBANNERVIDEOAD_SECOND_LOAD  3500


//BannerVideoWebview
#define  PERFORMANCESTATSRTBBANNERVIDEOAD_WEBVIEW_FIRST_LOAD  5000
#define  PERFORMANCESTATSRTBBANNERVIDEOAD_WEBVIEW_SECOND_LOAD  1200

//Interstitial
#define  PERFORMANCESTATSRTBINTERSTITIALAD_FIRST_LOAD  8000
#define  PERFORMANCESTATSRTBINTERSTITIALAD_SECOND_LOAD  3000


//InterstitialWebview
#define  PERFORMANCESTATSRTBINTERSTITIALAD_WEBVIEW_FIRST_LOAD  6000
#define  PERFORMANCESTATSRTBINTERSTITIALAD_WEBVIEW_SECOND_LOAD  2000

//MAR
#define  PERFORMANCESTATSRTBMARAD_FIRST_LOAD  2000
#define  PERFORMANCESTATSRTBMARAD_SECOND_LOAD  500

//Native
#define  PERFORMANCESTATSRTBNATIVEAD_FIRST_LOAD  2000
#define  PERFORMANCESTATSRTBNATIVEAD_SECOND_LOAD  500

//Video
#define  PERFORMANCESTATSRTBVIDEOAD_FIRST_LOAD  7500
#define  PERFORMANCESTATSRTBVIDEOAD_SECOND_LOAD  6000


//VideoWebview
#define  PERFORMANCESTATSRTBVIDEOAD_WEBVIEW_FIRST_LOAD  400
#define  PERFORMANCESTATSRTBVIDEOAD_WEBVIEW_SECOND_LOAD  400



#define  PERFORMANCESTATSRTBAD_FIRST_REQUEST  @"FirstRequest"
#define  PERFORMANCESTATSRTBAD_SECOND_REQUEST  @"SecondRequest"



#define  PERFORMANCESTATSRTBAD_FIRST_REQUEST_NATIVE_SDK  @"FirstRequestNativeSDK"
#define  PERFORMANCESTATSRTBAD_SECOND_REQUEST_NATIVE_SDK  @"SecondRequestNativeSDK"

#define  NATIVE_SDK  @"nativeSDK"
#define  MAR_NATIVE_SDK  @"marNativeSDK"



#define  BANNER  @"banner"
#define  BANNERNATIVERENDERER  @"bannernativerenderer"
#define  BANNERNATIVE  @"bannernative"
#define  BANNERVIDEO  @"bannervideo"
#define  MAR  @"mar"
#define  VIDEO  @"video"
#define  NATIVE  @"native"
#define  INTERSTITIAL  @"interstitial"


#define  BANNER_PLACEMENT  @"15215010"
#define  BANNERNATIVERENDERER_PLACEMENT  @"19197535"
#define  BANNERNATIVE_PLACEMENT  @"19197535"
#define  BANNERVIDEO_PLACEMENT  @"19197534"
#define  MAR_PLACEMENT  @"19212468"
#define  VIDEO_PLACEMENT  @"19197534"
#define  NATIVE_PLACEMENT  @"19197535"
#define  INTERSTITIAL_PLACEMENT  @"15215010"



@interface ANTimeTracker : NSObject

+ (instancetype)sharedInstance;

- (void) getDiffereanceAt:(NSString *_Nonnull)timeAt;
- (void) setTimeAt:(NSString *)atValue;
@property (nonatomic, readonly) float timeTaken;

+(void)saveSet:(NSString*)testCaseName date:(NSDate *)date loadTime:(int)value;
+(NSArray *)getData:(NSString*)testCaseName;

@property (nonatomic, readwrite, nullable) NSDate *webViewInitLoadingAt;
@property (nonatomic, readwrite,nullable) NSDate *webViewFinishLoadingAt;

-(float) getTimeTakenByWebview;


@property (nonatomic, readwrite, nullable) NSDate *networkAdRequestInit;
@property (nonatomic, readwrite,nullable) NSDate *networkAdRequestComplete;

-(float) getTimeTakenByNetworkCall;

@end

NS_ASSUME_NONNULL_END
