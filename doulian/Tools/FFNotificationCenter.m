//
//  FFNotificationCenter.m
//  doulian
//
//  Created by Suny on 2016/9/30.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import "FFNotificationCenter.h"
#import "AppDelegate.h"
#import "FFListFUDetailUserModel.h"
#import "FFListModel.h"
#import "FFFightRoomViewController.h"
#import "FFChallengeUserCreateRoomVC.h"
#import "FFSysMsgModel.h"
#import "FFIntroduceWebViewController.h"

#import <AudioToolbox/AudioToolbox.h>

@implementation FFNotificationCenter

static FFNotificationCenter *defaultManager = nil;

BOOL isSearching = YES;

int count = 1;

+(FFNotificationCenter *)defaultManager
{
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        if(defaultManager == nil){
            defaultManager = [[self alloc] init];
        }
     });
    
    return defaultManager;
}

- (instancetype)init
{
    self = [super init];
    if(self){
//        self.name = @"Singleton";
    }
    return self;
}

-(void)setIsSearching:(BOOL)issearching{
    isSearching = issearching;
}

-(void)showNoticeWithUserInfo:(NSDictionary *)userInfo{
    
    
    NSString *contentStr = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    NSString *jsonString = [userInfo objectForKey:@"custom"] ;
    NSData *jsonData= [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *infoDic = [MyUtil toArrayOrNSDictionary:jsonData];
    int type = [[infoDic valueForKey:@"type"] intValue];
    
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    AudioServicesPlaySystemSound(1007);
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    
    if (type==1) {
        //收到求帮通知
        FFListModel *ffListModel = [FFListModel modelWithDictionary:[infoDic valueForKey:@"fight"]];
        FFListFUDetailUserModel *ffUserModel = [FFListFUDetailUserModel modelWithDictionary:[infoDic valueForKey:@"user"]];

        UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:@"好友求助" message:contentStr preferredStyle:UIAlertControllerStyleAlert];
        [alertCon addAction:[UIAlertAction actionWithTitle:@"拔刀相助" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
            if ([app.window.rootViewController isKindOfClass:[UINavigationController class]]) {
                FFFightRoomViewController *room = [FFFightRoomViewController new];
                room.dataDic = [infoDic valueForKey:@"fight"];

                [((UINavigationController *)app.window.rootViewController) pushViewController:room animated:YES];
            }
            
        }]];
        [alertCon addAction:[UIAlertAction actionWithTitle:@"残忍拒绝" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            //        [self NeverSeenSongqian];
        }]];
        [app.window.rootViewController presentViewController:alertCon animated:YES completion:nil];

    }if (type==2) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowSystemMessageBadge" object:nil];
        [mUserDefaults setValue:@"1" forKey:@"ShowSystemMessageBadge"];

        
        //收到系统通知
        FFSysMsgModel *model = [FFSysMsgModel modelWithDictionary:[infoDic valueForKey:@"sys"]];
        UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:model.title message:model.content preferredStyle:UIAlertControllerStyleAlert];
        [alertCon addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                
            
        }]];
        if(!model.url){
            [alertCon addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            }]];
        }else{
            [alertCon addAction:[UIAlertAction actionWithTitle:@"去看看" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                FFIntroduceWebViewController *web = [FFIntroduceWebViewController new];
                web.webTitle = model.title;
                web.jumpRequest = [NSString stringWithFormat:@"%@",model.url];
                [((UINavigationController *)app.window.rootViewController) pushViewController:web animated:YES];
            }]];
        }
        
        [app.window.rootViewController presentViewController:alertCon animated:YES completion:nil];
        
    }else if(type== 4){
        //收到挑战
//        UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:@"挑战消息" message:contentStr preferredStyle:UIAlertControllerStyleAlert];
//        
//        [alertCon addAction:[UIAlertAction actionWithTitle:@"暂时不" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
//            
//        }]];
//        [alertCon addAction:[UIAlertAction actionWithTitle:@"斗起来" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//            
//            if ([app.window.rootViewController isKindOfClass:[UINavigationController class]]) {
//                FFChallengeUserCreateRoomVC *list = [FFChallengeUserCreateRoomVC new];
//                list.challengeId =[[infoDic valueForKey:@"challengeUser"] valueForKey:@"challengeId"];
//                list.isAcceptChallenge = YES;
//
//                [((UINavigationController *)app.window.rootViewController) pushViewController:list animated:YES];
//            }
//            
//        }]];
//        [app.window.rootViewController presentViewController:alertCon animated:YES completion:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowChallengeBadge" object:nil];
        [mUserDefaults setValue:@"1" forKey:@"ShowChallengeBadge"];
        
    }else if(type== 5){
        //收到应战
        UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:@"斗脸挑战" message:contentStr preferredStyle:UIAlertControllerStyleAlert];
        
        [alertCon addAction:[UIAlertAction actionWithTitle:@"没空" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {

        }]];
        [alertCon addAction:[UIAlertAction actionWithTitle:@"走着" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            if ([app.window.rootViewController isKindOfClass:[UINavigationController class]]) {
                FFFightRoomViewController *room = [FFFightRoomViewController new];
                room.dataDic = [infoDic valueForKey:@"fight"];
                room.isShowCreateRoomScore = YES;
                [((UINavigationController *)app.window.rootViewController) pushViewController:room animated:YES];
            }
            
        }]];
        [app.window.rootViewController presentViewController:alertCon animated:YES completion:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowAllBadge" object:nil];
        [mUserDefaults setValue:@"1" forKey:@"ShowAllBadge"];
    }

}

-(void)startFightWithImageUrl:(NSString *)url catchWord:(NSString *)catchWord presentId:(NSString *)presentId{
    
    if (isSearching == NO){
        return;
    }
    NSString *logId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"logId"]];
    NSString *token = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"token"]];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:logId,@"logId",token,@"token",url,@"avatarUrl",presentId,@"presentId",nil];
    //如果是审核，多传一个参数
    if ([MyUtil isAppCheck]) {
        [params setValue:@"1" forKey:@"isAppCheck"];
    }

    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [MyUtil requestPostURL:[NSString stringWithFormat:@"%@%@",kFFAPI,kFFAPI_FFStartFight] params:params success:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]] ) {
            
            NSString *error = [NSString stringWithFormat:@"%@",responseObject[@"error"]];
            if (error.integerValue==2001) {
                [mUserDefaults setValue:@"0" forKey:@"isShowSearchingView"];

                NSDictionary *dataDic = responseObject;
                [[NSNotificationCenter defaultCenter]postNotificationName:@"SearchingFightSucceed" object:nil];
                
                FFFightRoomViewController *r = [FFFightRoomViewController new];
                r.responseDic = dataDic;
                r.dataDic = [dataDic valueForKey:@"data"];
                r.isShowCreateRoomScore = YES;
                [((UINavigationController *)app.window.rootViewController) pushViewController:r animated:YES];
            }else if (error.integerValue==2002){
                if (isSearching == YES) {
                    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                    [dic setValue:url forKey:@"url"];
                    [dic setValue:catchWord forKey:@"catchWord"];
                    [dic setValue:presentId forKey:@"presentId"];
                    NSLog(@"count is %d",count++);
                    [self performSelector:@selector(noMethod:) withObject:dic afterDelay:5.0 ];
                    
                    
                    [mUserDefaults setValue:@"1" forKey:@"isShowSearchingView"];
                }
            }else if (error.integerValue==2003){
//                ghostView.message = @"正在比赛";
//                [ghostView show];
                
                NSDictionary *dataDic = responseObject;
                [mUserDefaults setValue:@"0" forKey:@"isShowSearchingView"];
                
                [[NSNotificationCenter defaultCenter]postNotificationName:@"SearchingFightSucceed" object:nil];
                
                FFFightRoomViewController *r = [FFFightRoomViewController new];
                r.responseDic = dataDic;
                r.dataDic = [dataDic valueForKey:@"data"];
                [((UINavigationController *)app.window.rootViewController) pushViewController:r animated:YES];
            }else{
                [mUserDefaults setValue:@"0" forKey:@"isShowSearchingView"];
                
//                ghostView.message = @"匹配失败";
//                [ghostView show];
            }
        }
    } failure:^(NSError *error) {
//        ghostView.message = @"匹配失败，请稍后重试";
//        [ghostView show];
        
    }];
}

-(void)noMethod:(NSDictionary *)dic{
//    NSLog(@"time is%@",[NSDate date]);
    [self startFightWithImageUrl:[dic valueForKey:@"url"] catchWord:[dic valueForKey:@"catchWord"] presentId:[dic valueForKey:@"presentId"]];
    
}

//取消匹配
-(void)cancelFight{

    NSString *logId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"logId"]];
    NSString *token = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"token"]];
    //    NSString *userId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"userId"]];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:logId,@"logId",token,@"token",nil];
    
    //如果是审核，多传一个参数
    if ([MyUtil isAppCheck]) {
        [params setValue:@"1" forKey:@"isAppCheck"];
    }
    
    [MyUtil requestPostURL:[NSString stringWithFormat:@"%@%@",kFFAPI,kFFAPI_FFCancelFight] params:params success:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]] ) {
            NSString *error = [NSString stringWithFormat:@"%@",responseObject[@"error"]];
            if (error.integerValue==2004) {
                //取消成功
                isSearching = NO;
                
                NSLog(@"after cancel count is %d",count);
                [[NSNotificationCenter defaultCenter]postNotificationName:@"CancelFightSucceed" object:nil];
                [mUserDefaults setValue:@"0" forKey:@"isShowSearchingView"];
//                view_fight_black.hidden = YES;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"setBtnNormal" object:nil];
            }else{
                [[NSNotificationCenter defaultCenter]postNotificationName:@"CancelFightSucceed" object:nil];
//                ghostView.message = @"取消匹配失败";
//                [ghostView show];
            }
        }
    } failure:^(NSError *error) {

        
    }];
}


@end
