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
#import "UIView+ANCategory.h"
#import "XCTestCase+ANCategory.h"
#import "ANGlobal.h"

static NSTimeInterval const kUIViewConstraintsTestCaseFrameRefreshDelay = 0.05;
static CGFloat const kUIViewConstraintsTestCaseContainerViewWidth = 320;
static CGFloat const kUIViewConstraintsTestCaseContainerViewHeight = 400;

@interface UIViewConstraintsTestCase : XCTestCase
@property (nonatomic, weak) UIView *containerView;
@property (nonatomic, weak) UIView *contentView;
@end

@implementation UIViewConstraintsTestCase

- (void)setUp {
    [super setUp];
    [self setupContainerView];
    [self setupContentView];
}

- (void)setupContainerView {
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kUIViewConstraintsTestCaseContainerViewWidth, kUIViewConstraintsTestCaseContainerViewHeight)];
    containerView.backgroundColor = [UIColor orangeColor];
    UIViewController *rootViewController = [ANGlobal getKeyWindow].rootViewController;
    [rootViewController.view addSubview:containerView];
    self.containerView = containerView;
}

- (void)setupContentView {
    UIView *contentView = [[UIView alloc] init];
    contentView.backgroundColor = [UIColor blueColor];
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView addSubview:contentView];
    self.contentView = contentView;
}

- (void)tearDown {
    [super tearDown];
    [self.containerView removeFromSuperview];
}

- (void)testConstrainWithSize {
    CGSize contentViewSize = CGSizeMake(300, 250);
    [self.contentView an_constrainWithSize:contentViewSize];
    [XCTestCase delayForTimeInterval:kUIViewConstraintsTestCaseFrameRefreshDelay];
    XCTAssertEqual(self.contentView.frame.size.width, contentViewSize.width);
    XCTAssertEqual(self.contentView.frame.size.height, contentViewSize.height);
    
    contentViewSize = CGSizeMake(200, 400);
    [self.contentView an_constrainWithSize:contentViewSize];
    [XCTestCase delayForTimeInterval:kUIViewConstraintsTestCaseFrameRefreshDelay];
    XCTAssertEqual(self.contentView.frame.size.width, contentViewSize.width);
    XCTAssertEqual(self.contentView.frame.size.height, contentViewSize.height);
    
    contentViewSize = CGSizeMake(100, 600);
    [self.contentView an_constrainWithSize:contentViewSize];
    [XCTestCase delayForTimeInterval:kUIViewConstraintsTestCaseFrameRefreshDelay];
    XCTAssertEqual(self.contentView.frame.size.width, contentViewSize.width);
    XCTAssertEqual(self.contentView.frame.size.height, contentViewSize.height);
}

- (void)testConstrainWithSizeWithDynamicWidth {
    CGSize contentViewSize = CGSizeMake(1, 250);
    [self.contentView an_constrainWithSize:contentViewSize];
    [XCTestCase delayForTimeInterval:kUIViewConstraintsTestCaseFrameRefreshDelay];
    XCTAssertEqual(self.contentView.frame.size.width, kUIViewConstraintsTestCaseContainerViewWidth);
    XCTAssertEqual(self.contentView.frame.size.height, contentViewSize.height);
}

- (void)testConstrainWithFrameSize {
    CGSize contentViewSize = CGSizeMake(300, 400);
    [self.contentView setFrame:CGRectMake(self.contentView.frame.origin.x, self.contentView.frame.origin.y, contentViewSize.width, contentViewSize.height)];
    [self.contentView an_constrainWithFrameSize];
    [XCTestCase delayForTimeInterval:kUIViewConstraintsTestCaseFrameRefreshDelay];
    XCTAssertEqual(self.contentView.frame.size.width, contentViewSize.width);
    XCTAssertEqual(self.contentView.frame.size.height, contentViewSize.height);
    
    contentViewSize = CGSizeMake(500, 300);
    [self.contentView setFrame:CGRectMake(self.contentView.frame.origin.x, self.contentView.frame.origin.y, contentViewSize.width, contentViewSize.height)];
    [self.contentView an_constrainWithFrameSize];
    [XCTestCase delayForTimeInterval:kUIViewConstraintsTestCaseFrameRefreshDelay];
    XCTAssertEqual(self.contentView.frame.size.width, contentViewSize.width);
    XCTAssertEqual(self.contentView.frame.size.height, contentViewSize.height);
}

- (void)testConstrainToSizeOfSuperview {
    [self.contentView an_constrainToSizeOfSuperview];
    [XCTestCase delayForTimeInterval:kUIViewConstraintsTestCaseFrameRefreshDelay];
    XCTAssertEqual(self.contentView.frame.size.width, self.containerView.frame.size.width);
    XCTAssertEqual(self.contentView.frame.size.height, self.containerView.frame.size.height);
    
    CGSize sizeToScaleContainerView = CGSizeMake(kUIViewConstraintsTestCaseContainerViewWidth * 2, kUIViewConstraintsTestCaseContainerViewHeight * 2);
    self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView an_constrainWithSize:sizeToScaleContainerView];
    [XCTestCase delayForTimeInterval:kUIViewConstraintsTestCaseFrameRefreshDelay];
    // Content view should automatically scale
    XCTAssertEqual(self.contentView.frame.size.width, self.containerView.frame.size.width);
    XCTAssertEqual(self.contentView.frame.size.height, self.containerView.frame.size.height);
}

- (void)testAlignToSuperviewNoOffset {
    CGSize contentViewSize = CGSizeMake(300, 250);
    [self.contentView an_constrainWithSize:contentViewSize];
    [self.contentView an_alignToSuperviewWithXAttribute:NSLayoutAttributeCenterX
                                             yAttribute:NSLayoutAttributeCenterY];
    [XCTestCase delayForTimeInterval:kUIViewConstraintsTestCaseFrameRefreshDelay];
    XCTAssertEqual(self.contentView.center.x, kUIViewConstraintsTestCaseContainerViewWidth / 2);
    XCTAssertEqual(self.contentView.center.y, kUIViewConstraintsTestCaseContainerViewHeight / 2);
    
    [self.contentView an_alignToSuperviewWithXAttribute:NSLayoutAttributeLeft
                                             yAttribute:NSLayoutAttributeTop];
    [XCTestCase delayForTimeInterval:kUIViewConstraintsTestCaseFrameRefreshDelay];
    XCTAssertEqual(self.contentView.frame.origin.x, 0);
    XCTAssertEqual(self.contentView.frame.origin.y, 0);
    
    [self.contentView an_alignToSuperviewWithXAttribute:NSLayoutAttributeRight
                                             yAttribute:NSLayoutAttributeTop];
    [XCTestCase delayForTimeInterval:kUIViewConstraintsTestCaseFrameRefreshDelay];
    XCTAssertEqual(self.contentView.frame.origin.x, kUIViewConstraintsTestCaseContainerViewWidth - contentViewSize.width);
    XCTAssertEqual(self.contentView.frame.origin.y, 0);
    
    [self.contentView an_alignToSuperviewWithXAttribute:NSLayoutAttributeLeft
                                             yAttribute:NSLayoutAttributeBottom];
    [XCTestCase delayForTimeInterval:kUIViewConstraintsTestCaseFrameRefreshDelay];
    XCTAssertEqual(self.contentView.frame.origin.x, 0);
    XCTAssertEqual(self.contentView.frame.origin.y, kUIViewConstraintsTestCaseContainerViewHeight - contentViewSize.height);
    
    [self.contentView an_alignToSuperviewWithXAttribute:NSLayoutAttributeCenterX
                                             yAttribute:NSLayoutAttributeBottom];
    [XCTestCase delayForTimeInterval:kUIViewConstraintsTestCaseFrameRefreshDelay];
    XCTAssertEqual(self.contentView.center.x, kUIViewConstraintsTestCaseContainerViewWidth / 2);
    XCTAssertEqual(self.contentView.frame.origin.y, kUIViewConstraintsTestCaseContainerViewHeight - contentViewSize.height);
    
    // Scale container view, content view should realign automatically as well.
    CGSize sizeToScaleContainerView = CGSizeMake(kUIViewConstraintsTestCaseContainerViewWidth * 2, kUIViewConstraintsTestCaseContainerViewHeight * 2);
    self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView an_constrainWithSize:sizeToScaleContainerView];
    [XCTestCase delayForTimeInterval:kUIViewConstraintsTestCaseFrameRefreshDelay];
    // Content view still aligned "bottom-center"
    XCTAssertEqual(self.contentView.center.x, sizeToScaleContainerView.width / 2);
    XCTAssertEqual(self.contentView.frame.origin.y, sizeToScaleContainerView.height - contentViewSize.height);

    [self.contentView an_alignToSuperviewWithXAttribute:NSLayoutAttributeCenterX
                                             yAttribute:NSLayoutAttributeCenterY];
    [XCTestCase delayForTimeInterval:kUIViewConstraintsTestCaseFrameRefreshDelay];
    XCTAssertEqual(self.contentView.center.x, sizeToScaleContainerView.width / 2);
    XCTAssertEqual(self.contentView.center.y, sizeToScaleContainerView.height / 2);
}

- (void)testAlignToSuperviewWithOffset {
    CGSize contentViewSize = CGSizeMake(300, 250);
    [self.contentView an_constrainWithSize:contentViewSize];
    CGPoint offset = CGPointMake(-10, -10);
    [self.contentView an_alignToSuperviewWithXAttribute:NSLayoutAttributeCenterX
                                             yAttribute:NSLayoutAttributeCenterY
                                                offsetX:offset.x
                                                offsetY:offset.y];
    [XCTestCase delayForTimeInterval:kUIViewConstraintsTestCaseFrameRefreshDelay];
    XCTAssertEqual(self.contentView.center.x, (kUIViewConstraintsTestCaseContainerViewWidth / 2) + offset.x);
    XCTAssertEqual(self.contentView.center.y, (kUIViewConstraintsTestCaseContainerViewHeight / 2) + offset.y);
    
    CGSize sizeToScaleContainerView = CGSizeMake(kUIViewConstraintsTestCaseContainerViewWidth * 2, kUIViewConstraintsTestCaseContainerViewHeight * 2);
    self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView an_constrainWithSize:sizeToScaleContainerView];
    [XCTestCase delayForTimeInterval:kUIViewConstraintsTestCaseFrameRefreshDelay];
    // Content view still aligned "center"
    XCTAssertEqual(self.contentView.center.x, (sizeToScaleContainerView.width / 2) + offset.x);
    XCTAssertEqual(self.contentView.center.y, (sizeToScaleContainerView.height / 2) + offset.y);

}

@end

