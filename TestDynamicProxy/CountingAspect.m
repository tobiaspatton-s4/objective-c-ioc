//
//  CountingAspect.m
//  TestDynamicProxy
//
//  Created by tobias patton on 7/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CountingAspect.h"

@interface CountingAspect(PrivateMethods)

- (NSString *) keyForSelector: (SEL)selector inClass: (Class)class;

@end

@implementation CountingAspect

@synthesize InvocationCounts;

- (id) init
{
    if(self = [super init])
    {
        InvocationCounts = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void) dealloc
{
    [InvocationCounts release];
    [super dealloc];
}

- (void) willInvoke: (NSInvocation *)invocation
{    
}

- (void) didInvoke: (NSInvocation *)invocation
{
    NSString *key = [self keyForSelector:[invocation selector] inClass:[[invocation target]class]];
    NSNumber *count = [InvocationCounts valueForKey:key];
    if(count == nil)
    {
        count = [NSNumber numberWithInt: 1];
    }
    else
    {
        count = [NSNumber numberWithInt:[count intValue] + 1 ];
    }    
    [InvocationCounts setValue:count forKey:key];
}

- (NSInteger) countForSelector: (SEL)selector inClass:(Class)class
{
    NSString *key = [self keyForSelector:selector inClass:class];
    NSNumber *count = [InvocationCounts valueForKey:key];
    if(count == nil)
    {
        return 0;
    }
    return [count integerValue];
}

- (NSString *) keyForSelector: (SEL)selector inClass: (Class)class
{
    return [NSString stringWithFormat:@"%@:%@", NSStringFromClass(class), NSStringFromSelector(selector)];
}

@end
