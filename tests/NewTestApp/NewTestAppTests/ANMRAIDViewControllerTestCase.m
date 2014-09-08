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

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "ANMRAIDViewController.h"

@interface ANMRAIDViewControllerTestCase : XCTestCase

@property (nonatomic, readwrite, strong) ANMRAIDViewController *viewController;

@end

@implementation ANMRAIDViewControllerTestCase

- (void)testExample {
    self.viewController = [[ANMRAIDViewController alloc] init];
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300.0f, 250.0f)];
    self.viewController.contentView = contentView;
    [self.viewController.view addSubview:contentView];
    self.viewController.contentView.opaque = NO;
    self.viewController.contentView.backgroundColor = [UIColor greenColor];
    self.viewController.allowOrientationChange = NO;
    self.viewController.orientation = UIInterfaceOrientationPortrait;
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"ANMRAIDViewController presented"];
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    [rootViewController presentViewController:self.viewController
                                     animated:YES
                                   completion:^{
                                       XCTAssert(CGRectEqualToRect(contentView.frame, self.viewController.view.frame));
                                       [expectation fulfill];
                                   }];

    [self waitForExpectationsWithTimeout:5.0f
                                 handler:nil];
}

@end