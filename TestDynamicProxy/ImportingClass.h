//
//  ImportingClass.h
//  TestDynamicProxy
//
//  Created by tobias patton on 12-07-28.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ILogger.h"
#import "SupportsLogging.h"

@interface ImportingClass : NSObject

@property (nonatomic, retain) id<ILogger> importLogger;

- (void) logMessage: (NSString *)message;

@end
