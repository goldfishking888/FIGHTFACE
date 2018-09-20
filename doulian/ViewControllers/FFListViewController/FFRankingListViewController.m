//
//  FFRankingListViewController.m
//  doulian
//
//  Created by WangJinyu on 16/10/19.
//  Copyright © 2016年 maomao. All rights reserved.
// 排行榜列表

#import "FFRankingListViewController.h"
#import "FFRankingListModel.h"
#import "FFPersonalDetailVC.h"//好友详情

#import <UMSocialCore/UMSocialCore.h>
#import "UMSocialUIManager.h"
#import "FFShareModel.h"

#define HeightOfCell 70
@interface FFRankingListViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView * _tableView;
    
    OLGhostAlertView *ghostView;
    MBProgressHUD *loadView;
    int pageIndex;
    NSMutableArray *dataArray;
    UIView * bgHeaderView;//头部背景
    
    
    //个人头部数据
    UIImageView * myIconImageV;
    UILabel * myNameLab;
    UILabel * myRankingLab;
    UILabel * winCountNameLab;
    UILabel * winCountLab;
    
    UIImageView *shareImage;
}

@end

@implementation FFRankingListViewController
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
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configHeadView];
    [self addBackBtn];
    [self addTitleLabel:@"好友排行榜"];
    [self addRightBtnwithImgName:nil Title:@"分享" TitleColor:[UIColor blackColor]];
    ghostView = [[OLGhostAlertView alloc] initWithTitle:nil message:nil timeout:0.6 dismissible:YES];
    ghostView.position = OLGhostAlertViewPositionCenter;
    pageIndex = 1;
    dataArray = [NSMutableArray arrayWithCapacity:0];
    [self initTableView];
    self.view.backgroundColor = kBackgraoudColorDefault;
    [self requestDataWithPage:pageIndex];
    [self getShareInfo];
    
    // Do any additional setup after loading the view.
}

-(void)onClickRightBtn:(UIButton *)sender{
//    ghostView.message = @"点击分享";
//    [ghostView show];
    __weak typeof(self) weakSelf = self;
    [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMShareMenuSelectionView *shareSelectionView, UMSocialPlatformType platformType) {
        
        [weakSelf shareWebPageToPlatformType:platformType ShareModel:_shareModel];
    }];

}

//拉取房间分享信息
-(void)getShareInfo{
    
    __weak typeof(self) weakSelf = self;
    NSString *logId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"logId"]];
    NSString *token = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"token"]];
    NSString *userId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"userId"]];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"2",@"type",userId,@"userId",@"0",@"fightId",@"0",@"presentId",nil];
    
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
                ghostView.message = @"获取内容失败，请重新登陆后重试";
                [ghostView show];
            }
        }
    } failure:^(NSError *error) {
        [loadView hide:YES];
        ghostView.message = @"网络出现问题，请稍后重试";
        [ghostView show];
        
    }];
    
}

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


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *isLogin = (NSString *)[mUserDefaults valueForKey:@"isLogin"];
    if (![isLogin isEqualToString:@"1"]) {
        ghostView.message = @"请先登录";
        [ghostView show];
        return;
    }
    NSLog(@"选择的indexpath.row is%d",(int)indexPath.row);
    FFPersonalDetailVC * vc = [[FFPersonalDetailVC alloc]init];
    if (dataArray.count > 0) {
        NSDictionary * dic = dataArray[indexPath.row][@"user"];
        vc.userIDStr = [NSString stringWithFormat:@"%@",dic[@"userId"]];
    }
    [self.navigationController pushViewController: vc animated:YES];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *askForHelpCellId = @"FFTavleViewCellId";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:askForHelpCellId];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ID1"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        //UITableViewCellAccessoryCheckmark;//显示最右边的箭头
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        //设置分割线距边界的距离
        tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        
        UIImageView * imageRankV = [[UIImageView alloc] initWithFrame:CGRectMake(20, HeightOfCell / 2 - 12, 24, 24)];
        imageRankV.layer.cornerRadius = imageRankV.frame.size.height / 2;
        imageRankV.layer.masksToBounds = YES;
        imageRankV.backgroundColor = RGBColor(251, 226, 84);
        imageRankV.tag = 9999;
        [cell addSubview:imageRankV];
        
        UIImageView *logo = [[UIImageView alloc] initWithFrame:CGRectMake(imageRankV.frame.origin.x + imageRankV.frame.size.width + 18, HeightOfCell / 2 - 22, 45, 45)];
        logo.layer.borderWidth = 1;
        logo.layer.borderColor = [[UIColor blackColor] CGColor];
        logo.layer.cornerRadius = logo.frame.size.width / 2;
        logo.layer.masksToBounds = YES;
        logo.image = [UIImage imageNamed:@"FFFriendIcon"];
        [logo setContentMode:UIViewContentModeScaleAspectFill];
        logo.tag = 10000;
        [cell addSubview:logo];
        
        UILabel *name = [self createLabelWithFrame:CGRectMake(logo.frame.origin.x + logo.frame.size.width + 10, HeightOfCell / 2 - 10, 150, 20) textAlignment:NSTextAlignmentLeft fontSize:17 textColor:[UIColor blackColor] numberOfLines:0 text:@"范冰冰"];
        name.tag = 10001;
        name.numberOfLines = 1;
        name.adjustsFontSizeToFitWidth = NO;
        name.lineBreakMode = NSLineBreakByTruncatingTail;
        [cell addSubview:name];
        
        UILabel* WinCountLab = [self createLabelWithFrame:CGRectMake(SCREEN_WIDTH - 100, HeightOfCell / 2 - 10, 100, 20) textAlignment:NSTextAlignmentCenter fontSize:17 textColor:[UIColor blackColor] numberOfLines:0 text:@"0000"];
        WinCountLab.tag = 10002;
        [cell addSubview:WinCountLab];
    }
    if ( dataArray.count > 0) {
        NSDictionary *dic = dataArray[indexPath.row];
        FFRankingListModel *ffRankListModel = [FFRankingListModel modelWithDictionary:dic];
        //第几名
        UIImageView *  ImageRankV = (UIImageView *)[cell viewWithTag:9999];
        if ([ffRankListModel.place isEqualToString:@"1"]) {
            //第一名
            ImageRankV.frame = CGRectMake(20, HeightOfCell / 2 - 14, 28, 33);
            ImageRankV.image = [UIImage imageNamed:@"FFRankingList_First"];
            ImageRankV.backgroundColor = [UIColor whiteColor];
        }else if ([ffRankListModel.place isEqualToString:@"2"]){
            ImageRankV.frame = CGRectMake(20, HeightOfCell / 2 - 14, 28, 33);
            ImageRankV.backgroundColor = [UIColor whiteColor];
            ImageRankV.image = [UIImage imageNamed:@"FFRankingList_Second"];
            
        }
        else if ([ffRankListModel.place isEqualToString:@"3"]){
            ImageRankV.frame = CGRectMake(20, HeightOfCell / 2 - 14, 28, 33);
            ImageRankV.backgroundColor = [UIColor whiteColor];
            ImageRankV.image = [UIImage imageNamed:@"FFRankingList_Third"];
        }else{
            ImageRankV.frame = CGRectMake(20, HeightOfCell / 2 - 12, 24, 24);
            ImageRankV.backgroundColor = RGBColor(251, 226, 84);
            ImageRankV.image = nil;
            
            UILabel * numLab = [self createLabelWithFrame:CGRectMake(0, 1, ImageRankV.frame.size.width, ImageRankV.frame.size.height - 2) textAlignment:NSTextAlignmentCenter fontSize:17 textColor:[UIColor blackColor] numberOfLines:1 text:[NSString stringWithFormat:@"%@",ffRankListModel.place]];//@"18"]];//
            numLab.adjustsFontSizeToFitWidth =YES;
            [ImageRankV addSubview:numLab];
        }
        
        UIImageView * iconImageV = (UIImageView *)[cell viewWithTag:10000];
        [iconImageV setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kFFAPI,ffRankListModel.user[@"avatar"]]] placeholderImage:[UIImage imageNamed:@"FFFriendIcon"]];
        //用户姓名
        UILabel * nameLab = (UILabel *)[cell viewWithTag:10001];
        [nameLab setText:ffRankListModel.user[@"name"]];
        //胜利场数
        UILabel * WinCountLab = (UILabel *)[cell viewWithTag:10002];
        [WinCountLab setText:[NSString stringWithFormat:@"%@",ffRankListModel.victoryCount]];
        
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return HeightOfCell;
}

#pragma mark - 下拉刷新的方法、上拉刷新的方法
-(void)initTableView{
    //高度减去tabbar高度50
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 44 + self.num, SCREEN_WIDTH, SCREENH_HEIGHT - 44 - self.num) style:UITableViewStylePlain];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    bgHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 265)];
    bgHeaderView.backgroundColor = kBackgraoudColorDefault;
    _tableView.tableHeaderView = bgHeaderView;
    
    UIImageView * yellowView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 175)];
    yellowView.backgroundColor = [UIColor orangeColor];
    [yellowView setImage:[UIImage imageNamed:@"FFRankingList_banner"]];
    [bgHeaderView addSubview:yellowView];
    
    //下半个椭圆
    UILabel * bantuoyuanlab = [self createLabelWithFrame:CGRectMake(0, yellowView.frame.size.height, SCREEN_WIDTH, 75) textAlignment:NSTextAlignmentCenter fontSize:18 textColor:[UIColor blackColor] numberOfLines:1 text:nil];
    bantuoyuanlab.backgroundColor = [UIColor whiteColor];
    //左下角圆角和右下角圆角
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:bantuoyuanlab.bounds byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight cornerRadii:CGSizeMake(10, 10)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = bantuoyuanlab.bounds;
    maskLayer.path = maskPath.CGPath;
    bantuoyuanlab.layer.mask = maskLayer;
    [bgHeaderView addSubview:bantuoyuanlab];
    
    //    UIImageView * myIconImageV;
    myIconImageV = [[UIImageView alloc]initWithFrame:CGRectMake(15, yellowView.frame.size.height + 14, 48, 48)];
    myIconImageV.image = [UIImage imageNamed:@"login_qq_normal"];
    myIconImageV.layer.cornerRadius = myIconImageV.frame.size.height / 2;
    myIconImageV.layer.masksToBounds = YES;
    myIconImageV.layer.borderWidth = 1;
    myIconImageV.layer.borderColor = [[UIColor blackColor] CGColor];
    [myIconImageV setContentMode:UIViewContentModeScaleAspectFill];
    [bgHeaderView addSubview:myIconImageV];
    
    //    UILabel * myNameLab;
    myNameLab = [self createLabelWithFrame:CGRectMake(87, yellowView.frame.size.height + 14, 160, 22) textAlignment:NSTextAlignmentLeft fontSize:17 textColor:[UIColor blackColor] numberOfLines:0 text:@"我的名字:暂无"];
    //    myNameLab.backgroundColor = [UIColor blueColor];
    [bgHeaderView addSubview:myNameLab];
    
    //    UILabel * myRankingLab;
    myRankingLab = [self createLabelWithFrame:CGRectMake(myNameLab.frame.origin.x, myNameLab.frame.origin.y + myNameLab.frame.size.height + 9, 150, 16) textAlignment:NSTextAlignmentLeft fontSize:14 textColor:[UIColor blackColor] numberOfLines:0 text:@"本周排名:暂无"];
    //    myRankingLab.backgroundColor = [UIColor blueColor];
    
    [bgHeaderView addSubview:myRankingLab];
    
    //    UILabel * winCountNameLab;
    winCountNameLab = [self createLabelWithFrame:CGRectMake(SCREEN_WIDTH - 80,myNameLab.frame.origin.y, 60, 20) textAlignment:NSTextAlignmentCenter fontSize:14 textColor:[UIColor blackColor] numberOfLines:0 text:@"胜场"];
    //    winCountNameLab.backgroundColor = [UIColor blueColor];
    [bgHeaderView addSubview:winCountNameLab];
    
    //    UILabel * winCountLab;
    winCountLab = [self createLabelWithFrame:CGRectMake(winCountNameLab.frame.origin.x,winCountNameLab.frame.origin.y + winCountNameLab.frame.size.height + 9, 70, 20) textAlignment:NSTextAlignmentCenter fontSize:17 textColor:[UIColor blackColor] numberOfLines:0 text:@"暂无"];
    //    winCountLab.backgroundColor = [UIColor orangeColor];
    [bgHeaderView addSubview:winCountLab];
    
    
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

#pragma mark - 个人排行榜数据赋值
-(void)valueDataOfselfDic:(NSMutableDictionary *)dataDicSelf
{
    NSString * placeStr = [NSString stringWithFormat:@"%@",dataDicSelf[@"place"]];
    NSMutableDictionary * dataDic = dataDicSelf[@"user"];
    [myIconImageV setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kFFAPI,dataDic[@"avatar"]]] placeholderImage:[UIImage imageNamed:@"login_qq_normal"]];
    [myNameLab setText:dataDic[@"name"]];
    if ([placeStr isEqualToString:@"0"]) {
        [myRankingLab setText:[NSString stringWithFormat:@"本周排名%@",@"暂无"]];
    }else{
        [myRankingLab setText:[NSString stringWithFormat:@"本周排名%@",dataDicSelf[@"place"]]];
    }
    [winCountLab setText:[NSString stringWithFormat:@"%@",dataDicSelf[@"victoryCount"]]];
}

#pragma mark - 下拉刷新的方法、上拉刷新的方法
- (void)headerRefresh{
    pageIndex =1;
    [dataArray removeAllObjects];
    [self requestDataWithPage:pageIndex];
    
}
- (void)footerRefresh{
    pageIndex ++;
    [self requestDataWithPage:pageIndex];
}

-(void)requestDataWithPage:(int)page{
    
    /* 排行榜
     http://192.168.8.223:8080 /sys/getRankingList
     * @param pageIndex
     * @param pageSize
     * @param userId (可选) 当前用户id  返回的用户的排名，如果没有用户或者没有排名，排名和胜利场数是0
     * @return
     */
    //NSString *logId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"logId"]];
    NSString *userId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"userId"]];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:userId,@"userId",[NSString stringWithFormat:@"%d",page],@"pageIndex",@"20",@"pageSize",nil];
    
    loadView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString * url = [NSString stringWithFormat:@"%@%@",kFFAPI,kFFAPI_FFGetRankList];
    [MyUtil requestPostURL:url params:params success:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]] ) {
            [loadView hide:YES];
            NSString *error = [NSString stringWithFormat:@"%@",responseObject[@"error"]];
            [_tableView headerEndRefreshing];
            [_tableView footerEndRefreshing];
            
            if (error.integerValue==0) {
                NSDictionary *dataDic = responseObject[@"data"];
                //自己的数据更新
                [self valueDataOfselfDic:dataDic[@"selfRank"]];
                if(page==1){
                    [dataArray removeAllObjects];
                    [dataArray addObjectsFromArray:[dataDic valueForKey:@"rankingList"]];
                    
                }else{
                    NSMutableArray *arrayTemp = [[NSMutableArray alloc] init];
                    [arrayTemp addObjectsFromArray:dataArray];
                    [arrayTemp addObjectsFromArray:[dataDic valueForKey:@"rankingList"]];
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
