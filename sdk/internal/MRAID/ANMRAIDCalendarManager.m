/*   Copyright 2014 APPNEXUS INC
 
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

#import "ANMRAIDCalendarManager.h"
#import <EventKit/EventKit.h>
#import "ANLogging.h"
#import "ANGlobal.h"

@interface ANMRAIDCalendarManager () <EKEventEditViewDelegate>

@property (nonatomic, readwrite, strong) EKEventStore *eventStore;
@property (nonatomic, readwrite, strong) NSDictionary *calendarDict;
@property (nonatomic, readwrite, weak) EKEventEditViewController *eventEditController;

@end

@implementation ANMRAIDCalendarManager

- (instancetype)initWithCalendarDictionary:(NSDictionary *)dict
                                  delegate:(id<ANMRAIDCalendarManagerDelegate>)delegate {
    if (self = [super init]) {
        _calendarDict = dict;
        _delegate = delegate;
        [self requestAccessFromUserForCalendarAccess];
    }
    return self;
}

- (EKEventStore *)eventStore {
    if (!_eventStore) _eventStore = [[EKEventStore alloc] init];
    return _eventStore;
}

- (void)requestAccessFromUserForCalendarAccess {
    __weak ANMRAIDCalendarManager *weakSelf = self;
    [self.eventStore requestAccessToEntityType:EKEntityTypeEvent
                                    completion:^(BOOL granted, NSError *error) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            ANMRAIDCalendarManager *strongSelf = weakSelf;
                                            if (granted) {
                                                [strongSelf setupCalendarUI];
                                            } else if (error) {
                                                ANLogError(@"MRAID creative requested calendar access, received error: %@", error);
                                            } else {
                                                ANLogError(@"MRAID creative requested calendar access, but access was denied.");
                                            }
                                            
                                            if (!granted) {
                                                if ([strongSelf.delegate respondsToSelector:@selector(calendarManager:calendarEditFailedWithErrorString:)]) {
                                                    [strongSelf.delegate calendarManager:strongSelf calendarEditFailedWithErrorString:@"User did not grant access to calendar"];
                                                }
                                            }
                                        });
                                    }];
}

- (void)setupCalendarUI {
    UIViewController *rvc = [self.delegate rootViewControllerForPresentationForCalendarManager:self];
    if (!ANCanPresentFromViewController(rvc)) {
        ANLogDebug(@"No root view controller provided, or root view controller view not attached to window - could not add event to calendar");
        if ([self.delegate respondsToSelector:@selector(calendarManager:calendarEditFailedWithErrorString:)]) {
            [self.delegate calendarManager:self calendarEditFailedWithErrorString:@"Could not present Calendar UI"];
        }
        return;
    }
    EKEvent *event = [[self class] eventWithEventStore:self.eventStore
                                    jsonCalendarObject:self.calendarDict];
    EKEventEditViewController *eventEditController = [[EKEventEditViewController alloc] init];
    eventEditController.eventStore = self.eventStore;
    eventEditController.editViewDelegate = self;
    eventEditController.event = event;
    self.eventEditController = eventEditController;
    if ([self.delegate respondsToSelector:@selector(willPresentCalendarEditForCalendarManager:)]) {
        [self.delegate willPresentCalendarEditForCalendarManager:self];
    }
    __weak ANMRAIDCalendarManager *weakSelf = self;
    [rvc presentViewController:eventEditController
                      animated:YES
                    completion:^{
                        ANMRAIDCalendarManager *strongSelf = weakSelf;
                        if ([strongSelf.delegate respondsToSelector:@selector(didPresentCalendarEditForCalendarManager:)]) {
                            [strongSelf.delegate didPresentCalendarEditForCalendarManager:strongSelf];
                        }
                    }];
}

- (void)dealloc {
    self.eventEditController.delegate = nil;
}

#pragma mark - EKEventEditViewDelegate

- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action {
    if (action != EKEventEditViewActionSaved) {
        if ([self.delegate respondsToSelector:@selector(calendarManager:calendarEditFailedWithErrorString:)]) {
            [self.delegate calendarManager:self calendarEditFailedWithErrorString:@"User did not save event"];
        }
    }
    if ([self.delegate respondsToSelector:@selector(willDismissCalendarEditForCalendarManager:)]) {
        [self.delegate willDismissCalendarEditForCalendarManager:self];
    }
    __weak ANMRAIDCalendarManager *weakSelf = self;
    [controller dismissViewControllerAnimated:YES
                                   completion:^{
                                       ANMRAIDCalendarManager *strongSelf = weakSelf;
                                       if ([strongSelf.delegate respondsToSelector:@selector(didDismissCalendarEditForCalendarManager:)]) {
                                           [strongSelf.delegate didDismissCalendarEditForCalendarManager:strongSelf];
                                       }
                                   }];
}

#pragma mark - Basic Event Generation

+ (EKEvent *)eventWithEventStore:(EKEventStore *)eventStore
              jsonCalendarObject:(NSDictionary *)calendarObject {
    EKEvent *event = [EKEvent eventWithEventStore:eventStore];
    
    event.title = [calendarObject[@"description"] description];
    event.notes = [calendarObject[@"summary"] description];
    event.location = [calendarObject[@"location"] description];
    event.calendar = [eventStore defaultCalendarForNewEvents];
    event.startDate = [[self class] dateWithDateFormattersOrAsEpochTimestampForString:[calendarObject[@"start"] description]];
    NSDate *endDate = [[self class] dateWithDateFormattersOrAsEpochTimestampForString:[calendarObject[@"end"] description]];
    if (!endDate) {
        endDate = [event.startDate dateByAddingTimeInterval:3600];
    }
    event.endDate = endDate;
    
    ANLogDebug(@"Event start date: %@", event.startDate);
    ANLogDebug(@"Event end date: %@", event.endDate);
    
    EKAlarm *reminder = [[self class] alarmWithReminderString:[calendarObject[@"reminder"] description]];
    if (reminder) {
        [event addAlarm:reminder];
    }
    
    id recurrenceObject = calendarObject[@"recurrence"];
    if ([recurrenceObject isKindOfClass:[NSDictionary class]]) {
        EKRecurrenceRule *recurrenceRule = [[self class] recurrenceRuleForRecurrence:(NSDictionary *)recurrenceObject];
        if (recurrenceRule) {
            [event addRecurrenceRule:recurrenceRule];
        }
    }
    
    return event;
}

// Read-only property
+ (EKEventStatus)eventStatusForStatus:(NSString *)status {
    if ([status isEqualToString:@"tentative"]) {
        return EKEventStatusTentative;
    } else if ([status isEqualToString:@"confirmed"]) {
        return EKEventStatusConfirmed;
    } else if ([status isEqualToString:@"cancelled"]) {
        return EKEventStatusCanceled;
    }
    
    return EKEventStatusNone;
}

+ (EKAlarm *)alarmWithReminderString:(NSString *)reminder {
    if (!reminder.length) {
        return nil;
    }
    
    NSDate *date = [[self class] dateWithDateFormattersForDateString:reminder];
    if (date) {
        return [EKAlarm alarmWithAbsoluteDate:date];
    } else {
        return [EKAlarm alarmWithRelativeOffset:([reminder doubleValue] / 1000.0)];
    }
}

#pragma mark - Event Recurrences

+ (EKRecurrenceRule *)recurrenceRuleForRecurrence:(NSDictionary *)recurrence {
    EKRecurrenceFrequency frequency = [[self class] recurrenceFrequencyForFrequency:[recurrence[@"frequency"] description]];
    NSInteger interval = [[self class] intervalForIntervalString:[recurrence[@"interval"] description]];
    EKRecurrenceEnd *end = [[self class] recurrenceEndForExpires:[recurrence[@"expires"] description]];
    
    NSArray *daysOfTheWeek = nil;
    NSArray *daysOfTheMonth = nil;
    NSArray *monthsOfTheYear = nil;
    NSArray *daysOfTheYear = nil;
    
    id daysInWeekObject = recurrence[@"daysInWeek"];
    if ([daysInWeekObject isKindOfClass:[NSArray class]]) {
        daysOfTheWeek = [[self class] EKRecurrenceDaysOfTheWeekArrayForDaysInWeekArray:(NSArray *)daysInWeekObject];
    }
    
    id daysInMonthObject = recurrence[@"daysInMonth"];
    if ([daysInMonthObject isKindOfClass:[NSArray class]]) {
        daysOfTheMonth = [[self class] EKRecurrenceDaysOfTheMonthArrayForDaysInMonthArray:(NSArray *)daysInMonthObject];
    }

    id weeksInMonthObject = recurrence[@"weeksInMonth"];
    if ([weeksInMonthObject isKindOfClass:[NSArray class]]) {
        NSArray *updatedDaysOfTheWeek = [[self class] updatedEKRecurrenceDaysOfTheWeekArrayForWeeksInMonthArray:(NSArray *)weeksInMonthObject
                                                                                 EKRecurrenceDaysOfTheWeekArray:daysOfTheWeek];
        if (updatedDaysOfTheWeek) {
            daysOfTheWeek = updatedDaysOfTheWeek;
        }
    }
    
    id monthsInYearObject = recurrence[@"monthsInYear"];
    if ([monthsInYearObject isKindOfClass:[NSArray class]]) {
        monthsOfTheYear = [[self class] EKRecurrenceMonthsOfTheYearArrayForMonthsInYearArray:(NSArray *)monthsInYearObject];
    }
    
    id daysInYearObject = recurrence[@"daysInYear"];
    if ([daysInYearObject isKindOfClass:[NSArray class]]) {
        daysOfTheYear = [[self class] EKRecurrenceDaysOfTheYearArrayForDaysInYearArray:(NSArray *)daysInYearObject];
    }
    
    return [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:frequency
                                                        interval:interval
                                                   daysOfTheWeek:daysOfTheWeek
                                                  daysOfTheMonth:daysOfTheMonth
                                                 monthsOfTheYear:monthsOfTheYear
                                                  weeksOfTheYear:nil
                                                   daysOfTheYear:daysOfTheYear
                                                    setPositions:nil
                                                             end:end];
}

+ (NSInteger)intervalForIntervalString:(NSString *)intervalString {
    if (!intervalString.length) {
        return 1;
    }
    NSInteger interval = [intervalString integerValue];
    if (interval < 1) {
        interval = 1;
    }
    return interval;
}

+ (EKRecurrenceFrequency)recurrenceFrequencyForFrequency:(NSString *)frequency {
    if ([frequency isEqualToString:@"daily"]) {
        return EKRecurrenceFrequencyDaily;
    } else if ([frequency isEqualToString:@"weekly"]) {
        return EKRecurrenceFrequencyWeekly;
    } else if ([frequency isEqualToString:@"monthly"]) {
        return EKRecurrenceFrequencyMonthly;
    } else if ([frequency isEqualToString:@"yearly"]) {
        return EKRecurrenceFrequencyYearly;
    }

    return -1;
}

+ (EKRecurrenceEnd *)recurrenceEndForExpires:(NSString *)expires {
    if (!expires.length) {
        return nil;
    }
    
    NSDate *date = [[self class] dateWithDateFormattersOrAsEpochTimestampForString:expires];
    if (date) {
        return [EKRecurrenceEnd recurrenceEndWithEndDate:date];
    }
    return nil;
}

+ (NSArray *)EKRecurrenceDaysOfTheWeekArrayForDaysInWeekArray:(NSArray *)daysInWeek {
    if (!daysInWeek.count) {
        return nil;
    }
    
    NSMutableArray *ekRecurrenceDaysOfWeekArray = [[NSMutableArray alloc] init];
    [daysInWeek enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSInteger dayInWeek = [obj integerValue];
        if (dayInWeek >= 0 && dayInWeek <= 6) {
            [ekRecurrenceDaysOfWeekArray addObject:[EKRecurrenceDayOfWeek dayOfWeek:dayInWeek+1]];
        } else {
            ANLogDebug(@"MRAID creative passed invalid W3 day of week: %ld", (long)dayInWeek);
        }
    }];
    return [ekRecurrenceDaysOfWeekArray copy];
}

+ (NSArray *)EKRecurrenceDaysOfTheMonthArrayForDaysInMonthArray:(NSArray *)daysInMonth {
    if (!daysInMonth.count) {
        return nil;
    }
    
    NSMutableArray *ekRecurrenceDaysOfMonthArray = [[NSMutableArray alloc] init];
    [daysInMonth enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSInteger dayInMonth = [obj integerValue];
        
        if (dayInMonth >= -30 && dayInMonth <= 31) {
            if (dayInMonth <= 0) {
                dayInMonth = dayInMonth - 1;
            }
            [ekRecurrenceDaysOfMonthArray addObject:@(dayInMonth)];
        } else {
            ANLogDebug(@"MRAID creative passed invalid W3 day of month: %ld", (long)dayInMonth);
            return;
        }
    }];
    return [ekRecurrenceDaysOfMonthArray copy];
}

+ (NSArray *)updatedEKRecurrenceDaysOfTheWeekArrayForWeeksInMonthArray:(NSArray *)weeksInMonth
                                        EKRecurrenceDaysOfTheWeekArray:(NSArray *)daysOfTheWeek {
    if (!weeksInMonth.count) {
        return daysOfTheWeek;
    }
    
    NSMutableArray *ekRecurrenceDaysOfWeekArray = [[NSMutableArray alloc] init];
    [weeksInMonth enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        __block NSInteger weekNumber = [obj integerValue];
        if (weekNumber >= -3 && weekNumber <= 4) {
            [daysOfTheWeek enumerateObjectsUsingBlock:^(EKRecurrenceDayOfWeek *dayOfWeek, NSUInteger idx, BOOL *stop) {
                if (weekNumber <= 0) {
                    weekNumber = weekNumber - 1;
                }
                [ekRecurrenceDaysOfWeekArray addObject:[EKRecurrenceDayOfWeek dayOfWeek:dayOfWeek.dayOfTheWeek
                                                                             weekNumber:weekNumber]];
            }];
        } else {
            ANLogDebug(@"MRAID creative passed invalid W3 week in month: %ld", (long)weekNumber);
        }
    }];
    return [ekRecurrenceDaysOfWeekArray copy];
}

+ (NSArray *)EKRecurrenceDaysOfTheYearArrayForDaysInYearArray:(NSArray *)daysInYear {
    if (!daysInYear.count) {
        return nil;
    }
    
    NSMutableArray *ekRecurrenceDaysOfYearArray = [[NSMutableArray alloc] init];
    [daysInYear enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSInteger dayInYear = [obj integerValue];
        if (dayInYear >= -364 && dayInYear <= 365) {
            if (dayInYear <= 0) {
                dayInYear = dayInYear - 1;
            }
            [ekRecurrenceDaysOfYearArray addObject:@(dayInYear)];
        }
    }];
    return ekRecurrenceDaysOfYearArray;
}

+ (NSArray *)EKRecurrenceMonthsOfTheYearArrayForMonthsInYearArray:(NSArray *)monthsInYear {
    if (!monthsInYear.count) {
        return nil;
    }
    
    NSMutableArray *ekRecurrenceMonthsOfYearArray = [[NSMutableArray alloc] init];
    [monthsInYear enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSInteger monthInYear = [obj integerValue];
        if (monthInYear > 0 && monthInYear <= 12) {
            [ekRecurrenceMonthsOfYearArray addObject:@(monthInYear)];
        }
    }];
    return ekRecurrenceMonthsOfYearArray;
}

#pragma mark - Helper methods

+ (NSDate *)dateWithDateFormattersOrAsEpochTimestampForString:(NSString *)dateString {
    if (!dateString.length) {
        return nil;
    }
    
    NSDate *date = [[self class] dateWithDateFormattersForDateString:dateString];
    if (!date) {
        date = [NSDate dateWithTimeIntervalSince1970:[dateString doubleValue]];
    }
    return date;
}

+ (NSDate *)dateWithDateFormattersForDateString:(NSString *)dateString {
    if (!dateString.length) {
        return nil;
    }
    
    NSDate *date = [[[self class] sharedDateFormatter1] dateFromString:dateString];
    if (!date) {
        date = [[[self class] sharedDateFormatter2] dateFromString:dateString];
    }

    return date;
}

+ (NSDateFormatter *)sharedDateFormatter1 {
    static NSDateFormatter *dateFormatter1;
    static dispatch_once_t dateFormatter1Token;
    dispatch_once(&dateFormatter1Token, ^{
        dateFormatter1 = [[NSDateFormatter alloc] init];
        dateFormatter1.dateFormat = @"yyyy-MM-dd'T'HH:mmZZZZZ";
    });
    return dateFormatter1;
}

+ (NSDateFormatter *)sharedDateFormatter2 {
    static NSDateFormatter *dateFormatter2;
    static dispatch_once_t dateFormatter2Token;
    dispatch_once(&dateFormatter2Token, ^{
        dateFormatter2 = [[NSDateFormatter alloc] init];
        dateFormatter2.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
    });
    return dateFormatter2;
}

@end