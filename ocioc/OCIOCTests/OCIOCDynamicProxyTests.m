//
//  OCIOCDynamicProxyTests.m
//  ocioc
//
//  Created by Tobias Patton on 8/1/12.
//
//

#import "OCIOCDynamicProxyTests.h"

@interface DynamicProxyTestClass : NSObject

@property (nonatomic, assign) int intProperty;
@property (nonatomic, assign) int valueFromInstanceMethod;
- (void) instanceMethod: (int) value;
@end

@implementation DynamicProxyTestClass

- (void) instanceMethod: (int) value
{
    self.valueFromInstanceMethod = value;
}

@end

@implementation OCIOCDynamicProxyTests

- (void)setUp
{
    self.instance = [[DynamicProxyTestClass alloc] init];
    self.proxy = [[OCIOCDynamicProxy alloc] initWithBlock:^(){return [self.instance retain]; }];
    [super setUp];
}

- (void)tearDown
{
    self.instance = nil;
    self.proxy = nil;
    [super tearDown];
}

- (void)testProxiedProperty
{
    self.instance.intProperty = 100;
    
    // Property syntax (ie. foo.bar.gak) cannot be proxied, as the property path is validated at compile time.
    // So we rely on setter and getter methods.
    STAssertEquals(100, [self.proxy intProperty], @"Proxied property does not match the value that was set on the instance");
    
    [self.proxy setIntProperty:200];
    STAssertEquals(200, self.instance.intProperty, @"Instance property does not match the value that was set on the proxy");
}

- (void)testProxiedInstanceMethod
{
    [self.instance instanceMethod:100];
    STAssertEquals(100, [self.proxy valueFromInstanceMethod], @"Proxied value does not match the value that was passed to method on the instance");
    
    [self.proxy instanceMethod:200];
    STAssertEquals(200, [self.instance valueFromInstanceMethod], @"Instance value does not match the value that was passed to method on the proxy");
}

- (void)testUndeclaredMethod
{
    STAssertThrows([self.proxy methodThatDoesNotExist: 100], @"Invoking undeclared method did not throw");
}

@end
