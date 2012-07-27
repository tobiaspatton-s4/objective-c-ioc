//
//  IInterceptor.h
//  TestDynamicProxy
//
//  Created by tobias patton on 7/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IInterceptor <NSObject>

- (void) willInvoke: (NSInvocation *)invocation;
- (void) didInvoke: (NSInvocation *)invocation;

@end
