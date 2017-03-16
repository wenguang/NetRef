//
//  BrandInfo.h
//  NetRef
//
//  Created by wenguang pan on 2017/3/15.
//  Copyright © 2017年 wenguang pan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Coupon.h"

@interface BrandInfo : NSObject

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * bid;
@property (nonatomic, strong) NSString * brandStoreSn;
@property (nonatomic, assign) long sellTimeTo;
@property (nonatomic, assign) long sellTimeFrom;
@property (nonatomic, assign) BOOL isHiTao;
@property (nonatomic, strong) NSArray * superScriptList;
@property (nonatomic, strong) NSArray * labelList;
@property (nonatomic, strong) NSString * brandImage;
@property (nonatomic, strong) NSString * agio;
@property (nonatomic, strong) NSString * saleType;
@property (nonatomic, strong) NSArray * pmsList;
@property (nonatomic, strong) NSArray * customImage;
@property (nonatomic, copy) NSString *brandDesc;
@property (nonatomic, copy) NSString *brandExplanation;
@property (nonatomic, assign) BOOL isPreheat;
@property (nonatomic, copy) NSString *brandStoreLogo;
@property (nonatomic, copy) NSString *brandHeadImg;
@property (nonatomic, assign) BOOL canFavorite;
@property (nonatomic, assign) BOOL brandStoreFavorite;
@property (nonatomic, assign) BOOL bindRedPacketStatus;
@property (nonatomic, strong) Coupon *redPacketInfo;
@property (nonatomic, assign) NSInteger redPacketStatus;
@property (nonatomic, strong) NSArray *myRedPacket;
@property (nonatomic, assign) BOOL brandSpecial;
@property (nonatomic, assign) NSInteger saleStatus;

- (Class)typeOfpmsList;
- (Class)typeOflabelList;
- (Class)typeOfredPacketInfo;
- (Class)typeOfmyRedPacket;

@end
