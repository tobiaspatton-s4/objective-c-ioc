//
//  ImportingClass.m
//  TestDynamicProxy
//
//  Created by tobias patton on 12-07-28.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImportingClass.h"

@implementation ImportingClass

@synthesize ImportLogger;
@synthesize test;

- (void) logMessage: (NSString *)message
{
    if(ImportLogger == nil)
    {
        NSLog(@"!! No logger");
        return;
    }
    [ImportLogger logMessage:message];
}

@end
