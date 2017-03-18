//
//  HttpRequest.h
//  NetRef
//
//  Created by wenguang pan on 2017/3/12.
//  Copyright © 2017年 wenguang pan. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  @brief 网络请求类型枚举.
 */
typedef NS_ENUM (NSInteger, HttpRequestType) {
    HttpRequestTypeAsync = 1, // 异步请求.
    HttpRequestTypeSync,      // 同步请求.
};

/**
 *  @brief 网络请求Http Method类型枚举.
 */
typedef NS_ENUM (NSInteger, HttpMethodType) {
    HttpMethodTypeGet = 1,    // GET请求
    HttpMethodTypePost,       // POST请求
};


@interface HttpRequest : NSObject

@property (nonatomic, strong, readonly) NSMutableDictionary *requestHeaders;
@property (nonatomic, strong, readonly) NSMutableDictionary *parameters;
@property (nonatomic, copy) NSString *URLString;

@property (nonatomic, assign, readonly) NSInteger requestId;
@property (nonatomic, assign) HttpRequestType requestType;
@property (nonatomic, assign) HttpMethodType methodType;
@property (nonatomic, assign) NSTimeInterval timeoutInterval;
@property (nonatomic, assign) NSUInteger retryCount;
@property (nonatomic, assign) BOOL asyncParseResponse;


#pragma mark - Http Request Headers.

- (void)addRequestHeaderWithKey:(NSString *)key value:(id)value;
- (void)removeRequestHeaderWithKey:(NSString *)key;
- (void)clearAllRequestHeaders;
- (void)buildRequestHeaders;

#pragma mark - Http Request Parameters.

- (void)addParameterWithKey:(NSString *)key value:(id)value;
- (void)removeParameterWithKey:(NSString *)key;
- (void)clearAllParameters;

@end
