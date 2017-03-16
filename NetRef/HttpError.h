//
//  HttpError.h
//  LeFeng
//
//  Created by wenguang pan on 2017/3/12.
//  Copyright © 2017年 VIP. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  @brief 错误类型代码.
 */
typedef NS_ENUM(NSInteger, HttpErrorType) {
    HttpErrorTypeNetwork = 1,           // 网络错误.
    HttpErrorTypeParse,                 // 数据解析错误.
    HttpErrorTypeReturn,                // 返回的数据格式有误
    HttpErrorTypeOther,                 // 其他类型错误.
};


@interface HttpError : NSObject

@property(nonatomic, assign) NSInteger code;
@property(nonatomic, assign) NSInteger subcode;
@property(nonatomic, copy) NSString *message;
@property(nonatomic, strong) NSError *detail;

- (id)initWithCode:(NSInteger)code
           subcode:(NSInteger)subcode
           message:(NSString *)message
            detail:(NSError *)detail;

+ (HttpError *)errorWithCode:(NSInteger)code
                            subcode:(NSInteger)subcode
                            message:(NSString *)message
                             detail:(NSError *)detail;

@end
