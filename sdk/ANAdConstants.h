/*   Copyright 2014 APPNEXUS INC
 
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

typedef NS_ENUM(NSUInteger, ANCloseDelayType){
    ANCloseDelayTypeAbsolute = 0,
    ANCloseDelayTypeRelative
};

typedef NS_ENUM(NSInteger, ANAdResponseCode) {
    ANDefaultCode = -1,
    ANAdResponseSuccessful = 0,
    ANAdResponseInvalidRequest,
    ANAdResponseUnableToFill,
    ANAdResponseMediatedSDKUnavailable,
    ANAdResponseNetworkError,
    ANAdResponseInternalError,
    ANAdResponseBadFormat = 100,
    ANAdResponseBadURL,
    ANAdResponseBadURLConnection,
    ANAdResponseNonViewResponse
};

typedef NS_ENUM(NSUInteger, ANGender) {
    ANGenderUnknown,
    ANGenderMale,
    ANGenderFemale
};

typedef NS_ENUM(NSUInteger, ANNativeAdRegisterErrorCode) {
    ANNativeAdRegisterErrorCodeInvalidView = 200,
    ANNativeAdRegisterErrorCodeInvalidRootViewController,
    ANNativeAdRegisterErrorCodeExpiredResponse,
    ANNativeAdRegisterErrorCodeBadAdapter,
    ANNativeAdRegisterErrorCodeInternalError
};

typedef NS_ENUM(NSUInteger, ANNativeAdNetworkCode) {
    ANNativeAdNetworkCodeAppNexus = 0,
    ANNativeAdNetworkCodeMoPub,
    ANNativeAdNetworkCodeFacebook,
    ANNativeAdNetworkCodeInMobi,
    ANNativeAdNetworkCodeAdColony,
    ANNativeAdNetworkCodeYahoo,
    ANNativeAdNetworkCodeCustom,
};

typedef NS_ENUM(NSUInteger, ANVideoEvent){
    ANVideoEventUnknown = 0,
    ANVideoEventStart,
    ANVideoEventQuartileFirst,
    ANVideoEventQuartileMidPoint,
    ANVideoEventQuartileThird,
    ANVideoEventQuartileComplete,
    ANVideoEventZoomRestore,
    ANVideoEventZoomFullScreen,
    ANVideoEventPlay,
    ANVideoEventPause,
    ANVideoEventResume,
    ANVideoEventRewind,
    ANVideoEventMute,
    ANVideoEventUnMute,
    ANVideoEventStop,
    ANVideoEventCloseLinear,
    ANVideoEventSkip,
    ANVideoEventCreativeView
};
