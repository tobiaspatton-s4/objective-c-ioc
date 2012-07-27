//
//  CountingAspect.h
//  TestDynamicProxy
//
//  Created by tobias patton on 7/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IInterceptor.h"

@interface CountingAspect : NSObject<IInterceptor>

@property (nonatomic, retain) NSDictionary *InvocationCounts;

- (NSInteger) countForSelector: (SEL)selector inClass:(Class)class; 

@end
