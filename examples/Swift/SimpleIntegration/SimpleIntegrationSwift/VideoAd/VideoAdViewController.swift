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

import UIKit
import AppNexusSDK

class VideoAdViewController: UIViewController , ANInstreamVideoAdLoadDelegate, ANInstreamVideoAdPlayDelegate {
    
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var logTextView: UITextView!
    /// Frame for video view in portrait mode.
    var portraitVideoViewFrame = CGRect.zero
    /// Frame for video player in fullscreen mode.
    var fullscreenVideoFrame = CGRect.zero
    var videoAd: ANInstreamVideoAd?
    var videoContentPlayer: AVPlayer?
    @IBOutlet weak var playButton: UIButton!
    var isvideoAdAvailable = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Video Ad"
        
        
        
        if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
            viewDidEnterLandscape()
        }
        
        setupContentPlayer()
        videoAd = ANInstreamVideoAd(placementId: "1281482")
        videoAd?.load(with: self)
        videoAd?.clickThroughAction = ANClickThroughAction.openSDKBrowser
        
        
        playButton.layer.zPosition = CGFloat(MAXFLOAT)
        isvideoAdAvailable = false
        // Fix iPhone issue of log text starting in the middle of the UITextView
        automaticallyAdjustsScrollViewInsets = false
        portraitVideoViewFrame = videoView.frame
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func playButton_Touch(_ sender: Any) {
        playButton.isHidden = true
        if isvideoAdAvailable == false {
            videoContentPlayer!.play()
        } else {
            videoContentPlayer!.pause()
            videoAd?.play(withContainer: videoView, with: self)
            isvideoAdAvailable = false
        }
    }
    override func didRotate(from interfaceOrientation: UIInterfaceOrientation) {
        switch interfaceOrientation {
        case .landscapeLeft, .landscapeRight:
            viewDidEnterPortrait()
        case .portrait, .portraitUpsideDown:
            viewDidEnterLandscape()
        case .unknown:
            break
        @unknown default:
            break
        }
    }
    
    func setupContentPlayer() {
        let contentURL = URL(string: "https://acdn.adnxs.com/mobile/video_test/content/Scenario.mp4")
        if let contentURL = contentURL {
            videoContentPlayer = AVPlayer(url: contentURL)
        }
        if let contentURL = contentURL {
            videoContentPlayer = AVPlayer(url: contentURL)
        }
        let playerLayer = AVPlayerLayer(player: videoContentPlayer)
        playerLayer.frame = videoView.bounds
        videoView.layer.addSublayer(playerLayer)
        videoView.setNeedsLayout()
        videoView.translatesAutoresizingMaskIntoConstraints = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.itemDidFinishPlaying(_:)), name: .AVPlayerItemDidPlayToEndTime, object: videoContentPlayer?.currentItem)
    }
    
    func viewDidEnterLandscape() {
        let screenRect: CGRect = UIScreen.main.bounds
        fullscreenVideoFrame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)
        videoView.frame = fullscreenVideoFrame
    }
    
    func viewDidEnterPortrait() {
        videoView.frame = portraitVideoViewFrame
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        videoContentPlayer!.pause()
        videoAd!.remove()
        videoAd = nil
        super.viewWillDisappear(animated)
        
    }
    @objc func itemDidFinishPlaying(_ notification: Notification?) {
        print("finished playing content")
        //cleanup the player & start again
        videoContentPlayer = nil
        setupContentPlayer()
        playButton.isHidden = false
        isvideoAdAvailable = false
    }
    
    func getAdPlayElapsedTime() {
        // To get AdPlayElapsedTime
        let getAdPlayElapsedTime = videoAd!.getPlayElapsedTime()
        logMessage("getAdPlayElapsedTime \(getAdPlayElapsedTime)")
        
    }
    
    // MARK: - ANInstreamVideoAdDelegate.
    func adDidReceiveAd(_ ad: Any) {
        // To get AdDuration
        let getAdDuration = videoAd!.getDuration()
        logMessage("getAdDuration \(getAdDuration)")
        
        // To get CreativeURL
        let getCreativeURL = videoAd!.getCreativeURL()
        logMessage("getCreativeURL \(String(describing: getCreativeURL))")
        
        // To get VastURL
        let getVastURL = videoAd!.getVastURL()
        logMessage("getVastURL \(String(describing: getVastURL))")
        
        // To get VastXML
        let getVastXML = videoAd!.getVastXML()
        logMessage("getVastXML \(String(describing: getVastXML))")
        
        // To get AdPlayElapsedTime
        getAdPlayElapsedTime()
        isvideoAdAvailable = true
        
        logMessage("adDidReceiveAd")
        
    }
    
    func ad(_ ad: ANAdProtocol?) throws {
        isvideoAdAvailable = false
    }
    
    //----------------------------- -o-
    func adCompletedFirstQuartile(_ ad: ANAdProtocol) {
        getAdPlayElapsedTime()
    }
    
    func adCompletedMidQuartile(_ ad: ANAdProtocol) {
        getAdPlayElapsedTime()
        
    }
    //----------------------------- -o-
    func adPlayStarted(_ ad: ANAdProtocol) {
        getAdPlayElapsedTime()
        
    }
    
    func adCompletedThirdQuartile(_ ad: ANAdProtocol) {
        getAdPlayElapsedTime()
    }
    
    
    func adWasClicked(_ ad: ANAdProtocol) {
        
    }
    
    func adMute(_ ad: ANAdProtocol, withStatus muteStatus: Bool) {
        if muteStatus == true {
            logMessage("adMuteOn")
        } else {
            logMessage("adMuteOff")
        }
    }
    
    func adDidComplete(_ ad: ANAdProtocol, with state: ANInstreamVideoPlaybackStateType) {
        if state == ANInstreamVideoPlaybackStateType.skipped {
            logMessage("adWasSkipped")
        } else if state == ANInstreamVideoPlaybackStateType.error {
            logMessage("adplaybackFailedWithError")
        } else if state == ANInstreamVideoPlaybackStateType.completed {
            logMessage("adPlayCompleted")
            getAdPlayElapsedTime()
        }
        isvideoAdAvailable = false
        videoContentPlayer!.play()
        
    }
    
    
    func logMessage(_ log: String?) {
        let logString = "\(log ?? "")\n"
        logTextView.text = logTextView.text + (logString)
        if logTextView.text.count > 0 {
            let bottom = NSRange(location: logTextView.text.count - 1, length: 1)
            logTextView.scrollRangeToVisible(bottom)
        }
    }
    
}

