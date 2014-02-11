//
//  CustomKeywordsTVC.m
//  AppNexusSDKApp
//
//  Created by Jose Cabal-Ugaz on 2/10/14.
//  Copyright (c) 2014 AppNexus. All rights reserved.
//

#import "CustomKeywordsTVC.h"
#import "AdSettings.h"
#import "AddCustomKeywordViewController.h"

static NSString *const CellIdentifier = @"customKeywordCell";

@interface CustomKeywordsTVC () <AddCustomKeywordToPersistentStoreDelegate>

@property (nonatomic, strong) NSArray *orderedKeys;
@property (nonatomic, strong) NSDictionary *customKeywords;
@property (nonatomic, strong) AdSettings *persistentSettings;

@end

@implementation CustomKeywordsTVC

- (void)viewDidLoad {
    [self setEditBarButtonItemOnNavigationItem];
}

- (NSArray *)orderedKeys {
    if (!_orderedKeys) _orderedKeys = [[self customKeywords] keysSortedByValueUsingSelector:@selector(caseInsensitiveCompare:)];
    return _orderedKeys;
}

- (NSDictionary *)customKeywords {
    if (!_customKeywords) _customKeywords = [self.persistentSettings customKeywords];
    return _customKeywords;
}

- (AdSettings *)persistentSettings {
    if (!_persistentSettings) _persistentSettings = [[AdSettings alloc] init];
    return _persistentSettings;
}

#pragma mark Bar Button Items

- (void)setDoneBarButtonItemOnNavigationItem {
    UIBarButtonItem *newItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                             target:self
                                                                             action:@selector(finishedEditTableViewItems:)];
    self.navigationItem.leftBarButtonItem = newItem;
}

- (void)setEditBarButtonItemOnNavigationItem {
    UIBarButtonItem *newItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CircleMinus"]
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(editTableViewItems:)];
    self.navigationItem.leftBarButtonItem = newItem;
}

- (IBAction)editTableViewItems:(UIBarButtonItem *)sender {
    if ([self.customKeywords count] > 0) {
        [self setEditing:YES animated:YES];
        [self setDoneBarButtonItemOnNavigationItem];
    }
}

- (void)finishedEditTableViewItems:(UIBarButtonItem *)item {
    [self setEditing:NO animated:YES];
    [self setEditBarButtonItemOnNavigationItem];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.customKeywords count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSString *key = [self.orderedKeys objectAtIndex:indexPath.item];
    NSString *value = [self.customKeywords objectForKey:key];
    [[cell textLabel] setText:key];
    [[cell detailTextLabel] setText:value];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteCustomKeywordAtIndexPath:indexPath];
    }
}

- (void)deleteCustomKeywordAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary *mutableDict = [[self customKeywords] mutableCopy];
    NSString *key = [self.orderedKeys objectAtIndex:indexPath.item];
    [mutableDict removeObjectForKey:key];
    self.persistentSettings.customKeywords = [mutableDict copy];
    self.customKeywords = nil;
    self.orderedKeys = nil;
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[AddCustomKeywordViewController class]]) {
        AddCustomKeywordViewController *destinationVC = (AddCustomKeywordViewController *)segue.destinationViewController;
        destinationVC.delegate = self;
        if ([sender isKindOfClass:[UITableViewCell class]]) {
            UITableViewCell *cell = (UITableViewCell *)sender;
            destinationVC.existingKey = [cell.textLabel text];
            destinationVC.existingValue = [cell.detailTextLabel text];
        }
    }
}

#pragma mark AddCustomKeywordToPersistentStoreDelegate methods

- (void)addCustomKeywordWithKey:(NSString *)key andValue:(NSString *)value {
    NSMutableDictionary *mutableDict = [[self customKeywords] mutableCopy];
    [mutableDict setObject:value forKey:key];
    self.persistentSettings.customKeywords = [mutableDict copy];
    self.customKeywords = nil;
    self.orderedKeys = nil;
    [self.tableView reloadData];
}

- (void)deleteCustomKeywordWithKey:(NSString *)key {
    NSMutableDictionary *mutableDict = [[self customKeywords] mutableCopy];
    [mutableDict removeObjectForKey:key];
    self.persistentSettings.customKeywords = [mutableDict copy];
    self.customKeywords = nil;
    self.orderedKeys = nil;
}

@end
