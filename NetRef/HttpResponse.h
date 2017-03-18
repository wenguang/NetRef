//
//  HttpResponse.h
//  NetRef
//
//  Created by wenguang pan on 2017/3/12.
//  Copyright © 2017年 VIP. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, HttpDataType) {
    HttpDataTypeJSON = 1,  // JSON数据.
    HttpDataTypeBinary    // 二进制数据.
};

@interface HttpResponse : NSObject

@property (nonatomic, assign) NSInteger code;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, strong) id data;

@end
