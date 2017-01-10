//
//  ANAdAdapterBannerSmartAd.h
//  ANSDK
//
//  Created by Punnaghai Puviarasu on 11/21/16.
//  Copyright © 2016 AppNexus. All rights reserved.
//

#import "ANCustomAdapter.h"
#import "SASBannerView.h"
#import "ANAdAdapterSmartAdBase.h"

@interface ANAdAdapterBannerSmartAd :  ANAdAdapterSmartAdBase <ANCustomAdapterBanner, SASAdViewDelegate>

@end
