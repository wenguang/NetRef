//
//  AFNHTTPEngine.m
//  NetRef
//
//  Created by wenguang pan on 2017/3/16.
//  Copyright © 2017年 wenguang pan. All rights reserved.
//

#import "AFNHTTPEngine.h"
#import "HttpRequest.h"
#import "HttpError.h"
#import "HttpResponse.h"
#import "JsonParser.h"
#import <AFNetworking.h>

#define AFNHTTPREQUEST_ENGINE_REQUESTKEY @"AFNHTTPREQUEST_ENGINE_REQUESTKEY"

@interface AFNHTTPEngine ()
{
    NSMutableDictionary         *_httpRequestsDic;  // key is HTTPRequest's requestId, value is HTTPRequest.
}
@end

@implementation AFNHTTPEngine

- (void)sendRequest:(HttpRequest *)request modelClass:(Class)modelClass completionHandler:(HttpCompletionHandler)completionHandler
{
    [request buildRequestHeaders];
    
    AFHTTPSessionManager *httpManager = [AFHTTPSessionManager new];
    [httpManager.requestSerializer setStringEncoding:NSUTF8StringEncoding];
    [httpManager.requestSerializer setTimeoutInterval:request.timeoutInterval];
    [httpManager.requestSerializer setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [httpManager.requestSerializer setAllowsCellularAccess:YES];
    for (int i=0; i<request.requestHeaders.count; i++)
    {
        [httpManager.requestSerializer setValue:request.requestHeaders.allValues[i]
                             forHTTPHeaderField:request.requestHeaders.allKeys[i]];
    }
    
    __weak HttpRequest *currentRequest = request;
    __weak AFNHTTPEngine *weakSelf = self;
    
    [_httpRequestsDic setObject:request forKey:@(request.requestId)];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    if (request.methodType == HttpMethodTypeGet)
    {
        [httpManager GET:request.URLString
              parameters:request.parameters
                 success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject)
                {
                    [weakSelf handleSuccessRequest:currentRequest
                                              task:task
                                    responseObject:responseObject
                                        modelClass:modelClass
                                 completionHandler:completionHandler];
                }
                 failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
                {
                    [weakSelf handleFailureRequest:currentRequest
                                          task:task
                                         error:error
                                    modelClass:modelClass
                             completionHandler:completionHandler];
                }];
    }
    else if (request.methodType == HttpMethodTypePost)
    {
        [httpManager POST:request.URLString
               parameters:request.parameters
                  success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject)
                 {
                     [weakSelf handleSuccessRequest:currentRequest
                                               task:task
                                     responseObject:responseObject
                                         modelClass:modelClass
                                  completionHandler:completionHandler];
                 }
                          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
                 {
                     [weakSelf handleFailureRequest:currentRequest
                                               task:task
                                              error:error
                                         modelClass:modelClass
                                  completionHandler:completionHandler];
                 }];
    }
    else
    {
        NSLog(@"NOT IMP!");
    }
}

#pragma mark - Private Methods

- (void)handleFailureRequest:(HttpRequest *)request
                        task:(NSURLSessionDataTask *)task
                       error:(NSError *)error
                  modelClass:(Class)modelClass
           completionHandler:(HttpCompletionHandler)completionHandler
{
    [_httpRequestsDic removeObjectForKey:@(request.requestId)];
    if (_httpRequestsDic.count == 0)
    {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
    
    if (request.retryCount > 0)
    {
        request.retryCount--;
        [self sendRequest:request modelClass:modelClass completionHandler:completionHandler];
    }
    else
    {
        HttpError *errorResponse = [HttpError errorWithCode:HttpErrorTypeNetwork
                                                    subcode:error.code
                                                    message:error.localizedFailureReason
                                                     detail:error];
        
        completionHandler(nil, errorResponse);
    }
}

- (void)handleSuccessRequest:(HttpRequest *)request
                        task:(NSURLSessionDataTask *)task
              responseObject:(id)responseObject
                  modelClass:(Class)modelClass
           completionHandler:(HttpCompletionHandler)completionHandler
{
    [_httpRequestsDic removeObjectForKey:@(request.requestId)];
    if (_httpRequestsDic.count == 0)
    {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
    
    HttpDataType responseDataType = HttpDataTypeJSON;
    NSString *MIMEType = task.response.MIMEType;
    if ([MIMEType rangeOfString:@"json"].location != NSNotFound
        || [responseObject isKindOfClass:[NSDictionary class]])
    {
        responseDataType = HttpDataTypeJSON;
    }
    else
    {
        responseDataType = -1;
    }
    
    if (responseDataType != HttpDataTypeJSON)
    {
        HttpError *errorResponse = [HttpError errorWithCode:HttpErrorTypeReturn
                                                    subcode:-1
                                                    message:@"接口返回数据格式有误"
                                                     detail:nil];
        
        completionHandler(nil, errorResponse);
    }
    
    if (request.asyncParseResponse) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            JsonParser *parser = [JsonParser new];
            HttpResponse *response = [parser parseJSON:responseObject modelClass:modelClass];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(response, nil);
            });
        });
    }
    else
    {
        JsonParser *parser = [JsonParser new];
        HttpResponse *response = [parser parseJSON:responseObject modelClass:modelClass];
        completionHandler(response, nil);
    }
}

@end
