//
//  main.c
//  TestDynamicProxy
//
//  Created by tobias patton on 7/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreFoundation/CoreFoundation.h>
#import "DynamicProxy.h"
#import "Bootstrapper.h"
#import "Container.h"
#import "SimpleClass.h"
#import "CountingAspect.h"
#import "SupportsCounting.h"
#import "ILogger.h"

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        [Bootstrapper configureContainer];
        
        id proxy = [[[Container sharedContainer] newInstanceOfClass:[SimpleClass class]] autorelease];        
        [proxy doIt];
        NSLog(@"proxy.returnIt returned: %@", [proxy returnIt]);
        
        id proxy2 = [[[Container sharedContainer] newInstanceOfClass:[SimpleClass class]] autorelease];        
        [proxy2 doIt];
        
        CountingAspect *countingAspect = [[Container sharedContainer] InterceptorForProtocol:@protocol(SupportsCounting)];
        NSLog(@"SimpleClass doIt() was called %ld times", [countingAspect countForSelector:@selector(doIt) inClass:[SimpleClass class]]);
        
        id<ILogger> logger = [[[Container sharedContainer] newInstanceOfProtocol:@protocol(ILogger)] autorelease];
        [logger logMessage:@"hello world"];
        
        return 0;
    }
}

