//
//  UIColor+SPB.m
//  M_Music
//
//  Created by bianchx on 14-7-9.
//  Copyright (c) 2014年 青岛拓宇网络科技有限公司. All rights reserved.
//

#import "UIColor+SPB.h"

@implementation UIColor (SPB)

/*
 *  获取颜色
 */
+(UIColor *)colorWithHex:(int)color alpha:(float)alpha{
    return [UIColor colorWithRed:((Byte)(color >> 16))/255.0 green:((Byte)(color >> 8))/255.0 blue:((Byte)color)/255.0 alpha:alpha];
}

@end
