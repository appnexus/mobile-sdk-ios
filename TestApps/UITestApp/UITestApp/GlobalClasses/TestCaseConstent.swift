/*   Copyright 2019 APPNEXUS INC
 
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


import Foundation

struct PlacementTestConstants {
    static let PlacementTest : String = "PlacementTest"

    struct BannerAd {
        static let testRTBBanner320x50 : String = "testRTBBanner320x50"
        static let testRTBBanner300x250: String = "testRTBBanner300x250"
    }
    struct BannerNativeAd {
        static let testRTBBannerNative : String = "testRTBBannerNative"
        static let testRTBBannerNativeRendering: String = "testRTBBannerNativeRendering"
    }
    struct BannerVideoAd {
        static let testVPAIDBannerVideo : String = "testVPAIDBannerVideo"
        static let testBannerVideo: String = "testBannerVideo"
    }
    struct NativeAd {
        static let testRTBNative : String = "testRTBNative"
    }
    struct VideoAd {
        static let testVPAIDVideoAd : String = "testVPAIDVideoAd"
        static let testRTBVideo: String = "testRTBVideo"
    }
    
    struct InterstitialAd {
        static let testRTBInterstitial : String = "testRTBInterstitial"
    }
}
