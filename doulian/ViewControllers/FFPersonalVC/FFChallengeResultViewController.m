//
//  FFChallengeResultViewController.m
//  doulian
//
//  Created by WangJinyu on 16/10/31.
//  Copyright © 2016年 maomao. All rights reserved.
//  个人中心-战绩

#import "FFChallengeResultViewController.h"
//#import "FFAllFightHistoryCell.h"//所有的战斗cell
#import "FFPersonalDetailCell.h"//所有的战斗样式
#import "FFReceiveFightCell.h"//收到的挑战cell样式
#import "FFChallengersModel.h"//收到的挑战model
#import "FFFightRoomViewController.h"//战斗详情界面
#import "FFChallengeUserCreateRoomVC.h"//应战跳到的列表
#import "FFFriendDetailListModel.h"//cell的model

@interface FFChallengeResultViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    OLGhostAlertView *ghostView;
    MBProgressHUD *loadView;
    MBProgressHUD *loadView2;

    int pageIndex;
    int pageIndex2;
    NSMutableArray *dataArray;
    NSMutableArray *dataArray2;
    UITableView * _tableView;
    
    UIButton * leftBtn;
    UIButton * rightBtn;
    
    UIView * redPointV1;//小红点
    UIView * redPointV2;//小红点2
    
    NSString * currentTimeStr;//当前时间
}
@end

@implementation FFChallengeResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackBtn];
    [self addTitleLabel:@"战绩" withTitleColor:[UIColor blackColor]];
//    _clickBOOL = NO;
    [self addHeadBtnView];
    [self addRedPoint];
    [self initTableView];
    dataArray = [NSMutableArray arrayWithCapacity:0];
    dataArray2 = [NSMutableArray arrayWithCapacity:0];
    ghostView = [[OLGhostAlertView alloc] initWithTitle:nil message:nil timeout:0.6 dismissible:YES];
    ghostView.position = OLGhostAlertViewPositionCenter;
    pageIndex = 1;
    pageIndex2 = 1;
    [self requestDataWithPage:pageIndex];
    [self requestData2WithPage:pageIndex2];
    
    if ([mUserDefaults valueForKey:@"ShowAllBadge"]&&[[mUserDefaults valueForKey:@"ShowAllBadge"] isEqualToString:@"1"]) {
        [self showAllBadge];
    }
    if ([mUserDefaults valueForKey:@"ShowChallengeBadge"]&&[[mUserDefaults valueForKey:@"ShowChallengeBadge"] isEqualToString:@"1"]) {
        [self showChallengerBadge];
    }
    
    //添加接收
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAllBadge) name:@"ShowAllBadge" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showChallengerBadge) name:@"ShowChallengeBadge" object:nil];
    /*
     ShowAllBadge
     ShowChallengeBadge
     */
}
#pragma mark - 下拉刷新的方法、上拉刷新的方法
- (void)headerRefresh{
    if (_clickBOOL == NO) {
        pageIndex = 1;
        [self requestDataWithPage:pageIndex];
    }else if (_clickBOOL == YES){
        pageIndex2 = 1;
        [self requestData2WithPage:pageIndex2];
    }
}
- (void)footerRefresh{
    if (_clickBOOL == NO) {
        pageIndex ++;
        [self requestDataWithPage:pageIndex];
    }else if (_clickBOOL == YES){
        pageIndex2 ++;
        [self requestData2WithPage:pageIndex];
    }
}

#pragma mark - 所有的战斗
-(void)requestDataWithPage:(int)page{
    NSString *isLogin = (NSString *)[mUserDefaults valueForKey:@"isLogin"];
    if (![isLogin isEqualToString:@"1"]) {
        ghostView.message = @"请先登录";
        [ghostView show];
        return;
    }
    /*http://192.168.8.223:8080/ fight/getHistoryFights
     http://192.168.8.223:8080 /fight/getFightReports

     * @param userId 用户userid
     * @param pageIndex
     * @param pageSize
     * @param logId
     * @param token
     * @return
     */
    NSString *logId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"logId"]];
    NSString *token = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"token"]];
    NSString * userIDStr = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"userId"]];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:logId,@"logId",token,@"token",[NSString stringWithFormat:@"%d",page],@"pageIndex",@"10",@"pageSize",userIDStr,@"userId",nil];
    
    loadView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [MyUtil requestPostURL:[NSString stringWithFormat:@"%@%@",kFFAPI,kFFAPI_FFSelfHistoryFights] params:params success:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]] ) {
            [loadView hide:YES];
            NSString *error = [NSString stringWithFormat:@"%@",responseObject[@"error"]];
            currentTimeStr = [NSString stringWithFormat:@"%@",responseObject[@"currTime"]];
            [_tableView headerEndRefreshing];
            [_tableView footerEndRefreshing];
            if (error.integerValue==0) {
                NSDictionary *dataDic = responseObject;
                if(page==1){
                    [dataArray removeAllObjects];
                    [dataArray addObjectsFromArray:[dataDic valueForKey:@"data"]];
                    
                }else{
                    NSMutableArray *arrayTemp = [[NSMutableArray alloc] init];
                    [arrayTemp addObjectsFromArray:dataArray];
                    [arrayTemp addObjectsFromArray:[dataDic valueForKey:@"data"]];
                    dataArray = arrayTemp;
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
        [_tableView footerEndRefreshing];
        [loadView hide:YES];
        ghostView.message = @"网络出现问题，请稍后重试";
        [ghostView show];
        
    }];
    
}

#pragma mark - 收到的挑战
-(void)requestData2WithPage:(int)page{
    NSString *isLogin = (NSString *)[mUserDefaults valueForKey:@"isLogin"];
    if (![isLogin isEqualToString:@"1"]) {
        ghostView.message = @"请先登录";
        [ghostView show];
        return;
    }
    /*获取挑战者列表
     http://192.168.8.223:8080 /fight/getChallenges
     * @param userId 当前查看挑战者的用户id
     * @param logId
     * @param token
     @param pageIndex
     * @param pageSize
     
     * @return	{"error":0,"msg":"","currTime":1474446457369,"data":[{"avatarUrl":"/face/2016/08/30/9117995fe64743259fea07bf70992ee2.png","challengeId":9,"create_time":1474446290000,"fromUserId":16,"toUserId":32,"user":{"age":36,"avatar":"/face/2016/08/29/117cd7495fa1483a9b00ac532b0f8c7d.jpg","mobile":"15063941036","name":"nihao","selfIntroduction":"self","sex":1,"third":0,"total_score":1681,"userId":16}}]}
     */
    NSString *logId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"logId"]];
    NSString *token = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"token"]];
    NSString *userId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"userId"]];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:logId,@"logId",token,@"token",[NSString stringWithFormat:@"%d",page],@"pageIndex",@"10",@"pageSize",userId,@"userId",nil];
    
    loadView2 = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [MyUtil requestPostURL:[NSString stringWithFormat:@"%@%@",kFFAPI,kFFAPI_FFGetChallengerList] params:params success:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]] ) {
         [loadView2 hide:YES];
            NSString *error = [NSString stringWithFormat:@"%@",responseObject[@"error"]];
            [_tableView headerEndRefreshing];
            [_tableView footerEndRefreshing];
            if (error.integerValue==0) {
                NSDictionary *dataDic = responseObject;
                if(page==1){
                    [dataArray2 removeAllObjects];
                    [dataArray2 addObjectsFromArray:[dataDic valueForKey:@"data"]];
                }else{
                    NSMutableArray *arrayTemp = [[NSMutableArray alloc] init];
                    [arrayTemp addObjectsFromArray:dataArray2];
                    [arrayTemp addObjectsFromArray:[dataDic valueForKey:@"data"]];
                    dataArray2 = arrayTemp;
                }
                
                NSMutableArray *trashArray = [[NSMutableArray alloc] init];
                for (int i = 0;i<dataArray2.count;i++) {
                    NSMutableDictionary *dic = dataArray2[i];
                    FFChallengersModel *ffChallengerModel = [FFChallengersModel modelWithDictionary:dic];
                    NSLog(@"ffChallengerModel is %@ \n",ffChallengerModel);
                }
                for (int i = 0; i<trashArray.count; i++) {
                    [dataArray2 removeObject:dataArray2[[trashArray[i] intValue]-i]];
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
        [_tableView footerEndRefreshing];
        [loadView2 hide:YES];
        ghostView.message = @"网络出现问题，请稍后重试";
        [ghostView show];
        
    }];
    
}

-(void)addHeadBtnView
{
    UIView * bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 44 + self.num, SCREEN_WIDTH, 60)];
    bgView.backgroundColor = RGBColor(241, 241, 241);
    [self.view addSubview:bgView];
    
    UIView * circleV = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 131.5, 14, 263, 32)];
    circleV.backgroundColor = [UIColor blackColor];
    circleV.layer.cornerRadius = 4;
    circleV.layer.masksToBounds = YES;
    [bgView addSubview:circleV];
    
    leftBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    leftBtn.frame = CGRectMake(1, 1, 130, 30);
    leftBtn.backgroundColor = RGBColor(251, 226, 84);
    //左上角圆角和左下角圆角
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:leftBtn.bounds byRoundingCorners:UIRectCornerTopLeft|UIRectCornerBottomLeft cornerRadii:CGSizeMake(4, 4)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = leftBtn.bounds;
    maskLayer.path = maskPath.CGPath;
    leftBtn.layer.mask = maskLayer;
    [leftBtn setTitle:@"所有的战斗" forState:UIControlStateNormal];
    [leftBtn setTitleColor:RGBColor(54, 28, 29) forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(BtnClick:) forControlEvents:UIControlEventTouchUpInside];
    leftBtn.tag = 1111;
    [circleV addSubview:leftBtn];
    
    rightBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    rightBtn.frame = CGRectMake(132, 1, 130, 30);
    rightBtn.backgroundColor = [UIColor whiteColor];
    //右上角圆角和右下角圆角
    UIBezierPath *maskPath2 = [UIBezierPath bezierPathWithRoundedRect:rightBtn.bounds byRoundingCorners:UIRectCornerTopRight|UIRectCornerBottomRight cornerRadii:CGSizeMake(4, 4)];
    
    CAShapeLayer *maskLayer2 = [[CAShapeLayer alloc] init];
    maskLayer2.frame = rightBtn.bounds;
    maskLayer2.path = maskPath2.CGPath;
    rightBtn.layer.mask = maskLayer2;
    [rightBtn setTitle:@"收到的挑战" forState:UIControlStateNormal];
    [rightBtn setTitleColor:RGBColor(155, 155, 155) forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(BtnClick:) forControlEvents:UIControlEventTouchUpInside];
    rightBtn.tag = 2222;
    [circleV addSubview:rightBtn];
    
}

#pragma mark - 添加小红点
-(void)addRedPoint
{
    redPointV1 = [[UIView alloc]initWithFrame:CGRectMake(leftBtn.frame.size.width - 20, 4, 10, 10)];
    redPointV1.backgroundColor = [UIColor clearColor];
    redPointV1.layer.cornerRadius = redPointV1.frame.size.width / 2;
    redPointV1.layer.masksToBounds = YES;
    [leftBtn addSubview:redPointV1];
    
    redPointV2 = [[UIView alloc]initWithFrame:CGRectMake(rightBtn.frame.size.width - 20, 4, 10, 10)];
    redPointV2.backgroundColor = [UIColor clearColor];
    redPointV2.layer.cornerRadius = redPointV2.frame.size.width / 2;
    redPointV2.layer.masksToBounds = YES;
    [rightBtn addSubview:redPointV2];
}

-(void)backUp:(id)sender{
    
    if ([redPointV2.backgroundColor isEqual:[UIColor clearColor]]) {
        [mUserDefaults setValue:@"0" forKey:@"ShowChallengeBadge"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HideBadge" object:nil];
    }
    [self hideAllBadge];
    [mUserDefaults setValue:@"0" forKey:@"ShowAllBadge"];
    [self.navigationController popViewControllerAnimated:YES];
    
}


-(void)BtnClick:(UIButton *)sender
{
    if (sender.tag == 1111) {
        [self hideAllBadge];
        _clickBOOL = NO;
        
        //字体颜色调换
        [leftBtn setTitleColor:RGBColor(54, 28, 29) forState:UIControlStateNormal];
        [rightBtn setTitleColor:RGBColor(155, 155, 155) forState:UIControlStateNormal];
        //背景颜色调换
        leftBtn.backgroundColor = RGBColor(251, 226, 84);
        rightBtn.backgroundColor = [UIColor whiteColor];
        [_tableView reloadData];
    }else if (sender.tag == 2222){
        _clickBOOL = YES;
        [self hideChallengerBadge];
        redPointV2.backgroundColor = [UIColor clearColor];

        //字体颜色调换
        [leftBtn setTitleColor:RGBColor(155, 155, 155) forState:UIControlStateNormal];
        [rightBtn setTitleColor:RGBColor(54, 28, 29) forState:UIControlStateNormal];
        //背景颜色调换
        leftBtn.backgroundColor = [UIColor whiteColor];
        rightBtn.backgroundColor = RGBColor(251, 226, 84);
        [_tableView reloadData];
    }
}

-(void)showAllBadge//显示左边小红点
{
    redPointV1.backgroundColor = [UIColor redColor];
}

-(void)showChallengerBadge////显示右边小红点
{
    redPointV2.backgroundColor = [UIColor redColor];
}

-(void)hideAllBadge//隐藏左边小红点
{
    redPointV1.backgroundColor = [UIColor clearColor];
}

-(void)hideChallengerBadge//隐藏右边小红点
{
    redPointV2.backgroundColor = [UIColor clearColor];
}

-(void)initTableView{
    //高度减去tabbar高度50
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 44 + self.num + 60, SCREEN_WIDTH, SCREENH_HEIGHT - 44 - self.num - 60) style:UITableViewStylePlain];
    _tableView.backgroundColor = RGBColor(255, 255, 255);
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    _tableView.tableFooterView = [[UIView alloc]init];
    // 下拉刷新
    [_tableView addHeaderWithTarget:self action:@selector(headerRefresh)];
    _tableView.headerPullToRefreshText= @"下拉刷新";
    _tableView.headerReleaseToRefreshText = @"松开马上刷新";
    _tableView.headerRefreshingText = @"努力加载中……";
    // 上拉刷新
    [_tableView addFooterWithTarget:self action:@selector(footerRefresh)];
    _tableView.footerPullToRefreshText= @"上拉加载更多";
    _tableView.footerReleaseToRefreshText = @"松开马上刷新";
    _tableView.footerRefreshingText = @"努力加载中……";
    _tableView.backgroundColor = kBackgraoudColorDefault;
}
#pragma mark- UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    int i = 0;
    if (_clickBOOL == NO) {
        i = (int)dataArray.count;
    }else if (_clickBOOL == YES){
        i = (int)dataArray2.count;
    }
    return i;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    int height = 0;
    if (_clickBOOL == NO) {
        height = 140;
    }else if (_clickBOOL == YES){
        height = 70;
    }

    return height;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_clickBOOL == NO) {
        static NSString *recomendTavleViewCellId = @"FFTableViewCellIDD";
        FFPersonalDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:recomendTavleViewCellId];
        if (!cell) {
            cell = [[FFPersonalDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:recomendTavleViewCellId];
//            [cell setBackgroundColor:RGBAColor(240, 240, 240, 1)];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
        }
        if (dataArray.count > 0) {
            NSDictionary *dic = dataArray[indexPath.row];
            FFFriendDetailListModel *ffListModel = [FFFriendDetailListModel modelWithDictionary:dic];
            NSString * userIDStr = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"userId"]];

            [cell configData:ffListModel withfriendStr:userIDStr withCurrentTime:currentTimeStr];
        }
        return cell;
    }else if (_clickBOOL == YES){
        static NSString *recomendTavleViewCellId = @"FFTableViewCellIDDD";
        FFReceiveFightCell *cell = [tableView dequeueReusableCellWithIdentifier:recomendTavleViewCellId];
        if (!cell) {
            cell = [[FFReceiveFightCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:recomendTavleViewCellId];
//            [cell setBackgroundColor:RGBAColor(240, 240, 240, 1)];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
        }
        if (dataArray2.count > 0) {
            NSMutableDictionary * dic = dataArray2[indexPath.row];//列表里user的dic是挑战者的信息,外面是自己的info
            FFChallengersModel * ffChallengerModel = [FFChallengersModel modelWithDictionary:dic];
            [cell configData:ffChallengerModel withIndexPath:indexPath];
        }
        return cell;
    }else{
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"IDCELL"];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"IDCELL"];
        }
        return cell;
    }
    
    
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_clickBOOL == NO) {
        if (dataArray.count > 0) {
            NSDictionary *dic = dataArray[indexPath.row];
            FFFightRoomViewController *room = [FFFightRoomViewController new];
            room.dataDic = dic;
            room.isFromHistory = YES;
            [self.navigationController pushViewController:room animated:YES];
        }
    }else if (_clickBOOL == YES){
        if (dataArray2.count > 0) {
            //跳转到应战
            FFChallengeUserCreateRoomVC * vc = [[FFChallengeUserCreateRoomVC alloc]init];
                    vc.dataDic = dataArray2[indexPath.row];
                    /*avatarUrl = "/face/2016/08/30/9117995fe64743259fea07bf70992ee2.png";
                     challengeId = 50;
                     "create_time" = 1475216666000;
                     fromUserId = 16;
                     presentId = 0;
                     toUserId = 28;*/
                    vc.challengeId = [NSString stringWithFormat:@"%@",dataArray2[indexPath.row][@"challengeId"]];
                    vc.isAcceptChallenge = YES;
            [self requestCheckFightWithChaVC:vc];
        }
    }
//    NSDictionary *dic = dataArray[indexPath.row];
//    FFFightRoomViewController *room = [FFFightRoomViewController new];
//    room.dataDic = dic;
//    [self.navigationController pushViewController:room animated:YES];
}
//查看用户当前道具
-(void)requestCheckFightWithChaVC:(FFChallengeUserCreateRoomVC *)vc{
    NSString *isLogin = (NSString *)[mUserDefaults valueForKey:@"isLogin"];
    if (![isLogin isEqualToString:@"1"]) {
        ghostView.message = @"请先登录";
        [ghostView show];
        return;
    }
    NSString *logId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"logId"]];
    NSString *token = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"token"]];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:logId,@"logId",token,@"token",nil];
    
    //    loadView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [MyUtil requestPostURL:[NSString stringWithFormat:@"%@%@",kFFAPI,kFFAPI_FFCheckFight] params:params success:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]] ) {
            [loadView hide:YES];
            NSString *error = [NSString stringWithFormat:@"%@",responseObject[@"error"]];
            if (error.integerValue==0) {
                NSDictionary *dataDic = [responseObject valueForKey:@"data"];
                NSMutableArray *presentArray ;
                for (NSString *key in dataDic.allKeys) {
                    if ([key isEqualToString:@"userPresents"]) {
                        if ([dataDic valueForKey:@"userPresents"]) {
                            presentArray = [dataDic valueForKey:@"userPresents"];
                        }
                    }
                }
                vc.arrayPresents = presentArray;
                [self.navigationController pushViewController:vc animated:true];
                NSLog(@"1");
            }else{
                [self.navigationController pushViewController:vc animated:true];

//                ghostView.message = @"您当前有比赛正在进行中，自动为您跳转";
//                ghostView.timeout = 2.0;
//                [ghostView show];
                //                FFFightRoomViewController *room = [FFFightRoomViewController new];
                //                room.responseDic = responseObject;
                //                room.dataDic = [responseObject valueForKey:@"data"];
                //                [self.navigationController pushViewController:room animated:true];
            }
        }
    } failure:^(NSError *error) {
        [_tableView headerEndRefreshing];
        [_tableView footerEndRefreshing];
        [loadView hide:YES];
        ghostView.message = @"网络出现问题，请稍后重试";
        [ghostView show];
        
    }];
    
}
/*
斗脸历史
http://192.168.8.223:8080/fight/getHistoryFights
* @param userId 用户userid
* @param pageIndex
* @param pageSize
* @param logId
* @param token
* @return
*/
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//   NSString * challengeStr;
//    if ([redPointV2.backgroundColor isEqual:[UIColor redColor]]) {
//        challengeStr = @"1";
//    }else{
//        challengeStr = @"0";
//
//    }
//    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
//    [dic setValue:@"0" forKey:@"AllBadge"];
//    [dic setValue:challengeStr forKey:@"ChallengerBadge"];

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
