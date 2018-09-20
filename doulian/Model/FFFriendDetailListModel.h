//
//  FFFriendDetailListModel.h
//  doulian
//
//  Created by WangJinyu on 16/10/28.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FFFriendDetailListModel : NSObject
@property (nonatomic, strong) NSString *create_time;
@property (nonatomic, strong) NSString *end_time;
@property (nonatomic, strong) NSString *fightId;
@property (nonatomic, strong) NSMutableArray *fightUsers;
@property (nonatomic, strong) NSString *isClose;
@property (nonatomic, strong) NSString *isReady;
@property (nonatomic, strong) NSString *name;
//@property (nonatomic, strong) NSString *remainingTime;
@property (nonatomic, strong) NSString *start_time;

@end
/*fightUsers =     (
 {
 avatar = "/face/2016/10/27/9898bd8eb02b43c6b556d3a76ca2545a.png";
 catchWord = "";
 "create_time" = 1477555445000;
 fightId = 240;
 id = 442;
 score = 0;
 userId = 12;
 voted = 0;
 },
 {
 avatar = "/face/2016/10/26/9f277f714c774a41aaab0757c1bafac3.jpg";
 catchWord = "come+on";
 "create_time" = 1477555445000;
 fightId = 240;
 id = 443;
 score = 0;
 userId = 24;
 voted = 0;
 }
 );*/
