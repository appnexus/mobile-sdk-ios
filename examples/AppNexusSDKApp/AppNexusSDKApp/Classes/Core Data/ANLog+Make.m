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

#import "ANLog+Make.h"

@implementation ANLog (Make)

+ (void)storeLogOutput:(NSString *)output
              withName:(NSString *)name
                onDate:(NSDate *)date
  withOriginatingClass:(NSString *)originatingClass
          fromAppNexus:(BOOL)isAppNexus
         withProcessID:(NSInteger)processID
inManagedObjectContext:(NSManagedObjectContext *)context {
    ANLog *log = nil;
    if (context) {
        log = [NSEntityDescription insertNewObjectForEntityForName:@"ANLog" inManagedObjectContext:context];
        log.datetime = date;
        log.originatingClass = originatingClass;
        log.isAppNexus = [NSNumber numberWithBool:isAppNexus];
        log.output = output;
        log.name = name;
        log.processID = [NSNumber numberWithInteger:processID];
        log.text = [ANLog generateTextWithLogOutput:output
                                           withName:name
                                             onDate:date
                               withOriginatingClass:originatingClass
                                       fromAppNexus:isAppNexus
                                      withProcessID:processID];
    }
}

+ (NSString *)generateTextWithLogOutput:(NSString *)output
                               withName:(NSString *)name
                                 onDate:(NSDate *)date
                withOriginatingClass:(NSString *)originatingClass
                        fromAppNexus:(BOOL)isAppNexus
                        withProcessID:(NSInteger)processID {
    NSString *d = date ? [NSString stringWithFormat:@"%@\n", date] : @"";
    NSString *n = name || [name length] ? [NSString stringWithFormat:@"%@\n", name] : @"";
    NSString *cn = originatingClass || [originatingClass length] ? [NSString stringWithFormat:@"%@\n", originatingClass] : @"";
    NSString *pid = processID ? [NSString stringWithFormat:@"PID: %d\n", processID] : @"";
    NSString *o = output || [output length] ? output : @"";
    NSString *text = [NSString stringWithFormat:@"%@%@%@%@%@",d,n,cn,pid,o];
    return text;
}

@end