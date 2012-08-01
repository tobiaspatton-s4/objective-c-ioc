//
//  OCIOCDynamicProxyTests.h
//  ocioc
//
//  Created by Tobias Patton on 8/1/12.
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "OCIOCDynamicProxy.h"

@class DynamicProxyTestClass;

@interface OCIOCDynamicProxyTests : SenTestCase

@property (nonatomic, retain) DynamicProxyTestClass *instance;
@property (nonatomic, retain) id proxy;

@end
