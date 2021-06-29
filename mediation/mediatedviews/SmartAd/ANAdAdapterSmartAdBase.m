/*   Copyright 2016 APPNEXUS INC
 
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
#import "ANAdAdapterSmartAdBase.h"

@implementation ANAdAdapterSmartAdBase

@synthesize delegate;

- (void)configureSmartDisplaySDKWithSiteId:(NSInteger)siteId {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // The configure method should never be called more than once
        [[SASConfiguration sharedInstance] configureWithSiteId:siteId];
    });
}

- (NSString *)keywordsFromTargetingParameters:(ANTargetingParameters *)targetingParameters {
        //currently we are not sure in what format the params needs to be passed to the SmartAd server. Hence keeping it empty
    if(targetingParameters.location != nil){
        ANLocation *location = targetingParameters.location;
        if (location) {
            [[SASConfiguration sharedInstance] setManualLocation:CLLocationCoordinate2DMake(location.latitude, location.longitude)];
            
        }
    }
        return @"";
}

#pragma mark - PrivateMethods

- (SASAdPlacement *)parseAdUnitParameters:(NSString *)adUnitString targetingParameters:(ANTargetingParameters *)targetingParameters {
    
    if (adUnitString == nil || [adUnitString isEqualToString:@""]) {
        // No ad unit string, cannot create a placement
        return nil;
    }
    
    // Ad unit string is converted in JSON
    NSData *data = [adUnitString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *adUnitDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    // Parsing Smart IDs from the Ad unit JSON
    NSInteger siteId = [adUnitDictionary[SMARTAD_SITEID] integerValue];
    NSString *pageIdString = adUnitDictionary[SMARTAD_PAGEID];
    NSInteger formatId = [adUnitDictionary[SMARTAD_FORMATID] integerValue];
    NSString *targetString;
    if (targetingParameters != nil) {
        targetString = [self keywordsFromTargetingParameters:targetingParameters];
    }
    
    if (siteId <= 0 || formatId <= 0 || pageIdString == nil || [pageIdString isEqualToString:@""]) {
        // No valid Smart IDs found in the ad unit string
        return nil;
    }
    
    // Setting the SiteID if necessary
    [self configureSmartDisplaySDKWithSiteId:siteId];
    
    // Creating a placement
    SASAdPlacement *placement;
    if ([pageIdString integerValue] > 0) {
        placement = [SASAdPlacement adPlacementWithSiteId:siteId pageId:[pageIdString integerValue] formatId:formatId keywordTargeting:targetString];
    } else {
        placement = [SASAdPlacement adPlacementWithSiteId:siteId pageName:pageIdString formatId:formatId keywordTargeting:targetString];
    }
    
    return placement;
}



@end
