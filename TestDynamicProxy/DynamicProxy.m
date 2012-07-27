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
@synthesize Interceptor;

- (id) initWithBlock: (InitializerBlock)initializerBlock andInterceptor:(id<IInterceptor>)interceptor;
{
    if(self = [super init])
    {
        InnerObject = initializerBlock();
        self.Interceptor = interceptor;
    }
    return self;
}

- (void) dealloc
{
    [InnerObject dealloc];
    [super dealloc];
}

- (void) forwardInvocation:(NSInvocation *)anInvocation
{
    if(Interceptor != nil)
    {
        [Interceptor willInvoke:anInvocation];
    }
    
    [anInvocation invokeWithTarget:InnerObject];
    
    if(Interceptor != nil)
    {
        [Interceptor didInvoke:anInvocation];
    }
}

- (NSMethodSignature *) methodSignatureForSelector:(SEL)aSelector
{
    return [InnerObject methodSignatureForSelector:aSelector];
}

@end
