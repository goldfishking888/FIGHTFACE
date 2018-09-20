//
//  FFListFightUserModel.h
//  doulian
//
//  Created by Suny on 16/8/26.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FFListFUDetailUserModel.h"

@interface FFListFightUserModel : NSObject

@property (nonatomic, strong) NSString *avatar;
@property (nonatomic, strong) NSString *catchWord;
@property (nonatomic, strong) NSString *create_time;
@property (nonatomic, strong) NSString *fightId;
//@property (nonatomic, strong) NSString *id; //不用
@property (nonatomic, strong) NSString *score;
@property (nonatomic, strong) NSMutableArray *scoreRecords;
@property (nonatomic, strong) NSString *scoreSubResult;
@property (nonatomic, strong) FFListFUDetailUserModel *user;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *voted;

@end
