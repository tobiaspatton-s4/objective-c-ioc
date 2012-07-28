//
//  ConsoleLogger.m
//  TestDynamicProxy
//
//  Created by tobias patton on 12-07-28.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ConsoleLogger.h"

@implementation ConsoleLogger

- (void) logMessage: (NSString *)msg
{
    NSLog(@"<%p> %@", self, msg);
}

@end
