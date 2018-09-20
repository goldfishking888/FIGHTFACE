//
//  FFAskForHelpModel.h
//  doulian
//
//  Created by WangJinyu on 16/9/12.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FFAskForHelpModel : NSObject
/*age = 36;
 avatar = "/face/2016/08/29/117cd7495fa1483a9b00ac532b0f8c7d.jpg";
 mobile = 15063941036;
 name = nihao;
 selfIntroduction = self;
 sex = 1;
 third = 0;
 "total_score" = 22;
 userId = 16;*/
@property (nonatomic, strong) NSString *age;
@property (nonatomic, strong) NSString *avatar;
@property (nonatomic, strong) NSString *mobile;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *selfIntroduction;
@property (nonatomic, strong) NSString *sex;
@property (nonatomic, strong) NSString *third;
@property (nonatomic, strong) NSString *total_score;
@property (nonatomic, strong) NSString *userId;
@end
