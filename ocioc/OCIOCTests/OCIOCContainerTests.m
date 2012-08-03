//
//  OCIOCContainerTests.m
//  ocioc
//
//  Created by Tobias Patton on 8/2/12.
//
//

#import "OCIOCContainerTests.h"
#import "OCIOCContainer.h"

@protocol ContainerTestProtocol
@end

@interface ContainerTestProtocolImplementation : NSObject<ContainerTestProtocol>
@end

@implementation ContainerTestProtocolImplementation
@end

@interface ContainerSingletonTestClass : NSObject
@end

@implementation ContainerSingletonTestClass
@end

@interface TestDepencency : NSObject
@end

@implementation TestDepencency
@end

@interface ContainerTestClass : NSObject
@property (nonatomic, retain) id<ContainerTestProtocol> importProtocolDependency;
@property (nonatomic, retain) TestDepencency *importClassDependency;
@end

@implementation ContainerTestClass
@synthesize importProtocolDependency;
@synthesize importClassDependency;
@end

@interface NestingContainerTestClass : NSObject
@property (nonatomic, retain) ContainerTestClass *importClassDependency;
@end

@implementation NestingContainerTestClass
@synthesize importClassDependency;
@end

@interface InfiniteRegressionTestClass : NSObject
@property (nonatomic, retain) InfiniteRegressionTestClass *importedRecursion;
@end

@implementation InfiniteRegressionTestClass
@synthesize importedRecursion;
@end

@implementation OCIOCContainerTests

- (void) setUp
{
    [[OCIOCContainer sharedContainer] registerProtocol:@protocol(ContainerTestProtocol)
                                       withInitializer:^(){ return [[ContainerTestProtocolImplementation alloc] init]; }
                                               andMode:kOCIOCModeNonShared];
    
    [[OCIOCContainer sharedContainer] registerClass:[ContainerTestClass class]
                                    withInitializer:^(){ return [[ContainerTestClass alloc] init]; }
                                            andMode:kOCIOCModeNonShared];
    
    [[OCIOCContainer sharedContainer] registerClass:[ContainerSingletonTestClass class]
                                    withInitializer:^(){ return [[ContainerSingletonTestClass alloc] init]; }
                                            andMode:kOCIOCModeShared];
    
    [[OCIOCContainer sharedContainer] registerClass:[TestDepencency class]
                                    withInitializer:^(){ return [[TestDepencency alloc] init]; }
                                            andMode:kOCIOCModeShared];
    
    [[OCIOCContainer sharedContainer] registerClass:[NestingContainerTestClass class]
                                    withInitializer:^(){ return [[NestingContainerTestClass alloc] init]; }
                                            andMode:kOCIOCModeShared];
    
    [[OCIOCContainer sharedContainer] registerClass:[InfiniteRegressionTestClass class]
                                    withInitializer:^(){ return [[InfiniteRegressionTestClass alloc] init]; }
                                            andMode:kOCIOCModeShared];
}

- (void) tearDown
{
    
}

- (void) testRegisterBlockForProtocol
{
    id protoImpl = [[OCIOCContainer sharedContainer] newInstanceOfProtocol:@protocol(ContainerTestProtocol)];
    STAssertTrue([protoImpl isKindOfClass:[ContainerTestProtocolImplementation class]], @"Expected container to give instance of ContainerTestProtocolImplementation. Returned object is of class %@", NSStringFromClass([protoImpl class]));
}

- (void) testRegisterBlockForClass
{
    id classImpl = [[OCIOCContainer sharedContainer] newInstanceOfClass:[ContainerTestClass class]];
    STAssertTrue([classImpl isKindOfClass:[ContainerTestClass class]], @"Expected container to give instance of ContainerTestClass. Returned object is of class %@", NSStringFromClass([classImpl class]));
}

- (void) testSingleton
{
    id singletonImpl1 = [[OCIOCContainer sharedContainer] newInstanceOfClass:[ContainerSingletonTestClass class]];
    id singletonImpl2 = [[OCIOCContainer sharedContainer] newInstanceOfClass:[ContainerSingletonTestClass class]];
    
    STAssertTrue([singletonImpl1 isEqual:singletonImpl2], @"Singleton objects returned from container are not the same");
}

- (void) testProtocolDependencySatisfied
{
    ContainerTestClass *testObject = [[OCIOCContainer sharedContainer] newInstanceOfClass:[ContainerTestClass class]];
    STAssertNotNil(testObject.importProtocolDependency, @"Property importProtocolDependency was not injected.");
}

- (void) testClassDependencySatisfied
{
    ContainerTestClass *testObject = [[OCIOCContainer sharedContainer] newInstanceOfClass:[ContainerTestClass class]];
    STAssertNotNil(testObject.importClassDependency, @"Property importClassDependency was not injected.");
}

- (void) testTwoLevelsOfDepenciesSatisfied
{
    NestingContainerTestClass *testObject = [[OCIOCContainer sharedContainer] newInstanceOfClass:[NestingContainerTestClass class]];
    STAssertNotNil(testObject.importClassDependency, @"Property importClassDependency was not injected.");
    STAssertNotNil(testObject.importClassDependency.importProtocolDependency, @"Property importClassDependency.importProtocolDependency was not injected.");
    STAssertNotNil(testObject.importClassDependency.importClassDependency, @"Property importClassDependency.importProtocolDependency was not injected.");
}

- (void) testInfiniteRecursionThrows
{
    STAssertThrows([[OCIOCContainer sharedContainer] newInstanceOfClass:[InfiniteRegressionTestClass class]],
                   @"Getting instance of class with recursive depenencies should throw");
}

// TODO: Test registered interceptors

@end
