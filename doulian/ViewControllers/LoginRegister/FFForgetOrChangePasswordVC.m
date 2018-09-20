//
//  FFForgetOrChangePasswordVC.m
//  doulian
//
//  Created by WangJinyu on 2016/11/4.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import "FFForgetOrChangePasswordVC.h"
#import "RootViewController.h"
#import "FFListViewController.h"//首页
#import "UMessage.h"

#define HEIGHT_MENU 60
#define HEIGHT_SPACE 15
#define COLOR_TF_BORDER_DEFAULT [[UIColor colorWithHex:0xe0e0e0 alpha:1] CGColor]
#define COLOR_TF_BORDER_SELECTED [[UIColor orangeColor]CGColor]
//倒计时时间
#define TIME 60
@interface FFForgetOrChangePasswordVC ()
{
    UITextField * userName;
    UITextField * userPswConfirm ;
    UITextField * userPsw ;//输入新密码
    UITextField * userPsw2 ;//确认新密码
    
    OLGhostAlertView *ghostView;
    MBProgressHUD *loadView;
    
    UIView * bgView;
    
    UIButton *login;
    UIButton *forget;
    UIButton * registerBtn;
    UIButton * getConfirmBtn;//获取验证码btn
    UILabel * timeLab;
    NSTimer * timer;
    int time;
    
}
@end

@implementation FFForgetOrChangePasswordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackBtn];
    [self addTitleLabel:@"找回密码" withTitleColor:[UIColor blackColor]];
    //    [self initView];
    [self initHeadView];
    ghostView = [[OLGhostAlertView alloc] initWithTitle:nil message:nil timeout:0.6 dismissible:YES];
    ghostView.position = OLGhostAlertViewPositionCenter;
    // Do any additional setup after loading the view.
}

#pragma mark- UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    NSMutableString * changedString=[[NSMutableString alloc]initWithString:textField.text];
    [changedString replaceCharactersInRange:range withString:string];
    
    if (changedString.length != 0) {
        getConfirmBtn.backgroundColor = [UIColor whiteColor];
        timeLab.textColor = RGBColor(74, 74, 74);
        getConfirmBtn.layer.borderColor = [RGBColor(74, 74, 74) CGColor];
    }else{
        timeLab.textColor = RGBColor(145, 145, 145);
        getConfirmBtn.backgroundColor = RGBColor(204, 204, 204);
        getConfirmBtn.layer.borderColor = [RGBColor(204, 204, 204) CGColor];
    }
    
    return YES;
}

-(void)initHeadView{
    
    bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 44 + self.num, SCREEN_WIDTH, SCREENH_HEIGHT - 44 - self.num)];
    bgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgView];
    
    //手机图标/////////////////////////////
    UIImageView * phoneImaV = [[UIImageView alloc]initWithFrame:CGRectMake(40, 5, 25, 30)];
    phoneImaV.image = [UIImage imageNamed:@"FFLogin_mobile"];
    [bgView addSubview:phoneImaV];
    
    //账号、密码
    userName = [[UITextField alloc] initWithFrame:CGRectMake(phoneImaV.frame.origin.x + phoneImaV.frame.size.width + 5, 0, SCREEN_WIDTH - 40 * 2 - phoneImaV.frame.size.width - 5, 40)];
    userName.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    //    [userName setBorderStyle:UITextBorderStyleRoundedRect];//设置边框样式
    userName.placeholder = @"请输入手机号";
    userName.clearButtonMode = UITextFieldViewModeAlways;
    userName.delegate=self;
    userName.tag = 2;
    [bgView addSubview:userName];
    
    //输入框底下的线
    UIView * bgLineView = [[UIView alloc]initWithFrame:CGRectMake(phoneImaV.frame.origin.x, userName.frame.origin.y + userName.frame.size.height + 1, SCREEN_WIDTH - 40 * 2, 1)];
    bgLineView.backgroundColor = RGBColor(90, 62, 13);
    //RGBColor(90, 62, 13);
    [bgView addSubview:bgLineView];
    
    //验证码图标///////////////////////////
    UIImageView * confirmImaV = [[UIImageView alloc]initWithFrame:CGRectMake(40, bgLineView.frame.origin.y + bgLineView.frame.size.height + 20, phoneImaV.frame.size.width, phoneImaV.frame.size.height)];
    confirmImaV.image = [UIImage imageNamed:@"FFRegister_ConfirmMessage"];
    [bgView addSubview:confirmImaV];
    
    //验证码输入框
    userPswConfirm = [[UITextField alloc] initWithFrame:CGRectMake(confirmImaV.frame.origin.x + confirmImaV.frame.size.width + 5, userName.frame.origin.y + userName.frame.size.height + 20, SCREEN_WIDTH - 40 * 2 - phoneImaV.frame.size.width - 5, 40)];
    userPswConfirm.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    //    [userName setBorderStyle:UITextBorderStyleRoundedRect];//设置边框样式
    userPswConfirm.placeholder = @"验证码";
    userPswConfirm.clearButtonMode = UITextFieldViewModeAlways;
    userPswConfirm.delegate=self;
    userPswConfirm.tag = 2;
    [bgView addSubview:userPswConfirm];
    
    //输入框底下的线
    UIView * bg2LineView = [[UIView alloc]initWithFrame:CGRectMake(phoneImaV.frame.origin.x, userPswConfirm.frame.origin.y + userPswConfirm.frame.size.height + 1, SCREEN_WIDTH / 2 - 40, 1)];
    bg2LineView.backgroundColor = RGBColor(90, 62, 13);
    [bgView addSubview:bg2LineView];
    
    getConfirmBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    getConfirmBtn.frame=CGRectMake(SCREEN_WIDTH / 2 , userName.frame.origin.y + userName.frame.size.height + 20, SCREEN_WIDTH / 2 - 40, 40);
    [getConfirmBtn.layer setCornerRadius:4];
    [getConfirmBtn.layer setMasksToBounds:YES];
    getConfirmBtn.layer.borderWidth = 1;
    getConfirmBtn.layer.borderColor = [RGBColor(204, 204, 204) CGColor];
    [getConfirmBtn addTarget:self action:@selector(getConfirmClick) forControlEvents:UIControlEventTouchUpInside];
    getConfirmBtn.backgroundColor = RGBColor(204, 204, 204);
    [bgView addSubview:getConfirmBtn];
    
    time = TIME;
    
    timeLab = [self createLabelWithFrame:CGRectMake(0, 0, getConfirmBtn.frame.size.width, getConfirmBtn.frame.size.height) textAlignment:NSTextAlignmentCenter fontSize:14 textColor:RGBColor(145, 145, 145) numberOfLines:0 text:@"获取验证码"];
    [getConfirmBtn addSubview:timeLab];
    
    //密码锁图标/////////////////////////
    UIImageView * passWordImaV = [[UIImageView alloc]initWithFrame:CGRectMake(40, bg2LineView.frame.origin.y + bg2LineView.frame.size.height + 20, phoneImaV.frame.size.width, phoneImaV.frame.size.height)];
    passWordImaV.image = [UIImage imageNamed:@"FFLogin_passWord"];
    [bgView addSubview:passWordImaV];
    
    userPsw = [[UITextField alloc] initWithFrame:CGRectMake(passWordImaV.frame.origin.x + passWordImaV.frame.size.width + 5,userPswConfirm.frame.origin.y + userPswConfirm.frame.size.height + 20, userName.frame.size.width, 40)];
    //    [userPsw setBorderStyle:UITextBorderStyleRoundedRect];//设置边框样式
    userPsw.delegate=self;
    userPsw.placeholder = @"请输入新密码";
    userPsw.clearButtonMode = UITextFieldViewModeAlways;
    userPsw.secureTextEntry = YES;
    userPsw.clearsOnBeginEditing = NO;
    [bgView addSubview:userPsw];
    
    //输入框底下的线
    UIView * bg3LineView = [[UIView alloc]initWithFrame:CGRectMake(phoneImaV.frame.origin.x, userPsw.frame.origin.y + userPsw.frame.size.height + 1, SCREEN_WIDTH - 40 * 2, 1)];
    bg3LineView.backgroundColor = RGBColor(90, 62, 13);
    //RGBColor(90, 62, 13);
    [bgView addSubview:bg3LineView];
    
    //密码锁图标2/////////////////////////
    UIImageView * passWord2ImaV = [[UIImageView alloc]initWithFrame:CGRectMake(40, bg3LineView.frame.origin.y + bg3LineView.frame.size.height + 20, phoneImaV.frame.size.width, phoneImaV.frame.size.height)];
    passWord2ImaV.image = [UIImage imageNamed:@"FFLogin_passWord"];
    [bgView addSubview:passWord2ImaV];
    
    userPsw2 = [[UITextField alloc] initWithFrame:CGRectMake(passWordImaV.frame.origin.x + passWordImaV.frame.size.width + 5,userPsw.frame.origin.y + userPsw.frame.size.height + 20, userName.frame.size.width, 40)];
    //    [userPsw setBorderStyle:UITextBorderStyleRoundedRect];//设置边框样式
    userPsw2.delegate=self;
    userPsw2.placeholder = @"请再次输入密码";
    userPsw2.clearButtonMode = UITextFieldViewModeAlways;
    userPsw2.secureTextEntry = YES;
    userPsw2.clearsOnBeginEditing = NO;
    [bgView addSubview:userPsw2];
    
    //输入框底下的线
    UIView * bg4LineView = [[UIView alloc]initWithFrame:CGRectMake(phoneImaV.frame.origin.x, userPsw2.frame.origin.y + userPsw2.frame.size.height + 1, SCREEN_WIDTH - 40 * 2, 1)];
    bg4LineView.backgroundColor = RGBColor(90, 62, 13);
    //RGBColor(90, 62, 13);
    [bgView addSubview:bg4LineView];
    
    
    //点击注册按钮
    login=[UIButton buttonWithType:UIButtonTypeSystem];
    login.frame=CGRectMake(bgLineView.frame.origin.x, userPsw2.frame.origin.y + userPsw2.frame.size.height + 20, bgLineView.frame.size.width, 40);
    [login setTitle:@"确定" forState:UIControlStateNormal];
    [login.titleLabel setFont:[UIFont systemFontOfSize:17]];
    [login.layer setCornerRadius:4];
    [login.layer setMasksToBounds:YES];
    login.layer.borderColor = [RGBColor(74, 74, 74) CGColor];
    login.layer.borderWidth = 1;
    [login addTarget:self action:@selector(registerClick) forControlEvents:UIControlEventTouchUpInside];
    [login setBackgroundColor:RGBColor(255, 227, 91)];
    [login setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
    [bgView addSubview:login];
    
}

-(void)changeTimeAtTimedisplay
{
    time --;
    timeLab.text = [NSString stringWithFormat:@"重新获取(%d)", time];
    timeLab.backgroundColor = RGBColor(204, 204, 204);
    timeLab.textColor = RGBColor(145, 145, 145);
    getConfirmBtn.userInteractionEnabled = NO;
    if(time == 0){
        time = TIME;
        [timer invalidate];
        timeLab.text = @"获取验证码";
        timeLab.textColor = RGBColor(74, 74, 74);
        timeLab.backgroundColor = [UIColor whiteColor];
        getConfirmBtn.userInteractionEnabled = YES;
    }
}
/*
 找回密码 用获取手机号
 http://192.168.8.223:8080/sys/findPassWordCode
 * @param mobile 手机号
 
 设置新密码
 http://192.168.8.223:8080/user/setPassWord
 * @param mobile
 * @param code 验证码
 * @param newPassWord 新密码
 * @return	  同注册
 */
#pragma mark - 注册 点击按钮发送 验证码
-(void)getConfirmClick
{
    if (![self checkTelephoneNumber]) {
        return;
    }
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(changeTimeAtTimedisplay) userInfo:nil repeats:YES];
    [timer fire];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:userName.text,@"mobile", nil];
    loadView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    // http://192.168.8.223:8080/sys/findPassWordCode
    [MyUtil requestPostURL:[NSString stringWithFormat:@"%@%@",kFFAPI,kFFAPI_FFChangePsWGetMobileMes] params:params success:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]] ) {
            [loadView hide:YES];
            NSString *error = [NSString stringWithFormat:@"%@",responseObject[@"error"]];
            
            if (responseObject&&error.integerValue==0) {
                //发送成功
                ghostView.message = @"发送验证码成功,请及时在手机上查看";
                [ghostView show];
                
            }else if (error.integerValue ==2)
            {
                ghostView.message=@"该账号尚未被注册";
                [ghostView show];
                return;
            }else if (error.integerValue ==3)
            {
                ghostView.message=@"您的密码今天已找回超过三次";
                [ghostView show];
                return;
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

- (BOOL)checkPassWord
{
    if (userPsw.text.length == 0) {//判断是否为空
        ghostView.message = @"新密码不能为空";
        [ghostView show];
        return NO;
    }
    
    if (userPsw2.text.length == 0) {//判断是否为空
        ghostView.message  = @"新密码不能为空";
        [ghostView show];
        return NO;
    }else if(userPsw2.text.length < 6){
        ghostView.message = @"新密码长度不能小于六位";
        [ghostView show];
        return NO;
    }else if (![userPsw2.text isEqualToString:userPsw.text]){
        ghostView.message = @"两次输入密码不相同";
        [ghostView show];
        return NO;
    }
    
    return YES;
}

#pragma mark - 点击注册按钮
-(void)registerClick{
    if (userPswConfirm.text.length == 0) {
        ghostView.message = @"请输入验证码";
        [ghostView show];
        return;
    }
    /*设置新密码
     http://192.168.8.223:8080/user/setPassWord
     * @param mobile
     * @param code 验证码
     * @param newPassWord 新密码
     * @return	  同注册*/
    
    NSString *code = [NSString stringWithFormat:@"%@%@",userPsw.text,@"facefight"];
    code = [NSString md5:code];
    
    NSString *dataStr = [MyUtil DataTOjsonString:[NSDictionary dictionaryWithObjectsAndKeys:userName.text,@"mobile",IMEI,@"imei", nil]];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:userName.text,@"mobile",code,@"newPassWord", userPswConfirm.text,@"code",@"0",@"third",dataStr,@"data", nil];
    loadView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [MyUtil requestPostURL:[NSString stringWithFormat:@"%@%@",kFFAPI,kFFAPI_FFForgetSetPassword] params:params success:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]] ) {
            [loadView hide:YES];
            NSString *error = [NSString stringWithFormat:@"%@",responseObject[@"error"]];
            if (error.integerValue==0) {
                NSString *msg = [NSString stringWithFormat:@"%@",responseObject[@"msg"]];
                ghostView.message = msg;
                [ghostView show];
                NSDictionary *dataDic = responseObject;
                NSDictionary *dic = [dataDic valueForKey:@"data"];
                [mUserDefaults setValue:[dic valueForKey:@"token"] forKey:@"token"];
                [mUserDefaults setValue:[dic valueForKey:@"log_id"] forKey:@"logId"];
                [mUserDefaults setValue:[dic valueForKey:@"mobile"] forKey:@"mobile"];
                [mUserDefaults setValue:[dic valueForKey:@"userId"] forKey:@"userId"];
                [mUserDefaults setValue:[dic valueForKey:@"name"] forKey:@"name"];
                [mUserDefaults setValue:userPsw.text forKey:@"password"];
                [mUserDefaults setValue:@"1" forKey:@"isLogin"];
                
                //设置友盟推送别名
                [UMessage setAlias:[NSString stringWithFormat:@"%@",[dic valueForKey:@"userId"]] type:@"face" response:^(id responseObject, NSError *error) {
                    NSLog(@"%@",error);
                }];
                //创建一个消息对象 崩溃原因可能是通知没销毁
                NSNotification * notice = [NSNotification notificationWithName:@"refreshFFListHeader" object:nil userInfo:@{@"message":@"refreshPage"}];
                //发送消息
                [[NSNotificationCenter defaultCenter]postNotification:notice];
                //修改密码成功后需要pop到主界面
                for (UIViewController *item in self.navigationController.viewControllers) {
                    if ([item isKindOfClass:[RootViewController class]]) {
                        [self.navigationController popToViewController:item animated:true];
                    }
                }
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
