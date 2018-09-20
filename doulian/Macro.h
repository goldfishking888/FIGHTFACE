//
//  Macro.h
//  doulian
//
//  Created by Suny on 16/8/24.
//  Copyright © 2016年 maomao. All rights reserved.
//

#ifndef Macro_h
#define Macro_h
//========================================//
#define kFFAPI @"http://192.168.8.223:8080"
//#define kFFAPI @"http://doulian.qihaoduo.com"

#define kFFAPI_AppCheck @"/sys/iOSCheck"//登录/sys/iOSCheck

#define kFFAPI_Login @"/user/login"//登录
#define kFFAPI_Register @"/user/register"//注册
#define kFFAPI_UserAgreement @"/sys/userAgreement"//用户协议
#define kFFAPI_AboutUs @"/sys/aboutUs"//关于斗脸
#define kFFAPI_FFList @"/fight/getCurrentFights"//斗脸列表
#define kFFAPI_FFGetCarousels @"/sys/getCarousels"//斗脸轮播请求图片
#define kFFAPI_FFGetRankList @"/sys/getRankingList"//排行榜
#define kFFAPI_FFSearchFriend @"/user/searchFriend"//搜索陌生人
#define kFFAPI_FFSearchMyFriends @"/user/searchMyFriends" //搜索好友
#define kFFAPI_FFSelfHistoryFights @"/fight/getHistoryFights"//个人斗脸战绩历史.所有的战斗
#define kFFAPI_FFChangeIcon @"/user/uploadFace"//修改头像,上传头像
#define kFFAPI_FFChangeBgImage @"/user/uploadBackGround"//修改背景
#define kFFAPI_FFUploadFightFace @"/user/pickFace"//上传都连图片
#define kFFAPI_FFStartFight @"/fight/startFight"//开始斗脸匹配
#define kFFAPI_FFCancelFight @"/fight/cancelFight"//取消斗脸匹配
#define kFFAPI_FFModifyInformation @"/user/updateUser"//修改用户资料
#define kFFAPI_FFFightVote @"/fight/vote"//投票
#define kFFAPI_FFAddFriend @"/user/addFriend"//加好友
#define kFFAPI_FFRelieveFriend @"/user/relieveFriend"//删除好友
#define kFFAPI_FFHistoryFace @"/user/getUserFaces"//历史头像
#define kFFAPI_FFGetFriendList @"/user/getFriends"//获取好友列表
#define kFFAPI_FFGETAskFriendList @"/fight/getCanHelpFriends" //获取可以请求好友的列表
#define kFFAPI_FFGETFriendDetail @"/user/getFriendDetail" //获取好友详情最近五条挑战记录
#define kFFAPI_FFGETUserDetail @"/user/getUserDetail"//通过id获取用户详情
#define kFFAPI_FFLogOut @"/user/logout"//退出登录
//2017/3/27加入接口
#define kFFAPI_SysMessageCount @"/sys/getUnreadMessageNum"//获取系统通知数

/*获取注册时手机验证码接口
 http://192.168.8.223:8080/sys/registerCode
 * @param mobile 手机号
 找回密码 用获取手机号
 http://192.168.8.223:8080/sys/findPassWordCode
 * @param mobile 手机号*/
#define kFFAPI_FFSendFriendListForHelp @"/push/askHelpIOS" //发送好友列表求帮
#define kFFAPI_FFRegisterGetMobileMes @"/sys/registerCode"//注册时候获取验证码接口
#define kFFAPI_FFChangePsWGetMobileMes @"/sys/findPassWordCode"//找回密码获取验证码接口
#define kFFAPI_FFForgetSetPassword @"/user/setPassWord"//忘记密码请求设置密码接口
#define kFFAPI_FFFightRoomInfo @"/fight/fightDetail"//斗脸房间信息
#define kFFAPI_FFSetPassword @"/user/changePassWord"//修改密码
#define kFFAPI_FFGetChallengerList @"/fight/getChallenges"//获取挑战者列表
#define kFFAPI_FFGetUserScoreRecords @"/user/getUserScoreRecords"//获取积分历史记录列表(个人中心)
#define kFFAPI_FFGetPurchaseHistory @"/present/getPurchaseHistory"//获取积分商城消费记录
#define kFFAPI_FFGetUserScores @"/user/getUserScores"//获取当前用户剩余总积分
#define kFFAPI_FFGetSystemMessage @"/sys/getSystemMessage"//获取消息列表
#define kFFAPI_FFCheckFight @"/fight/checkFight"//查看用户是否有比赛在进行
#define kFFAPI_FFGetComments @"/fight/getComments"//拉取评论列表
#define kFFAPI_FFPostComments @"/fight/commentFight"//发表评论
#define kFFAPI_FFPresentList @"/present/getPresentList"//礼品列表
#define kFFAPI_FFExchangePresent @"/present/exchangePresent"//兑换礼品
#define kFFAPI_FFChanllengeUser @"/fight/challengeUser"//发起斗脸挑战
#define kFFAPI_FFAcceptChanllenge @"/fight/acceptChallenge"//接受斗脸挑战

#define kFFAPI_FFFightRoomPresentsInFight @"/present/getPresentsInFight"//比赛中斗脸道具可使用
#define kFFAPI_FFUserPropInFight @"/fight/usePropInFight"//比赛中使用道具
#define kFFAPI_FFGetInFightRecord @"/fight/getFightRecord"//拉取对战实况
#define kFFAPI_FFGetShareInfo @"/sys/getShares"//拉取分享信息
#define kFFAPI_FFGetScoreExplanation @"/sys/scoreExplanation"//积分说明
#define kFFAPI_FFGetExchangeExplanation @"/sys/exchangeExplanation"//兑换说明
#define kFFAPI_FFGetPresentDescribe @"/present/getPresentDescribe"//获取礼品说明(url)
#define kFFAPI_FFWeiXinSecret @"/sys/getWeiXinSecret"//获取微信分享秘钥
//========================================//
//1.获取屏幕宽度与高度
//#define SCREEN_WIDTH   [UIScreen mainScreen].bounds.size.width
//#define SCREENH_HEIGHT [UIScreen mainScreen].bounds.size.height

#define kBackgraoudColorDefault RGBAColor(250, 250, 250, 1)


//需要横屏或者竖屏，获取屏幕宽度与高度
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000 // 当前Xcode支持iOS8及以上

#define SCREEN_WIDTH ([[UIScreen mainScreen] respondsToSelector:@selector(nativeBounds)]?[UIScreen mainScreen].nativeBounds.size.width/[UIScreen mainScreen].nativeScale:[UIScreen mainScreen].bounds.size.width)
#define SCREENH_HEIGHT ([[UIScreen mainScreen] respondsToSelector:@selector(nativeBounds)]?[UIScreen mainScreen].nativeBounds.size.height/[UIScreen mainScreen].nativeScale:[UIScreen mainScreen].bounds.size.height)
#define SCREEN_SIZE ([[UIScreen mainScreen] respondsToSelector:@selector(nativeBounds)]?CGSizeMake([UIScreen mainScreen].nativeBounds.size.width/[UIScreen mainScreen].nativeScale,[UIScreen mainScreen].nativeBounds.size.height/[UIScreen mainScreen].nativeScale):[UIScreen mainScreen].bounds.size)
#else
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREENH_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREEN_SIZE [UIScreen mainScreen].bounds.size
#endif


////2.获取通知中心
//#define FFNotificationCenter [NSNotificationCenter defaultCenter]

//3.设置随机颜色
#define FFRandomColor [UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1.0]

//4.设置RGB颜色/设置RGBA颜色
#define RGBColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define RGBAColor(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:a]
//rgb颜色转换（16进制->10进制）
#define mRGBToColor(rgb) [UIColor colorWithRed:((float)((rgb & 0xFF0000) >> 16))/255.0 green:((float)((rgb & 0xFF00) >> 8))/255.0 blue:((float)(rgb & 0xFF))/255.0 alpha:1.0]
// clear背景颜色
#define FFClearColor [UIColor clearColor]

#define kDefaultYellowColor RGBColor(251, 226, 84)

//5.自定义高效率的 NSLog
#ifdef DEBUG
#define FFLog(...) NSLog(@"%s 第%d行 \n %@\n\n",__func__,__LINE__,[NSString stringWithFormat:__VA_ARGS__])
#else
#define FFLog(...)

#endif

//6.弱引用/强引用
#define FFWeakSelf(type)  __weak typeof(type) weak##type = type;
#define FFStrongSelf(type)  __strong typeof(type) type = weak##type;

//7.设置 view 圆角和边框
#define FFViewBorderRadius(View, Radius, Width, Color)\
\
[View.layer setCornerRadius:(Radius)];\
[View.layer setMasksToBounds:YES];\
[View.layer setBorderWidth:(Width)];\
[View.layer setBorderColor:[Color CGColor]]

//8.由角度转换弧度 由弧度转换角度
#define FFDegreesToRadian(x) (M_PI * (x) / 180.0)
#define FFRadianToDegrees(radian) (radian*180.0)/(M_PI)

//9.设置加载提示框（第三方框架：Toast）
#define FFToast(str)              CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle]; \
[kWindow  makeToast:str duration:0.6 position:CSToastPositionCenter style:style];\
kWindow.userInteractionEnabled = NO; \
dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{\
kWindow.userInteractionEnabled = YES;\
});\

//10.设置加载提示框（第三方框架：MBProgressHUD）
// 加载
#define kShowNetworkActivityIndicator() [UIApplication sharedApplication].networkActivityIndicatorVisible = YES
// 收起加载
#define HideNetworkActivityIndicator()      [UIApplication sharedApplication].networkActivityIndicatorVisible = NO
// 设置加载
#define NetworkActivityIndicatorVisible(x)  [UIApplication sharedApplication].networkActivityIndicatorVisible = x

#define kWindow [UIApplication sharedApplication].keyWindow

#define kBackView         for (UIView *item in kWindow.subviews) { \
if(item.tag == 10000) \
{ \
[item removeFromSuperview]; \
UIView * aView = [[UIView alloc] init]; \
aView.frame = [UIScreen mainScreen].bounds; \
aView.tag = 10000; \
aView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3]; \
[kWindow addSubview:aView]; \
} \
} \

#define kShowHUDAndActivity kBackView;[MBProgressHUD showHUDAddedTo:kWindow animated:YES];kShowNetworkActivityIndicator()


#define kHiddenHUD [MBProgressHUD hideAllHUDsForView:kWindow animated:YES]

#define kRemoveBackView         for (UIView *item in kWindow.subviews) { \
if(item.tag == 10000) \
{ \
[UIView animateWithDuration:0.4 animations:^{ \
item.alpha = 0.0; \
} completion:^(BOOL finished) { \
[item removeFromSuperview]; \
}]; \
} \
} \

#define kHiddenHUDAndAvtivity kRemoveBackView;kHiddenHUD;HideNetworkActivityIndicator()


//11.获取view的frame/图片资源
//获取view的frame（不建议使用）
//#define kGetViewWidth(view)  view.frame.size.width
//#define kGetViewHeight(view) view.frame.size.height
//#define kGetViewX(view)      view.frame.origin.x
//#define kGetViewY(view)      view.frame.origin.y

//获取图片资源
#define kGetImage(imageName) [UIImage imageNamed:[NSString stringWithFormat:@"%@",imageName]]


//12.获取当前语言
#define DLCurrentLanguage ([[NSLocale preferredLanguages] objectAtIndex:0])

//13.使用 ARC 和 MRC
#if __has_feature(objc_arc)
// ARC
#else
// MRC
#endif

//14.判断当前的iPhone设备/系统版本
//判断是否为iPhone
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

//判断是否为iPad
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

//判断是否为ipod
#define IS_IPOD ([[[UIDevice currentDevice] model] isEqualToString:@"iPod touch"])

// 判断是否为 iPhone 5SE 长宽比1.775
#define iPhone5SE [[UIScreen mainScreen] bounds].size.width == 320.0f && [[UIScreen mainScreen] bounds].size.height == 568.0f

// 判断是否为iPhone 6/6s 长宽比1.778
#define iPhone6_6s [[UIScreen mainScreen] bounds].size.width == 375.0f && [[UIScreen mainScreen] bounds].size.height == 667.0f

// 判断是否为iPhone 6Plus/6sPlus 1.777
#define iPhone6Plus_6sPlus [[UIScreen mainScreen] bounds].size.width == 414.0f && [[UIScreen mainScreen] bounds].size.height == 736.0f

#define isiPhoneBelow5s ([[UIScreen mainScreen] bounds].size.height<=568)
#define isiPhoneUpper6plus ([[UIScreen mainScreen] bounds].size.height>=736)

//获取系统版本
#define IOS_SYSTEM_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

//判断 iOS 8 或更高的系统版本
#define IOS_VERSION_8_OR_LATER (([[[UIDevice currentDevice] systemVersion] floatValue] >=8.0)? (YES):(NO))

//15.判断是真机还是模拟器
#if TARGET_OS_IPHONE
//iPhone Device
#endif

#if TARGET_IPHONE_SIMULATOR
//iPhone Simulator
#endif

//16.沙盒目录文件
//获取temp
#define kPathTemp NSTemporaryDirectory()

//获取沙盒 Document
#define kPathDocument [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]

//获取沙盒 Cache
#define kPathCache [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject]

//17.GCD 的宏定义
//GCD - 一次性执行
#define kDISPATCH_ONCE_BLOCK(onceBlock) static dispatch_once_t onceToken; dispatch_once(&onceToken, onceBlock);

//GCD - 在Main线程上运行
#define kDISPATCH_MAIN_THREAD(mainQueueBlock) dispatch_async(dispatch_get_main_queue(), mainQueueBlock);

//GCD - 开启异步线程
#define kDISPATCH_GLOBAL_QUEUE_DEFAULT(globalQueueBlock) dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), globalQueueBlocl);


//用于拼接两个字符串
#define kConJoinURL(shouzhiji,url) [[NSString alloc] initWithFormat:@"%@%@",shouzhiji,url];
// 获取设备的IMEI
#define IMEI [MyUtil getIMEI]
// 获取app的版本号
#define kAppVersion [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]

#define mUserDefaults       [NSUserDefaults standardUserDefaults]
#define TokenStr [mUserDefaults setValue:[dic valueForKey:@"token"] forKey:@"token"];

//审核隐藏字段名
#define HideForCheck @"HideForCheck"
#define AccountForCheck @"12100001111"

#endif /* Macro_h */
