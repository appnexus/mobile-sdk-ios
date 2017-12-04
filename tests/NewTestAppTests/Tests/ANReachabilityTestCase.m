//
//  ANReachabilityTestCase.m
//  NewTestApp
//
//  Created by David Reeder on 23/02/2017.
//  Copyright © 2017 AppNexus. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <arpa/inet.h>

#import "ANReachability+ANTest.h"




@interface ANReachabilityTestCase : XCTestCase
    //EMPTY
@end

@implementation ANReachabilityTestCase

- (void)setUp     { [super setUp]; }
- (void)tearDown  {
    [ANReachability toggleNonReachableNetworkStatusSimulationEnabled:NO];
    [super tearDown];
}


- (void)testHostname
{
    NSString  *hostNameString  = @"appnexus.com";

    ANReachability  *hostname  = [ANReachability reachabilityWithHostName:hostNameString];
    XCTAssertNotNil(hostname);

    XCTAssertTrue([hostname currentReachabilityStatus]);
}

- (void) testAppNexusIPAddress
{
    NSString           *hostNumberString  = @"68.67.154.120";   // % dig appnexus.com
    struct in_addr      hostNumber;
    struct sockaddr_in  socketAddress;

    int  rval  = -1;


    //
    rval = inet_aton([hostNumberString cStringUsingEncoding:NSASCIIStringEncoding], &hostNumber);
    XCTAssertEqual(rval, 1);

    bzero(&socketAddress, sizeof(socketAddress));
    socketAddress.sin_len           = sizeof(socketAddress);
    socketAddress.sin_family        = AF_INET;
    socketAddress.sin_addr.s_addr   = htonl(hostNumber.s_addr);
    [ANReachability toggleNonReachableNetworkStatusSimulationEnabled:NO];
    ANReachability  *appNexusIPAddress  = [ANReachability reachabilityWithAddress:&socketAddress];
    XCTAssertNotNil(appNexusIPAddress);
    XCTAssertTrue([appNexusIPAddress currentReachabilityStatus]);
    
    [ANReachability toggleNonReachableNetworkStatusSimulationEnabled:YES];
    XCTAssertFalse([appNexusIPAddress currentReachabilityStatus]);
    
}

@end
