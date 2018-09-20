//
//  DLRegisterViewController.m
//  doulian
//
//  Created by Suny on 16/8/24.
//  Copyright © 2016年 maomao. All rights reserved.
// 11-3编辑 登陆新界面

#import "FFLoginViewController.h"
#import "FFRegisterViewController.h"
#import "UMessage.h"
#import "FFForgetOrChangePasswordVC.h"//新的忘记密码界面

#import <UMSocialCore/UMSocialCore.h>

#define COLOR_TF_BORDER_DEFAULT [[UIColor colorWithHex:0xe0e0e0 alpha:1] CGColor]
#define COLOR_TF_BORDER_SELECTED [[UIColor orangeColor]CGColor]

@implementation FFLoginViewController
{
    UITextField * userName;
    UITextField * userPsw ;
    OLGhostAlertView *ghostView;
    MBProgressHUD *loadView;
    
    UIView * bgView;
    
    UIButton *login;
    UIButton *forget;
    UIButton * registerBtn;
    
}
-(void)viewDidLoad{
    [super viewDidLoad];
    [self initView];
    
    if ([[UMSocialManager defaultManager] isInstall:UMSocialPlatformType_WechatSession]) {
        [self initThirdLoginView];
    }
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    //将触摸事件添加到当前view
    [self.view addGestureRecognizer:tapGestureRecognizer];
    ghostView = [[OLGhostAlertView alloc] initWithTitle:nil message:nil timeout:0.6 dismissible:YES];
    ghostView.position = OLGhostAlertViewPositionCenter;
}
//点击手势让键盘收起来
-(void)keyboardHide:(UITapGestureRecognizer*)tap{
    [userName resignFirstResponder];
    [userPsw resignFirstResponder];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    
    if ([userName isFirstResponder]) {
        [userName resignFirstResponder];
        [userPsw becomeFirstResponder];
    }else if ([userPsw isFirstResponder]){
        [userPsw resignFirstResponder];
    }
    return YES;
    
}
-(void)initView{
    //添加返回按钮
    float topdistance = 0;
    long losVersion = [[UIDevice currentDevice].systemVersion floatValue] * 10000;
    if (losVersion >= 70000) {
        topdistance = 20;
    }
    self.num =topdistance;
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton * _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _backBtn.frame = CGRectMake(10,5+self.num,50,21);
    [_backBtn.titleLabel setFont:[UIFont fontWithName:@"Courier" size:15]];
    [_backBtn addTarget:self action:@selector(backUp:) forControlEvents:UIControlEventTouchUpInside];
    [_backBtn setBackgroundImage:[UIImage imageNamed:@"btn_back.png"] forState:UIControlStateNormal];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 80, 44);
    [button addTarget:self action:@selector(BackUp:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    [self.view addSubview:_backBtn];
    
    UIImageView * iconImageV = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 50, 75, 100, 100)];
    iconImageV.image = [UIImage imageNamed:@"AboutFight_logo"];
    [self.view addSubview:iconImageV];

    bgView = [[UIView alloc]initWithFrame:CGRectMake(0, iconImageV.frame.origin.y + iconImageV.frame.size.height+ 60, SCREEN_WIDTH, SCREENH_HEIGHT - iconImageV.frame.size.height - 75)];
    bgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgView];
    
    //手机图标
    UIImageView * phoneImaV = [[UIImageView alloc]initWithFrame:CGRectMake(40, 5, 25, 30)];
    phoneImaV.image = [UIImage imageNamed:@"FFLogin_mobile"];
    [bgView addSubview:phoneImaV];
    
    //账号、密码
    userName = [[UITextField alloc] initWithFrame:CGRectMake(phoneImaV.frame.origin.x + phoneImaV.frame.size.width + 5, 0, SCREEN_WIDTH - 40 * 2 - phoneImaV.frame.size.width - 5, 40)];
    userName.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
//    [userName setBorderStyle:UITextBorderStyleRoundedRect];//设置边框样式
    userName.placeholder = @"手机号";
    userName.clearButtonMode = UITextFieldViewModeAlways;
    userName.delegate=self;
    userName.tag = 2;
    [bgView addSubview:userName];
    
    //输入框底下的线
    UIView * bgLineView = [[UIView alloc]initWithFrame:CGRectMake(phoneImaV.frame.origin.x, userName.frame.origin.y + userName.frame.size.height + 1, SCREEN_WIDTH - 40 * 2, 1)];
    bgLineView.backgroundColor = RGBColor(90, 62, 13);
    //RGBColor(90, 62, 13);
    [bgView addSubview:bgLineView];
    
    //密码锁图标
    UIImageView * passWordImaV = [[UIImageView alloc]initWithFrame:CGRectMake(40, bgLineView.frame.origin.y + bgLineView.frame.size.height + 20, phoneImaV.frame.size.width, phoneImaV.frame.size.height)];
    passWordImaV.image = [UIImage imageNamed:@"FFLogin_passWord"];
    [bgView addSubview:passWordImaV];
    
    userPsw = [[UITextField alloc] initWithFrame:CGRectMake(passWordImaV.frame.origin.x + passWordImaV.frame.size.width + 5,userName.frame.origin.y + userName.frame.size.height + 20, userName.frame.size.width, 40)];
//    [userPsw setBorderStyle:UITextBorderStyleRoundedRect];//设置边框样式
    userPsw.delegate=self;
    userPsw.placeholder = @"请输入密码";
    userPsw.clearButtonMode = UITextFieldViewModeAlways;
    userPsw.secureTextEntry = YES;
    userPsw.clearsOnBeginEditing = NO;
    [bgView addSubview:userPsw];
    
    //输入框底下的线
    UIView * bg2LineView = [[UIView alloc]initWithFrame:CGRectMake(phoneImaV.frame.origin.x, userPsw.frame.origin.y + userPsw.frame.size.height + 1, SCREEN_WIDTH - 40 * 2, 1)];
    bg2LineView.backgroundColor = RGBColor(90, 62, 13);
    //RGBColor(90, 62, 13);
    [bgView addSubview:bg2LineView];

    //登录
    login=[UIButton buttonWithType:UIButtonTypeSystem];
    login.frame=CGRectMake(bgLineView.frame.origin.x, userPsw.frame.origin.y + userPsw.frame.size.height + 20, bgLineView.frame.size.width, 40);
    [login setTitle:@"登录" forState:UIControlStateNormal];
    [login.titleLabel setFont:[UIFont systemFontOfSize:17]];
    [login.layer setCornerRadius:4];
    [login.layer setMasksToBounds:YES];
    login.layer.borderWidth = 1;
    login.layer.borderColor = [RGBColor(90, 62, 13) CGColor];
    [login addTarget:self action:@selector(loginClick:) forControlEvents:UIControlEventTouchUpInside];
    [login setBackgroundColor:RGBColor(255, 227, 91)];
    [login setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
    [bgView addSubview:login];

    //忘记密码
    forget=[UIButton buttonWithType:UIButtonTypeSystem];
    forget.frame=CGRectMake(login.frame.origin.x, login.frame.origin.y + login.frame.size.height + 10, 70, 30);
    [forget setTitle:@"忘记密码 ?" forState:UIControlStateNormal];
    
    forget.titleLabel.font = [UIFont systemFontOfSize: 13.0];
    
    [forget addTarget:self action:@selector(forget) forControlEvents:UIControlEventTouchUpInside];
    
    [forget setBackgroundColor:[UIColor clearColor]];
    
    [forget setTitleColor:RGBColor(90, 62, 13) forState:UIControlStateNormal];
    [bgView addSubview:forget];
    
    registerBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    registerBtn.frame=CGRectMake(login.frame.origin.x + login.frame.size.width - 70, login.frame.origin.y + login.frame.size.height + 10, 70, 30);
    [registerBtn setTitle:@"注册新用户" forState:UIControlStateNormal];
    registerBtn.titleLabel.font = [UIFont systemFontOfSize: 13.0];
    [registerBtn addTarget:self action:@selector(newUserRegister) forControlEvents:UIControlEventTouchUpInside];
    [registerBtn setBackgroundColor:[UIColor clearColor]];
    [registerBtn setTitleColor:RGBColor(90, 62, 13) forState:UIControlStateNormal];
    [bgView addSubview:registerBtn];
    
    if ([mUserDefaults valueForKey:@"logId"]) {
        NSString *logId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"logId"]];
        if (logId.length==11) {
            userName.text = [mUserDefaults valueForKey:@"logId"];
        }
        
    }
}


#pragma mark-初始化第三方登录按钮
-(void)initThirdLoginView{
    
    //合作登陆线条
    UILabel * lineLeftLab = [self createLabelWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 140, forget.frame.origin.y + forget.frame.size.height + 15, 280, 1) textAlignment:NSTextAlignmentLeft fontSize:14 textColor:RGBColor(90, 62, 13) numberOfLines:0 text:@""];
    lineLeftLab.backgroundColor = RGBColor(90, 62, 13);
    [bgView addSubview:lineLeftLab];
    //合作登录文字
    UILabel * cooperationLab = [self createLabelWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 30, forget.frame.origin.y + forget.frame.size.height + 5, 60, 20) textAlignment:NSTextAlignmentCenter fontSize:14 textColor:RGBColor(90, 62, 13) numberOfLines:0 text:@"合作登录"];
    cooperationLab.backgroundColor = [UIColor whiteColor];
    [bgView addSubview:cooperationLab];

    UIButton *btn1 = [MyUtil createButtonWithFrame:CGRectMake(SCREEN_WIDTH/4-32,forget.frame.origin.y + forget.frame.size.height + 35, 64, 64) target:self Action:@selector(otherLoginBtn:) Title:@"" BackgroundImage:[UIImage imageNamed:@"login_wechat"] image:nil Tag:3];
    [bgView addSubview:btn1];
    
    
    UIButton *btn2 = [MyUtil createButtonWithFrame:CGRectMake(SCREEN_WIDTH*3/4-32,btn1.frame.origin.y, 64, 64) target:self Action:@selector(otherLoginBtn:) Title:@"" BackgroundImage:[UIImage imageNamed:@"login_qq_normal"] image:nil Tag:1];
    [bgView addSubview:btn2];
}

-(void)otherLoginBtn:(UIButton *)sender{
    switch (sender.tag) {
        case 1:
        {
            [[UMSocialManager defaultManager] getUserInfoWithPlatform:UMSocialPlatformType_QQ currentViewController:nil completion:^(id result, NSError *error) {
                if (error) {
                    
                } else {
                    UMSocialUserInfoResponse *resp = result;
                    
                    // 授权信息
                    NSLog(@"QQ uid: %@", resp.uid);
                    NSLog(@"QQ openid: %@", resp.openid);
                    NSLog(@"QQ accessToken: %@", resp.accessToken);
                    NSLog(@"QQ expiration: %@", resp.expiration);
                    
                    // 用户信息
                    NSLog(@"QQ name: %@", resp.name);
                    NSLog(@"QQ iconurl: %@", resp.iconurl);
                    NSLog(@"QQ gender: %@", resp.gender);
                    
                    // 第三方平台SDK源数据
                    NSLog(@"QQ originalResponse: %@", resp.originalResponse);
                    [self loginByThirdWithUserData:resp type:@"1"];
                }
            }];
        }
            break;
        case 3:
        {
            //WeiXin
            [[UMSocialManager defaultManager] getUserInfoWithPlatform:UMSocialPlatformType_WechatSession currentViewController:nil completion:^(id result, NSError *error) {
                if (error) {
                    
                } else {
                    UMSocialUserInfoResponse *resp = result;
                    
                    // 授权信息
                    NSLog(@"Wechat uid: %@", resp.uid);
                    NSLog(@"Wechat openid: %@", resp.openid);
                    NSLog(@"Wechat accessToken: %@", resp.accessToken);
                    NSLog(@"Wechat refreshToken: %@", resp.refreshToken);
                    NSLog(@"Wechat expiration: %@", resp.expiration);
                    
                    // 用户信息
                    NSLog(@"Wechat name: %@", resp.name);
                    NSLog(@"Wechat iconurl: %@", resp.iconurl);
                    NSLog(@"Wechat gender: %@", resp.gender);
                    
                    // 第三方平台SDK源数据
                    NSLog(@"Wechat originalResponse: %@", resp.originalResponse);
                    [self loginByThirdWithUserData:resp type:@"2"];
                }
            }];
    
        }
            break;
            
        default:
            break;
    }
}


#pragma mark-忘记密码
-(void)forget
{
    FFForgetOrChangePasswordVC * vc = [[FFForgetOrChangePasswordVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - 新用户注册
-(void)newUserRegister
{
    FFRegisterViewController *rg = [[FFRegisterViewController alloc] init];
    [self.navigationController pushViewController:rg animated:true];

}


-(void)loginClick:(BOOL )isThird{
    
    [self checkTelephoneNumber];//检查电话号码

    NSString *code = [NSString stringWithFormat:@"%@%@",userPsw.text,@"facefight"];
    code = [NSString md5:code];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:userName.text,@"logId",code,@"password",@"0",@"third", nil];
    loadView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [MyUtil requestPostURL:[NSString stringWithFormat:@"%@%@",kFFAPI,kFFAPI_Login] params:params success:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]] ) {
            [loadView hide:YES];
            NSString *error = [NSString stringWithFormat:@"%@",responseObject[@"error"]];
            NSString *msg = [NSString stringWithFormat:@"%@",responseObject[@"msg"]];
            ghostView.message = msg;
            [ghostView show];
            if (error.integerValue==0) {
                NSDictionary *dataDic = responseObject;

                NSDictionary *dic = [dataDic valueForKey:@"data"];
                NSLog(@"%@",dic[@"win"]);
                [mUserDefaults setValue:[dic valueForKey:@"lose"] forKey:@"lose"];//负场
                [mUserDefaults setValue:[dic valueForKey:@"win"] forKey:@"win"];//胜场
                [mUserDefaults setValue:[dic valueForKey:@"rateWinning"] forKey:@"rateWinning"];//胜率
                [mUserDefaults setValue:[dic valueForKey:@"draw"] forKey:@"draw"];//平局
                [mUserDefaults setValue:[dic valueForKey:@"inviteCode"] forKey:@"inviteCode"];//平局
                [mUserDefaults setValue:[dic valueForKey:@"age"] forKey:@"age"];
                [mUserDefaults setValue:[dic valueForKey:@"avatar"] forKey:@"avatar"];
                [mUserDefaults setValue:[dic valueForKey:@"create_time"] forKey:@"create_time"];
                [mUserDefaults setValue:[dic valueForKey:@"imei"] forKey:@"imei"];
                [mUserDefaults setValue:[dic valueForKey:@"selfIntroduction"] forKey:@"selfIntroduction"];
                [mUserDefaults setValue:[dic valueForKey:@"sex"] forKey:@"sex"];
                [mUserDefaults setValue:[dic valueForKey:@"third"] forKey:@"third"];
                [mUserDefaults setValue:[dic valueForKey:@"total_score"] forKey:@"total_score"];
                [mUserDefaults setValue:[dic valueForKey:@"userId"] forKey:@"userId"];
                [mUserDefaults setValue:[dic valueForKey:@"token"] forKey:@"token"];
                [mUserDefaults setValue:[dic valueForKey:@"log_id"] forKey:@"logId"];
                [mUserDefaults setValue:[dic valueForKey:@"mobile"] forKey:@"mobile"];
                [mUserDefaults setValue:[dic valueForKey:@"userId"] forKey:@"id"];
                [mUserDefaults setValue:[dic valueForKey:@"name"] forKey:@"name"];
                [mUserDefaults setValue:userPsw.text forKey:@"password"];
                [mUserDefaults setValue:@"1" forKey:@"isLogin"];
                
                //设置友盟推送别名
                [UMessage setAlias:[NSString stringWithFormat:@"%@",[dic valueForKey:@"userId"]] type:@"face" response:^(id responseObject, NSError *error) {
                    
                    NSLog(@"当前Alias 为 %@face,绑定成功",[dic valueForKey:@"userId"]);
                }];
                //创建一个消息对象 崩溃原因可能是通知没销毁
                NSNotification * notice = [NSNotification notificationWithName:@"refreshFFListHeader" object:nil userInfo:@{@"message":@"refreshPage"}];
                //发送消息
                [[NSNotificationCenter defaultCenter]postNotification:notice];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginSucceed" object:nil];
                [self.navigationController popViewControllerAnimated:true];
            }else{
                ghostView.message = @"获取内容失败，请稍后重试";
                [ghostView show];
            }
        }
    } failure:^(NSError *error) {
        [loadView hide:YES];
        ghostView.message = @"网络出现问题，请稍后重试";
        [ghostView show];
        
    }];
}

-(void)loginByThirdWithUserData:(UMSocialUserInfoResponse *)userData type:(NSString *)type{
//    NSString *dataStr = [MyUtil DataTOjsonString:[NSDictionary dictionaryWithObjectsAndKeys:userData.name,@"name",[userData.gender isEqualToString:@"男"]?@"1":@"2",@"sex",IMEI,@"imei", nil]];
    NSString *dataStr = [MyUtil DataTOjsonString: userData.originalResponse];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:userData.openid,@"logId",type,@"third",dataStr,@"data",@"111111",@"password" ,nil];
    loadView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [MyUtil requestPostURL:[NSString stringWithFormat:@"%@%@",kFFAPI,kFFAPI_Login] params:params success:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]] ) {
            [loadView hide:YES];
            NSString *error = [NSString stringWithFormat:@"%@",responseObject[@"error"]];
            if (error.integerValue==0) {
                NSString *msg = [NSString stringWithFormat:@"%@",responseObject[@"msg"]];
                ghostView.message = msg;
                [ghostView show];
                NSDictionary *dataDic = responseObject;
                
                NSDictionary *dic = [dataDic valueForKey:@"data"];
                
                [mUserDefaults setValue:[dic valueForKey:@"lose"] forKey:@"lose"];//负场
                [mUserDefaults setValue:[dic valueForKey:@"win"] forKey:@"win"];//胜场
                [mUserDefaults setValue:[dic valueForKey:@"rateWinning"] forKey:@"rateWinning"];//胜率
                [mUserDefaults setValue:[dic valueForKey:@"draw"] forKey:@"draw"];//平局
                [mUserDefaults setValue:[dic valueForKey:@"inviteCode"] forKey:@"inviteCode"];//平局
                [mUserDefaults setValue:[dic valueForKey:@"age"] forKey:@"age"];
                [mUserDefaults setValue:[dic valueForKey:@"avatar"] forKey:@"avatar"];
                [mUserDefaults setValue:[dic valueForKey:@"create_time"] forKey:@"create_time"];
                [mUserDefaults setValue:[dic valueForKey:@"imei"] forKey:@"imei"];
                [mUserDefaults setValue:[dic valueForKey:@"selfIntroduction"] forKey:@"selfIntroduction"];
                [mUserDefaults setValue:[dic valueForKey:@"sex"] forKey:@"sex"];
                [mUserDefaults setValue:[dic valueForKey:@"third"] forKey:@"third"];
                [mUserDefaults setValue:[dic valueForKey:@"total_score"] forKey:@"total_score"];
                [mUserDefaults setValue:[dic valueForKey:@"userId"] forKey:@"userId"];
                [mUserDefaults setValue:[dic valueForKey:@"token"] forKey:@"token"];
                [mUserDefaults setValue:[dic valueForKey:@"log_id"] forKey:@"logId"];
                [mUserDefaults setValue:[dic valueForKey:@"mobile"] forKey:@"mobile"];
                [mUserDefaults setValue:[dic valueForKey:@"userId"] forKey:@"id"];
                [mUserDefaults setValue:[dic valueForKey:@"name"] forKey:@"name"];
//                [mUserDefaults setValue:userPsw.text forKey:@"password"];
                [mUserDefaults setValue:@"1" forKey:@"isLogin"];
                
                //设置友盟推送别名
                [UMessage setAlias:[NSString stringWithFormat:@"%@",[dic valueForKey:@"userId"]] type:@"face" response:^(id responseObject, NSError *error) {
                    
                    NSLog(@"当前Alias 为 %@face,绑定成功",[dic valueForKey:@"userId"]);
                }];
                //创建一个消息对象 崩溃原因可能是通知没销毁
                NSNotification * notice = [NSNotification notificationWithName:@"refreshFFListHeader" object:nil userInfo:@{@"message":@"refreshPage"}];
                //发送消息
                [[NSNotificationCenter defaultCenter]postNotification:notice];
                [self.navigationController popViewControllerAnimated:true];
            }else{
                ghostView.message = @"获取内容失败，请稍后重试";
                [ghostView show];
            }
        }
    } failure:^(NSError *error) {
        [loadView hide:YES];
        ghostView.message = @"网络出现问题，请稍后重试";
        [ghostView show];
        
    }];
}

/***检测是否是正确的电话号码***/
- (BOOL)checkTelephoneNumber
{
    if (userName.text.length == 0) {//判断是否为空
        ghostView.message = @"手机号码不能为空";
        [ghostView show];
        return NO;
    }
    
    //判断是否是11位
    if (userName.text.length != 11){
        ghostView.message = @"手机号码格式错误，请输入真实有效的信息";
        [ghostView show];
        return NO;
    }
    
    //    NSString *subNumber = [insertWordField.text substringWithRange:NSMakeRange(0, 3)];
    //    NSArray *telArray = [NSArray arrayWithObjects:@"134",@"135",@"144",@"136",@"137",@"138",@"139",@"147",@"150",@"151",@"152",@"157",@"170",@"158",@"159",@"182",@"183",@"184",@"187",@"188",@"130",@"131",@"132",@"156",@"185",@"186",@"145",@"133",@"153",@"180",@"181",@"189", nil];
    
    NSString *phoneRegex = @"^((1))\\d{10}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    //    NSLog(@"phoneTest is %@",phoneTest);
    BOOL isMobile = [phoneTest evaluateWithObject:userName.text];
    
    //判断手机前三位
    if (isMobile) {
        return YES;
    }
    else
    {
        ghostView.message = @"手机号码格式错误，请输入真实有效的信息";
        [ghostView show];
        return NO;
    }
}

- (void)BackUp:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
