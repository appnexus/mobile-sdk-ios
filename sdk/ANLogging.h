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

#import <Foundation/Foundation.h>

// Lower = finer-grained logs.
typedef enum 
{
	ANLogLevelAll		= 0,
	ANLogLevelTrace		= 10,
	ANLogLevelDebug		= 20,
	ANLogLevelInfo		= 30,
	ANLogLevelWarn		= 40,
	ANLogLevelError		= 50,
	ANLogLevelFatal		= 60,
	ANLogLevelOff		= 70
} ANLogLevel;

ANLogLevel ANLogGetLevel(void);
void ANLogSetLevel(ANLogLevel level);
void _ANLogTrace(NSString *format, ...);
void _ANLogDebug(NSString *format, ...);
void _ANLogInfo(NSString *format, ...);
void _ANLogWarn(NSString *format, ...);
void _ANLogError(NSString *format, ...);
void _ANLogFatal(NSString *format, ...);

#if AN_DEBUG_MODE

#define ANLogTrace(...) _ANLogTrace(__VA_ARGS__)
#define ANLogDebug(...) _ANLogDebug(__VA_ARGS__)
#define ANLogInfo(...) _ANLogInfo(__VA_ARGS__)
#define ANLogWarn(...) _ANLogWarn(__VA_ARGS__)
#define ANLogError(...) _ANLogError(__VA_ARGS__)
#define ANLogFatal(...) _ANLogFatal(__VA_ARGS__)

#else

#define ANLogTrace(...) {}
#define ANLogDebug(...) {}
#define ANLogInfo(...) {}
#define ANLogWarn(...) {}
#define ANLogError(...) {}
#define ANLogFatal(...) {}

#endif
