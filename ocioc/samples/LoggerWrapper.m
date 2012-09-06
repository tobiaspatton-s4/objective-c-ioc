//
//  LoggerWrapper.m
//  samples
//
//  Created by tobias patton on 12-09-05.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LoggerWrapper.h"
#import <ocioc/ocioc.h>

@implementation LoggerWrapper

OCIOC_BEGIN_IMPORTS
OCIOC_REGISTER_IMPORT(logger, LoggerWrapper)
OCIOC_END_IMPORTS

@synthesize logger;

- (void) logMessage: (NSString *)msg
{
    [logger logMessage:msg];
}

@end
