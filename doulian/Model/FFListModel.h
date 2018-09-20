//
//  FFListModel.h
//  doulian
//
//  Created by Suny on 16/8/26.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FFListModel : NSObject

@property (nonatomic, strong) NSString *create_time;
@property (nonatomic, strong) NSString *end_time;
@property (nonatomic, strong) NSString *fightId;
@property (nonatomic, strong) NSMutableArray *fightUsers;
@property (nonatomic, strong) NSString *isClose;
@property (nonatomic, strong) NSString *isReady;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *remainingTime;
@property (nonatomic, strong) NSString *start_time;
@property (nonatomic, strong) NSString *challengeId;


@end
