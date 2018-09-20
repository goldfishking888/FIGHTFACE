//
//  ChallengersModel.h
//  doulian
//
//  Created by WangJinyu on 16/9/23.
//  Copyright © 2016年 maomao. All rights reserved.
// 挑战者列表

#import <Foundation/Foundation.h>

@interface FFChallengersModel : NSObject
@property(nonatomic,strong)NSString * avatarUrl;// = "/face/2016/08/30/9117995fe64743259fea07bf70992ee2.png";
@property(nonatomic,strong)NSString *challengeId;// = 51;
@property(nonatomic,strong)NSString *create_time;// = 1475222602000;
@property(nonatomic,strong)NSString *fromUserId;// = 45;
@property(nonatomic,strong)NSString *presentId;// = 0;
@property(nonatomic,strong)NSString *toUserId;// = 28;
@property(nonatomic,strong)NSMutableDictionary *user;/* =     {
    age = 0;
    avatar = "/face/2016/09/06/c451d86a691e4d94bc6f44051b7ab52d.png";
    mobile = 15800000004;
    name = "\U563f\U563f\U563f";
    selfIntroduction = "\U6765\U554a\Uff0c\U4e92\U76f8\U4f24\U5bb3\U554a";
    sex = 1;
    third = 0;
    "total_score" = 6;
    userId = 45;   };*/
@property(nonatomic,strong)NSString *valid;// = 0;
@end
