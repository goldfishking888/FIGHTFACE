//
//  RootViewController.h
//  doulian
//
//  Created by Suny on 16/8/23.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import "YPTabBarController.h"

@interface RootViewController : YPTabBarController

//开启斗脸（随机匹配）
-(void)startFightWithImageUrl2:(NSString *)url catchWord:(NSString *)catchWord presentId:(NSString *)presentId;
//取消匹配
-(void)cancelFight2;

@end
