//
//  DynamicProxy.h
//  TestDynamicProxy
//
//  Created by tobias patton on 7/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OCIOCIntercepting.h"

typedef id (^OCIOCInitializerBlock)();

@interface OCIOCDynamicProxy : NSProxy

@property (nonatomic, retain) id innerObject;
@property (nonatomic, retain) NSMutableArray *interceptors;

- (id) initWithBlock: (OCIOCInitializerBlock)initializerBlock;
- (void) addInterceptor: (id<OCIOCIntercepting>) interceptor;
- (Class) InnerClass;

@end
