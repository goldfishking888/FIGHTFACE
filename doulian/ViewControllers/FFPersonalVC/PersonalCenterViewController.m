//
//  PersonolCenterViewController.m
//  doulian
//
//  Created by WangJinyu on 16/8/24.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import "PersonalCenterViewController.h"
#import "FFLoginViewController.h"
#import "RootViewController.h"//退出登陆回到首页
#import "FFSeeFightHistoryViewController.h"//查看斗历史页
//#import "FFChangeInformationVC.h"//修改资料
#import "FFEditingInformationViewController.h"//修改资料
#import "HMObjcSugar.h"//简单设置控件的各种坐标值
#import "FFSettingMainViewController.h"//设置
#import "FFMessageViewController.h"//消息界面
#import "FFIntegralListViewController.h"//积分列表
#import "FFChallengeResultViewController.h"//战绩列表

#define kHeaderHeight 205 //头部高度
#define kHeightOfJiange 8 //头部和cell的间隔高度
#define ActionSheetTag 255 //

@interface PersonalCenterViewController ()<UIAlertViewDelegate,UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>
{
    UITapGestureRecognizer * tap;//点击看大图的tap

    OLGhostAlertView *ghostView;
    MBProgressHUD *loadView;
    NSMutableArray *dataArray;
    //age": 36,  "imei": "3222",   "mobile": "15063941036",   "name": "nihao",  "self_introduction": "self", "sex": 1}）  mobile:手机号 ,name :名称 ,imei：设备号,sex 性别 1:男 2：女 ; age： 年龄，self_introduction ：
    UIImageView * bgImageV;//整个滑动界面
    UIButton * headImageBtn;//头像点击
    UILabel * nameLabel;//昵称
    UIView * bgViewWhite;//名字下面白色
    
    
    UITableView * _tableView;
    int appearTime;
    UIView *_header;//导航栏颜色
    UIStatusBarStyle _statusBarYStyle;//改变那个时间颜色等
    UILabel * winCountLab;//胜 胜率 负
    UILabel * winRateLab;
    UILabel * loseCountLab;
    
    NSString * winCountStr;
    NSString * winRateStr;
    NSString * loseCountStr;
}

@property (nonatomic, strong) UIImagePickerController *imagePickerController;

@end

@implementation PersonalCenterViewController
-(void)viewWillAppear:(BOOL)animated
{
    if (appearTime >= 1) {
        [self requestData];
    }else
    {
        appearTime++;
    }
    //appearTime++;
    
}
#pragma mark - 登陆点击事件
-(void)onClickLeftBtn:(UIButton *)sender{
    FFLoginViewController *rig = [[FFLoginViewController alloc] init];
    [self.navigationController pushViewController:rig animated:true];
}
- (void)viewDidLoad {
    appearTime = 0;
    [super viewDidLoad];
    [self initTableView];
    [self requestData];
    [self addRightBtnwithImgName:nil Title:@"编辑" TitleColor:[UIColor whiteColor]];
    self.automaticallyAdjustsScrollViewInsets = NO;//YES在拖动的时候有变化
    _statusBarYStyle = UIStatusBarStyleLightContent;
    
    ghostView = [[OLGhostAlertView alloc] initWithTitle:nil message:nil timeout:0.6 dismissible:YES];
    ghostView.position = OLGhostAlertViewPositionCenter;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideDot:) name:@"HideBadge" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSysDot:) name:@"ShowSystemMessageBadge" object:nil];
    // Do any additional setup after loading the view.
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
    
    [MyUtil requestPostURL:[NSString stringWithFormat:@"%@%@",kFFAPI,kFFAPI_FFGETUserDetail] params:params success:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]] ) {
            NSLog(@"responseObject is ----<>%@",responseObject);
            NSString *error = [NSString stringWithFormat:@"%@",responseObject[@"error"]];
            if (error.integerValue==0) {
                NSMutableDictionary *dataDic = [responseObject[@"data"] mutableCopy];
                [self valueDataOfheader:dataDic];
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

-(void)hideDot:(NSNotification *)noti{
    [_tableView reloadData];
}

-(void)showSysDot:(NSNotification *)noti{
    [_tableView reloadData];

}

#pragma mark - 滑动手势
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offset = scrollView.contentOffset.y + kHeaderHeight + 75 + 55;//把底部的2块空白考虑进去
    //    NSLog(@"%f",offset);
    if (offset < 0) { //下拉 | 放大
        NSDictionary *dic = @{
                              @"offset" : [NSString stringWithFormat:@"%f",offset]
                              };
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"zys" object:nil userInfo:dic];
        _header.hm_height = kHeaderHeight;
        _header.hm_y = 0;
        _header.hm_height = kHeaderHeight - offset;
        headImageBtn.frame = CGRectMake(SCREEN_WIDTH / 2 - 40, kHeaderHeight - offset - 55, 80, 80);
        nameLabel.frame = CGRectMake(SCREEN_WIDTH / 2 - 100, headImageBtn.frame.size.height + headImageBtn.frame.origin.y + 8, 200, 23);
        bgImageV.alpha = 1;
    } else {
        
        _header.hm_y = 0;
        CGFloat minOffset = kHeaderHeight - 64;
        _header.hm_y = minOffset > offset ? - offset : - minOffset;
        
        CGFloat progress = 1 - (offset / minOffset);
        if (progress <= 0.01) {
            bgImageV.alpha = progress;
        }else
        {
            bgImageV.alpha = 1;
        }
        //        bgImageV.alpha = progress;
        _statusBarYStyle = progress < 0.4 ? UIStatusBarStyleDefault:UIStatusBarStyleLightContent;
        [self.navigationController setNeedsStatusBarAppearanceUpdate];
    }
    bgImageV.hm_height = _header.hm_height;
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return _statusBarYStyle;
}


#pragma mark 头部数据读取
-(void)valueDataOfheader:(NSMutableDictionary *)dataDic
{/*data =     {
  age = 45;
  avatar = "/face/2016/11/09/fe60d49216064aa59f31ca2e7bbcaf6a.jpg";
  birthday = "";
  draw = 15;
  friend = 1;
  lose = 901;
  mobile = 15165272220;
  name = "\U6597\U8138\U5723\U6597\U58eb";
  rateWinning = "71.74%";
  selfIntroduction = "\U65a4\U65a4\U8ba1\U8f83\U4e86\U65a4\U65a4\U8ba1\U8f83\Uff1f\U4e00";
  sex = 1;
  third = 0;
  "total_score" = 99;
  userId = 28;
  win = 2325;
  };
  error = 0;
  msg = "";
  }
*/
    NSString * bgImgUrl = [NSString stringWithFormat:@"%@%@",kFFAPI,dataDic[@"background"]];
    UIImage * bgImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:bgImgUrl]]];
    [bgImageV setImage:((bgImage == nil)?[UIImage imageNamed:@"person_person_bg"]:bgImage)];

    NSString * imageUrl = [NSString stringWithFormat:@"%@%@",kFFAPI,dataDic[@"avatar"]];
     //修改信息之后单例返回头像 单例去掉
//    self.userInfo = [UserInfo shareUserInfo];
//    UIImage * headIMageNew = self.userInfo.imageIconNew;
//    if (!headIMageNew) {
        UIImage * headImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]];
        [headImageBtn setImage:((headImage == nil)?[UIImage imageNamed:@"person_person_icon"]:headImage) forState:UIControlStateNormal];
//    }else    {
//        [headImageBtn setImage:headIMageNew forState:UIControlStateNormal];
//    }
    
    NSString *name = [NSString stringWithFormat:@"%@",dataDic[@"name"]];//
    [nameLabel setText:((name.length>0)?[NSString stringWithFormat:@"%@",name]:@"暂无昵称")];
    nameLabel.numberOfLines = 1;
    
    NSString *rateWinningStr = [NSString stringWithFormat:@"%@",dataDic[@"rateWinning"]];//
    [winRateLab setText:((rateWinningStr.length > 0)?[NSString stringWithFormat:@"%@",rateWinningStr]:@"暂无")];
    NSString *winCountLabStr = [NSString stringWithFormat:@"%@",dataDic[@"win"]];//
    [winCountLab setText:((winCountLabStr.length > 0)?[NSString stringWithFormat:@"%@",winCountLabStr]:@"暂无")];
 
    int loseAndDrawCount = [dataDic[@"draw"] intValue]+ [dataDic[@"lose"] intValue];
    [loseCountLab setText:((loseAndDrawCount > 0)?[NSString stringWithFormat:@"%d",loseAndDrawCount]:@"暂无")];
}


-(void)addTitleLabel:(NSString*)title
{
    UILabel *titleLabel4 = [[UILabel alloc]initWithFrame:CGRectMake(30, 10+self.num, SCREEN_WIDTH - 30 * 2, 25)] ;
    [titleLabel4 setTextAlignment:NSTextAlignmentCenter];
    [titleLabel4 setBackgroundColor:[UIColor clearColor]];
    [titleLabel4 setTextColor:[UIColor whiteColor]];
    [titleLabel4 setFont:[UIFont fontWithName:@"Courier" size: 17]];
    [titleLabel4 setText:title];
    [self.view addSubview:titleLabel4];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        if ([MyUtil isAppCheck]) {
            return 3;
        }
        return 4;
    }else if(section == 1){
        return 2;
    }else{
        return 1;
    }
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"IDcell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"IDcell"];
    }
    
    if ([MyUtil isAppCheck]) {
        if (indexPath.section == 0 && indexPath.row == 0) {
            UIImageView * imageV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 30, 30)];
            imageV.image = [UIImage imageNamed:@"personalCenter_message"];
            [cell addSubview:imageV];
            
            UILabel * lab = [[UILabel alloc]initWithFrame:CGRectMake(imageV.frame.origin.x + imageV.frame.size.width + 10, imageV.frame.origin.y, 150, 30)];
            lab.text = @"消息";
            lab.textColor = RGBColor(74, 74, 74);
            lab.font = [UIFont systemFontOfSize:14];
            [cell addSubview:lab];
            
            UIView *redDot = [[UIView alloc] initWithFrame:CGRectMake(lab.frame.origin.x+16*2+5, 5, 10, 10)];
            FFViewBorderRadius(redDot, 5, 1, [UIColor clearColor]);
            redDot.backgroundColor = [UIColor clearColor];
            if ([mUserDefaults valueForKey:@"ShowSystemMessageBadge"]&&[[mUserDefaults valueForKey:@"ShowSystemMessageBadge"] isEqualToString:@"1"]){
                redDot.backgroundColor = [UIColor redColor];
            }
            [cell addSubview:redDot];
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        }else if (indexPath.section == 0 && indexPath.row == 1) {
            UIImageView * imageV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 30, 30)];
            imageV.image = [UIImage imageNamed:@"personalCenter_Count"];
            [cell addSubview:imageV];
            
            UILabel * lab = [[UILabel alloc]initWithFrame:CGRectMake(imageV.frame.origin.x + imageV.frame.size.width + 10, imageV.frame.origin.y, 150, 30)];
            lab.text = @"积分";
            lab.textColor = RGBColor(74, 74, 74);
            lab.font = [UIFont systemFontOfSize:14];
            [cell addSubview:lab];
            //        cell.textLabel.text = @"修改昵称";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else if (indexPath.section == 0 && indexPath.row == 2) {
            UIImageView * imageV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 30, 30)];
            imageV.image = [UIImage imageNamed:@"personalCenter_setting"];
            [cell addSubview:imageV];
            
            UILabel * lab = [[UILabel alloc]initWithFrame:CGRectMake(imageV.frame.origin.x + imageV.frame.size.width + 10, imageV.frame.origin.y, 150, 30)];
            lab.text = @"设置";
            lab.textColor = RGBColor(74, 74, 74);
            lab.font = [UIFont systemFontOfSize:14];
            [cell addSubview:lab];
            //        cell.textLabel.text = @"修改昵称";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }

    }else{
        if (indexPath.section == 0 && indexPath.row == 0) {
            UIImageView * imageV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 30, 30)];
            imageV.image = [UIImage imageNamed:@"personalCenter_message"];
            [cell addSubview:imageV];
            
            UILabel * lab = [[UILabel alloc]initWithFrame:CGRectMake(imageV.frame.origin.x + imageV.frame.size.width + 10, imageV.frame.origin.y, 150, 30)];
            lab.text = @"消息";
            lab.textColor = RGBColor(74, 74, 74);
            lab.font = [UIFont systemFontOfSize:14];
            [cell addSubview:lab];
            
            UIView *redDot = [[UIView alloc] initWithFrame:CGRectMake(lab.frame.origin.x+16*2+5, 5, 10, 10)];
            FFViewBorderRadius(redDot, 5, 1, [UIColor clearColor]);
            redDot.backgroundColor = [UIColor clearColor];
            if ([mUserDefaults valueForKey:@"ShowSystemMessageBadge"]&&[[mUserDefaults valueForKey:@"ShowSystemMessageBadge"] isEqualToString:@"1"]){
                redDot.backgroundColor = [UIColor redColor];
            }
            [cell addSubview:redDot];

        
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        }else if (indexPath.section == 0 && indexPath.row == 1) {
            UIImageView * imageV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 30, 30)];
            imageV.image = [UIImage imageNamed:@"personalCenter_fightResult"];
            [cell addSubview:imageV];
            
            UILabel * lab = [[UILabel alloc]initWithFrame:CGRectMake(imageV.frame.origin.x + imageV.frame.size.width + 10, imageV.frame.origin.y, 150, 30)];
            lab.text = @"战绩";
            lab.textColor = RGBColor(74, 74, 74);
            lab.font = [UIFont systemFontOfSize:14];
            //        [lab sizeToFit];
            [cell addSubview:lab];
            //        cell.textLabel.text = @"修改昵称";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            UIView *redDot = [[UIView alloc] initWithFrame:CGRectMake(lab.frame.origin.x+16*2+5, 5, 10, 10)];
            FFViewBorderRadius(redDot, 5, 1, [UIColor clearColor]);
            redDot.backgroundColor = [UIColor clearColor];
            if ([mUserDefaults valueForKey:@"ShowAllBadge"]&&[[mUserDefaults valueForKey:@"ShowAllBadge"] isEqualToString:@"1"]){
                redDot.backgroundColor = [UIColor redColor];
            }
            if ([mUserDefaults valueForKey:@"ShowChallengeBadge"]&&[[mUserDefaults valueForKey:@"ShowChallengeBadge"] isEqualToString:@"1"]){
                redDot.backgroundColor = [UIColor redColor];
            }
            [cell addSubview:redDot];
        }else if (indexPath.section == 0 && indexPath.row == 2) {
            UIImageView * imageV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 30, 30)];
            imageV.image = [UIImage imageNamed:@"personalCenter_Count"];
            [cell addSubview:imageV];
            
            UILabel * lab = [[UILabel alloc]initWithFrame:CGRectMake(imageV.frame.origin.x + imageV.frame.size.width + 10, imageV.frame.origin.y, 150, 30)];
            lab.text = @"积分";
            lab.textColor = RGBColor(74, 74, 74);
            lab.font = [UIFont systemFontOfSize:14];
            [cell addSubview:lab];
            //        cell.textLabel.text = @"修改昵称";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else if (indexPath.section == 0 && indexPath.row == 3) {
            UIImageView * imageV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 30, 30)];
            imageV.image = [UIImage imageNamed:@"personalCenter_setting"];
            [cell addSubview:imageV];
            
            UILabel * lab = [[UILabel alloc]initWithFrame:CGRectMake(imageV.frame.origin.x + imageV.frame.size.width + 10, imageV.frame.origin.y, 150, 30)];
            lab.text = @"设置";
            lab.textColor = RGBColor(74, 74, 74);
            lab.font = [UIFont systemFontOfSize:14];
            [cell addSubview:lab];
            //        cell.textLabel.text = @"修改昵称";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }

    }
    
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([MyUtil jumpToLoginVCIfNoLogin]) {
        return;
    }
    
    if ([MyUtil isAppCheck]) {
        if (indexPath.section == 0 && indexPath.row == 0) {
            NSLog(@"点击了消息");
            FFMessageViewController *ffsVC = [[FFMessageViewController alloc]init];
            [self.navigationController pushViewController:ffsVC animated:YES];
            
        }else if (indexPath.section == 0 && indexPath.row == 1){//战绩
            FFIntegralListViewController * vc = [[FFIntegralListViewController alloc]init];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if (indexPath.section == 0 && indexPath.row == 2){
           
            //设置界面
            FFSettingMainViewController * vc = [[FFSettingMainViewController alloc]init];
            [self.navigationController pushViewController:vc animated:YES];
        }else if (indexPath.section == 0 && indexPath.row == 3){
            
        }
        return;
    }
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        NSLog(@"点击了消息");
        FFMessageViewController *ffsVC = [[FFMessageViewController alloc]init];
        [self.navigationController pushViewController:ffsVC animated:YES];
        
    }else if (indexPath.section == 0 && indexPath.row == 1){//战绩
        FFChallengeResultViewController * vc = [[FFChallengeResultViewController alloc]init];
        //        vc.clickBOOL = NO;//默认跳到所有的战斗
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (indexPath.section == 0 && indexPath.row == 2){
        FFIntegralListViewController * vc = [[FFIntegralListViewController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.section == 0 && indexPath.row == 3){
        //设置界面
        FFSettingMainViewController * vc = [[FFSettingMainViewController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    
    
}
#pragma mark - 编辑资料
-(void)onClickRightBtn:(UIButton *)sender
{
    if ([MyUtil jumpToLoginVCIfNoLogin]) {
        return;
    }
    FFEditingInformationViewController *ffsVC = [[FFEditingInformationViewController alloc]init];
    [self.navigationController pushViewController:ffsVC animated:YES];
}

-(void)initTableView{
    //高度减去tabbar高度50
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0,  0, SCREEN_WIDTH, SCREENH_HEIGHT-50) style:UITableViewStylePlain];
    _tableView.backgroundColor = RGBColor(243, 243, 243);
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:_tableView];
    _tableView.tableFooterView = [[UIView alloc]init];//去除掉多余的线
    
    _tableView.contentInset = UIEdgeInsetsMake(kHeaderHeight + 75 + 55, 0, 0, 0);//75  55 是下面白色的高度
    
    //右上角编辑
    UIButton * editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    editBtn.frame = CGRectMake(SCREEN_WIDTH - 100, 20, 100, 50);
    editBtn.backgroundColor = [UIColor clearColor];
    [editBtn addTarget:self action:@selector(onClickRightBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:editBtn];
    
    _header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.hm_width, kHeaderHeight)];
    _header.backgroundColor = RGBColor(251, 226, 84);
    [self.view addSubview:_header];
    
    //背景图
    bgImageV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kHeaderHeight)];
    bgImageV.userInteractionEnabled = YES;
//    bgImageV.image = [UIImage imageNamed:@"person_person_bg"];
    bgImageV.contentMode = UIViewContentModeScaleAspectFill;//图片左右上下都变大
    bgImageV.clipsToBounds = YES;
    UITapGestureRecognizer *tapTheBgImg = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeBgImageTap:)];
    [bgImageV addGestureRecognizer:tapTheBgImg];
//    bgImageV.frame = CGRectMake(0, 0, self.view.hm_width, kHeaderHeight);
    [_header addSubview:bgImageV];
    
    // UIButton * headImageBtn;//头像点击
    headImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    headImageBtn.frame = CGRectMake(SCREEN_WIDTH / 2 - 40, kHeaderHeight - 55, 80, 80);
    headImageBtn.layer.cornerRadius = headImageBtn.frame.size.width / 2;
    headImageBtn.layer.masksToBounds = YES;
    headImageBtn.layer.borderWidth = 0.5;
    headImageBtn.layer.borderColor = [[UIColor whiteColor] CGColor];
    [headImageBtn setImage:[UIImage imageNamed:@"person_person_icon"] forState:UIControlStateNormal];
    [headImageBtn addTarget:self action:@selector(HeadImageClick) forControlEvents:UIControlEventTouchUpInside];
    [headImageBtn.imageView setContentMode:UIViewContentModeScaleAspectFill];
    [_header addSubview:headImageBtn];
    
    //        UILabel * nameLabel;//昵称
    nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 100, headImageBtn.frame.size.height + headImageBtn.frame.origin.y + 8, 200, 19)];
    //    nameLabel.backgroundColor = [UIColor blueColor];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.textColor = RGBColor(74, 74, 74);
    nameLabel.text = @"昵称:暂无";
    nameLabel.font = [UIFont systemFontOfSize:17];
    [_header addSubview:nameLabel];

    //名字下面白色
    bgViewWhite = [[UIView alloc]initWithFrame:CGRectMake(0, - 75 - 53 - kHeightOfJiange, SCREEN_WIDTH, 75)];
    bgViewWhite.backgroundColor = [UIColor whiteColor];
    [_tableView addSubview:bgViewWhite];
    
    //胜率下面白色
    UIView * bgViewbottom = [[UIView alloc]initWithFrame:CGRectMake(0, -53 - kHeightOfJiange, SCREEN_WIDTH, 55)];
    bgViewbottom.backgroundColor = [UIColor clearColor];
    [_tableView addSubview:bgViewbottom];
    NSArray * arrayName = @[@"胜",@"胜率",@"平&负"];
    for (int i = 0; i < 3; i++) {
        UIView * bgView1 = [[UIView alloc]initWithFrame:CGRectMake(0 + SCREEN_WIDTH / 3 * i, -52 - kHeightOfJiange, SCREEN_WIDTH / 3 - 1, 52)];
        bgView1.backgroundColor = [UIColor whiteColor];
        [_tableView addSubview:bgView1];
        
        UILabel * nameLab = [self createLabelWithFrame:CGRectMake(bgView1.frame.size.width / 2 - 25, 8, 50, 20) textAlignment:NSTextAlignmentCenter fontSize:14 textColor:[UIColor grayColor] numberOfLines:0 text:arrayName[i]];
        [bgView1 addSubview:nameLab];
    }
    winCountLab = [self createLabelWithFrame:CGRectMake(SCREEN_WIDTH / 3 / 2 - 25, 30 - 55 - kHeightOfJiange, 50, 20) textAlignment:NSTextAlignmentCenter fontSize:14 textColor:RGBColor(74, 74, 74) numberOfLines:0 text:@"暂无"];
    [_tableView addSubview:winCountLab];
    
    winRateLab = [self createLabelWithFrame:CGRectMake( SCREEN_WIDTH / 3 + (SCREEN_WIDTH / 3 / 2 - 35), 30 - 55 - kHeightOfJiange, 70, 20) textAlignment:NSTextAlignmentCenter fontSize:14 textColor:RGBColor(74, 74, 74) numberOfLines:0 text:@"暂无"];
    [_tableView addSubview:winRateLab];
    
    loseCountLab = [self createLabelWithFrame:CGRectMake(SCREEN_WIDTH / 3 * 2 + (SCREEN_WIDTH / 3 / 2 - 25), 30 - 55 - kHeightOfJiange, 50, 20) textAlignment:NSTextAlignmentCenter fontSize:14 textColor:RGBColor(74, 74, 74) numberOfLines:0 text:@"暂无"];
    [_tableView addSubview:loseCountLab];
}



#pragma mark - 点击头像放大
-(void)HeadImageClick
{
    [self magnifyImage:tap];

//    if ([MyUtil jumpToLoginVCIfNoLogin]) {
//        return;
//    }
//    FFEditingInformationViewController *ffsVC = [[FFEditingInformationViewController alloc]init];
//    [self.navigationController pushViewController:ffsVC animated:YES];
}

//查看大图
- (void)magnifyImage:(UITapGestureRecognizer*)taps
{
    if ([MyUtil jumpToLoginVCIfNoLogin]) {
        return;
    }
    
    UIImageView *imageView= [[UIImageView alloc]init];
    imageView.image = headImageBtn.currentImage;
    if (imageView.image==nil) {
        return;
    }
    NSLog(@"局部放大");
    [SJAvatarBrowser showImage:imageView];//调用方法
}
#pragma mark - 创建Label

- (UILabel *)createLabelWithFrame:(CGRect)frame textAlignment:(NSTextAlignment)textAlignment fontSize:(float)fontSize textColor:(UIColor *)textColor numberOfLines:(int)numberOfLines text:(id)text{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.textAlignment = textAlignment;
    [label setFont:[UIFont systemFontOfSize:fontSize]];
    [label setTextColor:textColor];
    [label setNumberOfLines:numberOfLines];
    [label setAdjustsFontSizeToFitWidth:YES];
    [label setLineBreakMode:NSLineBreakByWordWrapping];
    if ([[text class] isSubclassOfClass:[NSMutableAttributedString class]]) {
        
        [label setAttributedText:text];
        
    }else if([[text class] isSubclassOfClass:[NSString class]]){
        
        [label setText:text];
        
    }
    
    return label;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - tap 点击修改背景图像并上传**********
-(void)changeBgImageTap:(UITapGestureRecognizer *)tap
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
- (void)uploadImageToServerWithImage:(UIImage *)Image withFileName:(NSString *)fileName
{
    NSString *isLogin = (NSString *)[mUserDefaults valueForKey:@"isLogin"];
    if (![isLogin isEqualToString:@"1"]) {
        ghostView.message = @"请先登录";
        [ghostView show];
        return;
    }
    //    http://doulian.qihaoduo.comhttp://doulian.qihaoduo.com /user/uploadBackGround

    NSString *url =[NSString stringWithFormat:@"%@%@",kFFAPI,kFFAPI_FFChangeBgImage];//放上传图片的网址http://192.168.8.223:8080/user/uploadFace
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];//初始化请求对象
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];//设置服务器允许的请求格式内容
    //上传图片/文字，只能同POST   * @param fileData 上传头像文件（文件流，图片的格式） logId token
    
    NSString *logId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"logId"]];
    NSString *token = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"token"]];
    //对于图片进行压缩
    //NSData *data = UIImageJPEGRepresentation(image, 0.1);
    NSData *data = UIImagePNGRepresentation(Image);
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
        //成功之后设置背景头像
        bgImageV.image = Image;
        
        ghostView.message = @"设置背景成功";
        [ghostView show];
//#pragma mark - 单例返回上个界面头像
//        self.userInfo = [UserInfo shareUserInfo];
//        self.userInfo.imageIconNew = image;
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error = %@",error);
        ghostView.message = @"设置背景失败";
        [ghostView show];
        
    }];
    
}

//-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableViewCell * cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"IDcell"];
//    if (!cell) {
//        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"IDcell"];
//    }
//    if (indexPath.section == 0 && indexPath.row == 0) {
//        UIImageView * imageV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 30, 30)];
//        imageV.image = [UIImage imageNamed:@"person_person_install"];
//        [cell addSubview:imageV];
//
//        UILabel * lab = [[UILabel alloc]initWithFrame:CGRectMake(imageV.frame.origin.x + imageV.frame.size.width + 10, imageV.frame.origin.y, 150, 30)];
//        lab.text = @"斗脸战绩";
//        lab.textColor = [UIColor grayColor];
//        lab.font = [UIFont systemFontOfSize:16];
//        [cell addSubview:lab];
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//
//    }else if (indexPath.section == 0 && indexPath.row == 1) {
//        UIImageView * imageV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 30, 30)];
//        imageV.image = [UIImage imageNamed:@"person_person_install"];
//        [cell addSubview:imageV];
//
//        UILabel * lab = [[UILabel alloc]initWithFrame:CGRectMake(imageV.frame.origin.x + imageV.frame.size.width + 10, imageV.frame.origin.y, 150, 30)];
//        lab.text = @"修改资料";
//        lab.textColor = [UIColor grayColor];
//        lab.font = [UIFont systemFontOfSize:16];
//        [cell addSubview:lab];
//        //        cell.textLabel.text = @"修改昵称";
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//    }else if (indexPath.section == 0 && indexPath.row == 2) {
//        UIImageView * imageV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 30, 30)];
//        imageV.image = [UIImage imageNamed:@"person_person_install"];
//        [cell addSubview:imageV];
//
//        UILabel * lab = [[UILabel alloc]initWithFrame:CGRectMake(imageV.frame.origin.x + imageV.frame.size.width + 10, imageV.frame.origin.y, 150, 30)];
//        lab.text = @"收到的挑战";
//        lab.textColor = [UIColor grayColor];
//        lab.font = [UIFont systemFontOfSize:16];
//        [cell addSubview:lab];
//        //        cell.textLabel.text = @"修改昵称";
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//    }else if (indexPath.section == 0 && indexPath.row == 3) {
//        UIImageView * imageV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 30, 30)];
//        imageV.image = [UIImage imageNamed:@"person_person_install"];
//        [cell addSubview:imageV];
//
//        UILabel * lab = [[UILabel alloc]initWithFrame:CGRectMake(imageV.frame.origin.x + imageV.frame.size.width + 10, imageV.frame.origin.y, 150, 30)];
//        lab.text = @"积分说明";
//        lab.textColor = [UIColor grayColor];
//        lab.font = [UIFont systemFontOfSize:16];
//        [cell addSubview:lab];
//        //        cell.textLabel.text = @"修改昵称";
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//    }else if (indexPath.section == 0 && indexPath.row == 4) {
//        UIImageView * imageV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 30, 30)];
//        imageV.image = [UIImage imageNamed:@"person_person_install"];
//        [cell addSubview:imageV];
//
//        UILabel * lab = [[UILabel alloc]initWithFrame:CGRectMake(imageV.frame.origin.x + imageV.frame.size.width + 10, imageV.frame.origin.y, 150, 30)];
//        lab.text = @"关于斗脸";
//        lab.textColor = [UIColor grayColor];
//        lab.font = [UIFont systemFontOfSize:16];
//        [cell addSubview:lab];
//        //        cell.textLabel.text = @"修改昵称";
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//    }else if (indexPath.section == 1&& indexPath.row == 0)
//    {
//        UIImageView * imageV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 30, 30)];
//        imageV.image = [UIImage imageNamed:@"person_person_install"];
//        [cell addSubview:imageV];
//
//        UILabel * lab = [[UILabel alloc]initWithFrame:CGRectMake(imageV.frame.origin.x + imageV.frame.size.width + 10, imageV.frame.origin.y, 150, 30)];
//        lab.text = @"修改密码";
//        lab.textColor = [UIColor grayColor];
//        lab.font = [UIFont systemFontOfSize:16];
//        [cell addSubview:lab];
//        //cell.textLabel.text = @"设置密码";
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//
//    }else if (indexPath.section == 1&& indexPath.row == 1)
//    {
//        UIImageView * imageV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 30, 30)];
//        imageV.image = [UIImage imageNamed:@"person_person_install"];
//        [cell addSubview:imageV];
//
//        UILabel * lab = [[UILabel alloc]initWithFrame:CGRectMake(imageV.frame.origin.x + imageV.frame.size.width + 10, imageV.frame.origin.y, 150, 30)];
//        lab.text = @"清除缓存";
//        lab.textColor = [UIColor grayColor];
//        lab.font = [UIFont systemFontOfSize:16];
//        [cell addSubview:lab];
//        //cell.textLabel.text = @"设置密码";
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//
//    }
//    else if (indexPath.section == 2)
//    {
//        UIImageView * imageV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 30, 30)];
//        imageV.image = [UIImage imageNamed:@"person_person_install"];
//        [cell addSubview:imageV];
//
//        UILabel * lab = [[UILabel alloc]initWithFrame:CGRectMake(imageV.frame.origin.x + imageV.frame.size.width + 10, imageV.frame.origin.y, 150, 30)];
//        lab.text = @"退出登录";
//        lab.textColor = [UIColor grayColor];
//        lab.font = [UIFont systemFontOfSize:16];
//        [cell addSubview:lab];
//        //  cell.textLabel.text = @"退出登录";
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//    }
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    return cell;
//}
//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (indexPath.section == 0 && indexPath.row == 0) {
//        NSLog(@"点击了斗脸战绩");
//        FFSeeFightHistoryViewController *ffsVC = [[FFSeeFightHistoryViewController alloc]init];
//        [self.navigationController pushViewController:ffsVC animated:YES];
//
//    }else if (indexPath.section == 0 && indexPath.row == 2){
//        //        ghostView.message = @"挑战者列表";
//        //        [ghostView show];
//        FFChallengerListViewController * vc= [[FFChallengerListViewController alloc]init];
//        [self.navigationController pushViewController:vc animated:YES];
//    }else if (indexPath.section == 0 && indexPath.row == 4){
//        FFIntroduceWebViewController * vc = [[FFIntroduceWebViewController alloc]init];
//        vc.jumpRequest = @"http://www.v4.cc/News-548978.html";
//        vc.webTitle = @"关于斗脸";
//        [self.navigationController pushViewController:vc animated:YES];
//
//    }else if (indexPath.section == 1 && indexPath.row == 0)
//    {
//        NSLog(@"点击了修改密码");
//
//        FFPassWordViewController *ffsVC = [[FFPassWordViewController alloc]init];
//        ffsVC.myType = @"1";//直接修改密码
//        [self.navigationController pushViewController:ffsVC animated:YES];
//    }else if (indexPath.section == 1 && indexPath.row == 1)
//    {
//        NSLog(@"点击了清除缓存");
//        ghostView.message = @"清除缓存成功";
//        [ghostView show];
//    }
//}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
