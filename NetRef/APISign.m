//
//  APISign.m
//  NetRef
//
//  Created by wenguang pan on 2017/3/14.
//  Copyright © 2017年 wenguang pan. All rights reserved.
//

#import "APISign.h"
#import <CommonCrypto/CommonHMAC.h>

@implementation APISign

+ (NSString *)signValueWithParamters:(NSDictionary *)parameters
{
    //若要加强API安全性，可对登录用户的token再加一层校验
    
    NSString *mergedText = [NSString stringWithFormat:@"%@%@", API_KEY, [APISign stringWithParameters:parameters]];
    NSString *sha1Text = [self sha1ForString:mergedText];
    NSString *signString = [NSString stringWithFormat:@"APISign=%@", sha1Text];
    
    return signString;
}

+ (NSString *)authKey
{
    return @"Authorization";
}

#pragma mark - Helper

// 拼接参数为字符串
+ (NSString *)stringWithParameters:(NSDictionary *)parameters
{
    NSArray *allKeys = [parameters allKeys];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    NSArray *sortedKeys = [allKeys sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    NSMutableString *parametersString = [[NSMutableString alloc] init];
    for (id key in sortedKeys) {
        NSObject *value = [parameters valueForKey:key];
        if ([[value class] isSubclassOfClass:[NSString class]]) {
            [parametersString appendFormat:@"%@", value];
        }else if ([[value class] isSubclassOfClass:[NSNumber class]]) {
            [parametersString appendFormat:@"%@", [(NSNumber *)value stringValue]];
        }else {
            continue;
        }
    }
    return parametersString;
}

// 字符串SHA1
+ (NSString *)sha1ForString:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t outputBuffer[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, (CC_LONG)data.length, outputBuffer);
    NSMutableString *sha1String = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [sha1String appendFormat:@"%02x", outputBuffer[i]];
    }
    return sha1String;
}


@end
