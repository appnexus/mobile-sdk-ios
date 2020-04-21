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

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ANLog : NSManagedObject

@property (nonatomic, retain) NSDate * datetime;
@property (nonatomic, retain) NSNumber * isAppNexus;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * originatingClass;
@property (nonatomic, retain) NSString * output;
@property (nonatomic, retain) NSNumber * processID;
@property (nonatomic, retain) NSString * text;

@end
