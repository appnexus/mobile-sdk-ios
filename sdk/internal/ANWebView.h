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

#import "ANMRAIDProperties.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ANWebView : UIWebView
@end

@interface UIWebView (MRAIDExtensions)
// MRAID events
- (void)fireReadyEvent;
- (void)fireStateChangeEvent:(ANMRAIDState)state;
- (void)fireNewCurrentPositionEvent:(CGRect)frame;
- (void)fireErrorEvent:(NSString *)errorString function:(NSString *)function;

// set values for MRAID getters
- (void)setPlacementType:(NSString *)placementType;
- (void)setIsViewable:(BOOL)viewable;
- (void)setCurrentPosition:(CGRect)frame;
- (void)setDefaultPosition:(CGRect)frame;
- (void)setScreenSize:(CGSize)size;
- (void)setMaxSize:(CGSize)size;
- (void)setSupports:(NSString *)feature isSupported:(BOOL)isSupported;

- (void)setHidden:(BOOL)hidden animated:(BOOL)animated;

- (ANMRAIDState)getMRAIDState;

@end
