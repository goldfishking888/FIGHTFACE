//
//  FFTimerManager.m
//  doulian
//
//  Created by 孙扬 on 16/11/25.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import "FFTimerManager.h"

@implementation FFTimerManager

static FFTimerManager *defaultManager = nil;

NSMutableArray *timeArray;

NSTimer *timer;

+(FFTimerManager *)defaultManager
{
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        if(defaultManager == nil){
            defaultManager = [[self alloc] init];
            timeArray = [[NSMutableArray alloc] init];
        }
    });
    
    return defaultManager;
}

- (instancetype)init
{
    self = [super init];
    if(self){
        
    }
    return self;
}

-(void)removeData{
    [timer invalidate];
    [timeArray removeAllObjects];
}

-(void)addFightId:(NSString *)fightId remainingTime:(NSString *)timeStr dataDic:(NSDictionary *)dataDic{
    
    [timer invalidate];
    
    if ([self isContainFightId:fightId]) {
        [self setFightId:fightId remainingTime:timeStr];
    }else{
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setValue:fightId forKey:@"fightId"];
        [dic setValue:timeStr forKey:@"timeStr"];
        [dic setValue:dataDic forKey:@"dataDic"];
        [timeArray addObject:dic];
        //有比赛在进行中
        [[NSNotificationCenter defaultCenter] postNotificationName:@"setBtnFighting" object:nil];
    }
    
    //开启计时器
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(refreshTimer) userInfo:@"" repeats:YES];
}

-(BOOL)isContainFightId:(NSString *)fightId{
    if (timeArray.count>0) {
        for (NSMutableDictionary *item in timeArray) {
            if ([[item valueForKey:@"fightId"] isEqualToString:fightId]) {
                return YES;
            }
        }
        return NO;
    }
    return NO;
}

-(void)setFightId:(NSString *)fightId remainingTime:(NSString *)timeStr{
    int i = 0;
    for (NSMutableDictionary *item in timeArray) {
        if ([[item valueForKey:@"fightId"] isEqualToString:fightId]) {
            [item setValue:timeStr forKey:@"timeStr"];
            [timeArray replaceObjectAtIndex:i withObject:item];
            return;
        }
        i++;
    }
}

- (void)refreshTimer{
    for (int i = 0; i<timeArray.count; i++) {
        NSMutableDictionary *dic = timeArray[i];
        long int timeLongInt = [[[NSNumberFormatter alloc] numberFromString:[dic valueForKey:@"timeStr"]] longLongValue];
        timeLongInt -= 1000;
        [dic setValue:[NSString stringWithFormat:@"%ld",timeLongInt] forKey:@"timeStr"];
        [timeArray replaceObjectAtIndex:i withObject:dic];
    }
    
    NSMutableArray *arrayTemp = [[NSMutableArray alloc] init];
    for (NSMutableDictionary *item in timeArray) {
        NSString *timeStrTemp = [item valueForKey:@"timeStr"];
        if ([timeStrTemp longLongValue]>0) {
            [arrayTemp addObject:item];
        }
    }
    timeArray = [[NSMutableArray alloc] init];
    [timeArray addObjectsFromArray:arrayTemp];
    
    if (timeArray.count==0) {
        [timer invalidate];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"setBtnNormal" object:nil];
    }
    
}

-(NSString *)getNewestFightId{
    NSString *fightId = @"0";
    long int time = 0;
    int i= 0;
    int j = 0;
    if (timeArray.count>0) {
        for (NSMutableDictionary *dic in timeArray) {
            long int timeTemp =[[[NSNumberFormatter alloc] numberFromString:[dic valueForKey:@"timeStr"]] longLongValue];
            if (timeTemp>=time) {
                time = timeTemp;
                j = i;
            }
            i++;
        }
        NSMutableDictionary *dic = timeArray[j];
        if ([[dic valueForKey:@"timeStr"] longLongValue]>0) {
            fightId = [dic valueForKey:@"fightId"];
        }
        
    }
    
    
    return fightId;
}

-(NSDictionary *)getNewestFightDataDic{
    NSDictionary *dataDic;
    long int time = 0;
    int i= 0;
    int j = 0;
    if (timeArray.count>0) {
        for (NSMutableDictionary *dic in timeArray) {
            long int timeTemp =[[[NSNumberFormatter alloc] numberFromString:[dic valueForKey:@"timeStr"]] longLongValue];
            if (timeTemp>=time) {
                time = timeTemp;
                j = i;
            }
            i++;
        }
        NSMutableDictionary *dic = timeArray[j];
        dataDic = dic;
    }
    
    
    return dataDic;
}

@end
