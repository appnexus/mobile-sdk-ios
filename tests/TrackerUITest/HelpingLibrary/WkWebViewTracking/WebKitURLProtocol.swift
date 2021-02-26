

import Foundation
import WebKit

extension Notification.Name {
    static let didReceiveURLResponse = Notification.Name("didReceiveURLResponse")
}

@objc class WebKitURLProtocol: URLProtocol {
    
    static let internalKey = "com.toshiki.URLProtocolInternal"
    
    private lazy var session: URLSession = { [unowned self] in
        return URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }()
    
    private var response: URLResponse?
    private var responseData: NSMutableData?
    
    open override class func canInit(with request: URLRequest) -> Bool {
        return canServeRequest(request)
    }
    
    override open class func canInit(with task: URLSessionTask) -> Bool
    {
        guard let request = task.currentRequest else { return false }
        return canServeRequest(request)
    }
    
    private class func canServeRequest(_ request: URLRequest) -> Bool
    {
        guard
            URLProtocol.property(forKey: WebKitURLProtocol.internalKey, in: request) == nil,
            let url = request.url,
            (url.absoluteString.hasPrefix("http") || url.absoluteString.hasPrefix("https"))
        else {
            return false
        }
        return true
    }
    
    override func startLoading() {
        let mutableRequest = (request as NSURLRequest).mutableCopy() as! NSMutableURLRequest
        URLProtocol.setProperty(true, forKey: WebKitURLProtocol.internalKey, in: mutableRequest)
        session.dataTask(with: mutableRequest as URLRequest).resume()

    }
    
    override func stopLoading() {
        session.getTasksWithCompletionHandler { dataTasks, _, _ in
            dataTasks.forEach { $0.cancel() }
        }
    }
    
    open override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
}

extension WebKitURLProtocol: URLSessionDataDelegate {
    @objc public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        responseData?.append(data)
        
        client?.urlProtocol(self, didLoad: data)
    }
    
    @objc public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        self.response = response
        self.responseData = NSMutableData()
        
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: URLCache.StoragePolicy.notAllowed)
        completionHandler(.allow)
    }
    
    @objc public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        defer {
            if let error = error {
                client?.urlProtocol(self, didFailWithError: error)
            } else {
                client?.urlProtocolDidFinishLoading(self)
            }
        }
        
        guard task.originalRequest != nil else {
            return
        }
        
        if let response = response {
//            if let mime = response.mimeType, mime.contains("mpegurl") {
//                let data = (responseData ?? NSMutableData()) as Data
//                print(response.url!)
//                print(data.count)
//            }
            NotificationCenter.default.post(name: .didReceiveURLResponse, object: nil, userInfo: ["response": response])
        }
        
    }
    
    @objc public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        
        let updatedRequest: URLRequest
        if URLProtocol.property(forKey: WebKitURLProtocol.internalKey, in: request) != nil {
            let mutableRequest = (request as NSURLRequest).mutableCopy() as! NSMutableURLRequest
            URLProtocol.removeProperty(forKey: WebKitURLProtocol.internalKey, in: mutableRequest)
            
            updatedRequest = mutableRequest as URLRequest
        } else {
            updatedRequest = request
        }
        
        client?.urlProtocol(self, wasRedirectedTo: updatedRequest, redirectResponse: response)
        completionHandler(updatedRequest)
    }
    
    @objc public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let wrappedChallenge = URLAuthenticationChallenge(authenticationChallenge: challenge, sender: AuthenticationChallengeSender(handler: completionHandler))
        client?.urlProtocol(self, didReceive: wrappedChallenge)
    }
    
    @objc public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        client?.urlProtocolDidFinishLoading(self)
    }
}
