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

#import "ANRequest+Make.h"
#import "ANResponse+Make.h"
#import "ANLogging.h"

@implementation ANRequest (Make)

+ (void)storeRequestOutput:(NSString *)output onDate:(NSDate *)date inManagedObjectContext:(NSManagedObjectContext *)context {
    ANRequest *request = nil;
    if (context) {
        request = [NSEntityDescription insertNewObjectForEntityForName:@"ANRequest" inManagedObjectContext:context];
        request.datetime = date;
        request.text = output;
        [ANRequest deleteExcessRequests:context];
    }
}

+ (ANRequest *)lastRequestMadeInManagedObjectContext:(NSManagedObjectContext *)context {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ANRequest"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"datetime" ascending:NO]];
    [request setFetchLimit:1];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];

    if (!matches) {
        ANLogError(@"%@ %@ | Error Pulling From Managed Object Context", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return nil;
    } else {
        return [matches lastObject];
    }
}

+ (void)deleteExcessRequests:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ANRequest"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"datetime" ascending:YES]];

    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches) {
        ANLogError(@"%@ %@ | Error Pulling From Managed Object Context", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    } else {
        if ([matches count] > REQUEST_STORE_LIMIT) {
            for (int i = 0; i < [matches count] - REQUEST_STORE_LIMIT; i++) {
                [context deleteObject:[matches objectAtIndex:i]];
            }
        }
    }
}

+ (void)storeResponseOutput:(NSString *)output onDate:(NSDate *)date inManagedObjectContext:(NSManagedObjectContext *)context {
    if (context) {
        ANRequest *request = [[self class] lastRequestMadeInManagedObjectContext:context];
        if (request) {
            ANResponse *response = [ANResponse responseWithOutput:output onDate:date inManagedObjectContext:context];
            request.response = response;
        }
    }
}

@end
