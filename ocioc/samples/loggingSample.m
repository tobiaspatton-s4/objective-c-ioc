//
//  loggingSample.m
//  samples
//
//  Created by tobias patton on 7/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OCIOCContainer.h"
#import "LoggingInterceptor.h"
#import "SupportsLogging.h"
#import "ILogger.h"
#import "ConsoleLogger.h"

@interface SampleClass : NSObject<SupportsLogging>

@property (nonatomic, retain) id<ILogger> importLogger;
- (void) logMessage: (NSString *)msg;

@end

@implementation SampleClass

@synthesize importLogger;
- (void) logMessage: (NSString *)msg
{
    [importLogger logMessage:msg];
}

@end

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
        [container registerClass:[SampleClass class] 
                 withInitializer:^(){ return [[SampleClass alloc] init]; } 
                         andMode:modeNonShared];
        
        // Register a shared dependency. Any object created by the container that has a property with the "import" prefiex
        // and the type of id<ILogger> will get the shared ConsoleLogger instance injected.
        [container registerProtocol:@protocol(ILogger) withInitializer:^(){ return [[ConsoleLogger alloc] init]; } andMode:modeShared];
        
        SampleClass *sampleObject1 = [[[OCIOCContainer sharedContainer] newInstanceOfClass:[SampleClass class]] autorelease];
        [sampleObject1 logMessage:@"This is the first message"];
        
        SampleClass *sampleObject2 = [[[OCIOCContainer sharedContainer] newInstanceOfClass:[SampleClass class]] autorelease];
        [sampleObject2 logMessage:@"This is the second mesage"];
        
        [sampleObject2 logMessage:@"The two message should come from the same logger instance"];
        
        return 0;
    }
}