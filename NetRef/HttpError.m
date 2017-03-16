//
//  HttpError.m
//  LeFeng
//
//  Created by wenguang pan on 2017/3/12.
//  Copyright © 2017年 VIP. All rights reserved.
//

#import "HttpError.h"

@implementation HttpError

- (id)initWithCode:(NSInteger)code
           subcode:(NSInteger)subcode
           message:(NSString *)message
            detail:(NSError *)detail
{
    if (self = [super init]) {
        self.code = code;
        self.subcode = subcode;
        self.message = message;
        self.detail = detail;
    }
    return self;
}

+ (HttpError *)errorWithCode:(NSInteger)code
                            subcode:(NSInteger)subcode
                            message:(NSString *)message
                             detail:(NSError *)detail
{
    HttpError *error = [[HttpError alloc] initWithCode:code
                                               subcode:subcode
                                               message:message
                                                detail:detail];
    return error;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"{\n    code = %li\n    subcode = %li\n    message = %@\n    detail = %@\n}", (long)_code, (long)_subcode, _message, _detail];
}

@end
