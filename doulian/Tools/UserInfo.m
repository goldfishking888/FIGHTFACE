//
//  UserInfo.m
//  doulian
//
//  Created by WangJinyu on 16/10/26.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo

+(UserInfo *)shareUserInfo
{
    static UserInfo * shareUserInfo = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        shareUserInfo = [[UserInfo alloc]init];
    });
    return shareUserInfo;
}
-(id)init//如果.h里面有数组要在这初始化
{
    self = [super init];
    if (self) {
        //
    }
    return self;
}
@end
