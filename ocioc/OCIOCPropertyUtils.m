//
//  PropertyUtils.m
//  TestDynamicProxy
//
//  Created by tobias patton on 12-07-28.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OCIOCPropertyUtils.h"
#import <objc/objc-runtime.h>

@interface OCIOCPropertyUtils(PrivateMethods)
+ (NSDictionary *) parsePropertyAttributes: (NSString *)attr;
@end

@implementation OCIOCPropertyUtils

NSString *kOCIOCPropertyType = @"type";
NSString *kOCIOCPropertyProtocols = @"proto";

+ (NSDictionary *) classProperties: (Class)class
{
    unsigned propertyCount = 0;
    objc_property_t *propertyList = class_copyPropertyList(class, &propertyCount);
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    for(unsigned i = 0; i < propertyCount; i++)
    {
        NSString *propertyName = [NSString stringWithCString:property_getName(propertyList[i]) encoding:NSUTF8StringEncoding];
        NSString *propertyAttributes = [NSString stringWithCString:property_getAttributes(propertyList[i]) encoding:NSUTF8StringEncoding];
        [result setValue:[self parsePropertyAttributes:propertyAttributes] forKey:propertyName];
    }
    return result;
}

+ (NSDictionary *) parsePropertyAttributes: (NSString *)attr
{    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    if([attr characterAtIndex:0] != L'T')
    {
        NSLog(@"%@ is not a valid property attribute string", attr);
        return nil;
    }
    
    if([attr characterAtIndex:1] != L'@')
    {
        NSLog(@"%@ describes a property that's not an objective-c type. This is not currently supported", attr);
        return nil;
    }
    
    NSArray *components = [attr componentsSeparatedByString:@"\""];
    if([components count] < 3)
    {
        // type is "id" with no protocols
        [result setValue:nil forKey:kOCIOCPropertyType];
        [result setValue:nil forKey:kOCIOCPropertyProtocols];        
    }
    else 
    {
        NSString *typeAttr = [components objectAtIndex:1];
        NSRange startOfProtocols = [typeAttr rangeOfString:@"<"];
        
        // Parse the type name
        
        if(startOfProtocols.location == 0)
        {
            // type is "id"            
            [result setValue:nil forKey:kOCIOCPropertyType];
        }
        else if(startOfProtocols.location == NSNotFound)
        {
            // No protocols
            Class class = NSClassFromString(typeAttr);
            if(class == nil)
            {
                NSLog(@"Could not create class from name %@", typeAttr);
            }
            [result setValue:class forKey:kOCIOCPropertyType];
        }
        else 
        {
            // Has class name and protocols
            NSString *typeName = [typeAttr substringToIndex:startOfProtocols.location];
            Class class = NSClassFromString(typeName);
            if(class == nil)
            {
                NSLog(@"Could not create class from name %@", typeName);
            }
            [result setValue:class forKey:kOCIOCPropertyType];            
        }
        
        // Parse the list of protocols
        
        if(startOfProtocols.location == NSNotFound)
        {            
            [result setValue:nil forKey:kOCIOCPropertyProtocols];
        }
        else
        {   
            unsigned long loc = startOfProtocols.location + 1;
            unsigned long len = [typeAttr length] - loc - 1;
            NSString *protocolsAttr = [typeAttr substringWithRange:NSMakeRange(loc, len)];
            NSArray *protocolNames = [protocolsAttr componentsSeparatedByString:@"><"];
            NSMutableArray *protocols = [NSMutableArray array];
            for(id protocolName in protocolNames)
            {
                Protocol *proto = NSProtocolFromString(protocolName);
                if(proto == nil)
                {
                    NSLog(@"Could not create protocol from name %@", protocolName);
                }
                [protocols addObject:proto];
            }
            [result setValue:protocols forKey:kOCIOCPropertyProtocols];
        }
    }
    
    return result;
}

@end
