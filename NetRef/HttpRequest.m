//
//  HttpRequest.m
//  NetRef
//
//  Created by wenguang pan on 2017/3/12.
//  Copyright © 2017年 VIP. All rights reserved.
//

#import "HttpRequest.h"
#import "APISign.h"
#import <OpenUDID/OpenUDID.h>

static NSUInteger HTTP_REQUEST_ID = 0;         // 标识一个唯一的请求，递增

@implementation HttpRequest

- (id)init
{
    if (self = [super init]) {
        _requestHeaders = [[NSMutableDictionary alloc] init];
        _parameters = [[NSMutableDictionary alloc] init];
        _requestId = ++HTTP_REQUEST_ID;
        _requestType = HttpRequestTypeAsync;
        _methodType = HttpMethodTypeGet;
        _timeoutInterval = 15;
        _retryCount = 1;
        _asyncParseResponse = YES;
        
        [self buildCommonParameters];
    }
    return self;
}

#pragma mark - Http Request Headers.

- (void)addRequestHeaderWithKey:(NSString *)key value:(id)value
{
    [_requestHeaders setValue:value forKeyPath:key];
}

- (void)removeRequestHeaderWithKey:(NSString *)key
{
    [_requestHeaders removeObjectForKey:key];
}

- (void)clearAllRequestHeaders
{
    [_requestHeaders removeAllObjects];
}

- (void)buildRequestHeaders
{
    [self.requestHeaders removeAllObjects];
    NSString *signAuthorizationKey = [APISign authKey];
    NSString *signAuthorizationValue = [APISign signValueWithParamters:[self parameters]];
    [self addRequestHeaderWithKey:signAuthorizationKey value:signAuthorizationValue];
}


#pragma mark - Http Request Parameters.

- (void)addParameterWithKey:(NSString *)key value:(id)value
{
    [_parameters setValue:value forKeyPath:key];
}

- (void)removeParameterWithKey:(NSString *)key
{
    [_parameters removeObjectForKey:key];
}

- (void)clearAllParameters
{
    [_parameters removeAllObjects];
}

- (void)buildCommonParameters {
    [self addParameterWithKey:@"apiKey" value:API_KEY];
    [self addParameterWithKey:@"marsCid" value:[OpenUDID value]];
    
    long long timestamp = (long long)[[NSDate date] timeIntervalSince1970];
    NSString *timestampString = [NSString stringWithFormat:@"%lld", timestamp];
    [self addParameterWithKey:@"timestamp" value:timestampString];
    //TODO: add token 参数
}


@end
