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

@interface ANLocation : NSObject

/**
 The latitude of the user's location.  This must be a valid
 latitude, i.e., between -90.0 and 90.0.
 */
@property (nonatomic, readwrite, assign) CGFloat latitude;

/**
 The longitude of the user's location.  This must be a valid
 longitude, i.e., between -180.0 and 180.0.
 */
@property (nonatomic, readwrite, assign) CGFloat longitude;

/**
 The time when the user was in this location.  If nil, defaults to
 the current time.
 */
@property (nonatomic, readwrite, strong) NSDate *timestamp;

/**
 Determines the size of one side of the ``rectangle'' inside which
 the user is located.  If 0, defaults to 100 meters.  If negative,
 the location will be invalidated.
 */
@property (nonatomic, readwrite, assign) CGFloat horizontalAccuracy;

/**
 Gets the user's location, along with a timestamp and a degree of
 accuracy.  Returns nil if invalid location data is passed in (see
 the property definitions above for what constitutes invalid data).
 */
+ (ANLocation *)getLocationWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude
                  timestamp:(NSDate *)timestamp horizontalAccuracy:(CGFloat)horizontalAccuracy;

@end
