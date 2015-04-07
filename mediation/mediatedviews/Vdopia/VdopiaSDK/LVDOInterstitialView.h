//
//  VdoInterstitialView.h
//  iTennis
//
//  Created by Nitish garg on 15/11/13.
//
//

#import <Foundation/Foundation.h>
#import "LVDOAdViewDelegate.h"
#import "LVDOAdRequest.h"




@interface LVDOInterstitialView : UIViewController <LVDOAdViewDelegate>
{
    
    float BannerHieght;
    float BannerWidth;
    float Y_POSITION;
    int baneerPos;
    float statusBarHeight;
    CGSize originalSize;
    float navBarHeight;
    float tabFactor;
}

@property(nonatomic,strong)NSString *adUnitID;
@property(nonatomic,strong)id<LVDOAdViewDelegate> delegate;
@property(nonatomic,strong)LVDOAdRequest *request;
@property (nonatomic) int adType;


- (id)initWithAdUnitID:(NSString *)adUnitID delegate:(id)delegate;
- (id)initWithAdUnitID:(NSString *)adUnitID;
- (void)load;
- (void)load:(LVDOAdRequest *)request;
-(void)setAdRefreshInterval:(float)selectedInterval;
- (LVDOAdRequest *)getAdRequest;
- (void)setAdFormat:(int)adType;
- (void)setAdView:(UIView *)view;
-(void)closeActivatedBySDK;
- (void)setMraidAdView:(UIView *)view;
-(void) showInterstitialView;


@end
