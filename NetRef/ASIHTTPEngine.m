//
//  ASIHTTPEngine.m
//  NetRef
//
//  Created by wenguang pan on 2017/3/11.
//  Copyright © 2017年 wenguang pan. All rights reserved.
//

#import "ASIHTTPEngine.h"
#import <ASIHTTPRequest/ASIFormDataRequest.h>
#import <ASIHTTPRequest/ASINetworkQueue.h>
#import <ASIHTTPRequest/ASIHTTPRequest.h>
#import "HttpRequest.h"
#import "HttpError.h"
#import "HttpResponse.h"
#import "JsonParser.h"

#define ASIHTTPREQUEST_ENGINE_REQUESTKEY @"ASIHTTPREQUEST_ENGINE_REQUESTKEY"
#define ASIHTTPREQUEST_DID_RECEIVED_DATA_LENGTH @"ASIHTTPREQUEST_DID_RECEIVED_DATA_LENGTH"

@interface ASIHTTPEngine()
{
    NSMutableDictionary         *_httpRequestsDic;  // key is HTTPRequest's requestId, value is ASIHttpRequest.
    
    // about download
    ASINetworkQueue             *_downloadNetworkQueue;     // 下载队列.
    NSMutableArray              *_downloadingURLsArray;     // 已经在下载队列的下载资源URL.
}

@end

@implementation ASIHTTPEngine

- (id)init
{
    if (self = [super init]) {
        _httpRequestsDic = [[NSMutableDictionary alloc] init];
        _downloadingURLsArray = [[NSMutableArray alloc] init];
        
        _downloadNetworkQueue = [[ASINetworkQueue alloc] init];
        [_downloadNetworkQueue setMaxConcurrentOperationCount:3];
        [_downloadNetworkQueue setShowAccurateProgress:YES];
        [_downloadNetworkQueue setShouldCancelAllRequestsOnFailure:NO];
        [_downloadNetworkQueue go];
    }
    return self;
}

- (void)sendRequest:(HttpRequest *)request modelClass:(Class)modelClass completionHandler:(HttpCompletionHandler)completionHandler
{
    [request buildRequestHeaders];
    
    NSString *URLString = request.URLString;
    
    //处理GET请求
    if (request.methodType == HttpMethodTypeGet)
    {
        NSDictionary *parametersDictionary = request.parameters;
        NSInteger parametersCount = [parametersDictionary count];
        if (parametersCount > 0)
        {
            if ([URLString rangeOfString:@"?"].location == NSNotFound)
            {
                URLString = [URLString stringByAppendingString:@"?"];
            }
            NSMutableString *parameterString = [NSMutableString string];
            NSArray *keyArray = parametersDictionary.allKeys;
            for (NSUInteger i = 0; i < parametersCount; i++) {
                NSString *key = [keyArray objectAtIndex:i];
                id value = [parametersDictionary valueForKey:key];
                [parameterString appendFormat:@"%@=%@",key, value];
                if (i < parametersCount - 1)
                {
                    [parameterString appendString:@"&"];
                }
            }
            NSString *paramString = [NSString stringWithString:parameterString];
            paramString = [paramString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            URLString = [URLString stringByAppendingFormat:@"%@", paramString];
        }
    }
    
    ASIFormDataRequest *formDataRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:URLString]];
#ifdef DEBUG
    [formDataRequest setValidatesSecureCertificate:NO];
#endif
    formDataRequest.stringEncoding = NSUTF8StringEncoding;
    formDataRequest.timeOutSeconds = request.timeoutInterval;
    formDataRequest.requestMethod = request.methodType == HttpMethodTypeGet ? @"GET" : @"POST";
    formDataRequest.requestHeaders = (NSMutableDictionary *)request.requestHeaders;
    
    //处理POST请求
    if (request.methodType == HttpMethodTypePost)
    {
        for (NSString *key in request.parameters.allKeys)
        {
            id object = [request.parameters objectForKey:key];
            if ([[object class] isSubclassOfClass:[UIImage class]])
            {
                NSData *imageData = UIImageJPEGRepresentation(object, 1);
                [formDataRequest addData:imageData
                            withFileName:[NSString stringWithFormat:@"%@.jpg", key]
                          andContentType:@"image/jpeg"
                                  forKey:key];
            }
            else if ([[object class] isSubclassOfClass:[NSData class]])
            {
                [formDataRequest addData:object
                            withFileName:[NSString stringWithFormat:@"%@.jpg", key]
                          andContentType:@"image/jpeg"
                                  forKey:key];
            }
            else
            {
                [formDataRequest addPostValue:object forKey:key];
            }
        }
    }
    
    __weak ASIHTTPEngine *weakSelf = self;
    __weak ASIFormDataRequest *weakFormDataRequest = formDataRequest;
    
    //请求完成block
    [formDataRequest setCompletionBlock:^{
        
        HttpRequest *currentRequest = [weakFormDataRequest.userInfo valueForKey:ASIHTTPREQUEST_ENGINE_REQUESTKEY];
        
        NSLog(@"{\nrequest url = %@\nrequest herader = %@\nrequest parameter = %@\nresponse string = %@\n}",
              weakFormDataRequest.url, weakFormDataRequest.requestHeaders, currentRequest.parameters, weakFormDataRequest.responseString);
        
        [_httpRequestsDic removeObjectForKey:[NSNumber numberWithUnsignedInteger:currentRequest.requestId]];
        if ([_httpRequestsDic count] == 0)
        {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
        
        if (weakFormDataRequest.responseStatusCode != 200)
        {
            
            if (currentRequest.retryCount > 0)
            {
                currentRequest.retryCount = (--currentRequest.retryCount);
                [weakSelf sendRequest:currentRequest modelClass:modelClass completionHandler:completionHandler];
            }
            else
            {
                HttpError *errorResponse = [HttpError errorWithCode:HttpErrorTypeNetwork
                                                            subcode:weakFormDataRequest.responseStatusCode
                                                            message:weakFormDataRequest.responseStatusMessage
                                                             detail:weakFormDataRequest.error];
                
                completionHandler(nil, errorResponse);
            }
        }
        else
        {
            HttpDataType responseDataType = HttpDataTypeJSON;
            NSString *contentType = [weakFormDataRequest.responseHeaders objectForKey:@"Content-Type"];
            if ([contentType rangeOfString:@"json"].location != NSNotFound)
            {
                responseDataType = HttpDataTypeJSON;
            }
            else if (weakFormDataRequest.responseData)
            {
                NSError *error;
                id json = [NSJSONSerialization JSONObjectWithData:weakFormDataRequest.responseData
                                                          options:NSJSONReadingAllowFragments
                                                            error:&error];
                if (!error && json)
                {
                    responseDataType = HttpDataTypeJSON;
                }
                else
                {
                    responseDataType = -1;
                }
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
            
            __block NSError *error = nil;
            __block id jsonObject;
            if (currentRequest.asyncParseResponse) {
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                dispatch_async(queue, ^{
                    jsonObject = [NSJSONSerialization JSONObjectWithData:weakFormDataRequest.responseData
                                                                 options:NSJSONReadingAllowFragments
                                                                   error:&error];
                    if (error || !jsonObject)
                    {
                        HttpError *errorResposne = [HttpError errorWithCode:HttpErrorTypeParse
                                                                    subcode:1
                                                                    message:@"JSON解析出错"
                                                                     detail:nil];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completionHandler(nil, errorResposne);
                        });
                        
                    }
                    else
                    {
                        JsonParser *parser = [JsonParser new];
                        HttpResponse *response = [parser parseJSON:jsonObject modelClass:modelClass];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completionHandler(response, nil);
                        });
                    }
                });
            }
            else
            {
                jsonObject = [NSJSONSerialization JSONObjectWithData:weakFormDataRequest.responseData
                                                             options:NSJSONReadingAllowFragments
                                                               error:&error];
                if (error || !jsonObject)
                {
                    HttpError *errorResposne = [HttpError errorWithCode:HttpErrorTypeParse
                                                                subcode:1
                                                                message:@"JSON解析出错"
                                                                 detail:nil];
                    
                    completionHandler(nil, errorResposne);
                }
                else
                {
                    JsonParser *parser = [JsonParser new];
                    HttpResponse *response = [parser parseJSON:jsonObject modelClass:modelClass];
                    completionHandler(response, nil);
                }
            }
            
        }
    }];
    
    //请求失败的Block
    [formDataRequest setFailedBlock:^{
        
        HttpRequest *currentRequest = [weakFormDataRequest.userInfo valueForKey:ASIHTTPREQUEST_ENGINE_REQUESTKEY];
        [_httpRequestsDic removeObjectForKey:[NSNumber numberWithUnsignedInteger:currentRequest.requestId]];
        
        NSError *error = weakFormDataRequest.error;
        
        NSLog(@"{\nrequest url = %@\nrequest parameter = %@\nerror message = %@\nrequest herader = %@\n}",
              weakFormDataRequest.url, currentRequest.parameters,
              [error.userInfo valueForKey:@"NSLocalizedDescription"], weakFormDataRequest.requestHeaders);
        
        //如果error.code == 4的时候代表用户取消请求
        if (error.code != ASIRequestCancelledErrorType)
        {
            if (currentRequest.retryCount > 0)
            {
                currentRequest.retryCount = (--currentRequest.retryCount);
                [weakSelf sendRequest:currentRequest modelClass:modelClass completionHandler:completionHandler];
            }
            else
            {
                if ([_httpRequestsDic count] == 0)
                {
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                }
                
                NSString *errorMessage = [error.userInfo valueForKey:@"NSLocalizedDescription"];
                NSInteger subcode = error.code;
                
                HttpError *errorResponse = [HttpError errorWithCode:HttpErrorTypeNetwork
                                                            subcode:subcode
                                                            message:errorMessage
                                                             detail:error];
                completionHandler(nil, errorResponse);
            }
        }
        else
        { // 用户取消请求.
            if ([_httpRequestsDic count] == 0)
            {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            }
        }
    }];
    
    // 启动ASIHTTPRequest
    [_httpRequestsDic setObject:formDataRequest forKey:@(request.requestId)];
    formDataRequest.userInfo = @{ASIHTTPREQUEST_ENGINE_REQUESTKEY: request};
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    if (request.requestType == HttpRequestTypeAsync)
    {
        [formDataRequest startSynchronous];
    }
    else
    {
        [formDataRequest startAsynchronous];
    }
}

@end

