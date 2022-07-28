/*   Copyright 2022 APPNEXUS INC
 
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

#import "XandrAd.h"
#import "ANGlobal.h"
#import "ANHTTPNetworkSession.h"
#import "ANLogging.h"
#import "ANSDKSettings.h"


NSString * const  VIEWABLE_IMP_CONFIG_URL = @"https://acdn.adnxs.com/mobile/viewableimpression/member_list_array.json";


#pragma mark -

@interface XandrAd()


@property (nonatomic, readwrite, assign)  NSInteger memberId;


@property (nonatomic, readwrite, strong) NSMutableArray *viewableImpsMemberIdsArray;

@end



@implementation XandrAd


+ (id)sharedInstance {
    static dispatch_once_t xandrAdSDKToken;
    static XandrAd *xandrAdSDK;
    dispatch_once(&xandrAdSDKToken, ^{
        xandrAdSDK = [[XandrAd alloc] init];
        xandrAdSDK.memberId = -1;
    });
    return xandrAdSDK;
}


- (void)initWithMemberID:(NSInteger)memberId preCacheRequestObjects:(BOOL)preCacheRequestObjects completionHandler:(XandrAdInitCompletion)completionHandler{
    
    ANLogDebug(@"XandrAd init");
    self.memberId = memberId;
    
    
    // Setup observer for completion status first
    if(completionHandler != nil){
            NSOperationQueue *queue = [[NSOperationQueue alloc]init];
            
            [[NSNotificationCenter defaultCenter] addObserverForName:@"kXandrAdInitSuccess"
                                                              object:nil
                                                               queue:queue
                                                          usingBlock:^(NSNotification *notification) {
                completionHandler(YES);
                [[NSNotificationCenter defaultCenter] removeObserver:@"kXandrAdInitSuccess"];
                [[NSNotificationCenter defaultCenter] removeObserver:@"kXandrAdInitFailed"];
            }];
            [[NSNotificationCenter defaultCenter] addObserverForName:@"kXandrAdInitFailed"
                                                              object:nil
                                                               queue:queue
                                                          usingBlock:^(NSNotification *notification) {
                completionHandler(NO);
                [[NSNotificationCenter defaultCenter] removeObserver:@"kXandrAdInitSuccess"];
                [[NSNotificationCenter defaultCenter] removeObserver:@"kXandrAdInitFailed"];
            }];
    }
    
    
    if(!_viewableImpsMemberIdsArray){
        ANLogDebug(@"XandrAd init: Fetching Viewable Impression Member Id's");
        NSURLRequest *request     = ANBasicRequestWithURL([NSURL URLWithString:VIEWABLE_IMP_CONFIG_URL]);
        
        [ANHTTPNetworkSession startTaskWithHttpRequest:request responseHandler:^(NSData * _Nonnull data, NSHTTPURLResponse * _Nonnull response) {
            if (!data) {
                ANLogError(@"XandrAd Init - Fetching Viewable Impression Member Id's Failed");
            }
            NSError *e = nil;
            self.viewableImpsMemberIdsArray = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &e];
            if (!self.viewableImpsMemberIdsArray) {
              ANLogError(@"XandrAd Init - Error parsing Viewable Impression Member List JSON: %@", e);
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kXandrAdInitSuccess" object:nil userInfo:nil];
        } errorHandler:^(NSError * _Nonnull error) {
            ANLogError(@"XandrAd Init - Fetching Viewable Impression Member Id's Failed");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kXandrAdInitFailed" object:nil userInfo:nil];
        }];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kXandrAdInitSuccess" object:nil userInfo:nil];
    }
    
    if(preCacheRequestObjects){
        [[ANSDKSettings sharedInstance] optionalSDKInitialization:nil];
    }
    
}


-(BOOL) doesContainMemberId:(NSInteger)buyerMemberId{
    return ([self.viewableImpsMemberIdsArray containsObject:[NSNumber numberWithInteger:buyerMemberId]]);
}


- (BOOL)isEligibleForViewableImpression:(NSInteger)buyerMemberId{
    return ([self doesContainMemberId:buyerMemberId ] || buyerMemberId == self.memberId);
}


- (BOOL)isInitialised{
    return self.memberId != -1;
}




@end
