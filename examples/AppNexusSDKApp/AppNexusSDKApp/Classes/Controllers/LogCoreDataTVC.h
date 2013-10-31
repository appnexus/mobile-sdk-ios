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

#import "CoreDataTableViewController.h"

#define CGFLOAT_TOP_INSET 8.0
#define CGFLOAT_BOT_INSET 8.0
#define TEXT_FONT @"Helvetica Neue"
#define CELL_TEXT_FACTOR 1.05
#define FETCH_LIMIT 500

@interface LogCoreDataTVC : CoreDataTableViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSString *predicate; // Allow Override
@property (nonatomic, strong) NSString *fullTextToEmail;

@end