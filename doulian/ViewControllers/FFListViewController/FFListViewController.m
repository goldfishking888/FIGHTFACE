//
//  DLListViewController.m
//  doulian
//
//  Created by Suny on 16/8/24.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import "FFListViewController.h"
#import "AFHTTPSessionManager.h"
#import "FFLoginViewController.h"
#import "FFCreateRoomViewController.h"

#import "FFListModel.h"
#import "FFListFightUserModel.h"
#import "FFListFUDetailUserModel.h"

#import "FFFightRoomViewController.h"

#import "FFPresentOuterModel.h"
#import "FFPresentListModel.h"

#import "FFFindingFightViewController.h"

#import "FFListCell.h"//列表cell
#import "LoopPageView.h"//lunbo轮播
#import "FFIntroduceWebViewController.h"//轮播跳转页面
#import "FFRankingListViewController.h"//排行榜界面
#import "HMObjcSugar.h"//简单设置控件的各种坐标值

#define FFTableCellHeight 161
#define FFTableCellPicSize 120
#define FFTableCellAvatarSize 30


#define kHeaderHeight 215 //头部高度
#define kHeightOfJiange 8 //头部和cell的间隔高度

#define mString(a,b,c) [NSString stringWithFormat:@"%@%@%@",a,b,c]

@implementation FFListViewController
{
    OLGhostAlertView *ghostView_Image;
    

    OLGhostAlertView *ghostView;
    MBProgressHUD *loadView;
    int pageIndex;
    NSMutableArray *dataArray;
    
//    UILabel *titleLabel4; //这三个首页改为带头部使用
//    UIView *_header;//导航栏颜色
//    UIStatusBarStyle _statusBarYStyle;//改变那个时间颜色等
    
    //所有剩余时间数组
    NSMutableArray *totalLastTime;
    NSMutableArray * arrayCarousels;//轮播数组
    NSTimer *timer;
    
    CGFloat rate;
}
#pragma mark - 收到通知刷新界面
-(void)notice:(id)sender
{
    NSLog(@"接收到通知");
    pageIndex = 1;
    [self requestDataWithPage:1];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    rate = 1;
    if (isiPhoneBelow5s) {
        rate = 320.0/375.0;
    }else if(isiPhoneUpper6plus){
        rate = 414.0/375.0;
    }
    
    [self initTableView];
    [self loadLunbo];
    
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//    [[UINavigationBar appearance] setBarTintColor:[UIColor blackColor]];
    self.view.backgroundColor = [UIColor whiteColor];
    dataArray= [[NSMutableArray alloc] init];
    ghostView = [[OLGhostAlertView alloc] initWithTitle:nil message:nil timeout:0.6 dismissible:YES];
    ghostView.position = OLGhostAlertViewPositionCenter;
    
    ghostView_Image = [[OLGhostAlertView alloc] initWithFrame:CGRectZero ImageName:@"toast_back"];
    ghostView_Image.position = OLGhostAlertViewPositionCenter;
//    self.automaticallyAdjustsScrollViewInsets = NO;//首页改成带头部使用
//    _statusBarYStyle = UIStatusBarStyleLightContent;

    pageIndex = 1;
//    sleep(2);
    loadView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self requestDataWithPage:pageIndex];
    
    //刷新本页的通知 用来注册成功或者登陆成功到这个界面手动刷新界面
    //获取通知中心单例对象
    NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
    //添加当前类对象为一个观察者，name和object设置为nil，表示接收一切通知
    [center addObserver:self selector:@selector(notice:) name:@"refreshFFListHeader" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notice:) name:@"SearchingFightSucceed" object:nil];
}

#pragma mark - 请求轮播接口
-(void)loadLunbo
{
    //这9行首页改为带头部使用
//    _header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.hm_width, kHeaderHeight)];
//    _header.backgroundColor = [UIColor yellowColor];
//    [self.view addSubview:_header];
//
//    titleLabel4 = [[UILabel alloc]initWithFrame:CGRectMake(30, 10+self.num, SCREEN_WIDTH - 30 * 2, 25)] ;
//    [titleLabel4 setTextAlignment:NSTextAlignmentCenter];
//    [titleLabel4 setBackgroundColor:[UIColor clearColor]];
//    [titleLabel4 setTextColor:[UIColor whiteColor]];
//    [titleLabel4 setFont:[UIFont fontWithName:@"Courier" size: 17]];
//    [titleLabel4 setText:@"斗脸"];
//    [self.view addSubview:titleLabel4];
    //    首页轮播
    //http://192.168.8.223:8080/sys/getCarousels
    //    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:logId,@"logId",token,@"token",[NSString stringWithFormat:@"%d",page],@"pageIndex",@"10",@"pageSize",nil];
    //http://192.168.8.223:8080 /sys/getCarousels
    self.loopView.imageNames = [[NSArray alloc]init];
    UIView * bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kHeaderHeight + 45)];
    _tableView.tableHeaderView = bgView;
    [MyUtil requestPostURL:[NSString stringWithFormat:@"%@%@",kFFAPI,kFFAPI_FFGetCarousels] params:nil success:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]] ) {
            [loadView hide:YES];
            NSString *error = [NSString stringWithFormat:@"%@",responseObject[@"error"]];
            if (error.integerValue==0) {
                NSDictionary *dataDic = responseObject;
                arrayCarousels = [dataDic valueForKey:@"data"];
                self.loopView = [[LoopPageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kHeaderHeight)];
//                self.loopView.backgroundColor  =[UIColor blueColor];
                self.loopView.imageNames = arrayCarousels;
                
               [bgView addSubview:self.loopView];
//                [_header addSubview:self.loopView];

                [_tableView reloadData];
            }else{
                self.loopView.imageNames = nil;
            }
        }
    } failure:^(NSError *error) {
        self.loopView.imageNames = nil;
        ghostView.message = @"网络出现问题，请稍后重试";
        [ghostView show];
    }];
    UIView * headerViews = [[UIView alloc]initWithFrame:CGRectMake(0, 215, SCREEN_WIDTH, 45)];
    headerViews.backgroundColor = kBackgraoudColorDefault;
    UIView * headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 5, headerViews.frame.size.width, 40)];
    headerView.backgroundColor = [UIColor whiteColor];
    [headerViews addSubview:headerView];
    
    UILabel * fightChannelLab = [self createLabelWithFrame:CGRectMake(11, 15, 100, 20) textAlignment:NSTextAlignmentLeft fontSize:18 textColor:[UIColor blackColor] numberOfLines:1 text:@"比赛频道"];
    [headerView addSubview:fightChannelLab];
    
    UILabel * rankLab = [self createLabelWithFrame:CGRectMake(headerView.frame.size.width - 10 - 80, 15, 80, 20) textAlignment:NSTextAlignmentRight fontSize:15 textColor:[UIColor blackColor] numberOfLines:1 text:@"排行榜  ＞"];
    [headerView addSubview:rankLab];
    
    UIButton * rankBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    rankBtn.frame = CGRectMake(0, 0, headerView.frame.size.width, headerView.frame.size.height);
    rankBtn.backgroundColor = [UIColor clearColor];
    [rankBtn addTarget:self action:@selector(rankBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:rankBtn];
    //左上角圆角和右上角圆角
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:headerView.bounds byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = headerView.bounds;
    maskLayer.path = maskPath.CGPath;
    headerView.layer.mask = maskLayer;
    [bgView addSubview:headerViews];
}

#pragma mark - 轮播中的点击图片调用的方法
-(void)loopButtonClick:(UIButton *)sender
{/* {
  "create_time" = 1475254861000;
  description = "\U68d2\U68d2\U7684";
  fightId = 201;
  id = 2;
  isClose = 0;
  pic = "/face/2016/09/30/873e07515cb54aceaeb3f179df662aac.jpg";
  title = "";
  type = 2;
  url = "";
  }*/
    if ([MyUtil jumpToLoginVCIfNoLogin]) {
        return;
    }
    
    NSLog(@"点击上面的轮播tag (id)is%d",sender.tag);
    int i= sender.tag;
//    for (int i = 0; i < arrayCarousels.count; i++) {
        if ([arrayCarousels[i][@"type"] intValue] == 1) {
            //@"跳转web页面";
            NSString * url = [NSString stringWithFormat:@"%@",arrayCarousels[i][@"url"]];
            if(!url||[url isEqualToString:@""]){
                return;
            }
            FFIntroduceWebViewController * vc= [[FFIntroduceWebViewController alloc]init];
            url = [NSString stringWithFormat:@"%@?logId=%@&token=%@&version=%@&platform=%@",url,[mUserDefaults valueForKey:@"logId"]?:@"",[mUserDefaults valueForKey:@"token"]?:@"",kAppVersion,@"iOS"];
            
            vc.jumpRequest = url;
            vc.webTitle = arrayCarousels[i][@"title"];
            [self.navigationController pushViewController:vc animated:YES];
            NSLog(@"type is 2 url is");
        }
        else if ([arrayCarousels[i][@"type"] intValue] == 2){
            //@"跳转比赛详情页面 fightId is%@",arrayCarousels[i][@"fightId"]];
            FFFightRoomViewController *room = [FFFightRoomViewController new];
            room.dataDic = arrayCarousels[i];
            [self.navigationController pushViewController:room animated:YES];
        }else{
            
        }
}

-(void)initTableView{
    //高度减去tabbar高度50
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0, SCREEN_WIDTH, SCREENH_HEIGHT - 50) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    //适配iOS11顶部出现的下拉问题
    if (@available(iOS 11.0, *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }

//    _tableView.contentInset = UIEdgeInsetsMake(kHeaderHeight, 0, 0, 0);//这句话用来实现带头部nav的
    
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

#pragma mark - 下拉刷新的方法、上拉刷新的方法
- (void)headerRefresh{
    pageIndex =1;
    [self requestDataWithPage:pageIndex];
    
}
- (void)footerRefresh{
    pageIndex ++;
    [self requestDataWithPage:pageIndex];
}

-(void)requestDataWithPage:(int)page{

    NSString *logId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"logId"]];
    NSString *token = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"token"]];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:logId,@"logId",token,@"token",[NSString stringWithFormat:@"%d",page],@"pageIndex",@"10",@"pageSize",nil];
    
    //如果是审核，多传一个参数
    if ([MyUtil isAppCheck]) {
        [params setValue:@"1" forKey:@"isAppCheck"];
    }
    
    
    [MyUtil requestPostURL:[NSString stringWithFormat:@"%@%@",kFFAPI,kFFAPI_FFList] params:params success:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]] ) {
            [loadView hide:YES];
            NSString *error = [NSString stringWithFormat:@"%@",responseObject[@"error"]];
            [_tableView headerEndRefreshing];
            [_tableView footerEndRefreshing];
            if (error.integerValue==0) {
                NSDictionary *dataDic = responseObject;
                if(page==1){
                    dataArray = [[NSMutableArray alloc] init];
                    [dataArray addObjectsFromArray:[dataDic valueForKey:@"data"]];
                    
                }else{
                    NSMutableArray *arrayTemp = [[NSMutableArray alloc] init];
                    [arrayTemp addObjectsFromArray:dataArray];
                    [arrayTemp addObjectsFromArray:[dataDic valueForKey:@"data"]];
                    dataArray = arrayTemp;
                }
                
                //脏数据处理
                NSMutableArray *trashArray = [[NSMutableArray alloc] init];
                for (int i = 0;i<dataArray.count;i++) {
                    NSMutableDictionary *dic = dataArray[i];
                    FFListModel *ffListModel = [FFListModel modelWithDictionary:dic];
                    NSMutableArray *arrayFightUsers = ffListModel.fightUsers;
                    
                    if (arrayFightUsers.count==0||arrayFightUsers.count==1) {
                        [trashArray addObject:[NSString stringWithFormat:@"%d",i]];
                    }
                }
                for (int i = 0; i<trashArray.count; i++) {
                    NSString * temNum =(NSString *) trashArray[i];
                    
                    [dataArray removeObject:dataArray[[temNum integerValue]-i]];
                }
                
                //构建需要显示时间的剩余时间数组
                totalLastTime = [[NSMutableArray alloc] init];
                for (int i = 0; i<dataArray.count; i++) {
                    NSDictionary *dic = dataArray[i];
                    FFListModel *ffListModel = [FFListModel modelWithDictionary:dic];
                    int reTime = [ffListModel.remainingTime intValue];
                    if (reTime>0) {
                        NSDictionary *dicTime = @{@"indexPathRow":[NSString stringWithFormat:@"%d",i],@"lastTime": ffListModel.remainingTime};
                        [totalLastTime addObject:dicTime];
                    }
                }
                
                [_tableView reloadData];
                [self startTimer];
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

-(void)requestCheckFight{
    
    NSString *logId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"logId"]];
    NSString *token = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"token"]];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:logId,@"logId",token,@"token",nil];
    
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
                FFCreateRoomViewController *rig = [[FFCreateRoomViewController alloc] init];
                rig.arrayPresents = presentArray;
                [self.navigationController pushViewController:rig animated:true];
                NSLog(@"1");
            }else{
                ghostView.message = @"您当前有比赛正在进行中，自动为您跳转";
                ghostView.timeout = 2.0;
                [ghostView show];
                FFFightRoomViewController *room = [FFFightRoomViewController new];
                room.responseDic = responseObject;
                room.dataDic = [responseObject valueForKey:@"data"];
                [self.navigationController pushViewController:room animated:true];
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


- (void)startTimer
{
    [timer invalidate];
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(refreshLessTime) userInfo:@"" repeats:YES];
    
    //如果不添加下面这条语句，在UITableView拖动的时候，会阻塞定时器的调用
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:UITrackingRunLoopMode];
    
}

- (void)refreshLessTime
{
    //    NSUInteger time;
    long int time ;
    //    timeInLine = [[[NSNumberFormatter alloc] numberFromString:roomModel.remainingTime] longValue];
    for (int i = 0; i < totalLastTime.count; i++) {
        time = [[[NSNumberFormatter alloc] numberFromString:[[totalLastTime objectAtIndex:i] objectForKey:@"lastTime"]] longLongValue];
        CGFloat retime = [[[NSNumberFormatter alloc] numberFromString:[[totalLastTime objectAtIndex:i] objectForKey:@"lastTime"]] floatValue]/1000;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[[[totalLastTime objectAtIndex:i] objectForKey:@"indexPathRow"] integerValue] inSection:0];
        FFListCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
        UILabel *timeLeft = cell.timerDecreaseLab;
        UILabel *label_left = cell.label_left;
        UIImageView *imageV = cell.timerDecreaseImageV;
        NSDictionary *dicInfo = dataArray[indexPath.row];
        FFListModel *ffListModel = [FFListModel modelWithDictionary:dicInfo];
        CGFloat totalTime = (ffListModel.end_time.longLongValue-ffListModel.start_time.longLongValue)/1000;
        CGFloat progress = (totalTime-retime)/totalTime;
        if(time<=0){
            timeLeft.text = @"";
            label_left.text = @"";
            UIImage *image = [UIImage imageNamed:@"已结束"];
            [image stretchableImageWithLeftCapWidth:20 topCapHeight:20];
            [imageV setImage:image];
//            imageV.backgroundColor = [UIColor clearColor];
//            FFViewBorderRadius(imageV, imageV.frame.size.width/2, 1, [UIColor clearColor]);
            cell.circleProgress.hidden = YES;
        }else{
            [imageV setImage:nil];
//            imageV.backgroundColor = RGBColor(251, 226, 84);
//            FFViewBorderRadius(imageV, imageV.frame.size.width/2, 1, RGBColor(54, 28, 29));
            cell.circleProgress.percent = progress;
            cell.circleProgress.hidden = NO;
            if(time%1000!=0&&time/1000<60){
                //一分钟以下显示到秒
                label_left.text = @"剩余";
                NSString *newTimeStr = [NSString stringWithFormat:@"%ld",time ];
                timeLeft.text = [NSString stringWithFormat:@"%@秒",[MyUtil ConvertStrToTime:newTimeStr toFormat:@"ss"]];
            }else{
                label_left.text = @"剩余";
                NSString *newTimeStr = [NSString stringWithFormat:@"%ld",time];
                timeLeft.text = [NSString stringWithFormat:@"%@分",[MyUtil ConvertStrToTime:newTimeStr toFormat:@"mm"]];
            }
            
            time -=1000*1;
        }
        NSDictionary *dic = @{@"indexPathRow": [NSString stringWithFormat:@"%ld",(long)indexPath.row],@"lastTime": [NSString stringWithFormat:@"%ld",time]};
        [totalLastTime replaceObjectAtIndex:i withObject:dic];
        //        [_tableView reloadData];
    }
}

- (NSString *)lessSecondToDay:(NSUInteger)seconds
{
    NSUInteger day  = (NSUInteger)seconds/(24*3600);
    NSUInteger hour = (NSUInteger)(seconds%(24*3600))/3600;
    NSUInteger min  = (NSUInteger)(seconds%(3600))/60;
    NSUInteger second = (NSUInteger)(seconds%60);
    
    NSString *time = [NSString stringWithFormat:@"%lu日%lu小时%lu分钟%lu秒",(unsigned long)day,(unsigned long)hour,(unsigned long)min,(unsigned long)second];
    return time;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return FFTableCellHeight*rate;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *recomendTavleViewCellId = @"FFTavleViewCellId";
    FFListCell *cell = [tableView dequeueReusableCellWithIdentifier:recomendTavleViewCellId];
    if (!cell) {
        cell = [[FFListCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:recomendTavleViewCellId];
        [cell setBackgroundColor:RGBAColor(240, 240, 240, 1)];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }

    if (dataArray.count > 0) {
        NSDictionary *dic = dataArray[indexPath.row];
        FFListModel *ffListModel = [FFListModel modelWithDictionary:dic];
        [cell configData:ffListModel withIndexPath:indexPath];
        cell.tag = (int)indexPath.row;
    }
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if (dataArray.count > 0) {
        NSDictionary *dic = dataArray[indexPath.row];
        FFFightRoomViewController *room = [FFFightRoomViewController new];
        room.dataDic = dic;
        [self.navigationController pushViewController:room animated:YES];
    }
    
//    ghostView_Image.title = [NSString stringWithFormat:@"开局积分+%@",@"2"];
//    ghostView_Image.timeout = 1.5;
//    [ghostView_Image showWithAnimation];

}


-(void)rankBtnClick
{
    NSLog(@"跳转到排行榜");
    if ([MyUtil jumpToLoginVCIfNoLogin]) {
        return;
    }
    FFRankingListViewController * vc = [[FFRankingListViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];//即使没有显示在window上，也不会自动的将self.view释放。注意跟ios6.0之前的区分
    // Add code to clean up any of your own resources that are no longer necessary.
    // 此处做兼容处理需要加上ios6.0的宏开关，保证是在6.0下使用的,6.0以前屏蔽以下代码，否则会在下面使用self.view时自动加载viewDidUnLoad
//    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0) {
//        //需要注意的是self.isViewLoaded是必不可少的，其他方式访问视图会导致它加载，在WWDC视频也忽视这一点。
//        if (self.isViewLoaded && !self.view.window)// 是否是正在使用的视图
//        {
//            // Add code to preserve data stored in the views that might be
//            // needed later.
//            // Add code to clean up other strong references to the view in
//            // the view hierarchy.
//            self.view = nil;// 目的是再次进入时能够重新加载调用viewDidLoad函数。
//        }
//    }
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
//#pragma mark - 发生滑动
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    CGFloat offset = scrollView.contentOffset.y + kHeaderHeight;//把底部的2块空白考虑进去
//    
//    NSLog(@"%f",offset);
//    if (offset < 0) { //下拉 | 放大
//        [titleLabel4 setTextColor:[UIColor clearColor]];
//        NSDictionary *dic = @{
//                              @"offset" : [NSString stringWithFormat:@"%f",offset]
//                              };
//        
//        [[NSNotificationCenter defaultCenter]postNotificationName:@"zys" object:nil userInfo:dic];
//        _header.hm_height = kHeaderHeight;
//        _header.hm_y = 0;
//        //        _header.hm_height = kHeaderHeight - offset;
//        
//        self.loopView.alpha = 1;
//        
//    } else {
//        
//        _header.hm_y = 0;
//        CGFloat minOffset = kHeaderHeight - 64;
//        _header.hm_y = minOffset > offset ? - offset : - minOffset;
//        
//        CGFloat progress = 1 - (offset / minOffset);
//        //        if (progress <= 0.01) {
//        //            self.loopView.alpha = progress;
//        //            [titleLabel4 setTextColor:[UIColor blackColor]];
//        //
//        //        }else
//        //        {
//        //            self.loopView.alpha = 1;
//        //            [titleLabel4 setTextColor:[UIColor clearColor]];
//        //
//        //        }
//        self.loopView.alpha = progress;
//        _statusBarYStyle = progress < 0.4 ? UIStatusBarStyleDefault:UIStatusBarStyleLightContent;
//        [self.navigationController setNeedsStatusBarAppearanceUpdate];
//    }
//    self.loopView.hm_height = _header.hm_height;
//}
//- (UIStatusBarStyle)preferredStatusBarStyle {
//    return _statusBarYStyle;
//}
@end
