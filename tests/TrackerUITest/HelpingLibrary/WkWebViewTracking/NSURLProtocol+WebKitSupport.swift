

import Foundation
import WebKit

extension URLProtocol {
    
    @objc class func contextControllerClass()->AnyClass {
        return NSClassFromString("WKBrowsingContextController")!
    }
    
    @objc class func registerSchemeSelector()->Selector {
        return NSSelectorFromString("registerSchemeForCustomProtocol:")
    }
    
    @objc class func unregisterSchemeSelector()->Selector {
        return NSSelectorFromString("unregisterSchemeForCustomProtocol:")
    }
    
    @objc class func wk_register(scheme:String){
        let cls:AnyClass = contextControllerClass()
        let sel = registerSchemeSelector()
        if cls.responds(to: sel) {
            _ = (cls as AnyObject).perform(sel, with: scheme)
        }
    }
    
    @objc class func wk_unregister(scheme:String){
        let cls:AnyClass = contextControllerClass()
        let sel = unregisterSchemeSelector()
        if cls.responds(to: sel) {
            _ = (cls as AnyObject).perform(sel, with: scheme)
        }
    }
}
