//
//  AppDelegate.m
//  doulian
//
//  Created by Suny on 16/8/23.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"
#import "UMessage.h"
#import <UMSocialCore/UMSocialCore.h>
#import <UserNotifications/UserNotifications.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "Harpy.h"
#import "UMMobClick/MobClick.h"

//#import <ShareSDK/ShareSDK.h>
//#import <ShareSDKConnector/ShareSDKConnector.h>

////腾讯开放平台（对应QQ和QQ空间）SDK头文件
//#import <TencentOpenAPI/TencentOAuth.h>
//#import <TencentOpenAPI/QQApiInterface.h>
//
////微信SDK头文件
//#import "WXApi.h"

#import "FFNotificationCenter.h"

#define WeChatAppId @"wxb2a2503dfce137e1"
#define WeChatAppSecret @"47ae3e4a0390c33c45bc63e01e151a1c"

#define QQAppId @"1105455593"
#define QQAppKey @"KAgubxkwm7sFGW4Z"

#define UMengAppKey @"57c8e2e167e58e09540012f1"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [Fabric with:@[[Crashlytics class]]];
    
    //设置 AppKey 及 LaunchOptions
    [UMessage startWithAppkey:UMengAppKey launchOptions:launchOptions];
    
    //UMengAnalytics
    UMConfigInstance.appKey = UMengAppKey;
    UMConfigInstance.channelId = @"App Store";
    [MobClick startWithConfigure:UMConfigInstance];//配置以上参数后调用此方法初始化SDK！
    
    
    //1.3.0版本开始简化初始化过程。如不需要交互式的通知，下面用下面一句话注册通知即可。
    [UMessage registerForRemoteNotifications];
    
    //iOS10必须加下面这段代码。
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate=self;
    UNAuthorizationOptions types10=UNAuthorizationOptionBadge|  UNAuthorizationOptionAlert|UNAuthorizationOptionSound;
    [center requestAuthorizationWithOptions:types10     completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            //点击允许
            //这里可以添加一些自己的逻辑
        } else {
            //点击不允许
            //这里可以添加一些自己的逻辑
        }
    }];
    
    [UMessage setLogEnabled:YES];
    [UMessage setAutoAlert:NO];
    //初始化ShareSDK
//    [self initMob];
    [[UMSocialManager defaultManager] openLog:YES];
    [[UMSocialManager defaultManager] setUmSocialAppkey:UMengAppKey];
    
    //设置是否审核
    [self setASCheckVersionEanbled:YES];
    
//     获取友盟social版本号
    NSLog(@"UMeng social version: %@", [UMSocialGlobal umSocialSDKVersion]);
    
    [MyUtil requestPostURL:[NSString stringWithFormat:@"%@%@",kFFAPI,kFFAPI_FFWeiXinSecret] params:nil success:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]] ) {
            NSString *error = [NSString stringWithFormat:@"%@",responseObject[@"error"]];
            if (error.integerValue==0) {
                NSString *secretStr = responseObject[@"data"];
                //设置微信的appKey和appSecret
                [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:WeChatAppId appSecret:secretStr redirectURL:@"http://doulian.qihaoduo.com/"];
            }else{

            }
        }
    } failure:^(NSError *error) {
        
    }];

    //设置微信的appKey和appSecret
//    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:WeChatAppId appSecret:WeChatAppSecret redirectURL:@"http://doulian.qihaoduo.com/"];

    
    //设置分享到QQ互联的appKey和appSecret
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:QQAppId  appSecret:nil redirectURL:@"http://doulian.qihaoduo.com/"];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    RootViewController *controller = [[RootViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    navController.navigationBarHidden = YES;
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];
    
    //新版本检测
    [[Harpy sharedInstance] setPresentingViewController:_window.rootViewController];
    [[Harpy sharedInstance] setForceLanguageLocalization:HarpyLanguageChineseSimplified];
    [[Harpy sharedInstance] setAlertType:HarpyAlertTypeOption];
    [[Harpy sharedInstance] checkVersion];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self getUnreadSysMessageCount];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // 1.2.7版本开始不需要用户再手动注册devicetoken，SDK会自动注册
    [UMessage registerDeviceToken:deviceToken];
    NSString *deviceTokenStr = [[NSString alloc] initWithFormat:@"%@",deviceToken];
//    
    deviceTokenStr = [[deviceTokenStr substringWithRange:NSMakeRange(0,72)] substringWithRange:NSMakeRange(1,71)];
//    
    deviceTokenStr = [deviceTokenStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"推送deviceTokenStr is \n\n%@\n\n",deviceTokenStr);

}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
    [UMessage didReceiveRemoteNotification:userInfo];
    [[FFNotificationCenter defaultManager] showNoticeWithUserInfo:userInfo];
}

//iOS10新增：处理前台收到通知的代理方法
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //应用处于前台时的远程推送接受
        //必须加这句代码
        [UMessage didReceiveRemoteNotification:userInfo];
        [[FFNotificationCenter defaultManager] showNoticeWithUserInfo:userInfo];
        
    }else{
        //应用处于前台时的本地推送接受
        [[FFNotificationCenter defaultManager] showNoticeWithUserInfo:userInfo];
    }
    
}

//iOS10新增：处理后台点击通知的代理方法
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler{
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //应用处于后台时的远程推送接受
        //必须加这句代码
        [UMessage didReceiveRemoteNotification:userInfo];
        [[FFNotificationCenter defaultManager] showNoticeWithUserInfo:userInfo];

        
    }else{
        //应用处于后台时的本地推送接受
    }
    
}

-(void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)err
{
    
    NSString *error_str = [NSString stringWithFormat: @"%@", err];
    NSLog(@"Failed to get token, error:%@", error_str);
    
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
    if (!result) {
        // 其他如支付等SDK的回调
    }
    return result;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
    if (!result) {
        // 其他如支付等SDK的回调
    }
    return result;
}

-(void)setASCheckVersionEanbled:(BOOL)enable{
    //先默认开启
    [mUserDefaults setValue:@"1" forKey:HideForCheck];
    
    if (enable) {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:kAppVersion,@"version",nil];

        [MyUtil requestPostURL:[NSString stringWithFormat:@"%@%@",kFFAPI,kFFAPI_AppCheck] params:params success:^(id responseObject) {
            if ([responseObject isKindOfClass:[NSDictionary class]] ) {
                NSString *error = [NSString stringWithFormat:@"%@",responseObject[@"error"]];
                if (error.integerValue==0) {
                    NSLog(@"请求接口是否是review - 成功");
                    NSString *num = responseObject[@"data"];
                    [mUserDefaults setValue:[NSString stringWithFormat:@"%@",num] forKey:HideForCheck];
//                    [mUserDefaults setValue:@"0" forKey:HideForCheck];
                    NSLog(@"Version from web is %@",num);
                    if([MyUtil isLogin] == YES) {
                        NSString *userName =[mUserDefaults valueForKey:@"logId"];
                        if (userName&&[userName respondsToSelector:@selector(isEqualToString:)]&&[userName isEqualToString:AccountForCheck]) {
                            [mUserDefaults setValue:@"1" forKey:HideForCheck];
                        }
                    }
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshFFListHeader" object:nil];

                }else{
                    
                }
            }
        } failure:^(NSError *error) {
            
        }];
        
    }else{
        //关闭
        [mUserDefaults setValue:[NSString stringWithFormat:@"%@",@"0"] forKey:HideForCheck];
    }
}

-(void)getUnreadSysMessageCount{
    NSString *userId = [mUserDefaults valueForKey:@"id"];
    if (!userId) {
        userId = @"0";
    }
    NSString *time = [mUserDefaults valueForKey:@"SysMesLastTime"];
    if (!time) {
        time = @"0";
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:userId,@"userId",time,@"timestamp", nil];
    [MyUtil requestPostURL:[NSString stringWithFormat:@"%@%@",kFFAPI,kFFAPI_SysMessageCount] params:params success:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]] ) {
            NSString *error = [NSString stringWithFormat:@"%@",responseObject[@"error"]];
            NSString *msg = [NSString stringWithFormat:@"%@",responseObject[@"msg"]];
            if (error.integerValue==0) {
                NSDictionary *dataDic = responseObject;
                NSLog(@"%@",dataDic);
                NSNumber *num = responseObject[@"data"];
                [mUserDefaults setValue:[responseObject valueForKey:@"currTime"] forKey:@"SysMesLastTime"];
                if (num.integerValue>0) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowSystemMessageBadge" object:nil];
                    [mUserDefaults setValue:@"1" forKey:@"ShowSystemMessageBadge"];
                }

            }
        }
    } failure:^(NSError *error) {
        
    }];
}

@end
