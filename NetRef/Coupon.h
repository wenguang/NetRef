//
//  Coupon.h
//  NetRef
//
//  Created by wenguang pan on 2017/3/15.
//  Copyright © 2017年 wenguang pan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum CouponStatusType {
    CouponStatusTypeCanUse = 1,   // 可以使用
    CouponStatusTypeIsUsed,       // 已经使用
    CouponStatusTypeNotStart,     // 未开始
    CouponStatusTypeIsOut,        // 已经过期
    CouponStatusTypeOther
} CouponStatusType;

@interface Coupon : NSObject

@property (nonatomic, copy) NSString *couponId ;
@property (nonatomic, copy) NSString *couponSn ;
@property (nonatomic, copy) NSString *beginTime ;
@property (nonatomic, copy) NSString *endTime ;
@property (nonatomic, copy) NSString *couponFav ;
@property (nonatomic, copy) NSString *useLimit ;
@property (nonatomic, copy) NSString *couponName ;
@property (nonatomic, copy) NSString *couponType ;
@property (nonatomic, copy) NSString *couponField ;
@property (nonatomic, copy) NSString *couponTypeName ;
@property (nonatomic, copy) NSString *couponFieldName ;
@property (nonatomic, copy) NSString *couponFavDesc ;
@property (nonatomic, assign) CouponStatusType status ;
@property (nonatomic, copy) NSString *statusDesc ;
@property (nonatomic, copy) NSString *usable;
@property (nonatomic, assign, getter=isSelected) BOOL selected ;
@property (nonatomic, assign) NSInteger activeTime;         
@property (nonatomic, copy) NSString *useOrderSn;
@property (nonatomic, assign) NSInteger onlinePay;
@property (nonatomic, copy) NSString *platform;

@property (nonatomic, copy) NSString *couponSource;
@property (nonatomic, assign) NSInteger unusableCode;

@property (nonatomic, assign) NSNumber *buyMore;

@property (nonatomic, assign) NSInteger cartable;

@end
