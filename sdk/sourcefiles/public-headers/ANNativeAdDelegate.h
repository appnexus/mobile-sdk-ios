/*   Copyright 2014 APPNEXUS INC
 
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

#import <Foundation/Foundation.h>

@class ANNativeAdResponse;

/*!
 * Defines all the callbacks for a native view registered
 * with an ANNativeAdResponse.
 */
@protocol ANNativeAdDelegate <NSObject>  

@optional
/*!
* Sent when the native  ad is about to expire.
*/
- (void)adWillExpire:(nonnull id)response;

/*!
* Sent when the native ad is expired.
*/
- (void)adDidExpire:(nonnull id)response;


/*!
 * Sent when the native view is clicked by the user.
 */
- (void)adWasClicked:(nonnull id)response;

/*!
 * Sent when the native view returns the click-through URL and click-through fallback URL
 *   to the user instead of opening it in a browser.
 */
- (void)adWasClicked: (nonnull id)response
             withURL: (nonnull NSString *)clickURLString
         fallbackURL: (nonnull NSString *)clickFallbackURLString;

/*!
 * Sent when the native view was clicked, and the click through
 * destination is about to open in the in-app browser.
 *
 * @note If it is preferred that the destination open in the
 * native browser instead, then set clickThroughAction to ANClickThroughActionOpenDeviceBrowser.
 */
- (void)adWillPresent:(nonnull id)response;

/*!
 * Sent when the in-app browser has finished presenting and taken
 * control from your application.
 */
- (void)adDidPresent:(nonnull id)response;

/*!
 * Sent when the in-app browser will close and before
 * control has been returned to your application.
 */
- (void)adWillClose:(nonnull id)response;

/*!
 * Sent when the in-app browser has closed and control
 * has been returned to your application.
 */
- (void)adDidClose:(nonnull id)response;

/*!
 * Sent when the ad is about to leave the app.
 * This will happen in a number of cases, including when
 *   clickThroughAction is set to ANClickThroughActionOpenDeviceBrowser.
 */
- (void)adWillLeaveApplication:(nonnull id)response;

/*!
* Sent when  an impression is recorded for an native ad
*/
- (void)adDidLogImpression:(nonnull id)response;

@end
