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

/**
 The lower the filter level, the more logs will be shown.
 For example, `ANLogLevelInfo` will display messages from
 `ANLogLevelInfo,` `ANLogLevelWarn,` and `ANLogLevelError.`
 The default level is `ANLogLevelWarn`
 */
typedef NS_ENUM(NSUInteger, ANLogLevel) {
	ANLogLevelAll		= 0,
	ANLogLevelTrace		= 10,
	ANLogLevelDebug		= 20,
	ANLogLevelInfo		= 30,
	ANLogLevelWarn		= 40,
	ANLogLevelError		= 50,
	ANLogLevelOff		= 60
};

/**
 Use the `ANLogManager` methods to set the desired level of log filter.
 */
@interface ANLogManager : NSObject

/**
 Gets the current log filter level.
 */
+ (ANLogLevel)getANLogLevel;

/**
 Sets the log filter level.
 */
+ (void)setANLogLevel:(ANLogLevel)level;

@end