//
//  APIManager.m
//  LeFeng
//
//  Created by wenguang pan on 2017/3/11.
//  Copyright © 2017年 VIP. All rights reserved.
//

#import "APIManager.h"
#import "HttpRequest.h"
#import "ASIHTTPEngine.h"
#import "JsonParser.h"
#import "BrandInfo.h"

@implementation APIManager

- (void)testCall {
    [self parseJson];
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

@end
