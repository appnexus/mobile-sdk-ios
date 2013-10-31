/*   Copyright 2013 APPNEXUS INC
 
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

#import "DebugSettingsTVC.h"
#import "DebugOutputViewController.h"
#import "ANAdFetcher.h"
#import "AdSettings.h"
#import "ANRequest+Make.h"
#import "ANResponse.h"
#import "ANLogging.h"

#define REQUEST_NOTIFICATION @"AppNexusSDKAppViewControllerUpdatedRequest"

@interface DebugSettingsTVC ()
@property (weak, nonatomic) IBOutlet UITextView *requestURL;
@property (weak, nonatomic) IBOutlet UITextView *serverResponse;

@property (strong, nonatomic) NSDictionary *textAttributes;

@end

@implementation DebugSettingsTVC

- (void)requestChangedNotification:(NSNotification *)notification {
    [self reloadRequest];
}

- (void)reloadRequest {
    ANLogDebug(@"%@ %@",  NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    ANRequest *request = [ANRequest lastRequestMadeInManagedObjectContext:self.managedObjectContext];
    if (request) {
        self.requestURL.attributedText = [[NSAttributedString alloc] initWithString:request.text
                                                                         attributes:self.textAttributes];
        NSString *responseText;
        
        if (request.response) {
            responseText = request.response.text;
            NSError *jsonError = nil;
            id JSONObject = [NSJSONSerialization JSONObjectWithData:[responseText dataUsingEncoding:NSUTF8StringEncoding]
                                                            options:NSJSONReadingMutableContainers
                                                              error:&jsonError];
            if (!jsonError) {
                NSData* jsonData = [NSJSONSerialization dataWithJSONObject:JSONObject
                                                                   options:NSJSONWritingPrettyPrinted
                                                                     error:&jsonError];
                responseText = [[NSString alloc] initWithData:jsonData
                                                     encoding:NSUTF8StringEncoding];
                
                ANLogDebug(@"%@ %@ | JSON id object: \n%@",  NSStringFromClass([self class]), NSStringFromSelector(_cmd), responseText);
            }
        } else {
            responseText = @"";
        }
        
        self.serverResponse.attributedText = [[NSAttributedString alloc] initWithString:responseText
                                                                             attributes:self.textAttributes];
        [self.update setRequestURL:self.requestURL.text withServerResponse:self.serverResponse.text];
        [self.tableView reloadData];
    }
}

- (void)setup {
    self.requestURL.scrollEnabled = NO;
    self.serverResponse.scrollEnabled = YES;
    [self setTextAttributes];
    [self reloadRequest];
}

- (void)setTextAttributes {
    UIFont *font = [UIFont fontWithName:TEXT_FONT size:[UIFont systemFontSize]];
    NSMutableParagraphStyle *pstyle = [[NSMutableParagraphStyle alloc] init];
    pstyle.lineBreakMode = NSLineBreakByCharWrapping;
    
    self.textAttributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:pstyle};
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadRequest];
    [self addAsRequestNotificationObserver];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removeAsRequestNotificationObserver];
}

- (void)addAsRequestNotificationObserver {
    ANLogDebug(@"%@ %@",  NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(requestChangedNotification:)
                                                 name:REQUEST_NOTIFICATION
                                               object:nil];
}

- (void)removeAsRequestNotificationObserver {
    ANLogDebug(@"%@ %@",  NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:REQUEST_NOTIFICATION
                                                  object:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSAttributedString *textToSize = indexPath.section ? self.serverResponse.attributedText : self.requestURL.attributedText;
    
    CGRect rect = [textToSize boundingRectWithSize:CGSizeMake(self.tableView.frame.size.width, CGFLOAT_MAX)
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                           context:nil];

    return CELL_TEXT_FACTOR * (rect.size.height + CGFLOAT_TOP_INSET + CGFLOAT_BOT_INSET);
}

@end
