//
//  HttpJsonParser.h
//  LeFeng
//
//  Created by wenguang pan on 2017/3/14.
//  Copyright © 2017年 VIP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpResponse.h"

@interface JsonParser : NSObject

- (HttpResponse *)parseJSON:(id)jsonObject modelClass:(Class)modelClass;

@end
