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
- (void) registerName:(NSString *)name withInitializer:(InitializerBlock)initializer andMode:(const NSString *)mode;
- (NSArray *) registeredInterceptorsForClass: (Class)class;
- (id) newInstanceOfName: (NSString *)name;
- (void) addInterceptorsToProxy: (id) proxy;
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

- (void) registerProtocol:(Protocol *)proto withInitializer:(InitializerBlock)initializer andMode:(const NSString *)mode
{
    [self registerName:NSStringFromProtocol(proto) withInitializer:initializer andMode:mode];    
}

- (void) registerClass: (Class)class withInitializer:(InitializerBlock)initializer andMode:(const NSString *)mode;
{
    [self registerName:NSStringFromClass(class) withInitializer:initializer andMode:mode];
}

- (void) registerName:(NSString *)name withInitializer:(InitializerBlock)initializer andMode:(const NSString *)mode
{
    if(mode == modeShared)
    {
        id instance = initializer();
        [Singletons setObject:instance forKey:name];  
        // Copy the block. It is stack object and will be invalidted when the stack from is popped.
        InitializerBlock block = [[^(){return [[Singletons valueForKey:name] retain];} copy] autorelease];
        [RegisteredClasses setObject:block forKey:name];    
    }
    else 
    {
        [RegisteredClasses setObject:initializer forKey:name];    
    }
}

- (void) registerInterceptor: (id<IInterceptor>)interceptor forProtocol: (Protocol *)proto;
{
    [RegisteredInterceptors setObject:interceptor forKey:NSStringFromProtocol(proto)];
}

- (id<IInterceptor>) InterceptorForProtocol: (Protocol *)proto
{
    return [RegisteredInterceptors valueForKey:NSStringFromProtocol(proto)];
}

- (NSArray *) registeredInterceptorsForClass: (Class)class
{
    NSMutableArray *result = [NSMutableArray array];
    
    for(id proto in [RegisteredInterceptors allKeys])
    {
        if([class conformsToProtocol:NSProtocolFromString(proto)])
        {
            [result addObject:[RegisteredInterceptors valueForKey:proto]];
        }
    }
    
    return result;
}

- (id) newInstanceOfProtocol: (Protocol *)proto
{
    return [self newInstanceOfName:NSStringFromProtocol(proto)];    
}

- (id) newInstanceOfClass: (Class)class
{
    return [self newInstanceOfName:NSStringFromClass(class)];
}

- (id) newInstanceOfName: (NSString *)name;
{
    InitializerBlock intializerBlock = [RegisteredClasses valueForKey:name];
    if(intializerBlock == nil)
    {
        NSLog(@"Class %@ was not registered with the container.", name);
        return nil;
    }
    
    id result = [[DynamicProxy alloc] initWithBlock:intializerBlock];
    
    if(result == nil)
    {
        NSLog(@"Initializer block regiester for Class %@ returned nil", name);
        return nil;
    }
    
    [self addInterceptorsToProxy:result];
    return result;    
}

- (void) addInterceptorsToProxy: (id) proxy
{
    NSArray *interceptors = [self registeredInterceptorsForClass:[proxy InnerClass]];
    if(interceptors == nil)
    {
        return;
    }
    
    for(id interceptor in interceptors)
    {
        [proxy addInterceptor:interceptor];
    }
}

@end
