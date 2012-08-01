//
//  DynamicProxy.m
//  TestDynamicProxy
//
//  Created by tobias patton on 7/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OCIOCDynamicProxy.h"

@implementation OCIOCDynamicProxy

@synthesize innerObject;
@synthesize interceptors;

- (id) initWithBlock: (OCIOCInitializerBlock)initializerBlock
{
    if(self = [super init])
    {
        self.innerObject = initializerBlock();
        self.interceptors = [NSMutableArray array];
    }
    return self;    
}

- (void) addInterceptor: (id<OCIOCIntercepting>) interceptor
{
    [interceptors addObject: interceptor];
}

- (void) dealloc
{
    [innerObject release];
    [interceptors release];
    [super dealloc];
}

- (void) forwardInvocation:(NSInvocation *)anInvocation
{
    if(interceptors != nil)
    {
        for(id interceptor in interceptors)
        {
            [interceptor willInvoke:anInvocation];
        }
    }
    
    [anInvocation invokeWithTarget:innerObject];
    
    if(interceptors != nil)
    {
        for(id interceptor in interceptors)
        {
            [interceptor didInvoke:anInvocation];
        }
    }
}

- (NSMethodSignature *) methodSignatureForSelector:(SEL)aSelector
{
    return [innerObject methodSignatureForSelector:aSelector];
}

- (Class) InnerClass
{
    return [innerObject class];
}

@end