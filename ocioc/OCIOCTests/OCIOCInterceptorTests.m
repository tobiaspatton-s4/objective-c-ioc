//
//  OCIOCInterceptorTests.m
//  ocioc
//
//  Created by Tobias Patton on 8/2/12.
//
//

#import "OCIOCInterceptorTests.h"
#import "OCIOCIntercepting.h"
#import "OCIOCDynamicProxy.h"

@protocol Testing<NSObject>
@end

@interface InvocationCountingInterceptor : NSObject<OCIOCIntercepting>
@property (nonatomic, retain) NSMutableDictionary *willInvokeCounts;
@property (nonatomic, retain) NSMutableDictionary *didInvokeCounts;
- (void) incrementCountForInvocation: (NSInvocation *)invocation inDictionary:(NSMutableDictionary *) dictionary;
@end

@implementation InvocationCountingInterceptor

- (id) init
{
    if(self = [super init])
    {
        self.willInvokeCounts = [[NSMutableDictionary alloc] init];
        self.didInvokeCounts = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void) dealloc
{
    self.willInvokeCounts = nil;
    self.didInvokeCounts = nil;
    [super dealloc];
}

- (void) incrementCountForInvocation: (NSInvocation *)invocation inDictionary:(NSMutableDictionary *) dictionary
{
    NSString *key = NSStringFromSelector([invocation selector]);
    NSNumber *value = [dictionary valueForKey:key];
    if(value == nil)
    {
        value = [NSNumber numberWithUnsignedInt:1];
    }
    else
    {
        value = [NSNumber numberWithUnsignedInt:[value unsignedIntValue] + 1];
    }
    
    [dictionary setValue:value forKey:key];
}

- (void) willInvoke: (NSInvocation *)invocation
{
    [self incrementCountForInvocation: invocation inDictionary:self.willInvokeCounts];
}

- (void) didInvoke: (NSInvocation *)invocation
{
    [self incrementCountForInvocation: invocation inDictionary:self.didInvokeCounts];
}
@end

@interface InterceptorTestClass : NSObject<Testing>
- (void) firstTestMethod;
- (void) secondTestMethod;
@end

@implementation InterceptorTestClass
- (void) firstTestMethod {}
- (void) secondTestMethod {}
@end

@implementation OCIOCInterceptorTests

@synthesize proxy;

- (void) setUp
{
    [super setUp];
    self.proxy = [[OCIOCDynamicProxy alloc] initWithBlock:^(){ return [[InterceptorTestClass alloc] init]; }];
    self.interceptor = [[InvocationCountingInterceptor alloc] init];
    
    [self.proxy addInterceptor:self.interceptor];
}

- (void) tearDown
{
    self.proxy = nil;
    self.interceptor = nil;
    [super tearDown];
}

- (void) testInterceptor
{
    const unsigned FIRST_METHOD_INVOCATION_COUNT = 5;
    const unsigned SECOND_METHOD_INVOCATION_COUNT = 3;
    
    for(unsigned i = 0; i < FIRST_METHOD_INVOCATION_COUNT; i++)
    {
        [self.proxy firstTestMethod];
    }
    
    for(unsigned i = 0; i < SECOND_METHOD_INVOCATION_COUNT; i++)
    {
        [self.proxy secondTestMethod];
    }
    
    STAssertEquals(FIRST_METHOD_INVOCATION_COUNT, [[self.interceptor.willInvokeCounts valueForKey:@"firstTestMethod"] unsignedIntValue], @"Interceptor should have been called %u times for firstTestMethod. Actual count was %@", FIRST_METHOD_INVOCATION_COUNT, [self.interceptor.willInvokeCounts valueForKey:@"firstTestMethod"]);
    STAssertEquals(FIRST_METHOD_INVOCATION_COUNT, [[self.interceptor.didInvokeCounts valueForKey:@"firstTestMethod"] unsignedIntValue], @"Interceptor should have been called %u times for firstTestMethod. Actual count was %@", FIRST_METHOD_INVOCATION_COUNT, [self.interceptor.didInvokeCounts valueForKey:@"firstTestMethod"]);
    
    STAssertEquals(SECOND_METHOD_INVOCATION_COUNT, [[self.interceptor.willInvokeCounts valueForKey:@"secondTestMethod"] unsignedIntValue], @"Interceptor should have been called %u times for firstTestMethod. Actual count was %@", SECOND_METHOD_INVOCATION_COUNT, [self.interceptor.willInvokeCounts valueForKey:@"secondTestMethod"]);
    STAssertEquals(SECOND_METHOD_INVOCATION_COUNT, [[self.interceptor.didInvokeCounts valueForKey:@"secondTestMethod"] unsignedIntValue], @"Interceptor should have been called %u times for firstTestMethod. Actual count was %@", SECOND_METHOD_INVOCATION_COUNT, [self.interceptor.didInvokeCounts valueForKey:@"secondTestMethod"]);
}

@end
