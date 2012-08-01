//
//  Container.h
//  TestDynamicProxy
//
//  Created by tobias patton on 7/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OCIOCDynamicProxy.h"
#import "OCIOCIntercepting.h"

@interface OCIOCContainer : NSObject

// Mode parameter for registerClass::
extern const NSString *modeShared;
extern const NSString *modeNonShared;

+ (OCIOCContainer *) sharedContainer;

@property (nonatomic, retain) NSMutableDictionary *registeredClasses;
@property (nonatomic, retain) NSMutableDictionary *registeredInterceptors;
@property (nonatomic, retain) NSMutableDictionary *singletons;

- (void) registerClass:(Class)class withInitializer:(OCIOCInitializerBlock)initializer andMode:(const NSString *)mode;
- (void) registerProtocol:(Protocol *)proto withInitializer:(OCIOCInitializerBlock)initializer andMode:(const NSString *)mode;

- (void) registerInterceptor: (id<OCIOCIntercepting>)interceptor forProtocol: (Protocol *)proto;
- (id<OCIOCIntercepting>) InterceptorForProtocol: (Protocol *)proto;

- (id) newInstanceOfClass: (Class)class;
- (id) newInstanceOfProtocol: (Protocol *)proto;

- (void) satisfyImportsForObject: (id)object;

@end
