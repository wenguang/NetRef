//
//  APIManager.m
//  NetRef
//
//  Created by wenguang pan on 2017/3/11.
//  Copyright © 2017年 wenguang pan. All rights reserved.
//

#import "APIManager.h"
#import "HttpRequest.h"
#import "ASIHTTPEngine.h"
#import "JsonParser.h"
#import "BrandInfo.h"

@implementation APIManager

- (void)testCall {
    //[self parseJson];
    [self testTypeEncoding];
}

- (void)startupCall {
    HttpRequest *request = [HttpRequest new];
    [request setURLString:@"http://xxxx"];
    [request addParameterWithKey:@"channelId" value:@""];
    [request addParameterWithKey:@"appVersion" value:@"1.0.0"];
    [request addParameterWithKey:@"appName" value:@"NetRef"];
    //TODO:添加网络类型的判断
    [request addParameterWithKey:@"net" value:@"WIFI"];
    
    ASIHTTPEngine *asiHttp = [ASIHTTPEngine new];
    [asiHttp sendRequest:request modelClass:[NSObject class] completionHandler:^(HttpResponse *response, HttpError *error) {
        
    }];
}

- (void)parseJson {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"brandInfo" ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:path];
    
    NSError *error;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
    if (error || !jsonObject) {
        NSLog(@"%@\n", error);
    }
    
    if ([jsonObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)jsonObject;
        id data = [dic valueForKey:@"data"];
        
        JsonParser *parser = [JsonParser new];
        HttpResponse *response =  [parser parseJSON:data modelClass:[BrandInfo class]];
        BrandInfo *brandInfo = (BrandInfo *)(response.data);
        NSLog(@"%@\n", brandInfo);
    }
}

// 类型编码：http://nshipster.cn/type-encodings/
- (void)testTypeEncoding {
    NSLog(@"int        : %s", @encode(int));
    NSLog(@"float      : %s", @encode(float));
    NSLog(@"float *    : %s", @encode(float*));
    NSLog(@"char       : %s", @encode(char));
    NSLog(@"char *     : %s", @encode(char *));
    NSLog(@"BOOL       : %s", @encode(BOOL));
    NSLog(@"void       : %s", @encode(void));
    NSLog(@"void *     : %s", @encode(void *));
    
    NSLog(@"NSObject * : %s", @encode(NSObject *));
    NSLog(@"NSObject   : %s", @encode(NSObject));
    NSLog(@"[NSObject] : %s", @encode(typeof([NSObject class])));
    NSLog(@"NSError ** : %s", @encode(typeof(NSError **)));
    
    int intArray[5] = {1, 2, 3, 4, 5};
    NSLog(@"int[]      : %s", @encode(typeof(intArray)));
    
    float floatArray[3] = {0.1f, 0.2f, 0.3f};
    NSLog(@"float[]    : %s", @encode(typeof(floatArray)));
    
    typedef struct _struct {
        short a;
        long long b;
        unsigned long long c;
    } Struct;
    NSLog(@"struct     : %s", @encode(typeof(Struct)));
}

@end
