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

#import "ANLogManager.h"

#import <Foundation/Foundation.h>

#define AN_DEBUG_MODE				1

extern NSString *const kANLoggingNotification;
extern NSString *const kANLogMessageKey;
extern NSString *const kANLogMessageLevelKey;

void _ANLogTrace(NSString *format, ...);
void _ANLogDebug(NSString *format, ...);
void _ANLogInfo(NSString *format, ...);
void _ANLogWarn(NSString *format, ...);
void _ANLogError(NSString *format, ...);

void notifyListener(NSString *message, NSInteger messageLevel);

#if AN_DEBUG_MODE

#define ANLogTrace(...) _ANLogTrace(__VA_ARGS__)
#define ANLogDebug(...) _ANLogDebug(__VA_ARGS__)
#define ANLogInfo(...) _ANLogInfo(__VA_ARGS__)
#define ANLogWarn(...) _ANLogWarn(__VA_ARGS__)
#define ANLogError(...) _ANLogError(__VA_ARGS__)

#else

#define ANLogTrace(...) {}
#define ANLogDebug(...) {}
#define ANLogInfo(...) {}
#define ANLogWarn(...) {}
#define ANLogError(...) {}

#endif
