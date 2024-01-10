/*   Copyright 2022 Xandr INC
 
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


import Cocoa
import AppNexusNativeMacOSSDK

class ViewController: NSViewController, ANNativeAdRequestDelegate , ANNativeAdDelegate {
    
    // App is responsible for holding(strong reference) on to the Request & Response ojects.
    var nativeAdRequest: ANNativeAdRequest?
    var nativeAdResponse: ANNativeAdResponse?
    
    var clickableViews = [XandrNativeAdView]()

    
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    
    var quotesList = Array<Any>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Enable logs for Debugging purpose
        ANLogManager.setANLogLevel(.all)
        XandrAd.sharedInstance().initWithMemberID(10094, preCacheRequestObjects: true ,completionHandler: { (status) in
            print("Done🔨 \(status)")
        })
        
        
        statusLabel.stringValue = "Requesting Ad"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.target = self
        
        // Load the Native ad
        loadNativeAd()
        
        
        if let path = Bundle.main.path(forResource: "quotes", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let quotes = jsonResult["quotes"] as? [Any] {
                    quotesList = quotes
                    self.tableView.reloadData()
                }
            } catch {
                // handle error
                quotesList = []
            }
        }
    }
    
    
    func loadNativeAd(){
        nativeAdRequest = ANNativeAdRequest()
        nativeAdRequest!.placementId = "17058950"
        nativeAdRequest!.shouldLoadIconImage = true // Optional - This instructs SDK to autodownload the Icon image. Default is false and nativeAdResponse?.iconImage will return nil
        nativeAdRequest!.shouldLoadMainImage = true // Optional - This instructs SDK to autodownload the Main image. Default is false and nativeAdResponse?.mainImage will return nil
        nativeAdRequest!.delegate = self
        nativeAdRequest!.rendererId = 100
        
        nativeAdRequest!.loadAd()
    }
    
    // MARK: - ANNativeAdRequestDelegate
    func adRequest(_ request: ANNativeAdRequest, didReceive response: ANNativeAdResponse) {
        self.nativeAdResponse = response
        self.tableView.reloadData()
        statusLabel.stringValue = "Ad Loaded successfully"
    }
    
    func adRequest(_ request: ANNativeAdRequest, didFailToLoadWithError error: Error, with adResponseInfo: ANAdResponseInfo?) {
        print("Ad request Failed With Error")
        statusLabel.stringValue = "Failed to Load Ad"
        
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        if(row == 100){
            return false
            
        }
        return true
    }
    
    // MARK: - ANNativeAdDelegate
    func adDidLogImpression(_ response: Any) {
        print("adDidLogImpression=====> Abhishek");
    }
    
    func adWillExpire(_ response: Any) {
        print("adWillExpire")
    }
    
    func adDidExpire(_ response: Any) {
        print("adDidExpire")
    }
    
    func adWasClicked(_ response: Any, withURL clickURLString: String, fallbackURL clickFallbackURLString: String) {
        print("adWasClicked=====> Abhishek \(clickURLString)");
        // Application is responsible for opening the click url returned here in the browser
    }
    
}


extension ViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return quotesList.count
    }
    
    
}

extension ViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if(row == 100){
            return 50 // To accomodate all the Native assets the height of row 100 is increased.
        }
        return 25
    }
    
    func tableView(_ tableView: NSTableView, didAdd rowView: NSTableRowView, forRow row: Int) {
        
        if(row == 100 && self.nativeAdResponse != nil){
            do{
                let rowView : NSTableRowView = tableView.rowView(atRow: row, makeIfNecessary: true)!
                
                try self.nativeAdResponse?.registerViewTracking(rowView, withRootViewController: self, clickableXandrNativeAdView: clickableViews)

            } catch {
                print("Failed to registerView for Tracking")
            }
            
        }
        
    }
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        // This is just for example. At row 100 a Native Ad will be displayed.
        if(row == 100 && self.nativeAdResponse != nil){
            if tableColumn == tableView.tableColumns[0] {
                let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init(rawValue: "AdCellID1"), owner: nil) as? NativeAdViewFirst
                
                self.nativeAdResponse?.delegate = self
                cell!.titleLabel.stringValue = "Ad:  \(self.nativeAdResponse?.title ?? "Unable to load Ad")"
                cell!.iconImageView.image = self.nativeAdResponse?.mainImage
                let clickableItem : XandrNativeAdView = cell! as XandrNativeAdView
                clickableViews.append(clickableItem)
                return cell
                
            }else{
                
                let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init(rawValue: "AdCellID2"), owner: nil) as? NativeAdViewSecond
              
                cell!.bodyLabel?.stringValue = self.nativeAdResponse?.body ?? ""
                cell!.sponsoredLabel.stringValue = "Sponsored by: \(self.nativeAdResponse?.sponsoredBy ?? "")"
                let clickableItem : XandrNativeAdView = cell! as XandrNativeAdView
                clickableViews.append(clickableItem)

                return cell
            }
            
        }else{
            if tableColumn == tableView.tableColumns[0] {
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init(rawValue: "NameCellID1"), owner: nil) as? NSTableCellView {
                    let quoteData : Dictionary<NSString,NSString> = quotesList[row] as! Dictionary<NSString,NSString>
                    
                    cell.textField?.stringValue = "\(row + 1)   \(quoteData["text"] ?? "")"
                    
                    return cell
                }
            }else{
                
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init(rawValue: "NameCellID2"), owner: nil) as? NSTableCellView {
                    let quoteData : Dictionary<NSString,NSString> = quotesList[row] as! Dictionary<NSString,NSString>
                    
                    cell.textField?.stringValue = "--\(quoteData["author"] ?? "No author")"
                    
                    return cell
                }
                
                
            }
        }
        return nil
    }
}
