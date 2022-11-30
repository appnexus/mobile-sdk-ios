/*   Copyright 2022 XANDR INC

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

#import "ANGPPSettings.h"

NSString * const  AN_IABGPP_HDR_GppString = @"IABGPP_HDR_GppString";
NSString * const  AN_IABGPP_GppSID = @"IABGPP_GppSID";

@implementation ANGPPSettings : NSObject


+ (nonnull NSString *) getGPPString{
    NSString* gppString = [[NSUserDefaults standardUserDefaults] objectForKey:AN_IABGPP_HDR_GppString];
    return gppString? gppString: @"";
}

+ (nonnull NSArray<NSNumber *> *) getGPPSIDArray{
    // Fetch the GppSid String, as per spec Multiple IDs are separated by underscore, e.g. “2_3”
    NSString* gppsidString = [[NSUserDefaults standardUserDefaults] objectForKey:AN_IABGPP_GppSID];
    
    if(gppsidString){
        // Process the Gppsid string and convert to an array
        NSArray<NSString *> *gppsidStringArray = [gppsidString componentsSeparatedByString:@"_"];
        
        
        // Convert String array to Integer Array.
        NSMutableArray<NSNumber *> *gppsidIntegerArray  = [[NSMutableArray alloc] init];
        for (NSString *gppsid in gppsidStringArray) {
            [gppsidIntegerArray addObject:[NSNumber numberWithInt:[gppsid intValue]]];
        }
        return gppsidIntegerArray;
    }else{
        return nil;
    }
    
}

@end
