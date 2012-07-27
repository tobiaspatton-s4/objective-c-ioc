//
//  Bootstrapper.m
//  TestDynamicProxy
//
//  Created by tobias patton on 7/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Bootstrapper.h"
#import "SimpleClass.h"
#import "LoggingInterceptor.h"
#import "SupportsCounting.h"
#import "CountingAspect.h"
#import "SupportsCounting.h"

@implementation Bootstrapper

+ (void) configureContainer
{
    Container *container = [Container sharedContainer];
    
    // Register classes
    [container registerClass:[SimpleClass class] withInitializer:^(){ return [[SimpleClass alloc] init]; } andMode:modeNonShared];
    
    // Register interceptors
    LoggingInterceptor *loggingInterceptor = [[[LoggingInterceptor alloc] init] autorelease];
    [container registerInterceptor:loggingInterceptor forProtocol:@protocol(SupportsLogging)];
    
    CountingAspect *countingAspect = [[[CountingAspect alloc] init] autorelease];
    [container registerInterceptor:countingAspect forProtocol:@protocol(SupportsCounting)];
}

@end
