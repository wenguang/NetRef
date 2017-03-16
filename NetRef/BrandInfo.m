//
//  BrandInfo.m
//  NetRef
//
//  Created by wenguang pan on 2017/3/15.
//  Copyright © 2017年 wenguang pan. All rights reserved.
//

#import "BrandInfo.h"
#import "LabelInfo.h"
#import "PmsInfo.h"
#import "RedPacket.h"

@implementation BrandInfo

- (Class)typeOfpmsList {
    return [PmsInfo class];
}

- (Class)typeOflabelList {
    return [LabelInfo class];
}

- (Class)typeOfredPacketInfo {
    return [Coupon class];
}

- (Class)typeOfmyRedPacket {
    return [RedPacket class];
}

@end
