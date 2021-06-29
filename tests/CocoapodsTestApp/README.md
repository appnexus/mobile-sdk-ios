CocoapodsTestApp SDK
=====================

## What is  CocoapodsTestApp?
CocoapodsTestApp is used to test that SDK is working fine when installed using Cocoapods.

In CocoapodsTestApp, we have test name `testRTBBannerAd()` which confirms that banner ad is loaded or not.

`testRTBBannerAd()`: Test verify that banner ad loaded or not by confirming the size of Ad.

## How to test CocoapodsTestApp?

### Manual 
* Goto tests/CocoapodsTestApp/
* Install pod via 
    ```
    pod install
  ``
* Open `CocoapodsTestApp.xcworkspace` 
* Goto test section & open `testRTBBannerAd` 
* Run the test & verify the test result is pass or fail



### Via Script 
* Goto tests/CocoapodsTestApp/
* Install pod via 
    ``` 
    pod install
  ```  
* Run test script
    ```
    sh runCocoapodsTestApp.sh
    ```
Wait for test result & verify the test result is pass or fail via report

