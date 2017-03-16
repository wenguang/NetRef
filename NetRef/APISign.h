//
//  APISign.h
//  NetRef
//
//  Created by wenguang pan on 2017/3/14.
//  Copyright © 2017年 wenguang pan. All rights reserved.
//

#import <Foundation/Foundation.h>

#define APP_SECRET @""
#define API_KEY @""

@interface APISign : NSObject

+ (NSString *)signValueWithParamters:(NSDictionary *)parameters;

+ (NSString *)authKey;

@end
