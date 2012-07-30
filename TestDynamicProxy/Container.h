//
//  Container.h
//  TestDynamicProxy
//
//  Created by tobias patton on 7/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DynamicProxy.h"
#import "IInterceptor.h"

@interface Container : NSObject

// Mode parameter for registerClass::
extern const NSString *modeShared;
extern const NSString *modeNonShared;

+ (Container *) sharedContainer;

@property (nonatomic, retain) NSMutableDictionary *RegisteredClasses;
@property (nonatomic, retain) NSMutableDictionary *RegisteredInterceptors;
@property (nonatomic, retain) NSMutableDictionary *Singletons;

- (void) registerClass:(Class)class withInitializer:(InitializerBlock)initializer andMode:(const NSString *)mode;
- (void) registerProtocol:(Protocol *)proto withInitializer:(InitializerBlock)initializer andMode:(const NSString *)mode;

- (void) registerInterceptor: (id<IInterceptor>)interceptor forProtocol: (Protocol *)proto;
- (id<IInterceptor>) InterceptorForProtocol: (Protocol *)proto;

- (id) newInstanceOfClass: (Class)class;
- (id) newInstanceOfProtocol: (Protocol *)proto;

- (void) satisfyImportsForObject: (id)object;

@end
