//
//  CrashTests.m
//  CrashTests
//
//  Created by Johannes Plunien on 3/12/2016.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "Thing.h"

@interface CrashTests : XCTestCase

@end

@implementation CrashTests

- (void)testA
{
    XCTAssertTrue(YES);
}

- (void)testB
{
    [Thing crash];
}

- (void)testC
{
    XCTAssertTrue(YES);
}

@end
