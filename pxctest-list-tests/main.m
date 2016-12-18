//
//  main.m
//  pxctest-list-tests
//
//  Created by Johannes Plunien on 10/12/2016.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import <objc/runtime.h>
#import "JRSwizzle.h"

@implementation XCTestCase (PXCTestKit)

+ (void)pxc_swizzle
{
    assert([XCTestCase jr_swizzleMethod:@selector(invokeTest) withMethod:@selector(pxc_empty) error:nil]);
    assert([XCTestCase jr_swizzleMethod:@selector(setUp) withMethod:@selector(pxc_empty) error:nil]);
    assert([XCTestCase jr_swizzleMethod:@selector(tearDown) withMethod:@selector(pxc_empty) error:nil]);
    assert([XCTestCase jr_swizzleClassMethod:@selector(setUp) withClassMethod:@selector(pxc_empty) error:nil]);
    assert([XCTestCase jr_swizzleClassMethod:@selector(tearDown) withClassMethod:@selector(pxc_empty) error:nil]);

    assert([NSClassFromString(@"XCTestCaseSuite") jr_swizzleMethod:@selector(setUp) withMethod:@selector(pxc_empty) error:nil]);
    assert([NSClassFromString(@"XCTestCaseSuite") jr_swizzleMethod:@selector(tearDown) withMethod:@selector(pxc_empty) error:nil]);

    [self pxc_enumerateSubclasses:^(__unsafe_unretained Class subClass) {
        assert([subClass jr_swizzleMethod:@selector(setUp) withMethod:@selector(pxc_empty) error:nil]);
        assert([subClass jr_swizzleMethod:@selector(tearDown) withMethod:@selector(pxc_empty) error:nil]);
        assert([subClass jr_swizzleClassMethod:@selector(setUp) withClassMethod:@selector(pxc_empty) error:nil]);
        assert([subClass jr_swizzleClassMethod:@selector(tearDown) withClassMethod:@selector(pxc_empty) error:nil]);
    }];
}

+ (void)pxc_enumerateSubclasses:(void (^)(Class subClass))enumerationBlock
{
    int numberOfClasses = objc_getClassList(NULL, 0);
    Class *classes = NULL;

    classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numberOfClasses);
    numberOfClasses = objc_getClassList(classes, numberOfClasses);

    for (NSInteger i=0; i<numberOfClasses; i++) {
        Class subClass = classes[i];
        Class superClass = classes[i];
        do {
            superClass = class_getSuperclass(superClass);
        } while(superClass && superClass != self);

        if (!superClass) {
            continue;
        }

        enumerationBlock(subClass);
    }

    free(classes);
}

+ (void)pxc_empty {}
- (void)pxc_empty {}

@end

@implementation XCTest (PXCTestKit)

+ (void)pxc_empty {}
- (void)pxc_empty {}

@end

@interface XCTestCaseSuite : NSObject

@end

@implementation XCTestCaseSuite

+ (void)pxc_empty {}
- (void)pxc_empty {}

@end

@interface PXCTestObserver : NSObject<XCTestObservation>

@end

@implementation PXCTestObserver

- (void)testBundleWillStart:(NSBundle *)testBundle
{
    [XCTestCase pxc_swizzle];
}

@end

static PXCTestObserver *observer;

__attribute__((constructor)) static void EntryPoint(void)
{
    [XCTestCase pxc_swizzle];
    observer = [PXCTestObserver new];
    [[XCTestObservationCenter sharedTestObservationCenter] addTestObserver:observer];
}
