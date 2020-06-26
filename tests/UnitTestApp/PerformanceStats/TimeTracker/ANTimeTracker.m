/*   Copyright 2020 APPNEXUS INC

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


#import "ANTimeTracker.h"


@interface ANTimeTracker()
@property (nonatomic, readwrite, strong, nullable) NSDate *lastTime;
@property (nonatomic, readwrite, strong, nullable) NSString *lastTimeAt;
@property (nonatomic, readwrite) float timeTaken;



@end


@implementation ANTimeTracker



+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static ANTimeTracker *timeTrackerObject;
    dispatch_once(&onceToken, ^{
        timeTrackerObject = [[ANTimeTracker alloc] init];
    });
    return timeTrackerObject;
}


- (void) getDiffereanceAt:(NSString *_Nonnull)timeAt{
    NSDate *currentDate= [NSDate date];
    
    float timeDiffrance = [currentDate timeIntervalSinceReferenceDate] - [self.lastTime timeIntervalSinceReferenceDate];
     
    NSLog(@"%@",[NSString stringWithFormat:@"Differance Between %@ - %@ = %f  ",self.lastTimeAt , timeAt , timeDiffrance*1000]);
    
    self.timeTaken = timeDiffrance*1000 ;
    self.lastTime = currentDate;
    self.lastTimeAt = timeAt;
}

- (void) setTimeAt:(NSString *)atValue{
    self.lastTimeAt = atValue;
    self.lastTime = [NSDate date];
}




+(void)saveSet:(NSString*)testCaseName date:(NSDate *)date loadTime:(float)value
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
   NSMutableArray * arrayOfTime = [[ANTimeTracker getData:testCaseName] mutableCopy];
    if(arrayOfTime.count > 10){
        [arrayOfTime removeObjectAtIndex:0];
    }else if (arrayOfTime == nil){
        arrayOfTime = [[NSMutableArray alloc] init];
    }
    
    NSDictionary *data = @{
        @"date" : [NSDate date].description,
        @"Testcase" : testCaseName,
        @"loadTime" : [NSString stringWithFormat:@"%f",value]
        
    };
    
    [arrayOfTime addObject:data];
    [standardUserDefaults setObject:arrayOfTime forKey:testCaseName];
    [standardUserDefaults synchronize];
}


+(NSArray *)getData:(NSString*)testCaseName
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
   
    NSArray *arrayOfTime = [standardUserDefaults objectForKey:testCaseName];
    return arrayOfTime;
}
-(float) getTimeTakenByWebview{
    return ([self.webViewFinishLoadingAt timeIntervalSinceReferenceDate] - [self.webViewInitLoadingAt timeIntervalSinceReferenceDate]) * 1000;

}
-(void)clearTimeTracker{
    self.lastTime = NULL;
    self.lastTimeAt = NULL;
    self.timeTaken = 0;
    self.webViewInitLoadingAt = NULL;
    self.webViewFinishLoadingAt = NULL;
    
}

-(float) getTimeTakenByNetworkCall{
    return ([self.networkAdRequestComplete timeIntervalSinceReferenceDate] - [self.networkAdRequestInit timeIntervalSinceReferenceDate]) * 1000;

}

@end
