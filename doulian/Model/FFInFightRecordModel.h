//
//  FFInFightRecordModel.h
//  doulian
//
//  Created by 孙扬 on 16/10/31.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FFPresentListModel.h"
#import "FFListFUDetailUserModel.h"

@interface FFInFightRecordModel : NSObject
@property (nonatomic, strong) NSString *create_time;
@property (nonatomic, strong) NSString *fightId;
@property (nonatomic, strong) NSDictionary *fromUser;

@property (nonatomic, strong) NSString *fromUserId;
@property (nonatomic, strong) FFPresentListModel *present;
@property (nonatomic, strong) NSString *presentId;
@property (nonatomic, strong) NSString *score;
@property (nonatomic, strong) NSString *seconds;
@property (nonatomic, strong) NSString *type; //1投票 2道具
@property (nonatomic, strong) NSString *userId;

@end
/*
 "create_time" = 1477905208980;
 fightId = 267;
 fromUser =             {
    age = 0;
    avatar = "/face/2016/10/26/fd27c5dca42341c69d56e3f4d0c6e31c.png";
    name = 0088;
    sex = 0;
    third = 0;
    "total_score" = 0;
    userId = 35;
 };
 fromUserId = 35;
 id = 253;
 present =             {
    describe = "\U5bf9\U53c2\U6570\U8005\U7684\U6bd4\U5206 \U968f\U673a +3\U5230-3";
    isClose = 0;
    isHot = 1;
    isVirtual = 1;
    label = "\U547d\U8fd0\U9ab0\U5b50";
    name = "\U4e0a\U5e1d\U7684\U53f3\U624b";
    photos = "/res/C293857CF65C4DEA8E15F2FB61F3CF50.png";
    presentId = 6;
    price = 1;
    unit = "\U4e2a";
    useInFight = 1;
 };
 presentId = 6;
 score = 3;
 seconds = 58;
 type = 2;
 userId = 31;
 */
