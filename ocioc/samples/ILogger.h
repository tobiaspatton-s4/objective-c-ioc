//
//  ILogger.h
//  TestDynamicProxy
//
//  Created by tobias patton on 12-07-28.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ILogger <NSObject>
@required
- (void) logMessage: (NSString *)msg;
@end
