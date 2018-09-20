//
//  FFFriendListViewController.m
//  doulian
//
//  Created by WangJinyu on 16/9/1.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import "FFFriendListViewController.h"
#import "FFfriendCell.h"
//#import "FTPopOverMenu.h"//更多下拉菜单
#import "FFAskForHelpViewController.h"//求帮助页面
#import "FFPersonalDetailVC.h"
#import "SearchFriendViewController.h"//搜索界面
#import "FFLoginViewController.h"//登陆
#import <UMSocialCore/UMSocialCore.h>
#import "UMSocialUIManager.h"

@interface FFFriendListViewController ()<UITableViewDataSource,UITableViewDelegate>
{
//    int pageIndex1;
    UITableView * _tableView;
    
    OLGhostAlertView * ghostView;
    MBProgressHUD * loadView;
    
    UIView * noFriendBgView;
    UIButton* headImageBtn;
    UIImageView *shareImage;
    UIView * bgFooterView;
    
}
@property (nonatomic,strong)NSMutableArray * dataArray;
@property (nonatomic,strong)NSMutableDictionary * dataDicAll;
@end

@implementation FFFriendListViewController

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

#pragma mark - 收到通知刷新界面
-(void)notice:(id)sender
{
    NSLog(@"接收到通知");
    [self requestData];
}

-(void)viewWillAppear:(BOOL)animated{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configHeadView];
    [self addRightBtnwithImgName:nil Title:@"添加" TitleColor:[UIColor blackColor]];
    [self addTitleLabel:@"好友" withTitleColor:[UIColor blackColor]];
    // Do any additional setup after loading the view.
    ghostView = [[OLGhostAlertView alloc] initWithTitle:nil message:nil timeout:0.6 dismissible:YES];
    ghostView.position = OLGhostAlertViewPositionCenter;
    self.dataArray = [NSMutableArray arrayWithCapacity:0];
    self.dataDicAll = [NSMutableDictionary dictionaryWithCapacity:0];
    
    [self createTableView];
    [self requestData];
    //通知刷新本页
    NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
    //添加当前类对象为一个观察者，name和object设置为nil，表示接收一切通知
    [center addObserver:self selector:@selector(notice:) name:@"refreshFFFriendListHeader" object:nil];
    [center addObserver:self selector:@selector(notice:) name:@"refreshFFListHeader" object:nil];
    
    [self getShareInfo];

}

-(void)searchBtnClick
{
    NSLog(@"点击搜索");
    SearchFriendViewController * vc = [[SearchFriendViewController alloc]init];
    vc.isSearchStranger = NO;
    [self.navigationController pushViewController:vc animated:NO];
}

-(void)onClickRightBtn:(UIButton *)sender
{
    NSLog(@"点击添加");
    SearchFriendViewController * vc = [[SearchFriendViewController alloc]init];
    vc.isSearchStranger = YES;
    [self.navigationController pushViewController:vc animated:NO];
}

#pragma mark - createTableView
-(void)createTableView
{
    UIView * bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 43 + self.num, SCREEN_WIDTH, 50)];
    bgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgView];
    
    UIView * lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [bgView addSubview:lineView];
    
    UIButton * searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.frame = CGRectMake(10, 10, SCREEN_WIDTH - 20, 30);
    [searchBtn setBackgroundColor:RGBColor(244, 244, 244)];
    [searchBtn setTitle:@"      搜索" forState:UIControlStateNormal];
    searchBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [searchBtn setTitleColor:RGBColor(155, 155, 155) forState:UIControlStateNormal];
    searchBtn.layer.cornerRadius = 4;
    searchBtn.layer.masksToBounds = YES;
    [searchBtn addTarget:self action:@selector(searchBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:searchBtn];
    
    UIImageView * searchImageV = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 30, 7, 16, 16)];
    searchImageV.image = [UIImage imageNamed:@"FFSearch_searchIcon"];
    [searchBtn addSubview:searchImageV];
    
//    UIImageView * searchImageV = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 12, 20)];
//    searchImageV.image = [UIImage imageNamed:@"FFLogin_passWord"];
//    [searchBtn addSubview:searchImageV];

    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 50 + 44 + self.num, SCREEN_WIDTH, SCREENH_HEIGHT - 50 - 50 - 44 - self.num ) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.tableFooterView = [[UIView alloc]init];
    [self.view addSubview:_tableView];
    
    headImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    headImageBtn.frame = CGRectMake(0, 0, SCREEN_WIDTH, 190);
    [headImageBtn setBackgroundImage:[UIImage imageNamed:@"FFFriendList_banner"] forState:UIControlStateNormal];
    [headImageBtn addTarget:self action:@selector(headImageClick) forControlEvents:UIControlEventTouchUpInside];
    _tableView.tableHeaderView = headImageBtn;
    
    // 下拉刷新
    [_tableView addHeaderWithTarget:self action:@selector(headerRefresh)];
    _tableView.headerPullToRefreshText= @"下拉刷新";
    _tableView.headerReleaseToRefreshText = @"松开马上刷新";
    _tableView.headerRefreshingText = @"努力加载中……";
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int i = 0;
    if (self.dataArray.count > 0) {
        i = (int)self.dataArray.count;
    }
    return i;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FFfriendCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ID1"];
    if (cell == nil)
    {
        cell = [[FFfriendCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ID1"];
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;//显示最右边的箭头
    }
    if (self.dataArray.count > 0) {
        [cell configDataDicFriend:self.dataArray[indexPath.row]];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FFPersonalDetailVC * vc = [[FFPersonalDetailVC alloc]init];
    if (self.dataArray.count > 0) {
        vc.userIDStr = [NSString stringWithFormat:@"%@",self.dataArray[indexPath.row][@"userId"]];
    }
    [self.navigationController pushViewController: vc animated:YES];

}

#pragma mark - 实现cell里面挑战ta的方法
-(void)challengeTaBtnClick:(UIButton *)sender
{
    NSLog(@"点击了挑战ta");
}

#pragma mark - 下拉刷新的方法、上拉刷新的方法
- (void)headerRefresh{
    [self requestData];
}

#pragma mark- 获取朋友列表
-(void)requestData
{
    if ([MyUtil jumpToLoginVCIfNoLogin]) {
        [_tableView headerEndRefreshing];
        bgFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, headImageBtn.frame.origin.y + headImageBtn.frame.size.height, SCREEN_WIDTH, 150)];
//        bgFooterView.backgroundColor = RGBColor(30, 150, 225);
        _tableView.tableFooterView = bgFooterView;
        
        UIButton * loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        loginBtn.frame = CGRectMake(SCREEN_WIDTH / 2 - 50, 10, 100, 100);
        [loginBtn setBackgroundColor:RGBColor(244, 244, 244)];
        [loginBtn setBackgroundImage:[UIImage imageNamed:@"FFFriend_noLogin"] forState:UIControlStateNormal];
        [loginBtn addTarget:self action:@selector(gotoLogoCLick) forControlEvents:UIControlEventTouchUpInside];
        [bgFooterView addSubview:loginBtn];
        
        UILabel * toastLab = [self createLabelWithFrame:CGRectMake(loginBtn.frame.origin.x, loginBtn.frame.size.height + loginBtn.frame.origin.y + 5, loginBtn.frame.size.width, 20) textAlignment:NSTextAlignmentCenter fontSize:14 textColor:RGBColor(74, 74, 74) numberOfLines:0 text:@"请登录查看"];
        [bgFooterView addSubview:toastLab];
        return;
    }else if(![MyUtil jumpToLoginVCIfNoLogin]){
    _tableView.tableFooterView = [[UIView alloc]init];
        [self makeUIOfAddFriend:NO];
    }
    
    NSString *logId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"logId"]];
    NSString *token = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"token"]];
    NSString * userId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"userId"]];
    
    if (!userId||[userId isEqualToString:@"(null)"]) {
        userId = @"0";
    }
    if (!logId||[logId isEqualToString:@"(null)"]) {
        logId = @"0";
    }
    if (!token||[token isEqualToString:@"(null)"]) {
        token = @"0";
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:logId,@"logId",token,@"token",userId,@"userId",nil];
    
    loadView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [MyUtil requestPostURL:[NSString stringWithFormat:@"%@%@",kFFAPI,kFFAPI_FFGetFriendList] params:params success:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]] ) {
            [loadView hide:YES];
            NSString *error = [NSString stringWithFormat:@"%@",responseObject[@"error"]];
            [_tableView headerEndRefreshing];
            if (error.integerValue==0) {
                NSDictionary *dataDic = responseObject;
                self.dataArray = [NSMutableArray arrayWithCapacity:0];
                self.dataArray = [dataDic valueForKey:@"data"];
                NSLog(@"hahahaha%@",[dataDic valueForKey:@"data"]);
                NSLog(@"self.dataArray.count hahahaha%d",(int)self.dataArray.count);

                if (self.dataArray.count == 0) {
                    [self makeUIOfAddFriend:YES];
                }else
                {
                    [self makeUIOfAddFriend:NO];
                }
                [_tableView reloadData];
                NSLog(@"1");
            }else{
                ghostView.message = @"获取内容失败，请稍后重试";
                [ghostView show];
            }
        }
    } failure:^(NSError *error) {
        [_tableView headerEndRefreshing];
        [loadView hide:YES];
        ghostView.message = @"网络出现问题，请稍后重试";
        [ghostView show];
    }];
}

-(void)makeUIOfAddFriend:(BOOL)ifMake
{
    
    if (ifMake == YES) {
         noFriendBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 44 + self.num + 190 + 50, SCREEN_WIDTH, SCREENH_HEIGHT - self.num - 44 - 190 - 50)];
        noFriendBgView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:noFriendBgView];
        
        UILabel * nofriendLab = [self createLabelWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 90, noFriendBgView.frame.size.height / 2 - 100, 180, 20) textAlignment:NSTextAlignmentCenter fontSize:17 textColor:[UIColor lightGrayColor] numberOfLines:0 text:@"还没有好友?"];
        [noFriendBgView addSubview:nofriendLab];
        
        UIButton * addButton = [UIButton buttonWithType:UIButtonTypeSystem];
        addButton.frame = CGRectMake(nofriendLab.frame.origin.x, nofriendLab.frame.origin.y + nofriendLab.frame.size.height + 5, nofriendLab.frame.size.width, nofriendLab.frame.size.height);
        [addButton setTitle:@"现在添加+" forState:UIControlStateNormal];
        [addButton setTitleColor:RGBColor(85, 164, 255) forState:UIControlStateNormal];
        [addButton addTarget:self action:@selector(onClickRightBtn:) forControlEvents:UIControlEventTouchUpInside];
        [noFriendBgView addSubview:addButton];
    }
        if (ifMake == NO && noFriendBgView) {
            [noFriendBgView removeFromSuperview];
        [_tableView reloadData];
    }
}

-(void)headImageClick
{
    __weak typeof(self) weakSelf = self;
    [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMShareMenuSelectionView *shareSelectionView, UMSocialPlatformType platformType) {
        
        [weakSelf shareWebPageToPlatformType:platformType ShareModel:_shareModel];
    }];
}

#pragma mark -
#pragma mark - 分享相关
//网页分享
- (void)shareWebPageToPlatformType:(UMSocialPlatformType)platformType ShareModel:(FFShareModel *)model
{
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    
    //创建网页内容对象
    //    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:@"分享标题" descr:@"分享内容描述" thumImage:[UIImage imageNamed:@"icon"]];
    NSString* thumbURL =  @"http://weixintest.ihk.cn/ihkwx_upload/heji/material/img/20160414/1460616012469.jpg";
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:model.title descr:model.message thumImage:shareImage.image];
    //设置网页地址
    shareObject.webpageUrl =model.url;
    
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
        if (error) {
            UMSocialLogInfo(@"************Share fail with error %@*********",error);
            ghostView.title = @"分享失败";
            [ghostView show];
            
        }else{
            if ([data isKindOfClass:[UMSocialShareResponse class]]) {
                UMSocialShareResponse *resp = data;
                //分享结果消息
                UMSocialLogInfo(@"response message is %@",resp.message);
                //第三方原始返回的数据
                UMSocialLogInfo(@"response originalResponse data is %@",resp.originalResponse);
                
                ghostView.title = @"分享成功";
                [ghostView show];
                
            }else{
                UMSocialLogInfo(@"response data is %@",data);
            }
        }
        //        [self alertWithError:error];
    }];
}


//拉取房间分享信息
-(void)getShareInfo{
    
    __weak typeof(self) weakSelf = self;
    NSString *logId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"logId"]];
    NSString *token = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"token"]];
    NSString *userId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"userId"]];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"3",@"type",userId,@"userId",@"0",@"fightId",@"0",@"presentId",nil];
    
    //    loadView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [MyUtil requestPostURL:[NSString stringWithFormat:@"%@%@",kFFAPI,kFFAPI_FFGetShareInfo] params:params success:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]] ) {
            [loadView hide:YES];
            NSString *error = [NSString stringWithFormat:@"%@",responseObject[@"error"]];
            if (error.integerValue==0) {
                _shareModel = [FFShareModel modelWithDictionary:responseObject[@"data"]];
                shareImage  = [[UIImageView alloc] initWithFrame:CGRectMake(0, -100, 30, 30)];
                [shareImage setImageWithURL:[NSURL URLWithString:_shareModel.pic]];
                
            }else{
//                ghostView.message = @"获取内容失败，请重新登陆后重试";
//                [ghostView show];
            }
        }
    } failure:^(NSError *error) {
        [loadView hide:YES];
        ghostView.message = @"网络出现问题，请稍后重试";
        [ghostView show];
        
    }];
    
}

-(void)gotoLogoCLick
{
    FFLoginViewController * vc = [[FFLoginViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
