//
//  main.m
//  pxctest
//
//  Created by Johannes Plunien on 23/11/16.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

#import <Foundation/Foundation.h>

@import PXCTestKit;

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        [CommandLineInterface bootstrap];
    }
    return 0;
}
