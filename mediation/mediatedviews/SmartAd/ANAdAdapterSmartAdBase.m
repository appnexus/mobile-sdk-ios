//
//  ANAdAdapterSmartAdBase.m
//  ANSDK
//
//  Created by Punnaghai Puviarasu on 1/9/17.
//  Copyright © 2017 AppNexus. All rights reserved.
//

#import "ANAdAdapterSmartAdBase.h"
#import "SASAdView.h"

@interface ANAdAdapterSmartAdBase()
    @property (nonatomic, readwrite) NSInteger siteId;
    @property (nonatomic, readwrite, strong) NSDictionary *adUnitDictionary;

@end


@implementation ANAdAdapterSmartAdBase

@synthesize delegate;
@synthesize adUnitDictionary =_adUnitDictionary;
@synthesize siteId = _siteId;

- (void) setSmartAdSiteId:(NSInteger)siteId{
    
    [SASAdView setSiteID:siteId baseURL:@"https://mobile.smartadserver.com"];
    
}

#pragma mark - PrivateMethods

-(NSDictionary *) parseAdUnitParameters:(NSString *) adUnitString{
    if(adUnitString != nil || ![adUnitString isEqualToString:@""]){
        NSData *data = [adUnitString dataUsingEncoding:NSUTF8StringEncoding];
        self.adUnitDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if(self.adUnitDictionary != nil){
            _siteId = (NSInteger)self.adUnitDictionary[@"siteId"];
            [self setSmartAdSiteId:_siteId];
        }
        return self.adUnitDictionary;
    }
    return nil;
}


- (NSString *)keywordsFromTargetingParameters:(ANTargetingParameters *)targetingParameters {
        //currently we are not sure in what format the params needs to be passed to the SmartAd server. Hence keeping it empty
        return @"";
}

- (void)locationFromTargetingParameters:(ANTargetingParameters *)targetingParameters {
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


@end
