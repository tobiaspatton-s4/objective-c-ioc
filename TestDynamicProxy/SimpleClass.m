//
//  SimpleClass.m
//  TestDynamicProxy
//
//  Created by tobias patton on 7/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SimpleClass.h"

@implementation SimpleClass

- (void) doIt
{
    NSLog(@"SimpleClass.DoIt()");
}
- (NSString *) returnIt
{
    NSLog(@"SimpleClass.returnIt()");    
    return @"SimpleClass.returnIt()";
}

@end
