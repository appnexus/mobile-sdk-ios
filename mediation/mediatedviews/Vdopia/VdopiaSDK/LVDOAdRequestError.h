//
//  LVDOAdRequestError.h
//  iTennis
//
//  Created by Nitish garg on 12/11/13.
//
//

#import <Foundation/Foundation.h>
enum vdoErrorCodes
{
     vdoAdErrorIncorrectAdRecieved=0,
     vdoAdErrorunKnownAd,
     vdoAdErrorNoAd,
     vdoAdErrorInventoryUnavailable,
     vdoAdErrorNetworkFailure
};


@interface LVDOAdRequestError : NSObject

@end
//incoreectAd
//noadd
//unknownAd
//inventoryUnavailable