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

#import "LogCoreDataTVC.h"
#import "ANLog.h"
#import "ANLogging.h"

#define CLASS_NAME @"LogCoreDataTVC"

@interface LogCoreDataTVC ()

@property NSDictionary *textAttributes;

//@property (strong, nonatomic) UIFont *font;
//@property (strong, nonatomic) NSMutableParagraphStyle *pstyle;

@end

@implementation LogCoreDataTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
}

//- (void)viewDidAppear:(BOOL)animated {
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.fetchedResultsController) {
        if (self.managedObjectContext) {
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ANLog"];
            request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"datetime"
                                                                      ascending:NO]];
            [request setFetchLimit:FETCH_LIMIT];
            if (self.predicate) {
                request.predicate = [NSPredicate predicateWithFormat:self.predicate];
            }
            self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                                managedObjectContext:self.managedObjectContext
                                                                                  sectionNameKeyPath:nil
                                                                                           cacheName:nil];
        } else {
            self.fetchedResultsController = nil;
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    self.fetchedResultsController = nil;
}

- (void)setup {
    UIFont *font = [UIFont fontWithName:TEXT_FONT size:[UIFont systemFontSize]];
    NSMutableParagraphStyle *pstyle = [[NSMutableParagraphStyle alloc] init];
    pstyle.lineBreakMode = NSLineBreakByCharWrapping;
    self.textAttributes = @{NSFontAttributeName:font,
                            NSParagraphStyleAttributeName:pstyle};
    
    /*self.font = [UIFont fontWithName:TEXT_FONT size:[UIFont systemFontSize]];
    self.pstyle = [[NSMutableParagraphStyle alloc] init];
    self.pstyle.lineBreakMode = NSLineBreakByCharWrapping;
    self.debug = YES;*/
}

//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    ANLogDebug(@"%@ tableView: estimatedHeightForRowAtIndexPath", CLASS_NAME);
//    return UITableViewAutomaticDimension;
    
    /*CGRect textRect = [[self textAtIndexPath:indexPath] boundingRectWithSize:CGSizeMake(self.tableView.frame.size.width, CGFLOAT_MAX)
                                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                                     context:nil];
    return CELL_TEXT_FACTOR * (textRect.size.height + CGFLOAT_TOP_INSET + CGFLOAT_BOT_INSET);*/
//}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    ANLogDebug(@"%@ tableView: heightForRowAtIndexPath: indexPath %d", CLASS_NAME, indexPath.item);
//    CGRect textRect = [[self textAtIndexPath:indexPath] boundingRectWithSize:CGSizeMake(self.tableView.frame.size.width, CGFLOAT_MAX)
//                                                                     options:NSStringDrawingUsesLineFragmentOrigin
//                                                                     context:nil];
    ANLog *log = [self.fetchedResultsController objectAtIndexPath:indexPath];
//    CGRect textRect = [log.text boundingRectWithSize:CGSizeMake(self.tableView.frame.size.width, CGFLOAT_MAX)
//                                             options:NSStringDrawingUsesLineFragmentOrigin
//                                          attributes:@{NSFontAttributeName:self.font,
//                                                       NSParagraphStyleAttributeName:self.pstyle}
//                                             context:nil];
    
    NSAttributedString *logAttrText = [[NSAttributedString alloc] initWithString:log.text
                                                                      attributes:self.textAttributes];
    CGRect textRect = [logAttrText boundingRectWithSize:CGSizeMake(self.tableView.frame.size.width, CGFLOAT_MAX)
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                                context:nil];
    
    return CELL_TEXT_FACTOR * (textRect.size.height + CGFLOAT_TOP_INSET + CGFLOAT_BOT_INSET);
}

//- (NSAttributedString *)textAtIndexPath:(NSIndexPath *)indexPath {
//    ANLog *log = [self.fetchedResultsController objectAtIndexPath:indexPath];
//    return [[NSAttributedString alloc] initWithString:log.text
//                                           attributes:@{NSFontAttributeName:self.font,
//                                                        NSParagraphStyleAttributeName:self.pstyle}];
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ANLogDebug(@"%@ %@ | index path: %d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), indexPath.item);
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ANLogCell"];
    if ([[cell.contentView.subviews objectAtIndex:0] isKindOfClass:[UITextView class]]) {
        UITextView *tv = [cell.contentView.subviews objectAtIndex:0];
//        tv.attributedText = [self textAtIndexPath:indexPath];
        ANLog *log = [self.fetchedResultsController objectAtIndexPath:indexPath];
        tv.attributedText = [[NSAttributedString alloc] initWithString:log.text
                                                            attributes:self.textAttributes];
        tv.scrollEnabled = NO;
    }
    return cell;
}

@end
