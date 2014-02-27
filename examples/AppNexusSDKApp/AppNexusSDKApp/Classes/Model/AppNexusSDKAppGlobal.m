/*   Copyright 2014 APPNEXUS INC
 
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

#import "AppNexusSDKAppGlobal.h"

@implementation AppNexusSDKAppGlobal

+ (UIColor *)colorFromString:(NSString *)color {
    NSScanner *scanner = [NSScanner scannerWithString:color];
    unsigned int scannedValue;
    [scanner scanHexInt:&scannedValue];
    
    int alpha = (scannedValue & 0xFF000000) >> 24;
    int red = (scannedValue & 0xFF0000) >> 16;
    int green = (scannedValue & 0xFF00) >> 8;
    int blue = (scannedValue & 0xFF);
    
    UIColor *colorObject = [UIColor colorWithRed:red/255.0
                                           green:green/255.0
                                            blue:blue/255.0
                                           alpha:alpha/255.0];
    
    return colorObject;
}

@end
