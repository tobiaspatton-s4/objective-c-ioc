//
//  DynamicProxy.h
//  TestDynamicProxy
//
//  Created by tobias patton on 7/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IInterceptor.h"

typedef id (^InitializerBlock)();

@interface DynamicProxy : NSObject

@property (nonatomic, retain) id InnerObject;
@property (nonatomic, retain) NSMutableArray *Interceptors;

- (id) initWithBlock: (InitializerBlock)initializerBlock;
- (id) initWithBlock: (InitializerBlock)initializerBlock andInterceptors:(NSArray *)interceptors;
- (void) addInterceptor: (id<IInterceptor>) interceptor;
- (Class) InnerClass;

@end
