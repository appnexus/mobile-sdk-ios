//
//  ANAdAdapterSmartAdBase.m
//  ANSDK
//
//  Created by Punnaghai Puviarasu on 1/9/17.
//  Copyright © 2017 AppNexus. All rights reserved.
//

#import "ANAdAdapterSmartAdBase.h"
#import "SASAdView.h"




@implementation ANAdAdapterSmartAdBase

@synthesize delegate;

- (void) setSmartAdSiteId:(NSInteger)siteId{
    
    [SASAdView setSiteID:siteId baseURL:SMARTAD_BASEURL];
    
}

- (NSString *)keywordsFromTargetingParameters:(ANTargetingParameters *)targetingParameters {
        //currently we are not sure in what format the params needs to be passed to the SmartAd server. Hence keeping it empty
    if(targetingParameters.location != nil){
        ANLocation *location = targetingParameters.location;
        if (location) {
            CLLocation *mpLoc = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(location.latitude, location.longitude)
                                                              altitude:0
                                                    horizontalAccuracy:location.horizontalAccuracy
                                                      verticalAccuracy:0
                                                             timestamp:location.timestamp];
            [SASAdView setLocation:mpLoc];
            
        }
    }
        return @"";
}

#pragma mark - PrivateMethods

-(NSDictionary *) parseAdUnitParameters:(NSString *) adUnitString{
    
    if(adUnitString != nil || ![adUnitString isEqualToString:@""]){
        NSData *data = [adUnitString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *adUnitDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if(adUnitDictionary != nil){
            NSInteger siteId = [adUnitDictionary[@"siteId"] integerValue];
            [self setSmartAdSiteId:siteId];
        }
        return adUnitDictionary;
    }
    return nil;
}


@end
