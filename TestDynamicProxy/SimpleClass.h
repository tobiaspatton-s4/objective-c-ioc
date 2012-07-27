//
//  SimpleClass.h
//  TestDynamicProxy
//
//  Created by tobias patton on 7/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SupportsLogging.h"
#import "SupportsCounting.h"

@interface SimpleClass : NSObject<SupportsLogging, SupportsCounting>

- (void) doIt;
- (NSString *) returnIt;

@end
