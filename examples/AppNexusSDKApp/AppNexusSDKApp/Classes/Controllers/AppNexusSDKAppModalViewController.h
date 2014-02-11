//
//  AdSettingsHelpViewController.h
//  AppNexusSDKApp
//
//  Created by Jose Cabal-Ugaz on 2/7/14.
//  Copyright (c) 2014 AppNexus. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AppNexusSDKAppModalViewControllerDelegate;

@interface AppNexusSDKAppModalViewController : UIViewController

@property (nonatomic, assign) UIInterfaceOrientation orientation;
@property (nonatomic, readwrite, weak) id<AppNexusSDKAppModalViewControllerDelegate> delegate;

@end

@protocol AppNexusSDKAppModalViewControllerDelegate <NSObject>

- (void)sdkAppModalViewControllerShouldDismiss:(AppNexusSDKAppModalViewController *)controller;

@end