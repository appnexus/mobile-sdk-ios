//
//  ANRealTimerTestCase.m
//  FunctionalTests
//
//  Created by Punnaghai Puviarasu on 3/1/21.
//  Copyright © 2021 AppNexus. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ANRealTimer.h"
#import "ANSDKSettings.h"
#import "XCTestCase+ANCategory.h"

@interface ANRealTimerTestCase : XCTestCase <ANRealTimerDelegate>
@property (nonatomic, strong) XCTestExpectation *loadAdSuccesfulException;
@property (nonatomic, readwrite, assign)  BOOL       oneSecTimerNotification;
@end

@implementation ANRealTimerTestCase

- (void)setUp {
    self.loadAdSuccesfulException = nil;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handle1SecTimerSentNotification)
                                                 name:@"kTimerNotification"
                                               object:nil];
    self.oneSecTimerNotification = NO;
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testSetTimerFor1Sec{
   //ANSDKSettings.sharedInstance.countImpressionOn1PxRendering = YES;
   [ANRealTimer addDelegate:self];
    
   self.loadAdSuccesfulException = [self expectationWithDescription:@"Timer Exception"];
   
   [self waitForExpectationsWithTimeout:10 handler:nil];
   XCTAssertTrue(self.oneSecTimerNotification);
    
}

- (void)handle1SecTimerSentNotification { 
    self.oneSecTimerNotification = YES;
    [ANRealTimer removeDelegate:self];
    [self.loadAdSuccesfulException fulfill];
}

@end
