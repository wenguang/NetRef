//
//  HTTPEngine.h
//  NetRef
//
//  Created by wenguang pan on 2017/3/16.
//  Copyright © 2017年 wenguang pan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HttpRequest;
@class HttpResponse;
@class HttpError;

typedef void (^HttpCompletionHandler)(HttpResponse *response, HttpError *error);

/**
 *  @brief 网络引擎基类.
 */
@interface HTTPEngine : NSObject

- (void)sendRequest:(HttpRequest *)request modelClass:(Class)modelClass completionHandler:(HttpCompletionHandler)completionHandler;

@end
