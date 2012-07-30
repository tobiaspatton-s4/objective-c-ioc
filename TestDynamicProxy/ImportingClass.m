//
//  ImportingClass.m
//  TestDynamicProxy
//
//  Created by tobias patton on 12-07-28.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImportingClass.h"
#import "ConsoleLogger.h"

@implementation ImportingClass

@synthesize importLogger;


- (void) logMessage: (NSString *)message
{
    if(importLogger == nil)
    {
        NSLog(@"!! No logger");
        return;
    }
    [importLogger logMessage:message];
}

@end
