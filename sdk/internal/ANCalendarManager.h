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

#import <EventKitUI/EventKitUI.h>

@protocol ANCalendarManagerDelegate;

@interface ANCalendarManager : NSObject

- (instancetype)initWithCalendarDictionary:(NSDictionary *)dict
                                  delegate:(id<ANCalendarManagerDelegate>)delegate;

@property (nonatomic, readwrite, weak) id<ANCalendarManagerDelegate> delegate;

@end

@protocol ANCalendarManagerDelegate <NSObject>

- (UIViewController *)rootViewControllerForPresentationForCalendarManager:(ANCalendarManager *)calendarManager;

@optional
- (void)willPresentCalendarEditForCalendarManager:(ANCalendarManager *)calendarManager;
- (void)didPresentCalendarEditForCalendarManager:(ANCalendarManager *)calendarManager;
- (void)willDismissCalendarEditForCalendarManager:(ANCalendarManager *)calendarManager;
- (void)didDismissCalendarEditForCalendarManager:(ANCalendarManager *)calendarManager;

@end