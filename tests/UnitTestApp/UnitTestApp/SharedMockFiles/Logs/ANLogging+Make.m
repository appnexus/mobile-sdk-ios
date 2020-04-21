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

#import "ANLogging.h"

#import "ANGlobal.h"

NSString *const kANLoggingNotification = @"kANLoggingNotification";
NSString *const kANLogMessageKey = @"kANLogMessageKey";
NSString *const kANLogMessageLevelKey = @"kANLogMessageLevelKey";
static ANLogLevel  ANLOG_LEVEL  =    ANLogLevelAll;


void _ANLog(ANLogLevel level, NSString *levelString, char const *logContext, NSString *format, ...) {
    if (ANLOG_LEVEL <= level) {
        format = ANErrorString(format); // returns the format string if error string not found
        format = [NSString stringWithFormat:@" APPNEXUS %@  %s -- %@", levelString, logContext, format];
        va_list args;
        va_start(args, format);
        NSString *fullString = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
        notifyListener(fullString, level);
        NSLog(@"%@", fullString);
    }
}

void notifyListener(NSString *message, NSInteger messageLevel)
{
    ANPostNotifications(kANLoggingNotification, nil,
                        @{kANLogMessageKey: message,
                          kANLogMessageLevelKey: @(messageLevel)});
}
