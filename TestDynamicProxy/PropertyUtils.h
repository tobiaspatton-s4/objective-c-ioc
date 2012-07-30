//
//  PropertyUtils.h
//  TestDynamicProxy
//
//  Created by tobias patton on 12-07-28.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

// The property's return type. The value type is "Class" or nil if propety returns "id"
extern NSString *PropertyType;

// The property's return type protocol list. The value type is "NSArray". Each array element has the type "Protocol *".
extern NSString *PropertyProtocols;

@interface PropertyUtils : NSObject

+ (NSDictionary *) classProperties: (Class)class;

@end
