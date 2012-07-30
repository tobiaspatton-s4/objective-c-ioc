//
//  main.c
//  TestDynamicProxy
//
//  Created by tobias patton on 7/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreFoundation/CoreFoundation.h>
#import <objc/runtime.h>
#import "Bootstrapper.h"
#import "ImportingClass.h"

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        [Bootstrapper configureContainer];
        
        ImportingClass *ic = [[ImportingClass alloc] init];
        [[Container sharedContainer] satisfyImportsForObject:ic];
        [ic logMessage:@"Hello world"];
        
        return 0;
    }
}

