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

#import "ANLogging.h"

NSString *const kANLoggingNotification = @"kANLoggingNotification";
NSString *const kANLogMessageKey = @"kANLogMessageKey";

static ANLogLevel ANLOG_LEVEL = ANLogLevelDebug;

ANLogLevel ANLogGetLevel()
{
	return ANLOG_LEVEL;
}

void ANLogSetLevel(ANLogLevel level)
{
	ANLOG_LEVEL = level;
}

void _ANLogTrace(NSString *format, ...)
{
	if (ANLOG_LEVEL <= ANLogLevelTrace)
    {
		format = [NSString stringWithFormat:@"APPNEXUS: %@", format];
        va_list args;
        va_start(args, format);
        notifyListener([[[NSString alloc] initWithFormat:format arguments:args] init]);
        NSLogv(format, args);
        va_end(args);
    }
}

void _ANLogDebug(NSString *format, ...)
{
	if (ANLOG_LEVEL <= ANLogLevelDebug)
    {
		format = [NSString stringWithFormat:@"APPNEXUS: %@", format];
        va_list args;
        va_start(args, format);
        notifyListener([[[NSString alloc] initWithFormat:format arguments:args] init]);
        NSLogv(format, args);
        va_end(args);
    }
}

void _ANLogWarn(NSString *format, ...)
{
	if (ANLOG_LEVEL <= ANLogLevelWarn)
    {
		format = [NSString stringWithFormat:@"APPNEXUS: %@", format];
        va_list args;
        va_start(args, format);
        notifyListener([[[NSString alloc] initWithFormat:format arguments:args] init]);
        NSLogv(format, args);
        va_end(args);
    }
}

void _ANLogInfo(NSString *format, ...)
{
	if (ANLOG_LEVEL <= ANLogLevelInfo)
    {
		format = [NSString stringWithFormat:@"APPNEXUS: %@", format];
        va_list args;
        va_start(args, format);
        notifyListener([[[NSString alloc] initWithFormat:format arguments:args] init]);
        NSLogv(format, args);
        va_end(args);
    }
}

void _ANLogError(NSString *format, ...)
{
	if (ANLOG_LEVEL <= ANLogLevelError)
    {
		format = [NSString stringWithFormat:@"APPNEXUS: %@", format];
        va_list args;
        va_start(args, format);
        notifyListener([[[NSString alloc] initWithFormat:format arguments:args] init]);
        NSLogv(format, args);
        va_end(args);
    }
}

void _ANLogFatal(NSString *format, ...)
{
	if (ANLOG_LEVEL <= ANLogLevelFatal)
    {
		format = [NSString stringWithFormat:@"APPNEXUS: %@", format];
        va_list args;
        va_start(args, format);
        notifyListener([[[NSString alloc] initWithFormat:format arguments:args] init]);
        NSLogv(format, args);
        va_end(args);
    }
}

void notifyListener(NSString *message)
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kANLoggingNotification
                                                        object:nil
                                                      userInfo:[NSDictionary dictionaryWithObject:message forKey:kANLogMessageKey]];
}