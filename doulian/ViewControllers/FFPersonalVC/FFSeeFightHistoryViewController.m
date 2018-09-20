//
//  FFSeeFightHistoryViewController.m
//  doulian
//
//  Created by WangJinyu on 16/8/25.
//  Copyright © 2016年 maomao. All rights reserved.
//  废弃不用了

#import "FFSeeFightHistoryViewController.h"
#import "FFListModel.h"
#import "FFListFightUserModel.h"
#import "FFListFUDetailUserModel.h"

#import "FFFightRoomViewController.h"
@interface FFSeeFightHistoryViewController ()
{
    OLGhostAlertView *ghostView;
    MBProgressHUD *loadView;
    int pageIndex;
    NSMutableArray *dataArray;
}
@end
#define FFTableCellHeight 200
#define FFTableCellPicSize 120
#define FFTableCellAvatarSize 30

#define mString(a,b,c) [NSString stringWithFormat:@"%@%@%@",a,b,c]
@implementation FFSeeFightHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackBtn];
    [self addTitleLabel:@"斗脸历史战绩"];
    [self initTableView];
    dataArray= [[NSMutableArray alloc] init];
    ghostView = [[OLGhostAlertView alloc] initWithTitle:nil message:nil timeout:0.6 dismissible:YES];
    ghostView.position = OLGhostAlertViewPositionCenter;
    pageIndex =1;
    [self requestDataWithPage:pageIndex];
    // Do any additional setup after loading the view.
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
    NSString *isLogin = (NSString *)[mUserDefaults valueForKey:@"isLogin"];
    if (![isLogin isEqualToString:@"1"]) {
        ghostView.message = @"请先登录";
        [ghostView show];
        return;
    }
    /*http://192.168.8.223:8080/ fight/getHistoryFights
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
            [_tableView headerEndRefreshing];
            [_tableView footerEndRefreshing];
            if (error.integerValue==0) {
                //                NSString *msg = [NSString stringWithFormat:@"%@",responseObject[@"msg"]];
                //                ghostView.message = msg;
                //                [ghostView show];
                NSDictionary *dataDic = responseObject;
                if(page==1){
                    [dataArray addObjectsFromArray:[dataDic valueForKey:@"data"]];
                    
                }else{
                    NSMutableArray *arrayTemp = [[NSMutableArray alloc] init];
                    [arrayTemp addObjectsFromArray:dataArray];
                    [arrayTemp addObjectsFromArray:[dataDic valueForKey:@"data"]];
                    dataArray = arrayTemp;
                }
                
                //                for (NSMutableDictionary *dic in dataArray) {
                //                    FFListModel *ffListModel = [FFListModel modelWithDictionary:dic];
                //                    NSMutableArray *arrayFightUsers = ffListModel.fightUsers;
                //
                //                    if (arrayFightUsers.count==0) {
                //                        [dataArray removeObject:dic];
                //                    }
                //                }
                //脏数据处理
                NSMutableArray *trashArray = [[NSMutableArray alloc] init];
                for (int i = 0;i<dataArray.count;i++) {
                    NSMutableDictionary *dic = dataArray[i];
                    FFListModel *ffListModel = [FFListModel modelWithDictionary:dic];
                    NSMutableArray *arrayFightUsers = ffListModel.fightUsers;
                    
                    if (arrayFightUsers.count==0) {
                        [trashArray addObject:[NSNumber numberWithInt:i]];
                    }
                }
                for (int i = 0; i<trashArray.count; i++) {
                    [dataArray removeObject:dataArray[[trashArray[i] intValue]-i]];
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
-(void)initTableView{
    //高度减去tabbar高度50
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 44 + 20, SCREEN_WIDTH, SCREENH_HEIGHT-44-20 ) style:UITableViewStylePlain];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
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
    return dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return FFTableCellHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *recomendTavleViewCellId = @"FFTavleViewCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:recomendTavleViewCellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:recomendTavleViewCellId];
        [cell setBackgroundColor:RGBAColor(240, 240, 240, 1)];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        //背景
        UIImageView *imgBack = [[UIImageView alloc]initWithImage:[[UIImage imageNamed:@"hr_circle_item"] stretchableImageWithLeftCapWidth:30 topCapHeight:14]];
        imgBack.backgroundColor = mRGBToColor(0xf9f9f9);
        [imgBack setFrame:CGRectMake(0, 0, SCREEN_WIDTH, FFTableCellHeight-20)];
        //        imgV.tag = 13001;
        [cell addSubview:imgBack];
        //
        //        UIImageView *imgVS = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"vs"]];
        //        [imgVS setFrame:CGRectMake((SCREEN_WIDTH-65)/2, 35, 70, 77)];
        ////        imgVS.center = cell.center;
        //        [cell addSubview:imgVS];
        
        //斗图左
        UIImageView *imgV = [[UIImageView alloc]initWithImage:[[UIImage imageNamed:@"hr_circle_item"] stretchableImageWithLeftCapWidth:30 topCapHeight:14]];
        imgV.backgroundColor = [UIColor blueColor];
        [imgV setFrame:CGRectMake(10, 10, FFTableCellPicSize, FFTableCellPicSize)];
        imgV.tag = 13001;
        [imgV setUserInteractionEnabled:YES];
        [cell addSubview:imgV];
        //斗图右
        UIImageView *imgV2 = [[UIImageView alloc]initWithImage:[[UIImage imageNamed:@"hr_circle_item"] stretchableImageWithLeftCapWidth:30 topCapHeight:14]];
        imgV2.backgroundColor = [UIColor blueColor];
        [imgV2 setFrame:CGRectMake(SCREEN_WIDTH-FFTableCellPicSize-10, 10, FFTableCellPicSize, FFTableCellPicSize)];
        imgV2.tag = 13002;
        [imgV2 setUserInteractionEnabled:YES];
        [cell addSubview:imgV2];
        
        //添加点击查看大图
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(magnifyImage:)];
        [imgV addGestureRecognizer:tap];
        UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(magnifyImage:)];
        [imgV2 addGestureRecognizer:tap2];
        
        //比分左
        UILabel *scoreLabel = [self createLabelWithFrame:CGRectMake(15+FFTableCellPicSize, 55, 50, 20) textAlignment:NSTextAlignmentCenter fontSize:18 textColor:mRGBToColor(0x5c5c5c) numberOfLines:0 text:nil];
        [scoreLabel setFont:[UIFont boldSystemFontOfSize:18]];
        scoreLabel.tag = 13008;
        [cell addSubview:scoreLabel];
        //比分右
        UILabel *scoreLabel2 = [self createLabelWithFrame:CGRectMake(SCREEN_WIDTH-FFTableCellPicSize-15-50,55, 50, 20) textAlignment:NSTextAlignmentCenter fontSize:18 textColor:mRGBToColor(0x5c5c5c) numberOfLines:0 text:nil];
        [scoreLabel2 setFont:[UIFont boldSystemFontOfSize:18]];
        scoreLabel2.tag = 13009;
        [cell addSubview:scoreLabel2];
        
        //用户头像左
        UIImageView *imga = [[UIImageView alloc]initWithImage:[[UIImage imageNamed:@"hr_circle_item"] stretchableImageWithLeftCapWidth:30 topCapHeight:14]];
        imga.backgroundColor = [UIColor greenColor];
        [imga setFrame:CGRectMake(12, 10+FFTableCellPicSize+10, FFTableCellAvatarSize, FFTableCellAvatarSize)];
        imga.tag = 13006;
        [cell addSubview:imga];
        //用户头像右
        UIImageView *imga2 = [[UIImageView alloc]initWithImage:[[UIImage imageNamed:@"hr_circle_item"] stretchableImageWithLeftCapWidth:30 topCapHeight:14]];
        imga2.backgroundColor = [UIColor greenColor];
        [imga2 setFrame:CGRectMake(SCREEN_WIDTH-10-FFTableCellAvatarSize, 10+FFTableCellPicSize+10, FFTableCellAvatarSize, FFTableCellAvatarSize)];
        imga2.tag = 13007;
        [cell addSubview:imga2];
        //用户昵称左
        UILabel *nameLabel = [self createLabelWithFrame:CGRectMake(15+FFTableCellAvatarSize, FFTableCellPicSize+10*2+5, FFTableCellPicSize, 20) textAlignment:NSTextAlignmentLeft fontSize:14 textColor:mRGBToColor(0x5c5c5c) numberOfLines:0 text:nil];
        nameLabel.tag = 13003;
        [cell addSubview:nameLabel];
        //用户昵称右
        UILabel *nameLabel2 = [self createLabelWithFrame:CGRectMake(SCREEN_WIDTH-FFTableCellAvatarSize-15-FFTableCellPicSize, FFTableCellPicSize+10*2+5, FFTableCellPicSize, 20) textAlignment:NSTextAlignmentRight fontSize:14 textColor:mRGBToColor(0x5c5c5c) numberOfLines:0 text:nil];
        nameLabel2.tag = 13004;
        [cell addSubview:nameLabel2];
        
        //房间状态
        UILabel *statusLabel = [self createLabelWithFrame:CGRectMake(10+FFTableCellPicSize, FFTableCellHeight-20-40-30, SCREEN_WIDTH- 2*10-2*FFTableCellPicSize, 20) textAlignment:NSTextAlignmentCenter fontSize:14 textColor:mRGBToColor(0x999999) numberOfLines:1 text:@""];
        statusLabel.tag = 13010;
        [cell addSubview:statusLabel];
        
        //时间
        UILabel *timeLabel = [self createLabelWithFrame:CGRectMake(10+FFTableCellPicSize, FFTableCellHeight-20-40, SCREEN_WIDTH- 2*10-2*FFTableCellPicSize, 20) textAlignment:NSTextAlignmentCenter fontSize:11 textColor:mRGBToColor(0x999999) numberOfLines:1 text:@""];
        timeLabel.tag = 13005;
        [cell addSubview:timeLabel];
    }
    
    NSDictionary *dic = dataArray[indexPath.row];
    FFListModel *ffListModel = [FFListModel modelWithDictionary:dic];
    NSMutableArray *arrayFightUsers = ffListModel.fightUsers;
    FFListFightUserModel *userModel1 = [FFListFightUserModel modelWithDictionary:arrayFightUsers[0]];
    FFListFightUserModel *userModel2 = [FFListFightUserModel modelWithDictionary:arrayFightUsers[1]];
    FFListFUDetailUserModel *userDetailModel1 = userModel1.user;
    FFListFUDetailUserModel *userDetailModel2 = userModel2.user;
    
    UILabel *nameTempLabel = (UILabel *)[cell viewWithTag:13003];
    [nameTempLabel setText:userDetailModel1.name];
    
    UILabel *nameTempLabel2 = (UILabel *)[cell viewWithTag:13004];
    [nameTempLabel2 setText:userDetailModel2.name];
    
    UILabel *statusLabel = (UILabel *)[cell viewWithTag:13010];
    int reTime = [ffListModel.remainingTime intValue];
    [statusLabel setText:reTime<0?@"已结束":@"进行中"];
    
    UILabel *timeTempLabel = (UILabel *)[cell viewWithTag:13005];
    NSString *temStr = [MyUtil ConvertStrToTime:ffListModel.remainingTime toFormat:@"mm:ss"];
    [timeTempLabel setText:temStr];
    if(reTime<0                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     ){
        [timeTempLabel setHidden:YES];
    }else{
        [timeTempLabel setHidden:NO];
    }
    
    UILabel *scoreTempLabel = (UILabel *)[cell viewWithTag:13008];
    [scoreTempLabel setText:userModel1.score];
    
    UILabel *scoreTempLabel2 = (UILabel *)[cell viewWithTag:13009];
    [scoreTempLabel2 setText:userModel2.score];
    
    UIImageView *imgV = (UIImageView *)[cell viewWithTag:13001];
    NSString *imgurlV = kConJoinURL(kFFAPI, userModel1.avatar);
    [imgV setImageWithURL:[NSURL URLWithString:imgurlV] placeholderImage:nil];
    
    UIImageView *imgV2 = (UIImageView *)[cell viewWithTag:13002];
    NSString *imgurlV2 = kConJoinURL(kFFAPI, userModel2.avatar);
    [imgV2 setImageWithURL:[NSURL URLWithString:imgurlV2] placeholderImage:nil];
    
    UIImageView *imga = (UIImageView *)[cell viewWithTag:13006];
    NSString *imgurla = kConJoinURL(kFFAPI, userDetailModel1.avatar);
    [imga setImageWithURL:[NSURL URLWithString:imgurla] placeholderImage:nil];
    
    UIImageView *imga2 = (UIImageView *)[cell viewWithTag:13007];
    NSString *imgurla2 = kConJoinURL(kFFAPI, userDetailModel2.avatar);
    [imga2 setImageWithURL:[NSURL URLWithString:imgurla2] placeholderImage:nil];
    
    
    
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *dic = dataArray[indexPath.row];
    FFFightRoomViewController *room = [FFFightRoomViewController new];
    room.dataDic = dic;
    [self.navigationController pushViewController:room animated:YES];
}

//查看大图
- (void)magnifyImage:(UITapGestureRecognizer*)tap
{
    UIImageView *imageView=(UIImageView*)tap.view;
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
