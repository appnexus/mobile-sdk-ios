//
//  AddCustomKeywordViewController.h
//  AppNexusSDKApp
//
//  Created by Jose Cabal-Ugaz on 2/10/14.
//  Copyright (c) 2014 AppNexus. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddCustomKeywordToPersistentStoreDelegate;

@interface AddCustomKeywordViewController : UIViewController

@property (strong, nonatomic) id<AddCustomKeywordToPersistentStoreDelegate> delegate;
@property (strong, nonatomic) NSString *existingKey;
@property (strong, nonatomic) NSString *existingValue;

@end

@protocol AddCustomKeywordToPersistentStoreDelegate <NSObject>

- (void)addCustomKeywordWithKey:(NSString *)key andValue:(NSString *)value;
- (void)deleteCustomKeywordWithKey:(NSString *)key;

@end