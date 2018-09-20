//
//  FFIntegralListViewController.m
//  doulian
//
//  Created by WangJinyu on 16/11/1.
//  Copyright © 2016年 maomao. All rights reserved.
//  积分列表

#import "FFIntegralListViewController.h"
#import "FFIntroduceWebViewController.h"//积分说明
@interface FFIntegralListViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView * _tableView;
    NSMutableArray * dataArray;
    OLGhostAlertView *ghostView;
    MBProgressHUD *loadView;
    int pageIndex;
    UILabel * sumScoreLab;

}
@end

@implementation FFIntegralListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackBtn];
    [self addTitleLabel:@"积分列表" withTitleColor:[UIColor blackColor]];
    [self addRightBtnwithImgName:nil Title:@"积分说明" TitleColor:[UIColor blackColor]];
    [self initTableView];
    pageIndex = 1;
    dataArray = [NSMutableArray arrayWithCapacity:0];
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
    /*/*获得和消耗积分记录
     http://192.168.8.223:8080/user/ getUserScoreRecords
     * @param pageIndex
     * @param pageSize
     * @param userId
     * @param logId
     * @param token
     */
    NSString *logId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"logId"]];
    NSString *token = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"token"]];
    NSString *userId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"userId"]];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",page],@"pageIndex",@"20",@"pageSize",userId,@"userId",logId,@"logId",token,@"token",nil];
    
    loadView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [MyUtil requestPostURL:[NSString stringWithFormat:@"%@%@",kFFAPI,kFFAPI_FFGetUserScoreRecords] params:params success:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]] ) {
            [loadView hide:YES];
            NSString *error = [NSString stringWithFormat:@"%@",responseObject[@"error"]];
            [_tableView headerEndRefreshing];
            [_tableView footerEndRefreshing];
            if (error.integerValue==0) {
                NSDictionary *dataDic = responseObject[@"data"];
                NSString * sumScoreStr = [NSString stringWithFormat:@"剩余积分:%@分",dataDic[@"currScore"]];
                [sumScoreLab setText:sumScoreStr];
                if(page==1){
                    [dataArray removeAllObjects];
                    [dataArray addObjectsFromArray:[dataDic valueForKey:@"scoreRecord"]];
                    
                }else{
                    NSMutableArray *arrayTemp = [[NSMutableArray alloc] init];
                    [arrayTemp addObjectsFromArray:dataArray];
                    [arrayTemp addObjectsFromArray:[dataDic valueForKey:@"scoreRecord"]];
                    dataArray = arrayTemp;
                }
                NSLog(@"dataArray is %@ count is %d",dataArray,dataArray.count);

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

-(void)initTableView
{
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 44 + self.num, SCREEN_WIDTH, SCREENH_HEIGHT - 44 - self.num - 40) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
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
    
    
    UIView * bgView = [[UIView alloc]initWithFrame:CGRectMake(0, SCREENH_HEIGHT - 40, SCREEN_WIDTH, 40)];
    bgView.backgroundColor = kBackgraoudColorDefault;
    [self.view addSubview:bgView];
    
    sumScoreLab = [[UILabel alloc]initWithFrame:CGRectMake(20, 10, 200, 20)];
    sumScoreLab.text = @"剩余积分:暂无";
    sumScoreLab.textAlignment = NSTextAlignmentLeft;
    sumScoreLab.textColor = [UIColor grayColor];
    sumScoreLab.font = [UIFont boldSystemFontOfSize:18];
    [bgView addSubview:sumScoreLab];
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
static NSString * FFIntegralID = @"FFIntegralID";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:FFIntegralID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FFIntegralID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        UILabel * messageLab = [self createLabelWithFrame:CGRectMake(20, 20, SCREEN_WIDTH - 20 - 100, 20) textAlignment:NSTextAlignmentLeft fontSize:14 textColor:[UIColor blackColor] numberOfLines:0 text:@"积分记录"];
        messageLab.tag = 8008;
        [cell.contentView addSubview:messageLab];
        
        UILabel * addDelScoreLab = [self createLabelWithFrame:CGRectMake(SCREEN_WIDTH - 90, 15, 80, 20) textAlignment:NSTextAlignmentRight fontSize:14 textColor:[UIColor blackColor] numberOfLines:0 text:@"+1积分"];
        addDelScoreLab.tag = 8009;
        [addDelScoreLab setTextColor:RGBColor(245, 116, 35)];
        [cell.contentView addSubview:addDelScoreLab];
        
        UILabel * timeLab = [self createLabelWithFrame:CGRectMake(addDelScoreLab.frame.origin.x, addDelScoreLab.frame.origin.y + addDelScoreLab.frame.size.height + 5, 80, 20) textAlignment:NSTextAlignmentRight fontSize:12 textColor:[UIColor lightGrayColor] numberOfLines:0 text:@"时间暂无"];
        timeLab.tag = 8010;
        [cell.contentView addSubview:timeLab];
    }
    if (dataArray.count > 0) {
          NSDictionary * dataDic = dataArray[indexPath.row];
        UILabel * mesLab = [(UILabel *)cell viewWithTag:8008];
        [mesLab setText:dataDic[@"message"]];
        
        UILabel * addDeleleLab = [(UILabel *)cell viewWithTag:8009];
        if ([dataDic[@"type"] intValue] == 7) {//返回的字符类型等于7 的时候带负号的str 不需要加+
            [addDeleleLab setText:[NSString stringWithFormat:@"%@积分",dataDic[@"score"]]];
        }else{
            [addDeleleLab setText:[NSString stringWithFormat:@"+%@积分",dataDic[@"score"]]];
        }
        
        UILabel * timeLabel = (UILabel *)[cell viewWithTag:8010];
        NSString * startStr = [NSString stringWithFormat:@"%@",dataDic[@"create_time"]];
        NSTimeInterval startTime = [startStr doubleValue] / 1000;
        NSDate * startLocalDate = [NSDate dateWithTimeIntervalSince1970:startTime];
        NSDateFormatter * startFormatter = [[NSDateFormatter alloc]init];
        [startFormatter setDateFormat:@"MM-dd HH:mm"];
        NSString * startDate = [startFormatter stringFromDate:startLocalDate];
        [timeLabel setText:startDate];
    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

-(void)onClickRightBtn:(UIButton *)sender
{
    FFIntroduceWebViewController * vc = [[FFIntroduceWebViewController alloc]init];
    vc.jumpRequest = [NSString stringWithFormat:@"%@%@",kFFAPI,@"/sys/scoreExplanation"] ;
    vc.webTitle = @"积分说明";
    [self.navigationController pushViewController:vc animated:YES];

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
