#import <XCTest/XCTest.h>

@interface SampleTests : XCTestCase

@end

@implementation SampleTests

- (void)testInSampleTestsThatSucceeds
{
    XCTAssertTrue(YES);
}

- (void)testInSampleTestsThatFails
{
    XCTAssertTrue(NO);
}

- (void)testEnvironmentVariableInjection
{
    XCTAssertEqualObjects([NSProcessInfo processInfo].environment[@"FOO"], @"BAR");
}

@end
