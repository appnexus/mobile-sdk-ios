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

import XCTest

class FunctionalUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

}


// Useful methods for waiting
extension XCTestCase {
    func wait(for element: XCUIElement, timeout: TimeInterval) {
        let p = NSPredicate(format: "exists == true") // Checks for exists true
        let e = expectation(for: p, evaluatedWith: element, handler: nil)
        wait(for: [e], timeout: timeout)
    }
    func wait(_ interval: Int) {
        let expectation: XCTestExpectation = self.expectation(description: "wait")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(interval * Int(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
            expectation.fulfill()
        })
        waitForExpectations(timeout: TimeInterval(interval), handler: nil)
    }
}

