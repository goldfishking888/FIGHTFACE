//
//  FFPersonalDetailVC.m
//  doulian
//
//  Created by WangJinyu on 16/9/23.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import "FFPersonalDetailVC.h"
#import "FFFriendDetailListModel.h"
#import "FFListFightUserModel.h"
#import "FFListFUDetailUserModel.h"
#import "FFChallengeUserCreateRoomVC.h"//应战跳转界面 挑战他跳转界面
#import "HMObjcSugar.h"//简单设置控件的各种坐标值
#import "FFPersonalDetailCell.h"//
#import "FFFightRoomViewController.h"//跳转比赛界面
#define kHeaderHeight 215 //头部高度
#define kHeightOfJiange 10 //头部和cell的间隔高度

#define FFTableCellHeight 200
#define FFTableCellPicSize 120 //这三个是控制tableview的
#define FFTableCellAvatarSize 30
#define FFIconNeedToDecrease 55

#define mString(a,b,c) [NSString stringWithFormat:@"%@%@%@",a,b,c]
@interface FFPersonalDetailVC ()<UITableViewDelegate,UITableViewDataSource>
{
    OLGhostAlertView *ghostView;
    MBProgressHUD *loadView;
    int pageIndex;
    NSMutableArray *dataArray;
    NSMutableDictionary * dataDicOfUser;
    //age": 36,  "imei": "3222",   "mobile": "15063941036",   "name": "nihao",  "self_introduction": "self", "sex": 1}）  mobile:手机号 ,name :名称 ,imei：设备号,sex 性别 1:男 2：女 ; age： 年龄，self_introduction ：
    UILabel *titleLabel4;
    UIImageView * bgImageV;//整个滑动界面
    UIButton * headImageBtn;//头像点击
    
    UILabel * nameLabel;//昵称
    //    UILabel * ageLabel;//年龄
    //    UILabel * mobileLab;//手机号码
    //    UILabel * introducLab;//自我介绍
    //    UILabel * sexLab;//性别
    UITapGestureRecognizer * tap;
    UILabel * ffLabel;//斗脸历史
    
    UITableView * _tableView;
    UIButton * addAndDelFriendBtn;//加为好友btn
    int addDeleteTag;
    UILabel * addFriendLab;//加为好友列表显示
    int appearTime;
    
    UIView *_header;//导航栏颜色
    UIStatusBarStyle _statusBarYStyle;//改变那个时间颜色等
    
    UILabel * winCountLab;//胜 胜率 负
    UILabel * winRateLab;
    UILabel * loseCountLab;
    
    NSString * winCountStr;
    NSString * winRateStr;
    NSString * loseCountStr;
    
    NSString * currentTimeStr;
    
    
    
}
@end

@implementation FFPersonalDetailVC

//返回按钮点击
-(void)backUpClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initTableView];
    [self addHeaderView];
    dataDicOfUser = [NSMutableDictionary dictionaryWithCapacity:0];
    [self requestDataWithUserIDStr:self.userIDStr];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    _statusBarYStyle = UIStatusBarStyleLightContent;
    ghostView = [[OLGhostAlertView alloc] initWithTitle:nil message:nil timeout:0.6 dismissible:YES];
    ghostView.position = OLGhostAlertViewPositionCenter;
    [self requestData];
}
-(void)requestDataWithUserIDStr:(NSString *)userIdStr
{/*
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
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:userIdStr,@"toUserId",userId,@"userId",userId,@"fromUserId",logId,@"logId",token,@"token",nil];
    
    [MyUtil requestPostURL:[NSString stringWithFormat:@"%@%@",kFFAPI,kFFAPI_FFGETUserDetail] params:params success:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]] ) {
            NSLog(@"responseObject is ----<>%@",responseObject);
            NSString *error = [NSString stringWithFormat:@"%@",responseObject[@"error"]];
            currentTimeStr = [NSString stringWithFormat:@"%@",responseObject[@"currTime"]];
            [_tableView headerEndRefreshing];
            [_tableView footerEndRefreshing];
            if (error.integerValue==0) {
                NSDictionary *dataDic = responseObject[@"data"];
                [self valueDataOfheader:dataDic];
                dataDicOfUser = [dataDic mutableCopy];
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
- (void )addHeaderView {
    
    _header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.hm_width, kHeaderHeight)];
    _header.backgroundColor = RGBColor(251, 226, 84);
    [self.view addSubview:_header];
    
    bgImageV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kHeaderHeight)];
    bgImageV.userInteractionEnabled = YES;
    bgImageV.image = [UIImage imageNamed:@"person_person_bg"];
    bgImageV.contentMode = UIViewContentModeScaleAspectFill;//图片左右上下都变大
    //        UIButton * headImageBtn;//头像点击
    headImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    headImageBtn.frame = CGRectMake(SCREEN_WIDTH / 2 - 40, kHeaderHeight - FFIconNeedToDecrease, 80, 80);
    headImageBtn.layer.cornerRadius = headImageBtn.frame.size.width / 2;
    headImageBtn.layer.masksToBounds = YES;
    headImageBtn.layer.borderWidth = 0.5;
    headImageBtn.layer.borderColor = [[UIColor whiteColor] CGColor];
    [headImageBtn.imageView setContentMode:UIViewContentModeScaleAspectFill];
    [headImageBtn setBackgroundImage:[UIImage imageNamed:@"person_person_icon"] forState:UIControlStateNormal];
    [headImageBtn addTarget:self action:@selector(headImageClick) forControlEvents:UIControlEventTouchUpInside];
    
    [bgImageV addSubview:headImageBtn];
    
    addAndDelFriendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addAndDelFriendBtn.frame = CGRectMake(SCREEN_WIDTH - 70, kHeaderHeight - FFIconNeedToDecrease, 50, 30);
    addAndDelFriendBtn.layer.cornerRadius = 10;
    addAndDelFriendBtn.layer.masksToBounds = YES;
    addAndDelFriendBtn.layer.borderWidth = 0.5;
    addAndDelFriendBtn.layer.borderColor = [[UIColor blackColor] CGColor];
    //已经是好友FFFriendDetail_isFriend
    [addAndDelFriendBtn addTarget:self action:@selector(addFriendWithToUserId) forControlEvents:UIControlEventTouchUpInside];
    [bgImageV addSubview:addAndDelFriendBtn];
    
    //        UILabel * nameLabel;//昵称
    nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 100, headImageBtn.frame.size.height + headImageBtn.frame.origin.y + 8, 200, 23)];
    //    nameLabel.backgroundColor = [UIColor blueColor];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.textColor = [UIColor blackColor];
    nameLabel.text = @"昵称:暂无";
    nameLabel.font = [UIFont boldSystemFontOfSize:18];
    [bgImageV addSubview:nameLabel];
    
    bgImageV.frame = CGRectMake(0, 0, self.view.hm_width, kHeaderHeight);
    [_header addSubview:bgImageV];
    //返回按钮
    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _backButton.frame = CGRectMake(10,9+self.num,51,21);
    [_backButton.titleLabel setFont:[UIFont fontWithName:@"Courier" size:15]];
    [_backButton addTarget:self action:@selector(backUp:) forControlEvents:UIControlEventTouchUpInside];
    [_backButton setBackgroundImage:[UIImage imageNamed:@"btn_back_white"] forState:UIControlStateNormal];
    //返回按钮点击区域
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 80, 44);
    [button addTarget:self action:@selector(backUpClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    [self.view addSubview:_backButton];
    
    titleLabel4 = [[UILabel alloc]initWithFrame:CGRectMake(30, 10+self.num, SCREEN_WIDTH - 30 * 2, 25)] ;
    [titleLabel4 setTextAlignment:NSTextAlignmentCenter];
    [titleLabel4 setBackgroundColor:[UIColor clearColor]];
    [titleLabel4 setTextColor:[UIColor whiteColor]];
    [titleLabel4 setFont:[UIFont fontWithName:@"Courier" size: 17]];
    [titleLabel4 setText:@"用户详情"];
    [self.view addSubview:titleLabel4];
    
}

-(void)addFriendWithToUserId{
    NSString * toUserId = [NSString stringWithFormat:@"%@",dataDicOfUser[@"userId"]];
    NSString *isLogin = (NSString *)[mUserDefaults valueForKey:@"isLogin"];
    if (![isLogin isEqualToString:@"1"]) {
        ghostView.message = @"请先登录";
        [ghostView show];
        return;
    }
    NSString * useridStr = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"userId"]];
    
    if ([toUserId isEqualToString:useridStr]) {
        ghostView.message = @"不能添加自己为好友";
        [ghostView show];
        return;
    }
    
    NSString *logId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"logId"]];
    NSString *token = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"token"]];
    NSString *userId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"userId"]];
    if (addDeleteTag == 10000) {
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:logId,@"logId",token,@"token",userId,@"fromUserId",toUserId,@"toUserId",nil];
        
        loadView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [MyUtil requestPostURL:[NSString stringWithFormat:@"%@%@",kFFAPI,kFFAPI_FFAddFriend] params:params success:^(id responseObject) {
            if ([responseObject isKindOfClass:[NSDictionary class]] ) {
                [loadView hide:YES];
                NSString *error = [NSString stringWithFormat:@"%@",responseObject[@"error"]];
                if (error.integerValue==0) {
                    NSString *msg = [NSString stringWithFormat:@"%@",responseObject[@"msg"]];
                    ghostView.message = @"成功添加好友";
                    [ghostView show];
                    [addAndDelFriendBtn setImage:[UIImage imageNamed:@"FFFriendDetail_isFriend"] forState:UIControlStateNormal];
                    addDeleteTag = 10001;
                    //创建通知刷新好友列表
                    NSNotification * notice = [NSNotification notificationWithName:@"refreshFFFriendListHeader" object:nil userInfo:nil];
                    //发送消息
                    [[NSNotificationCenter defaultCenter]postNotification:notice];
                }else{
                    ghostView.message = responseObject[@"msg"];
                    [ghostView show];
                }
            }
        } failure:^(NSError *error) {
            [loadView hide:YES];
            ghostView.message = @"网络出现问题，请稍后重试";
            [ghostView show];
            
        }];
    }else if (addDeleteTag == 10001)//是好友就调取消好友接口
    {
        /*解除好友
         http://192.168.8.223:8080/user/relieveFriend
         * @param fromUserId  当前用户id
         * @param toUserId   想要解除的用户id
         * @param logId
         * @param token
         * @return {"error":0,"msg":"","currTime":1472716274701}
         */
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:logId,@"logId",token,@"token",userId,@"fromUserId",toUserId,@"toUserId",nil];
        
        loadView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [MyUtil requestPostURL:[NSString stringWithFormat:@"%@%@",kFFAPI,kFFAPI_FFRelieveFriend] params:params success:^(id responseObject) {
            if ([responseObject isKindOfClass:[NSDictionary class]] ) {
                [loadView hide:YES];
                NSString *error = [NSString stringWithFormat:@"%@",responseObject[@"error"]];
                if (error.integerValue==0) {
                    ghostView.message = @"成功解除好友";
                    [ghostView show];
                    [addAndDelFriendBtn setImage:[UIImage imageNamed:@"FFFriendDetail_addFriend"] forState:UIControlStateNormal];
                    addDeleteTag = 10000;
                    NSNotification * notice = [NSNotification notificationWithName:@"refreshFFFriendListHeader" object:nil userInfo:nil];
                    //发送消息
                    [[NSNotificationCenter defaultCenter]postNotification:notice];
                    
                }else{
                    NSString *msg = [NSString stringWithFormat:@"%@",responseObject[@"msg"]];
                    ghostView.message = msg;
                    [ghostView show];
                }
            }
        } failure:^(NSError *error) {
            [loadView hide:YES];
            ghostView.message = @"网络出现问题，请稍后重试";
            [ghostView show];
            
        }];
    }
    
    
}

#pragma mark- 获取好友详情的近五场比赛
-(void)requestData
{
    /*获取好友的近5场比赛记录
     http://192.168.8.223:8080/ user/getFriendDetail
     * @param friendId 好友的用户id
     * @param logId
     * @param token
     * @return*/
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
    
    NSLog(@"userid2222222is%@",userId);
    //    NSString * friendIDStr = [NSString stringWithFormat:@"%@",self.personDic[@"userId"]];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.userIDStr,@"friendId",logId,@"logId",token,@"token",nil];
    
    loadView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [MyUtil requestPostURL:[NSString stringWithFormat:@"%@%@",kFFAPI,kFFAPI_FFGETFriendDetail] params:params success:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]] ) {
            [loadView hide:YES];
            NSLog(@"responseObject is ----<>%@",responseObject);
            NSString *error = [NSString stringWithFormat:@"%@",responseObject[@"error"]];
            [_tableView headerEndRefreshing];
            [_tableView footerEndRefreshing];
            if (error.integerValue==0) {
                NSDictionary *dataDic = responseObject;
                dataArray = [dataDic valueForKey:@"data"];
            }
            [_tableView reloadData];
            NSLog(@"1");
        }else{
            ghostView.message = @"获取内容失败，请稍后重试";
            [ghostView show];
        }
    }
                   failure:^(NSError *error) {
                       [_tableView headerEndRefreshing];
                       [loadView hide:YES];
                       ghostView.message = @"网络出现问题，请稍后重试";
                       [ghostView show];
                       
                   }];
}

-(void)initTableView{
    //高度减去tabbar高度50
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREENH_HEIGHT - 50) style:UITableViewStylePlain];
    _tableView.backgroundColor = RGBColor(243, 243, 243);
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    _tableView.contentInset = UIEdgeInsetsMake(kHeaderHeight + 75 + 55, 0, 0, 0);//75  55 是下面白色的高度
    //名字下面白色
    UIView * bgViewWhite = [[UIView alloc]initWithFrame:CGRectMake(0, - 75 - 55 - kHeightOfJiange, SCREEN_WIDTH, 75)];
    bgViewWhite.backgroundColor = [UIColor whiteColor];
    [_tableView addSubview:bgViewWhite];
    
    //胜率下面白色
    UIView * bgViewbottom = [[UIView alloc]initWithFrame:CGRectMake(0, -55 - kHeightOfJiange, SCREEN_WIDTH, 55)];
    bgViewbottom.backgroundColor = [UIColor clearColor];
    [_tableView addSubview:bgViewbottom];
    NSArray * arrayName = @[@"胜",@"胜率",@"平&负"];
    for (int i = 0; i < 3; i++) {
        UIView * bgView1 = [[UIView alloc]initWithFrame:CGRectMake(0 + SCREEN_WIDTH / 3 * i, -54 - kHeightOfJiange, SCREEN_WIDTH / 3 - 1, 54)];
        bgView1.backgroundColor = [UIColor whiteColor];
        [_tableView addSubview:bgView1];
        
        UILabel * nameLab = [self createLabelWithFrame:CGRectMake(bgView1.frame.size.width / 2 - 25, 8, 50, 20) textAlignment:NSTextAlignmentCenter fontSize:14 textColor:RGBColor(131, 131, 131) numberOfLines:0 text:arrayName[i]];
        [bgView1 addSubview:nameLab];
    }
    winCountLab = [self createLabelWithFrame:CGRectMake(SCREEN_WIDTH / 3 / 2 - 25, 30 - 55 - kHeightOfJiange, 50, 20) textAlignment:NSTextAlignmentCenter fontSize:14 textColor:RGBColor(74, 74, 74) numberOfLines:0 text:@"暂无"];
//    winCountLab.backgroundColor = [UIColor greenColor];
    [_tableView addSubview:winCountLab];
    
    winRateLab = [self createLabelWithFrame:CGRectMake( SCREEN_WIDTH / 3 + (SCREEN_WIDTH / 3 / 2 - 35), 30 - 55 - kHeightOfJiange, 70, 20) textAlignment:NSTextAlignmentCenter fontSize:14 textColor:RGBColor(74, 74, 74) numberOfLines:0 text:@"暂无"];
//    winRateLab.backgroundColor = [UIColor greenColor];
    [_tableView addSubview:winRateLab];
    
    loseCountLab = [self createLabelWithFrame:CGRectMake(SCREEN_WIDTH / 3 * 2 + (SCREEN_WIDTH / 3 / 2 - 25), 30 - 55 - kHeightOfJiange, 50, 20) textAlignment:NSTextAlignmentCenter fontSize:14 textColor:RGBColor(74, 74, 74) numberOfLines:0 text:@"暂无"];
    [_tableView addSubview:loseCountLab];
    
    //添加返回按钮
    self.view.backgroundColor = kBackgraoudColorDefault;
    
    if (![MyUtil isAppCheck]) {
        UIView * bgView  = [[UIView alloc]initWithFrame:CGRectMake(0, SCREENH_HEIGHT - 60, SCREEN_WIDTH, 60)];
        bgView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:bgView];
        UIButton * fightBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        fightBtn.frame = CGRectMake(10, 5, SCREEN_WIDTH - 20, 50);
        fightBtn.backgroundColor = RGBColor(251, 226, 84);
        fightBtn.layer.cornerRadius = fightBtn.frame.size.height / 2;
        fightBtn.layer.masksToBounds = YES;
        fightBtn.layer.borderWidth = 1;
        fightBtn.layer.borderColor = [[UIColor blackColor] CGColor];
        [fightBtn addTarget:self action:@selector(goFightHerBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [bgView addSubview:fightBtn];
        
        UILabel * fightLab = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 50, 10, 100, 30)];
        fightLab.textColor = [UIColor blackColor];
        fightLab.text = @"挑战TA吧";
        fightLab.textAlignment = NSTextAlignmentCenter;
        fightLab.font = [UIFont boldSystemFontOfSize:18];
        [fightBtn addSubview:fightLab];

    }else{
        UIView * bgView  = [[UIView alloc]initWithFrame:CGRectMake(0, SCREENH_HEIGHT - 60, SCREEN_WIDTH, 60)];
        bgView.backgroundColor = RGBColor(243, 243, 243);
        [self.view addSubview:bgView];
    }
}

#pragma mark - 点击查看好友大图
-(void)headImageClick
{
    [self magnifyImage:tap];
}

#pragma mark 头部数据从新读下来的接口刷新
-(void)valueDataOfheader:(NSDictionary *)personDic
{
    NSString * bgImgUrl = [NSString stringWithFormat:@"%@%@",kFFAPI,personDic[@"background"]];
    UIImage * bgImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:bgImgUrl]]];
    [bgImageV setImage:((bgImage == nil)?[UIImage imageNamed:@"person_person_bg"]:bgImage)];
    
    NSString * imageUrl = [NSString stringWithFormat:@"%@%@",kFFAPI,personDic[@"avatar"]];
    UIImage * image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]];
    if (image == nil) {
        [headImageBtn setBackgroundImage:[UIImage imageNamed:@"person_person_icon"] forState:UIControlStateNormal];
    }else{
        [headImageBtn setImage:image forState:UIControlStateNormal];
    }
//    [headImageBtn.imageView setContentMode:UIViewContentModeScaleAspectFill];

    NSString *name = [NSString stringWithFormat:@"%@",personDic[@"name"]];//
    [nameLabel setText:((name.length>0)?[NSString stringWithFormat:@"%@",name]:@"暂无昵称")];
    nameLabel.numberOfLines = 1;
    if ([personDic[@"friend"] intValue] == 1) {
        
        [addAndDelFriendBtn setImage:[UIImage imageNamed:@"FFFriendDetail_isFriend"] forState:UIControlStateNormal];
        addDeleteTag = 10001;
    }else if ([personDic[@"friend"] intValue] == 0){
        
        [addAndDelFriendBtn setImage:[UIImage imageNamed:@"FFFriendDetail_addFriend"] forState:UIControlStateNormal];
        addDeleteTag = 10000;
    }
    winRateLab.text = [NSString stringWithFormat:@"%@",personDic[@"rateWinning"]];
    winCountLab.text = [NSString stringWithFormat:@"%@", personDic[@"win"]];
    int loseAndDrawCount = [personDic[@"draw"] intValue]+ [personDic[@"lose"] intValue];
    loseCountLab.text = [NSString stringWithFormat:@"%d", loseAndDrawCount];
    
}

-(void)goFightHerBtnClick
{
    
    
    if ([[mUserDefaults valueForKey:@"userId"] isEqual:[dataDicOfUser valueForKey:@"userId"]]) {
        ghostView.message = @"不能挑战自己";
        [ghostView show];
        return;
    }
    
    FFChallengeUserCreateRoomVC * vc = [[FFChallengeUserCreateRoomVC alloc]init];
    vc.dataDic = dataDicOfUser;
    [self.navigationController pushViewController:vc animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 140;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([MyUtil isAppCheck]) {
        return 0;
    }
    return dataArray.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (dataArray.count > 0) {
        NSDictionary *dic = dataArray[indexPath.row];
        FFFightRoomViewController *room = [FFFightRoomViewController new];
        room.dataDic = dic;
        [self.navigationController pushViewController:room animated:YES];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *recomendTableViewCellId = @"FFTableViewCellID";
    FFPersonalDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:recomendTableViewCellId];
    if (!cell) {
        cell = [[FFPersonalDetailCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:recomendTableViewCellId];
        [cell setBackgroundColor:[UIColor whiteColor]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    if (dataArray.count > 0) {
        NSDictionary *dic = dataArray[indexPath.row];
        FFFriendDetailListModel *ffListModel = [FFFriendDetailListModel modelWithDictionary:dic];
        [cell configData:ffListModel withfriendStr:self.userIDStr withCurrentTime:currentTimeStr];
        //        cell.tag = (int)indexPath.row;
    }
    return cell;
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

//查看大图
- (void)magnifyImage:(UITapGestureRecognizer*)taps
{
    UIImageView *imageView= [[UIImageView alloc]init];
    imageView.image = headImageBtn.currentImage;
    if (imageView.image==nil) {
        return;
    }
    NSLog(@"局部放大");
    [SJAvatarBrowser showImage:imageView];//调用方法
}

#pragma mark - 发生滑动
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offset = scrollView.contentOffset.y + kHeaderHeight+ 75 + 55;//把底部的2块空白考虑进去
    
    //    NSLog(@"%f",offset);
    if (offset < 0) { //下拉 | 放大
        [titleLabel4 setTextColor:[UIColor whiteColor]];
        NSDictionary *dic = @{
                              @"offset" : [NSString stringWithFormat:@"%f",offset]
                              };
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"zys" object:nil userInfo:dic];
        _header.hm_height = kHeaderHeight;
        _header.hm_y = 0;
        _header.hm_height = kHeaderHeight - offset;
        headImageBtn.frame = CGRectMake(SCREEN_WIDTH / 2 - 40, kHeaderHeight - offset - FFIconNeedToDecrease, 80, 80);
        nameLabel.frame = CGRectMake(SCREEN_WIDTH / 2 - 100, headImageBtn.frame.size.height + headImageBtn.frame.origin.y + 8, 200, 23);
        addAndDelFriendBtn.frame = CGRectMake(SCREEN_WIDTH - 70, kHeaderHeight - 50 - offset, 50, 30);
        
        bgImageV.alpha = 1;
        
    } else{
        
        _header.hm_y = 0;
        CGFloat minOffset = kHeaderHeight - 64;
        _header.hm_y = minOffset > offset ? - offset : - minOffset;

        CGFloat progress = 1 - (offset / minOffset);
        bgImageV.alpha = progress;
        if (progress <= 0.2) {
            [titleLabel4 setTextColor:[UIColor blackColor]];
            [_backButton setBackgroundImage:[UIImage imageNamed:@"btn_back"] forState:UIControlStateNormal];
        }else
        {
            [titleLabel4 setTextColor:[UIColor whiteColor]];
            [_backButton setBackgroundImage:[UIImage imageNamed:@"btn_back_white"] forState:UIControlStateNormal];

        }
        _statusBarYStyle = progress < 0.2 ? UIStatusBarStyleDefault:UIStatusBarStyleLightContent;
        [self.navigationController setNeedsStatusBarAppearanceUpdate];
    }
    bgImageV.hm_height = _header.hm_height;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return _statusBarYStyle;
}

- (void)BackUp:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
