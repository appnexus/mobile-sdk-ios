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

#import <XCTest/XCTest.h>
#import "ANMediationContainerView.h"
#import "XCTestCase+ANCategory.h"
#import "UIView+ANCategory.h"
#import "ANPBContainerView.h"
static NSTimeInterval const kUIViewConstraintsTestCaseFrameRefreshDelay = 0.05;

@interface ANContainerViewTestCase : XCTestCase

@end

@implementation ANContainerViewTestCase

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testANMediationDynamicWidthContainerView {
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 250)];
    ANMediationContainerView *containerView = [[ANMediationContainerView alloc] initWithMediatedView:contentView];
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootViewController.view addSubview:containerView];
    containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView an_constrainWithFrameSize];
    [XCTestCase delayForTimeInterval:kUIViewConstraintsTestCaseFrameRefreshDelay];
    XCTAssertEqual(containerView.frame.size.width, rootViewController.view.frame.size.width);
    XCTAssertEqual(containerView.frame.size.height, 250);
}

- (void)testANMediationStaticWidthContainerView {
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 250)];
    ANMediationContainerView *containerView = [[ANMediationContainerView alloc] initWithMediatedView:contentView];
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootViewController.view addSubview:containerView];
    containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView an_constrainWithFrameSize];
    [XCTestCase delayForTimeInterval:kUIViewConstraintsTestCaseFrameRefreshDelay];
    XCTAssertEqual(containerView.frame.size.width, 200);
    XCTAssertEqual(containerView.frame.size.height, 250);
}

- (void)testANPBDynamicWidthContainerView {
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 250)];
    ANPBContainerView *containerView = [[ANPBContainerView alloc] initWithContentView:contentView];
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootViewController.view addSubview:containerView];
    containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView an_constrainWithFrameSize];
    [XCTestCase delayForTimeInterval:kUIViewConstraintsTestCaseFrameRefreshDelay];
    XCTAssertEqual(containerView.frame.size.width, rootViewController.view.frame.size.width);
    XCTAssertEqual(containerView.frame.size.height, 250);
}

- (void)testANPBStaticWidthContainerView {
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 250)];
    ANPBContainerView *containerView = [[ANPBContainerView alloc] initWithContentView:contentView];
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootViewController.view addSubview:containerView];
    containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView an_constrainWithFrameSize];
    [XCTestCase delayForTimeInterval:kUIViewConstraintsTestCaseFrameRefreshDelay];
    XCTAssertEqual(containerView.frame.size.width, 200);
    XCTAssertEqual(containerView.frame.size.height, 250);
}


@end
