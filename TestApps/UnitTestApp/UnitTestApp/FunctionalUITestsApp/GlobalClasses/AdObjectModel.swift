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
import UIKit

struct AdObject: Codable
{
    var adType :  String
    var accessibilityIdentifier :  String
    var placement :  String
}

struct BannerAdObject: Codable
{
    var isVideo: Bool
    var isNative: Bool
    var enableNativeRendering: Bool!
    var height: String
    var width: String
    var autoRefreshInterval : Int
    var adObject: AdObject
}


struct InterstitialAdObject : Codable{
    var closeDelay : Int
    var adObject: AdObject
}


struct NativeAdObject : Codable{
    var shouldLoadIconImage : Bool
    var shouldLoadMainImage :  Bool
    var adObject: AdObject
    
}

struct VideoAdObject : Codable{
    var isVideo : Bool
    var adObject: AdObject
    
}

class AdObjectModel : NSObject {
    class func encodeBannerObject(adObject : BannerAdObject ) -> String {
        let encodedData = try? JSONEncoder().encode(adObject)
        return String(data: encodedData!, encoding: .utf8) ?? "{}"
    }
    
    class func encodeInterstitialObject(adObject : InterstitialAdObject ) -> String {
        let encodedData = try? JSONEncoder().encode(adObject)
        return String(data: encodedData!, encoding: .utf8) ?? "{}"
    }
    
    class func encodeNativeObject(adObject : NativeAdObject ) -> String {
        let encodedData = try? JSONEncoder().encode(adObject)
        return String(data: encodedData!, encoding: .utf8) ?? "{}"
    }
    class func encodeVideoObject(adObject : VideoAdObject ) -> String {
        let encodedData = try? JSONEncoder().encode(adObject)
        return String(data: encodedData!, encoding: .utf8) ?? "{}"
    }
    
    class func decodeBannerObject() -> BannerAdObject!{
        let jsonStringArray  = ProcessInfo.processInfo.arguments
        let jsonString : String = jsonStringArray.last!
        if let jsonData = jsonString.data(using: .utf8)
        {
            let bannerAdObject = try? JSONDecoder().decode(BannerAdObject.self, from: jsonData)
            return bannerAdObject
        }
        return nil
    }
    
    
    class func decodeInterstitialObject() -> InterstitialAdObject!{
        let jsonStringArray  = ProcessInfo.processInfo.arguments
        let jsonString : String = jsonStringArray.last!
        if let jsonData = jsonString.data(using: .utf8)
        {
            let interstitialAdObject = try? JSONDecoder().decode(InterstitialAdObject.self, from: jsonData)
            return interstitialAdObject
        }
        return nil
    }
    
    
    class func decodeNativeObject() -> NativeAdObject!{
        let jsonStringArray  = ProcessInfo.processInfo.arguments
        let jsonString : String = jsonStringArray.last!
        if let jsonData = jsonString.data(using: .utf8)
        {
            let nativeAdObject = try? JSONDecoder().decode(NativeAdObject.self, from: jsonData)
            return nativeAdObject
        }
        return nil
    }
    
    
    class func decodeVideoObject() -> VideoAdObject!{
        let jsonStringArray  = ProcessInfo.processInfo.arguments
        let jsonString : String = jsonStringArray.last!
        if let jsonData = jsonString.data(using: .utf8)
        {
            let videoAdObject = try? JSONDecoder().decode(VideoAdObject.self, from: jsonData)
            return videoAdObject
        }
        return nil
    }
}
