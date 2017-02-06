//
//  BaiduTraceSDK.h
//  BaiduTraceSDK
//
//  Created by Daniel Bey on 8/1/16.
//  Copyright © 2016 Daniel Bey. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for BaiduTraceSDK.
FOUNDATION_EXPORT double BaiduTraceSDKVersionNumber;

//! Project version string for BaiduTraceSDK.
FOUNDATION_EXPORT const unsigned char BaiduTraceSDKVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <BaiduTraceSDK/PublicHeader.h>
typedef void (*squeal_destructor_type)(void*);
const squeal_destructor_type SQUEAL_STATIC = ((squeal_destructor_type)0);
const squeal_destructor_type SQUEAL_TRANSIENT = ((squeal_destructor_type)-1);

#ifndef __BaiduTraceSDK__Umbrella__
#define __BaiduTraceSDK__Umbrella__
#include "CppInterface.h"
#endif