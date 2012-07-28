//
//  DynamicProxy.m
//  TestDynamicProxy
//
//  Created by tobias patton on 7/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DynamicProxy.h"

@implementation DynamicProxy

@synthesize InnerObject;
@synthesize Interceptors;

- (id) initWithBlock: (InitializerBlock)initializerBlock andInterceptors:(NSArray *)interceptors;
{
    if(self = [super init])
    {
        InnerObject = initializerBlock();
        self.Interceptors = interceptors;
    }
    return self;
}

- (void) dealloc
{
    [InnerObject release];
    [Interceptors release];
    [super dealloc];
}

- (void) forwardInvocation:(NSInvocation *)anInvocation
{
    if(Interceptors != nil)
    {
        for(id interceptor in Interceptors)
        {
            [interceptor willInvoke:anInvocation];
        }
    }
    
    [anInvocation invokeWithTarget:InnerObject];
    
    if(Interceptors != nil)
    {
        for(id interceptor in Interceptors)
        {
            [interceptor didInvoke:anInvocation];
        }
    }
}

- (NSMethodSignature *) methodSignatureForSelector:(SEL)aSelector
{
    return [InnerObject methodSignatureForSelector:aSelector];
}

@end
