//
//  OCIOCMacros.h
//  ocioc
//
//  Created by tobias patton on 12-09-05.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef ocioc_OCIOCMacros_h
#define ocioc_OCIOCMacros_h

#define OCIOC_BEGIN_IMPORTS + (void) initialize \
{

#define OCIOC_REGISTER_IMPORT(p, c) [[OCIOCContainer sharedContainer] registerImportForProperty: @"p" inClass:[c class]]; 

#define OCIOC_END_IMPORTS }

#endif
