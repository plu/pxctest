//
//  Tests.m
//  SuccessfulTests
//
//  Created by Johannes Plunien on 30/11/16.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface SuccessfulTests : XCTestCase

@end

@implementation SuccessfulTests

- (void)testOne {
    XCTAssertTrue(YES);
}

- (void)testTwo {
    XCTAssertTrue(YES);
}

- (void)testThree {
    XCTAssertTrue(YES);
}

- (void)testSkipped {
    XCTAssertTrue(NO);
}

@end
