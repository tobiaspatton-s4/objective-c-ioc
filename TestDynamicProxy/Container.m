//
//  Container.m
//  TestDynamicProxy
//
//  Created by tobias patton on 7/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Container.h"
#include "SupportsLogging.h"
#include "LoggingInterceptor.h"


@interface Container(PrivateMethods)
- (id<IInterceptor>) firstRegisteredInterceptorForClass: (Class)class;
@end

@implementation Container

const NSString *modeShared = @"ModeShared";
const NSString *modeNonShared = @"ModeNonShared";

static Container *gContainer;

+ (void)initialize
{
    if(gContainer == nil)
    {
        gContainer = [[Container alloc] init];
    }    
}

+ (Container *) sharedContainer
{
    return gContainer;
}

@synthesize RegisteredClasses;
@synthesize RegisteredInterceptors;
@synthesize Singletons;

- (id) init
{
    if(self = [super init])
    {        
        RegisteredClasses = [[NSMutableDictionary alloc] init];
        RegisteredInterceptors = [[NSMutableDictionary alloc] init];
        Singletons = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void) dealloc
{
    [RegisteredClasses release];
    [RegisteredInterceptors release];
    [Singletons release];
    [super dealloc];
}

- (void) registerClass: (Class)class withInitializer:(InitializerBlock)initializer andMode:(const NSString *)mode;
{
    InitializerBlock registeredInitializerBlock = initializer;
    if(mode == modeShared)
    {
        id instance = initializer();
        [Singletons setObject:instance forKey:NSStringFromClass(class)];
        registeredInitializerBlock = ^(){return [[Singletons valueForKey:NSStringFromClass(class)] retain];};
    }
    
    [RegisteredClasses setObject:registeredInitializerBlock forKey:NSStringFromClass(class)];
}

- (void) registerInterceptor: (id<IInterceptor>)interceptor forProtocol: (Protocol *)proto;
{
    [RegisteredInterceptors setObject:interceptor forKey:NSStringFromProtocol(proto)];
}

- (id<IInterceptor>) InterceptorForProtocol: (Protocol *)proto
{
    return [RegisteredInterceptors valueForKey:NSStringFromProtocol(proto)];
}

- (id<IInterceptor>) firstRegisteredInterceptorForClass: (Class)class
{
    id<IInterceptor> result = nil;
    
    for(id proto in [RegisteredInterceptors allKeys])
    {
        if([class conformsToProtocol:NSProtocolFromString(proto)])
        {
            result = [RegisteredInterceptors valueForKey:proto];
        }
    }
    
    return result;
}

- (id) newInstanceOfClass: (Class)class
{
    InitializerBlock intializerBlock = [RegisteredClasses valueForKey:NSStringFromClass(class)];
    if(intializerBlock == nil)
    {
        NSLog(@"Class %@ was not registered with the container.", NSStringFromClass(class));
        return nil;
    }
    
    id<IInterceptor> interceptor = [self firstRegisteredInterceptorForClass:class];    
    id result = [[DynamicProxy alloc] initWithBlock:intializerBlock andInterceptor:interceptor];
    
    if(result == nil)
    {
        NSLog(@"Initializer block regiester for Class %@ returned nil", NSStringFromClass(class));
        return nil;
    }
    
    return result;
}

@end
