//
//  FFEditingInformationViewController.m
//  doulian
//
//  Created by WangJinyu on 2016/11/16.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import "FFEditingInformationViewController.h"
#import "HMObjcSugar.h"//简单设置控件的各种坐标值
#import "ZHPickView.h"//选择器
#define kHeaderHeight 185 //头部高度
#define ActionSheetTag 255 //
#define ImageLabHeight 3

@interface FFEditingInformationViewController ()<UIAlertViewDelegate,UITextFieldDelegate,UITextViewDelegate,ZHPickViewDelegate>
{
    OLGhostAlertView *ghostView;
    MBProgressHUD *loadView;
    
    
    UITableView * _tableView;
    
    UIView * choseSexView;
    
    UITextField *tfName;
    UITextField *dateValue;
    UITextView *IntroTextView;
    
    UIImageView * bgImageV;
    
    UILabel * nameLabel;
    UILabel * sexLabel;
    UILabel * birthdayLabel;
    UILabel * selfIntroLabel;
    
    int sexTag;
    
    UIView *_header;//导航栏颜色
    
    UIStatusBarStyle _statusBarYStyle;//改变那个时间颜色等
    
    UIButton * iconBtn;
    CGPoint contentoffset;
    
    BOOL ifIsBgImage;
}
@property (nonatomic, strong) ZHPickView *datePicker;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;

@end

@implementation FFEditingInformationViewController

-(void)backUpClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 滑动手势
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offset = scrollView.contentOffset.y + kHeaderHeight;//把底部的2块空白考虑进去
    //    NSLog(@"%f",offset);
    if (offset < 0) { //下拉 | 放大
        NSDictionary *dic = @{
                              @"offset" : [NSString stringWithFormat:@"%f",offset]
                              };
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"zys" object:nil userInfo:dic];
        _header.hm_height = kHeaderHeight;
        _header.hm_y = 0;
        _header.hm_height = kHeaderHeight - offset;
        bgImageV.alpha = 1;
    } else {
        
        _header.hm_y = 0;
        CGFloat minOffset = kHeaderHeight - 64;
        _header.hm_y = minOffset > offset ? - offset : - minOffset;
        
        CGFloat progress = 1 - (offset / minOffset);
        bgImageV.alpha = 1;
//        _statusBarYStyle = progress < 0.4 ? UIStatusBarStyleDefault:UIStatusBarStyleLightContent;
//        [self.navigationController setNeedsStatusBarAppearanceUpdate];
    }
    bgImageV.hm_height = _header.hm_height;
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return _statusBarYStyle;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _statusBarYStyle = UIStatusBarStyleLightContent;
    [self.navigationController setNeedsStatusBarAppearanceUpdate];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    //将触摸事件添加到当前view
    [self.view addGestureRecognizer:tapGestureRecognizer];
    [self initTableView];
    self.automaticallyAdjustsScrollViewInsets = YES;//YES在拖动的时候有变化
    
    ghostView = [[OLGhostAlertView alloc] initWithTitle:nil message:nil timeout:0.5 dismissible:YES];
    ghostView.position = OLGhostAlertViewPositionCenter;
    
    [self addRightBtnwithImgName:nil Title:@"完成" TitleColor:[UIColor whiteColor]];
    sexTag = 0;
    ifIsBgImage = NO;
    [self requestData];//请求个人资料
}

//点击手势让键盘收起来
-(void)keyboardHide:(UITapGestureRecognizer*)tap{
    [tfName resignFirstResponder];
    // //    性别收起来
    //    if (sexTag == 1) {
    //        sexTag = 0;
    //        [choseSexView removeFromSuperview];
    //    }
    [IntroTextView resignFirstResponder];
    NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [_tableView scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    
    if ([tfName isFirstResponder]) {
        [tfName resignFirstResponder];
    }
    self.nameStr = textField.text;
    return YES;
    
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    NSLog(@"开始输入");
    NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
    [_tableView scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    NSLog(@"输入的个性签名 is %@",textView.text);
    self.selfIntroStr = textView.text;
}
#pragma mark - 个人签名开始编辑
-(void)textViewDidChange:(UITextView *)textView{
    NSString * message = textView.text;
    int length1 = message.length;
    int length2 = self.selfIntroStr.length;
    int length3 = IntroTextView.text.length;
    NSLog(@"总字数是%d----%d----%d",length1,length2,length3);
    if (length1 >= 90) {
        ghostView.message = @"字数已达上限";
        [ghostView show];
    }
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    return YES;
}

-(void)requestData
{
    /*
     查看用户详情
     http://192.168.8.223:8080 /user/getUserDetail
     * @param userId  查看的用户id
     * @param fromUserId （可选）  查看该房间的用户id，传入当前参数就会有这个用户在这个比赛房间中是否投票 ，和比赛两个用户的好友关系
     */
    NSString *isLogin = (NSString *)[mUserDefaults valueForKey:@"isLogin"];
    if (![isLogin isEqualToString:@"1"]) {
        ghostView.message = @"请先登录";
        [ghostView show];
        return;
    }
    NSString *logId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"logId"]];
    NSString *token = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"token"]];
    NSNumber * userId = [mUserDefaults valueForKey:@"userId"];
    NSLog(@"[mUserDefaults valueForKey:@userid]=====%@",[mUserDefaults valueForKey:@"userId"]);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:userId,@"toUserId",userId,@"fromUserId",logId,@"logId",token,@"token",nil];
    loadView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [MyUtil requestPostURL:[NSString stringWithFormat:@"%@%@",kFFAPI,kFFAPI_FFGETUserDetail] params:params success:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]] ) {
            [loadView hide:YES];
            NSLog(@"responseObject is ----<>%@",responseObject);
            NSString *error = [NSString stringWithFormat:@"%@",responseObject[@"error"]];
            if (error.integerValue==0) {
                NSMutableDictionary *dataDic = [responseObject[@"data"] mutableCopy];
                [self valueDataOfPerson:dataDic];
            }
            [_tableView reloadData];
            NSLog(@"1");
        }else{
            ghostView.message = @"获取内容失败，请稍后重试";
            [ghostView show];
        }
    }
                   failure:^(NSError *error) {
                       [loadView hide:YES];
                       ghostView.message = @"网络出现问题，请稍后重试";
                       [ghostView show];
                       
                   }];
    
}

//读取个人资料并赋值
-(void)valueDataOfPerson:(NSMutableDictionary *)dataDic
{
//    NSString * imageUrl = [NSString stringWithFormat:@"%@%@",kFFAPI,dataDic[@"avatar"]];
//    //修改信息之后单例返回头像
//    self.userInfo = [UserInfo shareUserInfo];
//    UIImage * headIMageNew = self.userInfo.imageIconNew;
//    if (!headIMageNew) {
//        UIImage * headImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]];
//        [iconBtn setImage:((headImage == nil)?[UIImage imageNamed:@"person_person_icon"]:headImage) forState:UIControlStateNormal];
//    }else
//    {
//        [iconBtn setImage:headIMageNew forState:UIControlStateNormal];
//        
//    }
    self.avatarStr = [NSString stringWithFormat:@"%@",dataDic[@"avatar"]];
    self.mobileStr = [NSString stringWithFormat:@"%@",dataDic[@"mobile"]];//@"15165272220";
    self.nameStr = [NSString stringWithFormat:@"%@",dataDic[@"name"]];//@"德玛西亚";
    self.sexStr = [NSString stringWithFormat:@"%@",dataDic[@"sex"]];//@"1";
    self.birthdayStr = [NSString stringWithFormat:@"%@",dataDic[@"birthday"]];//@"15";
    self.selfIntroStr = [NSString stringWithFormat:@"%@",dataDic[@"selfIntroduction"]];//@"免责事由从法律法规规定";
    NSString * bgImgUrl = [NSString stringWithFormat:@"%@%@",kFFAPI,dataDic[@"background"]];
    UIImage * bgImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:bgImgUrl]]];
    [bgImageV setImage:((bgImage == nil)?[UIImage imageNamed:@"person_person_bg"]:bgImage)];
}

-(void)onClickRightBtn:(UIButton *)sender{
    self.nameStr = tfName.text;
    if (IntroTextView.text.length > 90) {
        ghostView.message = @"个人签名字数超过限制";
        [ghostView show];
        return;
    }
    NSLog(@"nameStr is%@\n, sexStr is %@ \n, birthdayStrStr is %@ \n, selfIntroStr is %@\n",self.nameStr,self.sexStr,self.birthdayStr,self.selfIntroStr);
    /*修改用户接口
     http://192.168.8.223:8080/ user/updateUser
     * @param logId
     * @param token
     * @param data  （{"age": 36,  "imei": "3222",   "mobile": "15063941036",   "name": "nihao",  "self_introduction": "self", "sex": 1}）  mobile:手机号 ,name :名称 ,imei：设备号,sex 性别 1:男 2：女 ; age： 年龄，self_introduction ：自我宣言
     * @return  {"error":0,"msg":"","data":{"age":36,"avatar":"/face/2016/08/25/cfb45c8e4a034ae6a0eea244f18456f4.jpg","create_time":1472020498000,"id":16,"imei":"3222","log_id":"15063941036","mobile":"15063941036","name":"nihao","self_introduction":"self","sex":1,"third":0,"total_score":20}}*/
    NSString *isLogin = (NSString *)[mUserDefaults valueForKey:@"isLogin"];
    if (![isLogin isEqualToString:@"1"]) {
        ghostView.message = @"请先登录";
        [ghostView show];
        return;
    }
    NSString *logId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"logId"]];
    NSString *token = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"token"]];
    NSString *dataStr = [MyUtil DataTOjsonString:[NSDictionary dictionaryWithObjectsAndKeys:self.birthdayStr,@"birthday",[NSNumber numberWithInt:[self.sexStr intValue]],@"sex",IMEI,@"imei",[NSString stringWithFormat:@"%@",self.mobileStr],@"mobile",self.nameStr,@"name",self.selfIntroStr,@"selfIntroduction",nil]];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:logId,@"logId",token,@"token",dataStr,@"data",nil];
    
    loadView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [MyUtil requestPostURL:[NSString stringWithFormat:@"%@%@",kFFAPI,kFFAPI_FFModifyInformation] params:params success:^(id responseObject) {
        
        if ([responseObject isKindOfClass:[NSDictionary class]] ) {
            [loadView hide:YES];
            NSLog(@"responseObject is %@",responseObject);
            
            NSString *error = [NSString stringWithFormat:@"%@",responseObject[@"error"]];
            NSLog(@"error is %@",error);
            if (error.integerValue==0) {
                ghostView.message = @"修改成功";
                [ghostView show];
                NSDictionary *dataDic = responseObject;
                
                NSDictionary *dic = [dataDic valueForKey:@"data"];
//                [mUserDefaults setValue:[dic valueForKey:@"age"] forKey:@"age"];
//                [mUserDefaults setValue:[dic valueForKey:@"avatar"] forKey:@"avatar"];
//                [mUserDefaults setValue:[dic valueForKey:@"create_time"] forKey:@"create_time"];
//                [mUserDefaults setValue:[dic valueForKey:@"imei"] forKey:@"imei"];
//                [mUserDefaults setValue:[dic valueForKey:@"selfIntroduction"] forKey:@"selfIntroduction"];
//                [mUserDefaults setValue:[dic valueForKey:@"sex"] forKey:@"sex"];
//                [mUserDefaults setValue:[dic valueForKey:@"third"] forKey:@"third"];
//                [mUserDefaults setValue:[dic valueForKey:@"total_score"] forKey:@"total_score"];
//                [mUserDefaults setValue:[dic valueForKey:@"userId"] forKey:@"userId"];
//                [mUserDefaults setValue:[dic valueForKey:@"log_id"] forKey:@"logId"];
//                [mUserDefaults setValue:[dic valueForKey:@"mobile"] forKey:@"mobile"];
//                [mUserDefaults setValue:[dic valueForKey:@"name"] forKey:@"name"];
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

-(void)initTableView{
    
    //高度减去tabbar高度50
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 10, SCREEN_WIDTH, SCREENH_HEIGHT) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.tableFooterView = [[UIView alloc]init];//去除掉多余的线
    [self.view addSubview:_tableView];
    
    
    _header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.hm_width, kHeaderHeight)];
    _header.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_header];
    
    bgImageV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kHeaderHeight)];
    bgImageV.userInteractionEnabled = YES;
    bgImageV.image = [UIImage imageNamed:@"person_person_bg"];
    bgImageV.contentMode = UIViewContentModeScaleAspectFill;//图片左右上下都变大
    bgImageV.clipsToBounds = YES;
    UITapGestureRecognizer *tapTheBgImg = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(iconBtnClick)];
    ifIsBgImage = YES;
    [bgImageV addGestureRecognizer:tapTheBgImg];
    [_header addSubview:bgImageV];
    
    _tableView.contentInset = UIEdgeInsetsMake(kHeaderHeight, 0, 0, 0);//75  55 是下面白色的高度
    //返回按钮
    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _backButton.frame = CGRectMake(10,10+self.num,51,21);
    [_backButton.titleLabel setFont:[UIFont fontWithName:@"Courier" size:17]];
    [_backButton addTarget:self action:@selector(backUp:) forControlEvents:UIControlEventTouchUpInside];
    [_backButton setBackgroundImage:[UIImage imageNamed:@"btn_back_white"] forState:UIControlStateNormal];
    //返回按钮点击区域
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 80, 44);
    [button addTarget:self action:@selector(backUpClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    [self.view addSubview:_backButton];
    
    UILabel *titleLabel4 = [[UILabel alloc]initWithFrame:CGRectMake(30, 10+self.num, SCREEN_WIDTH - 30 * 2, 25)] ;
    [titleLabel4 setTextAlignment:NSTextAlignmentCenter];
    [titleLabel4 setBackgroundColor:[UIColor clearColor]];
    [titleLabel4 setTextColor:[UIColor whiteColor]];
    [titleLabel4 setFont:[UIFont fontWithName:@"Courier" size: 17]];
    [titleLabel4 setText:@"编辑资料"];
    [self.view addSubview:titleLabel4];
    
    NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [_tableView scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 4) {
        return 140;
    }else if (indexPath.row == 5) {
        return 220;
    }else{
        return 50;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell * cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"IDcell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"IDcell"];
    }
    if (indexPath.row == 0) {
        //修改头像的左边图标
        UIImageView * imageV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 16, 24, 24)];
        imageV.image = [UIImage imageNamed:@"person_changeInfo_icon"];
        [cell addSubview:imageV];
        //修改头像
        nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(imageV.frame.origin.x + imageV.frame.size.width + 7, imageV.frame.origin.y - ImageLabHeight, 150, 30)];
        nameLabel.text = [NSString stringWithFormat:@"%@%@",@"修改头像",@""];
        nameLabel.textColor = RGBColor(74, 74, 74);
        nameLabel.font = [UIFont systemFontOfSize:14];
        [cell addSubview:nameLabel];
        //头像
        iconBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        iconBtn.frame = CGRectMake(SCREEN_WIDTH - 50, cell.frame.size.height / 2 - 17,40, 40);
        iconBtn.layer.cornerRadius = iconBtn.frame.size.width / 2;
        iconBtn.layer.masksToBounds = YES;
        [iconBtn setImage:[UIImage imageNamed:@"person_person_bg"] forState:UIControlStateNormal];
        [iconBtn.imageView setContentMode:UIViewContentModeScaleAspectFill];
        [iconBtn addTarget:self action:@selector(iconBtnClickWithTag:) forControlEvents:UIControlEventTouchUpInside];
        iconBtn.tag = 10086;
        [cell addSubview:iconBtn];
        //如果有单例里面的图像实体先显示单例的就不显示url里面的 避免新头像上传后再次进入详情页读取的缓存头像是原来的头像这个情况
        NSString * imageUrl = [NSString stringWithFormat:@"%@%@",kFFAPI,self.avatarStr];
        //修改信息之后单例返回头像
        self.userInfo = [UserInfo shareUserInfo];
        UIImage * headIMageNew = self.userInfo.imageIconNew;
//        if (!headIMageNew) {
            UIImage * headImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]];
            [iconBtn setImage:((headImage == nil)?[UIImage imageNamed:@"person_person_icon"]:headImage) forState:UIControlStateNormal];
//        }else
//        {
//            [iconBtn setImage:headIMageNew forState:UIControlStateNormal];
//            
//        }
        UIView * lineView = [[UIView alloc]initWithFrame:CGRectMake(nameLabel.frame.origin.x, 55 - 1, SCREEN_WIDTH - nameLabel.frame.origin.x, 1)];
        lineView.backgroundColor = RGBColor(231, 231, 231);
        [cell addSubview:lineView];
        
    }else if (indexPath.row == 1) {
        //修改昵称
        UIImageView * imageV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 16, 24, 24)];
        imageV.image = [UIImage imageNamed:@"person_changeInfo_name"];
        [cell addSubview:imageV];
        
        tfName = [[UITextField alloc]initWithFrame:CGRectMake(imageV.frame.origin.x + imageV.frame.size.width + 7, imageV.frame.origin.y - ImageLabHeight, 200, 30)];
        tfName.placeholder = @"请输入昵称";
        tfName.text = [NSString stringWithFormat:@"%@%@",@"",self.nameStr];//昵称:
        tfName.textColor = RGBColor(74, 74, 74);
        tfName.font = [UIFont systemFontOfSize:14];
        tfName.delegate = self;
        [cell addSubview:tfName];
        UIView * lineView = [[UIView alloc]initWithFrame:CGRectMake(nameLabel.frame.origin.x, 50 - 1, SCREEN_WIDTH - nameLabel.frame.origin.x, 1)];
        lineView.backgroundColor = RGBColor(231, 231, 231);
        [cell addSubview:lineView];
    }
    else if (indexPath.row == 2){
        //修改性别
        UIImageView * imageV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 16, 24, 24)];
        imageV.image = [UIImage imageNamed:@"person_changeInfo_sex"];
        [cell addSubview:imageV];
        
        sexLabel = [[UILabel alloc]initWithFrame:CGRectMake(imageV.frame.origin.x + imageV.frame.size.width + 7, imageV.frame.origin.y - ImageLabHeight, 150, 30)];
        if ([self.sexStr isEqualToString:@"1"]) {
            sexLabel.text = [NSString stringWithFormat:@"%@%@",@" ",@"男"];
        }else if ([self.sexStr isEqualToString:@"2"])
        {
            sexLabel.text = [NSString stringWithFormat:@"%@%@",@" ",@"女"];
        }
        sexLabel.textColor = RGBColor(74, 74, 74);
        sexLabel.font = [UIFont systemFontOfSize:14];
        [cell addSubview:sexLabel];
        UIView * lineView = [[UIView alloc]initWithFrame:CGRectMake(nameLabel.frame.origin.x, 50 - 1, SCREEN_WIDTH - nameLabel.frame.origin.x, 1)];
        lineView.backgroundColor = RGBColor(231, 231, 231);
        [cell addSubview:lineView];
        //        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else if (indexPath.row == 3){
        //修改出生日期
        UIImageView * imageV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 16, 24, 24)];
        imageV.image = [UIImage imageNamed:@"person_changeInfo_age"];
        [cell addSubview:imageV];
        
        dateValue = [[UITextField alloc] initWithFrame:CGRectMake(imageV.frame.origin.x + imageV.frame.size.width + 7, imageV.frame.origin.y - ImageLabHeight, 150, 30)];
        dateValue.textColor = RGBColor(74, 74, 74);
        dateValue.font = [UIFont systemFontOfSize:14];
        
        //获取time
        NSDate *now = [NSDate date];
        
        NSDateFormatter *formater = [[NSDateFormatter alloc] init];
        [formater setDateFormat:@"yyyy-MM-dd"];
        if (self.birthdayStr.length == 0) {
            dateValue.text = [formater stringFromDate:now];
        }else{
            dateValue.text = self.birthdayStr;
        }
        
        self.datePicker = [[ZHPickView alloc] initDatePickWithDate:now datePickerMode:UIDatePickerModeDate isHaveNavControler:NO withIsBirth:@"1"];
        self.datePicker.delegate = self;
        dateValue.inputView = self.datePicker;
        [cell addSubview:dateValue];
        
        UIView * lineView = [[UIView alloc]initWithFrame:CGRectMake(nameLabel.frame.origin.x, 50 - 1, SCREEN_WIDTH - nameLabel.frame.origin.x, 1)];
        lineView.backgroundColor = RGBColor(231, 231, 231);
        [cell addSubview:lineView];
    }else if (indexPath.row == 4){
        //修改个人宣言
        UIImageView * imageV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 16, 24, 24)];
        imageV.image = [UIImage imageNamed:@"person_changeInfo_selfIntro"];
        [cell addSubview:imageV];
        
        IntroTextView = [[UITextView alloc]initWithFrame:CGRectMake(imageV.frame.origin.x + imageV.frame.size.width + 6, imageV.frame.origin.y - ImageLabHeight, SCREEN_WIDTH - 50, 110)];
        IntroTextView.text = [NSString stringWithFormat:@"%@%@",@"",self.selfIntroStr];
        IntroTextView.textColor = RGBColor(74, 74, 74);
//        IntroTextView.backgroundColor = [UIColor greenColor];
        IntroTextView.delegate = self;
        IntroTextView.scrollEnabled = NO;
        IntroTextView.font = [UIFont systemFontOfSize:14];
        [cell addSubview:IntroTextView];
        UIView * lineView = [[UIView alloc]initWithFrame:CGRectMake(nameLabel.frame.origin.x, 120 - 1, SCREEN_WIDTH - nameLabel.frame.origin.x, 1)];
        lineView.backgroundColor = RGBColor(231, 231, 231);
        [cell addSubview:lineView];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;//cell不显示选中状态
    return cell;
}

#pragma mark ZHPickViewDelegate
-(void)toobarDonBtnHaveClick:(ZHPickView *)pickView resultString:(NSString *)resultString
{
    if (resultString.length > 0)
    {
        dateValue.text = resultString;
        self.birthdayStr = resultString;
    }
    [dateValue resignFirstResponder];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        NSLog(@"点击了修改头像");
        ifIsBgImage = NO;
        [self iconBtnClick];
    }else if (indexPath.row == 2)
    {
        NSLog(@"点击了修改性别");
        if (sexTag == 0) {
            [self makeUIwithTag:@"2"];
            sexTag = 1;
        }
    }else if (indexPath.row == 3)
    {
        NSLog(@"点击了修改出生年月");
        
        
    }else if (indexPath.row == 4)
    {
        [IntroTextView becomeFirstResponder];
        NSLog(@"点击了修改个性签名");
    }
    
}



-(void)choseSexBtnClick:(UIButton *)sender
{
    
    NSLog(@"sextag====%d",sexTag);
    if (sexTag == 1) {
        sexTag = 0;
        [choseSexView removeFromSuperview];
    }
    if (sender.tag == 10086) {
        //选择了男
        self.sexStr = @"1";
        sexLabel.text = [NSString stringWithFormat:@" %@",@"男"];
    }else if (sender.tag == 10087)
    {
        self.sexStr = @"2";
        sexLabel.text = [NSString stringWithFormat:@" %@",@"女"];
        
    }
}

-(void)makeUIwithTag:(NSString *)tagStr
{
    if ([tagStr isEqualToString:@"2"]) {
        sexTag = 1;
        choseSexView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREENH_HEIGHT)];
        choseSexView.backgroundColor = RGBAColor(0, 0, 0, 0.6);
        choseSexView.layer.cornerRadius = 4;
        choseSexView.layer.masksToBounds = YES;
        [self.view addSubview:choseSexView];
        
        UIView * whiteBg = [[UIView alloc]initWithFrame:CGRectMake(10, SCREENH_HEIGHT - 110, SCREEN_WIDTH - 20, 100)];
        whiteBg.backgroundColor = [UIColor whiteColor];
        whiteBg.layer.cornerRadius = 6;
        whiteBg.layer.masksToBounds = YES;
        [choseSexView addSubview:whiteBg];
        
        UIButton * manBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        manBtn.frame = CGRectMake(0, 0, whiteBg.frame.size.width, 49);
        [manBtn setTitle:@"男" forState:UIControlStateNormal];
        [manBtn setTitleColor:RGBColor(74, 74, 74) forState:UIControlStateNormal];
        manBtn.tag = 10086;
        [manBtn addTarget:self action:@selector(choseSexBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [whiteBg addSubview:manBtn];
        //中间横线
        UIView * line = [[UIView alloc]initWithFrame:CGRectMake(manBtn.frame.origin.x, manBtn.frame.origin.y + manBtn.frame.size.height, manBtn.frame.size.width, 1)];
        line.backgroundColor = RGBColor(231, 231, 231);
        [whiteBg addSubview:line];
        
        UIButton * womanBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        womanBtn.frame = CGRectMake(0, 50, whiteBg.frame.size.width, 50);
        [womanBtn setTitle:@"女" forState:UIControlStateNormal];
        [womanBtn setTitleColor:RGBColor(74, 74, 74) forState:UIControlStateNormal];
        womanBtn.tag = 10087;
        [womanBtn addTarget:self action:@selector(choseSexBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [whiteBg addSubview:womanBtn];
    }
    //    else if ([tagStr isEqualToString:@"3"]) {
    //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请输入您的年龄(只能输入数字)" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    //        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    //        alert.tag = 222;
    //        tfAge = [alert textFieldAtIndex:0];
    //        tfAge.layer.borderWidth = 0;
    //        tfAge.placeholder = self.ageStr;
    //        [alert show];
    //    }
    //    else if ([tagStr isEqualToString:@"4"]) {
    //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请输入您的个人宣言" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    //        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    //        alert.tag = 333;
    //        tfIntro = [alert textFieldAtIndex:0];
    //        tfIntro.layer.borderWidth = 0;
    //        tfIntro.placeholder = self.selfIntroStr;
    //        [alert show];
    //    }
    
}

#pragma mark - 点击了修改头像
-(void)iconBtnClick
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"拍照片",@"从相册中选择图片",nil];
    
    actionSheet.delegate = self;
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    actionSheet.tag = ActionSheetTag;
    //[actionSheet showFromRect:CGRectMake(0, 519-120, 320, 120) inView:self.view animated:YES];
    
    UIWindow* window = [[[UIApplication sharedApplication] delegate] window];
    if ([window.subviews containsObject:self.view]) {
        [actionSheet showInView:self.view];
    }
    else {
        [actionSheet showInView:window];
    }
    
}

#pragma mark 修改照片
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSUInteger sourceType = 0;
    if (actionSheet.tag == ActionSheetTag) {
        if(buttonIndex == 0)
        {
            return;
        }
        else if (buttonIndex == 1) {
            if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                return;
            }
            if([[[UIDevice
                  currentDevice] systemVersion] floatValue]>=8.0) {
                
                self.modalPresentationStyle=UIModalPresentationOverCurrentContext;
                
            }
            sourceType = UIImagePickerControllerSourceTypeCamera;
        } else if (buttonIndex == 2){
            sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        
        self.imagePickerController = [[UIImagePickerController alloc] init];
        self.imagePickerController.delegate = self;
        self.imagePickerController.allowsEditing = YES;
        self.imagePickerController.sourceType = sourceType;
        
        //解决xcode输出信息为Snapshotting a view that has not been rendered results in an empty snapshot. Ensure your view has been rendered at least once before snapshotting or snapshot after screen updates.
        if([[[UIDevice
              currentDevice] systemVersion] floatValue]>=8.0) {
            self.modalPresentationStyle=UIModalPresentationOverCurrentContext;
        }
        [self presentViewController:self.imagePickerController animated:YES completion:^{}];
    }
}

//打开相册取消
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^(void){}];
}

//拍照保存到相册失败
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)info
{
    NSLog(@"error------------------------%@",error);
}

#pragma mark - image picker delegte
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];//得到当前的image
    NSString *fileName = nil;//代表图片放入文件夹中的名字 一般是拿到当前时间作为参数
    if(picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary){
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyyMMddHHmmss"];
        fileName = [[NSString alloc]initWithFormat:@"%@.jpg",[formatter stringFromDate:[NSDate date]]];
    }else if(picker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyyMMddHHmmss"];
        fileName = [[NSString alloc]initWithFormat:@"%@.jpg",[formatter stringFromDate:[NSDate date]]];
        UIImageWriteToSavedPhotosAlbum(image,
                                       self, @selector(image:didFinishSavingWithError:contextInfo:),
                                       nil);
        
    }
    
    //压缩图片至<=100k
    image = [MyUtil zipImage:image];
    
    [self uploadImageToServerWithImage:image withFileName:fileName];
    //imageSuccess = image;
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - 上传图片
- (void)uploadImageToServerWithImage:(UIImage *)image withFileName:(NSString *)fileName
{
    NSString *isLogin = (NSString *)[mUserDefaults valueForKey:@"isLogin"];
    if (![isLogin isEqualToString:@"1"]) {
        ghostView.message = @"请先登录";
        [ghostView show];
        return;
    }
    NSString *url;
    if (ifIsBgImage == NO) {
        url =[NSString stringWithFormat:@"%@%@",kFFAPI,kFFAPI_FFChangeIcon];//放上传图片的网址http://192.168.8.223:8080/user/uploadFace
    }else{
        url =[NSString stringWithFormat:@"%@%@",kFFAPI,kFFAPI_FFChangeBgImage];//放上传图片的网址http://192.168.8.223:8080/user/uploadFace
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];//初始化请求对象
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];//设置服务器允许的请求格式内容
    //上传图片/文字，只能同POST   * @param fileData 上传头像文件（文件流，图片的格式） logId token
    
    NSString *logId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"logId"]];
    NSString *token = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"token"]];
    //对于图片进行压缩
    //NSData *data = UIImageJPEGRepresentation(image, 0.1);
    NSData *data = UIImagePNGRepresentation(image);
    //NSData* imageData = UIImagePNGRepresentation(tempImage);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:logId,@"logId",token,@"token",nil];//,data,@"fileData"
    
    [manager POST:url parameters:params constructingBodyWithBlock:^(id  _Nonnull formData) {
        
        //第一个代表文件转换后data数据，第二个代表和服务器商定的图片的字段，第三个代表图片放入文件夹的名字，第四个代表文件的类型
        [formData appendPartWithFileData:data name:@"fileData" fileName:fileName mimeType:@"image/jpg"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"uploadProgress = %@",uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject = %@, task = %@",responseObject,task);
        id obj = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"obj = %@",obj);
        if (ifIsBgImage == NO) {
            [iconBtn setImage:image forState:UIControlStateNormal];
        }else if(ifIsBgImage == YES){
            bgImageV.image = image;
        }
        //成功之后设置头像
        
        ghostView.message = @"设置头像成功";
        [ghostView show];
#pragma mark - 单例返回上个界面头像
        self.userInfo = [UserInfo shareUserInfo];
        self.userInfo.imageIconNew = image;
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error = %@",error);
        ghostView.message = @"设置头像失败";
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
