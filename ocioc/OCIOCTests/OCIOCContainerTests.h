//
//  OCIOCContainerTests.h
//  ocioc
//
//  Created by Tobias Patton on 8/2/12.
//
//

#import <SenTestingKit/SenTestingKit.h>

@class ContainerTestInterceptor;

@interface OCIOCContainerTests : SenTestCase
@property (nonatomic, retain) ContainerTestInterceptor *testInterceptor;
@end
