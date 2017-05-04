/*   Copyright 2017 APPNEXUS INC
 
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


#import "ANAdAdapterBaseAdMarvel.h"
#import <CoreLocation/CoreLocation.h>
#import "ANCustomAdapter.h"
#import "ANLogging.h"

static NSString *kPartnerId = @"";
static NSString *kSiteId = @"";

@interface ANAdAdapterBaseAdMarvel()
    @property (nonatomic, readwrite, strong) UIViewController *rootViewController;
    @property (nonatomic, readwrite, strong) ANTargetingParameters *targetingParameters;
    @property (nonatomic, readwrite, strong) NSString *siteId;
    @property (nonatomic, readwrite, strong) NSString *partnerId;
    
@end

@implementation ANAdAdapterBaseAdMarvel

@synthesize rootViewController = _rootViewController;
@synthesize targetingParameters = _targetingParameters;

+(void) setPartnerId:(NSString *)partnerId{
    kPartnerId = partnerId;
}

+(void) setSiteId:(NSString *)siteId{
    kSiteId = siteId;
}

-(void)setSiteAndPartnerIdParameters:(NSString *) idString{
    
    if(idString != nil || ![idString isEqualToString:@""]){
        NSData *data = [idString dataUsingEncoding:NSUTF8StringEncoding];
        id idDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if(idDictionary != nil && [idDictionary isKindOfClass:[NSDictionary class]]){
            kSiteId = [idDictionary objectForKey:@"site_id"];
            kPartnerId = [idDictionary objectForKey:@"partner_id"];
        }
    }
}

-(ANTargetingParameters *)targetingParameters{
    return _targetingParameters;
}

-(void) setTargetingParameters:(ANTargetingParameters *) targetingParams{
    _targetingParameters = targetingParams;
}

- (UIViewController *)rootViewController {
    return _rootViewController;
}

-(void) setRootViewController:(UIViewController *) rootViewController{
    _rootViewController = rootViewController;
}



#pragma mark AdMarvelDelegate methods

- (NSString*)partnerId:(AdMarvelView *)adMarvelView
{
    return kPartnerId;
    
}

// The site id provided by AdMarvel
- (NSString*)siteId:(AdMarvelView *)adMarvelView
{
    return kSiteId;
    
}

- (UIViewController *) applicationUIViewController:(AdMarvelView *)adMarvelView
{
    return self.rootViewController;
}

// Any targeting parameters you want to pass
- (NSDictionary*) targetingParameters:(AdMarvelView *)adMarvelView{
    NSMutableDictionary* keywordDictionary = [[NSMutableDictionary alloc] init];
    
    ANGender gender = _targetingParameters.gender;
    switch (gender) {
        case ANGenderMale:
            [keywordDictionary setObject:@"male" forKey:TARGETING_PARAM_GENDER];
            break;
        case ANGenderFemale:
            [keywordDictionary setObject:@"female" forKey:TARGETING_PARAM_GENDER];
            break;
        default:
            break;
    }
    
    if ([self.targetingParameters age]) {
        [keywordDictionary setObject:self.targetingParameters.age forKey:TARGETING_PARAM_AGE];
    }
    
    ANLocation *location = self.targetingParameters.location;
    if (location) {
        CLLocation *mpLoc = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(location.latitude, location.longitude)
                                                          altitude:0
                                                horizontalAccuracy:location.horizontalAccuracy
                                                  verticalAccuracy:0
                                                         timestamp:location.timestamp];
        NSString *locationString = [NSString stringWithFormat:@"%f,%f", mpLoc.coordinate.latitude, mpLoc.coordinate.longitude];
        [keywordDictionary setObject:locationString forKey:TARGETING_PARAM_GEOLOCATION];
     }
    
    return keywordDictionary;
}

- (void)handleAdMarvelSDKClick:(NSString *)urlString forAdMarvelView:(AdMarvelView *)adMarvelView {
    ANLogTrace(@"Call to handle special functionality within the application is unsupported by the AdMarvel adapter");
}

#pragma -

@end
