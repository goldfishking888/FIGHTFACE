//
//  FFNotificationCenter.h
//  doulian
//
//  Created by Suny on 2016/9/30.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FFNotificationCenter : NSObject

+(FFNotificationCenter*)defaultManager;
//展示用户收到的推送
-(void)showNoticeWithUserInfo:(NSDictionary *)userInfo;
//开启斗脸（随机匹配）
-(void)startFightWithImageUrl:(NSString *)url catchWord:(NSString *)catchWord presentId:(NSString *)presentId;
//取消匹配
-(void)cancelFight;

-(void)setIsSearching:(BOOL)issearching;

//@property (nonatomic) BOOL isSearching;

@end
