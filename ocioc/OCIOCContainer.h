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
extern NSString *kOCIOCModeShared;
extern NSString *kOCIOCModeNonShared;

// Exception names
extern NSString *kOCIOCRecursionDepthExceededException;

+ (OCIOCContainer *) sharedContainer;

@property (nonatomic, retain) NSMutableDictionary *registeredClasses;
@property (nonatomic, retain) NSMutableDictionary *registeredInterceptors;
@property (nonatomic, retain) NSMutableDictionary *singletons;
@property (nonatomic, retain) NSMutableDictionary *imports;

- (void) registerClass:(Class)class withInitializer:(OCIOCInitializerBlock)initializer andMode:(const NSString *)mode;
- (void) registerProtocol:(Protocol *)proto withInitializer:(OCIOCInitializerBlock)initializer andMode:(const NSString *)mode;

- (void) registerInterceptor: (id<OCIOCIntercepting>)interceptor forProtocol: (Protocol *)proto;
- (id<OCIOCIntercepting>) InterceptorsForProtocol: (Protocol *)proto;

- (id) newInstanceOfClass: (Class)class;
- (id) newInstanceOfProtocol: (Protocol *)proto;

- (void) registerImportForProperty:(NSString *)propertyName inClass:(Class)class;

- (void) satisfyImportsForObject: (id)object;

@end
