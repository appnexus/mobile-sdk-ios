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


import UIKit

class VideoAdViewController: UIViewController , ANInstreamVideoAdLoadDelegate , ANInstreamVideoAdPlayDelegate {
    
    let videoContent = "https://acdn.adnxs.com/mobile/video_test/content/Scenario.mp4"
    
    var videoContentPlayer = AVPlayer()
    var videoAd = ANInstreamVideoAd()
    var adKey  : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Video Ad"
        if ProcessInfo.processInfo.arguments.contains("testRTBVideo") {
            adKey = "testRTBVideo"
            initialiseVideoAd()
           }
        if ProcessInfo.processInfo.arguments.contains("testVPAIDVideoAd") {
            adKey = "testVPAIDVideoAd"
            initialiseVideoAd()
        }
        // Do any additional setup after loading the view.
    }
    
    
    func initialiseVideoAd()  {
        let videoAdObject : VideoAdObject! = AdObjectModel.decodeVideoObject()
        if videoAdObject != nil {

            self.videoAd = ANInstreamVideoAd(placementId: videoAdObject?.adObject.placement)
            self.videoAd.clickThroughAction = ANClickThroughAction.returnURL
            setupContentPlayer()
            self.videoContentPlayer.pause()
            self.videoAd.load(with: self)
        }
    }
    
    func adDidReceiveAd(_ ad: ANAdProtocol!) {
        videoContentPlayer.pause()
        videoAd.center = self.view.center
        videoAd.play(withContainer: self.view, with: self as? ANInstreamVideoAdPlayDelegate)
    }
    
    func adDidComplete(_ ad: ANAdProtocol!, with state: ANInstreamVideoPlaybackStateType) {
        
    }
    
    func ad(_ ad: ANAdProtocol!, requestFailedWithError error: Error!) {
        
        let alertController = UIAlertController(title: "Alert", message: error.localizedDescription, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .destructive) { (action:UIAlertAction) in
            self.videoContentPlayer.play()
        }
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: Utility Methods
    func setupContentPlayer() {
        let contentURL = URL(string: videoContent)
        if let anURL = contentURL {
            videoContentPlayer = AVPlayer(url: anURL)
        }
        let playerLayer = AVPlayerLayer(player: videoContentPlayer)
        playerLayer.frame = self.view.bounds
        self.view.layer.addSublayer(playerLayer)
        self.view.setNeedsLayout()
        NotificationCenter.default.addObserver(self, selector: #selector(self.itemDidFinishPlaying(_:)), name: .AVPlayerItemDidPlayToEndTime, object: videoContentPlayer.currentItem)
    }
    
    @objc func itemDidFinishPlaying(_ notification: Notification?) {
        print("finished playing content")
        //cleanup the player & start again
        videoContentPlayer.replaceCurrentItem(with: nil)
        setupContentPlayer()
    }
}
