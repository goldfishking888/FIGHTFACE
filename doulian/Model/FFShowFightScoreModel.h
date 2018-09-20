//
//  FFShowFightScoreModel.h
//  doulian
//
//  Created by 孙扬 on 16/11/10.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FFShowFightScoreModel : NSObject

@property (nonatomic, strong) NSString *create_time;
@property (nonatomic, strong) NSString *fightId;
@property (nonatomic, strong) NSString *purchaseId;
@property (nonatomic, strong) NSString *score;
//类别 1：注册 ； 2：斗 ； 3：邀请； 4：投；5：获胜；6:失败；7：礼品消费
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *userId;

@end
