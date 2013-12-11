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

#import "ANLocation.h"

@implementation ANLocation

@synthesize latitude;
@synthesize longitude;
@synthesize timestamp;
@synthesize horizontalAccuracy;

#define DEFAULT_HOR_ACC 100

+ (ANLocation *)getLocationWithLatitude:(CGFloat)latitude
                              longitude:(CGFloat)longitude
                              timestamp:(NSDate *)timestamp
                     horizontalAccuracy:(CGFloat)horizontalAccuracy
{
    // verify that lat and long are valid
    if ((latitude < -90) || (latitude > 90))
        return nil;
    if ((longitude < -180) || (longitude > 180))
        return nil;
    
    // negative accuracy means the location is invalid; don't accept it
    if (horizontalAccuracy < 0)
        return nil;
    // default value if no accuracy was passed
    else if (horizontalAccuracy == 0)
        horizontalAccuracy = DEFAULT_HOR_ACC;
    
    // if given timestamp is nil, set time to now
    if (!timestamp)
        timestamp = [NSDate date];
    
    // make a new object every time to make sure we don't use old data
    ANLocation *location = [[ANLocation alloc] init];
    location.latitude = latitude;
    location.longitude = longitude;
    location.timestamp = timestamp;
    location.horizontalAccuracy = horizontalAccuracy;
    return location;
}

@end
