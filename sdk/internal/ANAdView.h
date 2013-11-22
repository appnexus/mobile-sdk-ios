/*   Copyright 2013 APPNEXUS INC
 
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

#import <UIKit/UIKit.h>
#import "ANGlobal.h"
#import "ANLogging.h"
#import "ANAdProtocol.h"
#import "ANAdFetcher.h"

@interface ANAdView : UIView <ANAdFetcherDelegate, ANAdProtocol>
{
    // Size of the ad requested
    CGSize __adSize;

    // Placement id for the ad
	NSString *__placementId;
    
    UIView *__contentView;
    UIButton *__closeButton;
}

#pragma mark Deprecrated Properties

// This property is deprecated, use "opensInNativeBrowser" instead
@property (nonatomic, readwrite, assign) BOOL clickShouldOpenInBrowser DEPRECATED_ATTRIBUTE;

@end

@interface ANAdView (ANAdFetcher)
@property (nonatomic, readwrite, strong) UIView *contentView;
@property (nonatomic, readwrite, strong) UIButton *closeButton;

- (void)removeCloseButton;

@end


////////////////////////////////////////////////////////////////////////////////////////////////////