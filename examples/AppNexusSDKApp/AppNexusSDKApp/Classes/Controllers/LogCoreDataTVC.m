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
#import "ANLog+Make.h"

#define CLASS_NAME @"LogCoreDataTVC"
#define EMAIL_MAX_LOGS 1000

@interface LogCoreDataTVC ()

@property (nonatomic, strong) NSDictionary *textAttributes;

// For color-coding
@property (nonatomic, strong) NSDictionary *errorTextAttributes;
@property (nonatomic, strong) NSDictionary *warningTextAttributes;
@property (nonatomic, strong) NSDictionary *debugTextAttributes;
@property (nonatomic, strong) NSDictionary *infoTextAttributes;
@property (nonatomic, strong) NSDictionary *tracetextAttributes;

@property (nonatomic, strong) UIColor *kAppNexusSDKAppLogLevelErrorColor;
@property (nonatomic, strong) UIColor *kAppNexusSDKAppLogLevelWarnColor;
@property (nonatomic, strong) UIColor *kAppNexusSDKAppLogLevelDebugColor;
@property (nonatomic, strong) UIColor *kAppNexusSDKAppLogLevelInfoColor;
@property (nonatomic, strong) UIColor *kAppNexusSDKAppLogLevelTraceColor;

@end

@implementation LogCoreDataTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (NSDictionary *)textAttributes {
    if (!_textAttributes) {
        UIFont *font = [UIFont fontWithName:TEXT_FONT size:[UIFont systemFontSize]];
        NSMutableParagraphStyle *pstyle = [[NSMutableParagraphStyle alloc] init];
        pstyle.lineBreakMode = NSLineBreakByCharWrapping;
        _textAttributes = @{NSFontAttributeName:font,
                            NSParagraphStyleAttributeName:pstyle};
    }
    return _textAttributes;
}

- (NSDictionary *)errorTextAttributes {
    if (!_errorTextAttributes) _errorTextAttributes = [[self class] setColor:[self kAppNexusSDKAppLogLevelErrorColor]
                                                           forTextAttributes:self.textAttributes];
    return _errorTextAttributes;
}

- (NSDictionary *)warningTextAttributes {
    if (!_warningTextAttributes) _warningTextAttributes = [[self class] setColor:[self kAppNexusSDKAppLogLevelWarnColor]
                                                               forTextAttributes:self.textAttributes];
    return _warningTextAttributes;
}

- (NSDictionary *)debugTextAttributes {
    if (!_debugTextAttributes) _debugTextAttributes = [[self class] setColor:[self kAppNexusSDKAppLogLevelDebugColor]
                                                           forTextAttributes:self.textAttributes];
    return _debugTextAttributes;
}

- (NSDictionary *)infoTextAttributes {
    if (!_infoTextAttributes) _infoTextAttributes = [[self class] setColor:[self kAppNexusSDKAppLogLevelInfoColor]
                                                         forTextAttributes:self.textAttributes];
    return _infoTextAttributes;
}

- (NSDictionary *)tracetextAttributes {
    if (!_tracetextAttributes) _tracetextAttributes = [[self class] setColor:[self kAppNexusSDKAppLogLevelTraceColor]
                                                               forTextAttributes:self.textAttributes];
    return _tracetextAttributes;
}

- (UIColor *)kAppNexusSDKAppLogLevelErrorColor {
    if (!_kAppNexusSDKAppLogLevelErrorColor) _kAppNexusSDKAppLogLevelErrorColor = [UIColor redColor]; // RGB(255,0,0)
    return _kAppNexusSDKAppLogLevelErrorColor;
}

- (UIColor *)kAppNexusSDKAppLogLevelWarnColor {
    if (!_kAppNexusSDKAppLogLevelWarnColor) _kAppNexusSDKAppLogLevelWarnColor = [UIColor colorWithRed:1.0f green:0.5f blue:0.0f alpha:1]; // RGB(255,127,0)
    return _kAppNexusSDKAppLogLevelWarnColor;
}

- (UIColor *)kAppNexusSDKAppLogLevelDebugColor {
    if (!_kAppNexusSDKAppLogLevelDebugColor) _kAppNexusSDKAppLogLevelDebugColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.5f alpha:1]; // RGB(0,0,127)
    return _kAppNexusSDKAppLogLevelDebugColor;
}

- (UIColor *)kAppNexusSDKAppLogLevelInfoColor {
    if (!_kAppNexusSDKAppLogLevelInfoColor) _kAppNexusSDKAppLogLevelInfoColor = [UIColor colorWithRed:0.0f green:0.5f blue:0.0f alpha:1]; // RGB(0,127,0)
    return _kAppNexusSDKAppLogLevelInfoColor;
}

- (UIColor *)kAppNexusSDKAppLogLevelTraceColor {
    if (!_kAppNexusSDKAppLogLevelTraceColor) _kAppNexusSDKAppLogLevelTraceColor = [UIColor blackColor]; //RGB(0,0,0)
    return _kAppNexusSDKAppLogLevelTraceColor;
}

+ (NSDictionary *)setColor:(UIColor *)color forTextAttributes:(NSDictionary *)attributes {
    NSMutableDictionary *mutableAttributes = [attributes mutableCopy];
    [mutableAttributes setObject:color forKey:NSForegroundColorAttributeName];
    return [mutableAttributes copy];
}

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
                                                                                  sectionNameKeyPath:@"processID"
                                                                                           cacheName:nil];
        } else {
            self.fetchedResultsController = nil;
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    self.fetchedResultsController = nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    ANLog *log = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSAttributedString *logAttrText = [[NSAttributedString alloc] initWithString:log.text
                                                                      attributes:self.textAttributes];
    CGRect textRect = [logAttrText boundingRectWithSize:CGSizeMake(self.tableView.frame.size.width, CGFLOAT_MAX)
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                                context:nil];
    
    return CELL_TEXT_FACTOR * (textRect.size.height + CGFLOAT_TOP_INSET + CGFLOAT_BOT_INSET);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ANLogCell"];
    if ([[cell.contentView.subviews objectAtIndex:0] isKindOfClass:[UITextView class]]) {
        UITextView *tv = [cell.contentView.subviews objectAtIndex:0];
        ANLog *log = [self.fetchedResultsController objectAtIndexPath:indexPath];
        tv.attributedText = [self attributedStringForANLog:log];
        tv.scrollEnabled = NO;
    }
    return cell;
}

- (NSAttributedString *)attributedStringForANLog:(ANLog *)log {
    if ([log.name isEqualToString:kAppNexusSDKAppLogLevelDebug]) {
        return [[NSAttributedString alloc] initWithString:log.text
                                               attributes:self.debugTextAttributes];
    } else if ([log.name isEqualToString:kAppNexusSDKAppLogLevelWarn]) {
        return [[NSAttributedString alloc] initWithString:log.text
                                               attributes:self.warningTextAttributes];
    } else if ([log.name isEqualToString:kAppNexusSDKAppLogLevelError]) {
        return [[NSAttributedString alloc] initWithString:log.text
                                               attributes:self.errorTextAttributes];
    } else if ([log.name isEqualToString:kAppNexusSDKAppLogLevelInfo]) {
        return [[NSAttributedString alloc] initWithString:log.text
                                               attributes:self.infoTextAttributes];
    } else {
        return [[NSAttributedString alloc] initWithString:log.text
                                               attributes:self.tracetextAttributes];
    }
}

- (NSString *)fullTextToEmail {
    _fullTextToEmail = @"";
    
    NSArray *fetchedResults = [self.fetchedResultsController fetchedObjects];
    int limitIndex = MIN([fetchedResults count], EMAIL_MAX_LOGS);
    for (int i = 0; i < limitIndex; i++) {
        ANLog *log = [fetchedResults objectAtIndex:i];
        _fullTextToEmail = [_fullTextToEmail stringByAppendingString:log.text];
        _fullTextToEmail = [_fullTextToEmail stringByAppendingString:@"\n"];
    }

    return _fullTextToEmail;
}

@end
