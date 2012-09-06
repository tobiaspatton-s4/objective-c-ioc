//
//  Container.m
//  TestDynamicProxy
//
//  Created by tobias patton on 7/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OCIOCContainer.h"
#include "OCIOCPropertyUtils.h"
#import <objc/runtime.h>

@interface OCIOCContainer(PrivateMethods)
- (void) registerName:(NSString *)name withInitializer:(OCIOCInitializerBlock)initializer andMode:(const NSString *)mode;
- (NSArray *) registeredInterceptorsForClass: (Class)class;
- (id) newInstanceOfName: (NSString *)name;
- (void) addInterceptorsToProxy: (id) proxy;
- (NSString *) defaultSetterForProperty: (NSString *)property;
@end

@implementation OCIOCContainer

NSString *kOCIOCModeShared = @"ModeShared";
NSString *kOCIOCModeNonShared = @"ModeNonShared";
NSString *kOCIOCRecursionDepthExceededException = @"RecursionDepthExceededException";

const static unsigned kOCIOCMaxRecursionDepthForSatisfyImports = 100;

static OCIOCContainer *gContainer;
static unsigned OCIOCSatisfyImportsRecursionGuard;


+ (void)initialize
{
    if(gContainer == nil)
    {
        gContainer = [[OCIOCContainer alloc] init];
        OCIOCSatisfyImportsRecursionGuard = 0;
    }    
}

+ (OCIOCContainer *) sharedContainer
{
    return gContainer;
}

@synthesize registeredClasses;
@synthesize registeredInterceptors;
@synthesize singletons;
@synthesize imports;

- (id) init
{
    if(self = [super init])
    {        
        registeredClasses = [[NSMutableDictionary alloc] init];
        registeredInterceptors = [[NSMutableDictionary alloc] init];
        singletons = [[NSMutableDictionary alloc] init];
        self.imports = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void) dealloc
{
    [registeredClasses release];
    [registeredInterceptors release];
    [singletons release];
    [imports release];
    [super dealloc];
}

- (void) registerProtocol:(Protocol *)proto withInitializer:(OCIOCInitializerBlock)initializer andMode:(const NSString *)mode
{
    [self registerName:NSStringFromProtocol(proto) withInitializer:initializer andMode:mode];    
}

- (void) registerClass: (Class)class withInitializer:(OCIOCInitializerBlock)initializer andMode:(const NSString *)mode;
{
    [self registerName:NSStringFromClass(class) withInitializer:initializer andMode:mode];
}

- (void) registerName:(NSString *)name withInitializer:(OCIOCInitializerBlock)initializer andMode:(const NSString *)mode
{
    if(mode == kOCIOCModeShared)
    {
        id instance = initializer();
        [singletons setObject:instance forKey:name];  
        // Copy the block. It is stack object and will be invalidted when the stack from is popped.
        OCIOCInitializerBlock block = [[^(){return [[singletons valueForKey:name] retain];} copy] autorelease];
        [registeredClasses setObject:block forKey:name];    
    }
    else 
    {
        [registeredClasses setObject:initializer forKey:name];    
    }
}

- (void) registerInterceptor: (id<OCIOCIntercepting>)interceptor forProtocol: (Protocol *)proto;
{
    [registeredInterceptors setObject:interceptor forKey:NSStringFromProtocol(proto)];
}

- (id<OCIOCIntercepting>) InterceptorsForProtocol: (Protocol *)proto
{
    return [registeredInterceptors valueForKey:NSStringFromProtocol(proto)];
}

- (NSArray *) registeredInterceptorsForClass: (Class)class
{
    NSMutableArray *result = [NSMutableArray array];
    
    for(id proto in [registeredInterceptors allKeys])
    {
        if([class conformsToProtocol:NSProtocolFromString(proto)])
        {
            [result addObject:[registeredInterceptors valueForKey:proto]];
        }
    }
    
    return result;
}

- (id) newInstanceOfProtocol: (Protocol *)proto
{
    id result = [self newInstanceOfName:NSStringFromProtocol(proto)];    
    [self satisfyImportsForObject:result];
    return result;
}

- (id) newInstanceOfClass: (Class)class
{
    id result = [self newInstanceOfName:NSStringFromClass(class)];
    [self satisfyImportsForObject:result];
    return result;
}

- (id) newInstanceOfName: (NSString *)name;
{
    OCIOCInitializerBlock intializerBlock = [registeredClasses valueForKey:name];
    if(intializerBlock == nil)
    {
        NSLog(@"Class %@ was not registered with the container.", name);
        return nil;
    }
    
    id result = [[OCIOCDynamicProxy alloc] initWithBlock:intializerBlock];
    
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
    NSArray *interceptors = [self registeredInterceptorsForClass:[proxy innerClass]];
    if(interceptors == nil)
    {
        return;
    }
    
    for(id interceptor in interceptors)
    {
        [proxy addInterceptor:interceptor];
    }
}

- (void) satisfyImportsForObject: (id)object
{
    // This method must only have a single exit point to ensure that this guard gets decremented.
    ++OCIOCSatisfyImportsRecursionGuard;
    
    if(OCIOCSatisfyImportsRecursionGuard > kOCIOCMaxRecursionDepthForSatisfyImports)
    {
        OCIOCSatisfyImportsRecursionGuard = 0;
        [NSException raise:kOCIOCRecursionDepthExceededException
                    format:@"Recursive calls to %@ has exceeded threshold of %u",
                                NSStringFromSelector(@selector(satisfyImportsForObject:)),
                                kOCIOCMaxRecursionDepthForSatisfyImports];
    }
    
    if([object class] == [OCIOCDynamicProxy class])
    {
        object = [(OCIOCDynamicProxy *)object innerObject];
    }
    
    NSMutableString *propertyTypeDisplayName = [NSMutableString string];    
    NSDictionary *properties = [imports valueForKey:NSStringFromClass([object class])];
    if(properties == nil)
    {
        NSLog(@"Cannot satisfy imports for class %@ becuase no imports were registered", NSStringFromClass([object class]));
    }
    
    NSArray *importPropertyKeys = [properties allKeys];
    
    for(id key in importPropertyKeys)
    {
        NSString *propertyDisplayName = [NSString stringWithFormat:@"%@.%@", [object class], key];
        OCIOCInitializerBlock initializer = nil;
        
        NSDictionary *propertyAttrs = [properties valueForKey:key];
        Class class = (Class)[propertyAttrs valueForKey:kOCIOCPropertyType];
        NSArray *protocols = (NSArray *)[propertyAttrs valueForKey:kOCIOCPropertyProtocols];
        
        if(class == nil && protocols == nil)
        {
            NSLog(@"Cannot satisfy imports for property %@ becuase the type is 'id' with no protocol", propertyDisplayName);
            continue;
        }
        
        // check for registered type first
        if(class == nil)
        {
            [propertyTypeDisplayName appendString:@"id"];           
        }
        else
        {
            [propertyTypeDisplayName appendString:NSStringFromClass(class)];
            initializer = [registeredClasses valueForKey:NSStringFromClass(class)];
        }
        
        if(initializer == nil)
        {
            // check for a registered protocol
            if(protocols == nil || [protocols count] == 0)
            {
                NSLog(@"Cannot satisfy import for %@, becuase the type %@ was not registered", propertyDisplayName, NSStringFromClass(class));
                continue;
            }
            if([protocols count] > 1)
            {
                NSLog(@"Cannot satisfy import for %@, because it specifies more than one protocol", propertyDisplayName);
                continue;
            }
            NSString *protoName = NSStringFromProtocol((Protocol *)[protocols objectAtIndex:0]);
            [propertyTypeDisplayName appendFormat:@"<%@>", protoName];
            initializer = [registeredClasses valueForKey:protoName];
        }
        if(initializer == nil)
        {
            NSLog(@"Unable to satisfy dependencies for %@ because the type %@ was not registered", propertyDisplayName, propertyTypeDisplayName);
            continue;
        }
        else
        {
            // finally, satisfy the depedency.
            id value = initializer();
            
            // Call this method recursively to satisfy nested dependencies
            [self satisfyImportsForObject:value];
            
            // TODO: Add support for custom setter methods
            SEL selector = NSSelectorFromString([self defaultSetterForProperty: key]);
            [object performSelector:selector withObject:value];
        }
    }
    
    --OCIOCSatisfyImportsRecursionGuard;
}

- (NSString *) defaultSetterForProperty: (NSString *)property
{
    NSString *firstLetter = [property substringWithRange:NSMakeRange(0,1)];
    return [NSString stringWithFormat:@"set%@%@:", [firstLetter uppercaseString], [property substringFromIndex:1]];
}

- (void) registerImportForProperty:(NSString *)propertyName inClass:(Class)class
{
    NSString *className = NSStringFromClass(class);
    NSMutableDictionary *dictForClass = [imports valueForKey:className];
    if(dictForClass == nil)
    {
        dictForClass = [NSMutableDictionary dictionary];
        [imports setValue:dictForClass forKey:className];
    }
    
    NSDictionary *classProperties = [OCIOCPropertyUtils classProperties:class];
    NSDictionary *propertyAttributes = [classProperties valueForKey:propertyName];
    
    [dictForClass setValue:propertyAttributes forKey:propertyName];
}

@end