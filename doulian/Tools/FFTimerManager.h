//
//  FFTimerManager.h
//  doulian
//
//  Created by 孙扬 on 16/11/25.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FFTimerManager : NSObject

+(FFTimerManager*)defaultManager;

-(void)removeData;

-(void)addFightId:(NSString *)fightId remainingTime:(NSString *)timeStr dataDic:(NSDictionary *)dataDic;

-(NSString *)getNewestFightId;
-(NSDictionary *)getNewestFightDataDic;

@end
