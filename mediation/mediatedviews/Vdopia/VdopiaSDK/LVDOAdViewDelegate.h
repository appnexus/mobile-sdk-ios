//
//  LVDOAdViewDelegate.h
//  iTennis
//
//  Created by Nitish garg on 08/11/13.
//
//

#import <Foundation/Foundation.h>
#import "LVDOAdRequestError.h"

@protocol LVDOAdViewDelegate <NSObject>
@optional

- (void)adViewDidReceiveAd;
- (void)didFailToReceiveAdWithError:(int)errorCode;

- (void)adViewWillPresentScreen;
- (void)adViewDidDismissScreen;
- (void)adViewWillDismissScreen;
- (void)adViewWillLeaveApplication;
- (void)adViewOnClick;
@end
