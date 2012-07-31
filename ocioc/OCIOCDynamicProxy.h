//
//  DynamicProxy.h
//  TestDynamicProxy
//
//  Created by tobias patton on 7/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OCIOCIntercepting.h"

typedef id (^InitializerBlock)();

@interface OCIOCDynamicProxy : NSObject

@property (nonatomic, retain) id InnerObject;
@property (nonatomic, retain) NSMutableArray *Interceptors;

- (id) initWithBlock: (InitializerBlock)initializerBlock;
- (void) addInterceptor: (id<OCIOCIntercepting>) interceptor;
- (Class) InnerClass;

@end
