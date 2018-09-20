//
//  FFSysMsgModel.h
//  doulian
//
//  Created by 孙扬 on 16/11/9.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FFSysMsgModel : NSObject

@property (nonatomic, strong) NSString *code;//1. 通知 2.活动
@property (nonatomic, strong) NSString *currentTime;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *url;

@end
