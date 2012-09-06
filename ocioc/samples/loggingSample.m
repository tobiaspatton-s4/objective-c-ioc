//
//  loggingSample.m
//  samples
//
//  Created by tobias patton on 7/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ocioc/ocioc.h>
#import "LoggingInterceptor.h"
#import "SupportsLogging.h"
#import "Logging.h"
#import "ConsoleLogger.h"
#import "LoggerWrapper.h"

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {   
        OCIOCContainer *container = [OCIOCContainer sharedContainer];
        
        // Register an interceptor. Whenever a method is called on an object that implements the "SupportsLogging"
        // protocol, the interceptor will be invoked.
        [container registerInterceptor:[[[LoggingInterceptor alloc] init] autorelease]
                           forProtocol:@protocol(SupportsLogging)];
        
        // Register a sample class with the container.
        [container registerClass:[LoggerWrapper class] 
                 withInitializer:^(){ return [[LoggerWrapper alloc] init]; } 
                         andMode:kOCIOCModeNonShared];
        
        // Register a shared dependency. Any object created by the container that has a property with the "import" prefiex
        // and the type of id<ILogger> will get the shared ConsoleLogger instance injected.
        [container registerProtocol:@protocol(Logging) withInitializer:^(){ return [[ConsoleLogger alloc] init]; } andMode:kOCIOCModeShared];
        
        LoggerWrapper *sampleObject1 = [[[OCIOCContainer sharedContainer] newInstanceOfClass:[LoggerWrapper class]] autorelease];
        [sampleObject1 logMessage:@"This is the first message"];
        
        LoggerWrapper *sampleObject2 = [[[OCIOCContainer sharedContainer] newInstanceOfClass:[LoggerWrapper class]] autorelease];
        [sampleObject2 logMessage:@"This is the second mesage"];
        
        [sampleObject2 logMessage:@"The two message should come from the same logger instance"];
        
        return 0;
    }
}