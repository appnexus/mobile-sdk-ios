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


#import "ANLogManager.h"

#import <Foundation/Foundation.h>



#define AN_DEBUG_MODE                1

extern NSString *const kANLoggingNotification;
extern NSString *const kANLogMessageKey;
extern NSString *const kANLogMessageLevelKey;

void notifyListener(NSString *message, NSInteger messageLevel);

#if AN_DEBUG_MODE

void _ANLog(ANLogLevel level, NSString *levelString, char const *logContext, NSString *format, ...)  NS_FORMAT_FUNCTION(4, 5);
#define ANLogMark()             _ANLog(ANLogLevelTrace, @"MARK",    __PRETTY_FUNCTION__, @"")
#define ANLogMarkMessage(...)   _ANLog(ANLogLevelTrace, @"MARK",    __PRETTY_FUNCTION__, __VA_ARGS__)
#define ANLogTrace(...)         _ANLog(ANLogLevelTrace, @"TRACE",   __PRETTY_FUNCTION__, __VA_ARGS__)
#define ANLogDebug(...)         _ANLog(ANLogLevelDebug, @"DEBUG",   __PRETTY_FUNCTION__, __VA_ARGS__)
#define ANLogInfo(...)          _ANLog(ANLogLevelInfo,  @"INFO",    __PRETTY_FUNCTION__, __VA_ARGS__)
#define ANLogWarn(...)          _ANLog(ANLogLevelWarn,  @"WARNING", __PRETTY_FUNCTION__, __VA_ARGS__)
#define ANLogError(...)         _ANLog(ANLogLevelError, @"ERROR",   __PRETTY_FUNCTION__, __VA_ARGS__)

#else

#define ANLogMark() {}
#define ANLogMarkMessage(...) {}
#define ANLogTrace(...) {}
#define ANLogDebug(...) {}
#define ANLogInfo(...) {}
#define ANLogWarn(...) {}
#define ANLogError(...) {}

#endif


