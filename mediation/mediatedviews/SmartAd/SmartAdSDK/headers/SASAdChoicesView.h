//
//  SASAdChoicesView.h
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 03/10/2016.
//
//

#import <UIKit/UIKit.h>


@class SASNativeAd;

/** The SASAdChoicesView class provides an Ad Choices button
 
 The Ad Choices button allows you to indicate easily that the content of the cell is a native ad and can redirect the
 user on a web page explaining how its data are used.
 
 Implementating the SASAdChoicesView can be required when using some third party mediation SDK, check the documentation
 of each mediation SDK for more informations.
 
 */
@interface SASAdChoicesView : UIButton

/** Register the native ad that is linked with the Ad Choices button.
 
 Registering the right native ad to each SASAdChoicesView instances is mandatory because it will be used to redirect the
 user on the right landing page.
 
 @param nativeAd the native ad linked with this Ad Choices button
 @param modalParentViewController the parent view controller of the modal view that will be displayed
    
 */
- (void)registerNativeAd:(SASNativeAd *)nativeAd modalParentViewController:(UIViewController *)modalParentViewController;

@end
