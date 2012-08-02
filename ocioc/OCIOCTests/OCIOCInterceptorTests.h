//
//  OCIOCInterceptorTests.h
//  ocioc
//
//  Created by Tobias Patton on 8/2/12.
//
//

#import <SenTestingKit/SenTestingKit.h>

@class InvocationCountingInterceptor;

@interface OCIOCInterceptorTests : SenTestCase
@property (nonatomic, retain) id proxy;
@property (nonatomic, retain) InvocationCountingInterceptor *interceptor;
@end
