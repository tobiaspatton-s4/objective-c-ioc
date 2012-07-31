//
//  LoggingInterceptor.m
//  TestDynamicProxy
//
//  Created by tobias patton on 7/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LoggingInterceptor.h"

@implementation LoggingInterceptor

- (void) willInvoke: (NSInvocation *)invocation
{
    NSLog(@"About to perform %@() on instance <%p> of %@", NSStringFromSelector([invocation selector]), [invocation target], [[invocation target] class]);
}

- (void) didInvoke: (NSInvocation *)invocation
{
    NSLog(@"Finished performing %@ on instance <%p> of %@", NSStringFromSelector([invocation selector]), [invocation target], [[invocation target] class]);
}

@end
