//
//  OCIOCTests.m
//  OCIOCTests
//
//  Created by Tobias Patton on 8/1/12.
//
//

#import "OCIOCPropertyUtilsTests.h"
#import "OCIOCPROpertyUtils.h"

@protocol TestProtocolOne <NSObject>
@end

@protocol TestProtocolTwo <NSObject>
@end

@interface PropertyUtilsTestClass : NSObject
@property (nonatomic, retain) id idProperty;
@property (nonatomic, retain) NSString *stringProperty;
@property (nonatomic, retain) id<TestProtocolOne> idWithOneProtocolProperty;
@property (nonatomic, retain) id<TestProtocolOne, TestProtocolTwo> idWithTwoProtocolsProperty;@end

@implementation PropertyUtilsTestClass
@end

@implementation OCIOCPropertyUtilsTests

- (void)setUp
{
    [super setUp];
    self.properties = [OCIOCPropertyUtils classProperties:[PropertyUtilsTestClass class]];
    STAssertNotNil([self.properties valueForKey:@"idProperty"], @"Method did return any information for idProperty");
}

- (void)tearDown
{
    self.properties = nil;
    [super tearDown];
}

- (void)testIdProperty
{    
    NSDictionary *propertyAttributes = [self.properties valueForKey:@"idProperty"];
    STAssertNil([propertyAttributes valueForKey:kOCIOCPropertyType], @"Property type reported for 'id' property was not nil");
    STAssertNil([propertyAttributes valueForKey:kOCIOCPropertyProtocols], @"Protocol list reported for 'id' property was not nil");
}

- (void)testStringProperty
{    
    STAssertNotNil([self.properties valueForKey:@"stringProperty"], @"Method did return any information for idProperty");
    
    NSDictionary *propertyAttributes = [self.properties valueForKey:@"stringProperty"];
    STAssertEqualObjects([propertyAttributes valueForKey:kOCIOCPropertyType], [NSString class], @"Property type reported for NSString property was not NSString");
    STAssertNil([propertyAttributes valueForKey:kOCIOCPropertyProtocols], @"Protocol list reported for NSString property was not nil");
}

- (void)testIdWithOneProtocolProperty
{    
    STAssertNotNil([self.properties valueForKey:@"idWithOneProtocolProperty"], @"Method did return any information for idWithOneProtocolProperty");
    
    NSDictionary *propertyAttributes = [self.properties valueForKey:@"idWithOneProtocolProperty"];
    STAssertNil([propertyAttributes valueForKey:kOCIOCPropertyType], @"Property type reported for 'id<TestProtocolOne>' property was not nil");
    
    STAssertNotNil([propertyAttributes valueForKey:kOCIOCPropertyProtocols], @"Protocol list reported for id<TestProtocolOne>' property was nil");
    NSArray *protocols = [propertyAttributes valueForKey:kOCIOCPropertyProtocols];
    
    STAssertEquals([protocols count], (NSUInteger)1, @"Protocol count for id<TestProtocolOne> property was %u not 1", [protocols count]);    
    STAssertEquals([protocols objectAtIndex:0], @protocol(TestProtocolOne), @"Protocol reported for id<TestProtocolOne> propety was not TestProtocolOne");
}

- (void)testIdWithTwoProtocolsProperty
{
    STAssertNotNil([self.properties valueForKey:@"idWithTwoProtocolsProperty"], @"Method did return any information for idWithTwoProtocolsProperty");
    
    NSDictionary *propertyAttributes = [self.properties valueForKey:@"idWithTwoProtocolsProperty"];
    STAssertNil([propertyAttributes valueForKey:kOCIOCPropertyType], @"Property type reported for 'id<TestProtocolOne, TestProtocolTwo>' property was not nil");
        
    STAssertNotNil([propertyAttributes valueForKey:kOCIOCPropertyProtocols], @"Protocol list reported for id<TestProtocolOne, TestProtocolTwo>>' property was nil");
    NSArray *protocols = [propertyAttributes valueForKey:kOCIOCPropertyProtocols];
    
    STAssertEquals([protocols count], (NSUInteger)2, @"Protocol count for id<TestProtocolOne> property was %u not 2", [protocols count]);
    STAssertEquals([protocols objectAtIndex:0], @protocol(TestProtocolOne), @"First protocol reported for id<TestProtocolOne, TestProtocolTwo>> propety was %@ not TestProtocolOne", NSStringFromProtocol([protocols objectAtIndex:0]));
    STAssertEquals([protocols objectAtIndex:1], @protocol(TestProtocolTwo), @"First protocol reported for id<TestProtocolOne, TestProtocolTwo>> propety was %@ not TestProtocolTwo", NSStringFromProtocol([protocols objectAtIndex:1]));
}

@end
