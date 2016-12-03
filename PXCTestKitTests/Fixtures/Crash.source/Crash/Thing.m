//
//  Thing.m
//  Crash
//
//  Created by Johannes Plunien on 3/12/2016.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

#import "Thing.h"

@implementation Thing

+ (void)crash
{
    __builtin_trap();
}

@end
