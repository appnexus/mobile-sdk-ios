
import Foundation
import WebKit

@objc class AuthenticationChallengeSender : NSObject, URLAuthenticationChallengeSender {
    
    typealias AuthenticationChallengeHandler = (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    
    let handler: AuthenticationChallengeHandler
    
    init(handler: @escaping AuthenticationChallengeHandler) {
        self.handler = handler
        super.init()
    }
    
    @objc func use(_ credential: URLCredential, for challenge: URLAuthenticationChallenge) {
        handler(.useCredential, credential)
    }
    
    @objc func continueWithoutCredential(for challenge: URLAuthenticationChallenge) {
        handler(.useCredential, nil)
    }

    @objc func cancel(_ challenge: URLAuthenticationChallenge) {
        handler(.cancelAuthenticationChallenge, nil)
    }

    @objc func performDefaultHandling(for challenge: URLAuthenticationChallenge) {
        handler(.performDefaultHandling, nil)
    }

    @objc func rejectProtectionSpaceAndContinue(with challenge: URLAuthenticationChallenge) {
        handler(.rejectProtectionSpace, nil)
    }
}
