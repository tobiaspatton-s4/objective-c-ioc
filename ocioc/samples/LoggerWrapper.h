//
//  LoggerWrapper.h
//  samples
//
//  Created by tobias patton on 12-09-05.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SupportsLogging.h"
#import "Logging.h"

@interface LoggerWrapper : NSObject<SupportsLogging>

@property (nonatomic, retain) id<Logging> logger;

- (void) logMessage: (NSString *)msg;

@end
