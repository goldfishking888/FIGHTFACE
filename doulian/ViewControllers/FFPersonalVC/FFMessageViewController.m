//
//  FFMessageViewController.m
//  doulian
//
//  Created by WangJinyu on 16/10/31.
//  Copyright © 2016年 maomao. All rights reserved.
//  个人中心-消息界面

#import "FFMessageViewController.h"
#import "FFIntroduceWebViewController.h"
@interface FFMessageViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView * _tableView;
    OLGhostAlertView *ghostView;
    MBProgressHUD *loadView;
    int pageIndex;
    NSMutableArray *dataArray;

}
@end

@implementation FFMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackBtn];
    [self addTitleLabel:@"消息" withTitleColor:[UIColor blackColor]];
    [self initTableView];
    pageIndex = 1;
    [self requestDataWithPage:pageIndex];
    dataArray = [NSMutableArray arrayWithCapacity:0];
    
    //所有系统消息已读
    [mUserDefaults setValue:@"0" forKey:@"ShowSystemMessageBadge"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowSystemMessageBadge" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HideBadge" object:nil];

    // Do any additional setup after loading the view.
}

-(void)initTableView{
    //高度减去tabbar高度50
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0,  44 + self.num, SCREEN_WIDTH, SCREENH_HEIGHT - 44 - self.num) style:UITableViewStylePlain];
    _tableView.backgroundColor = RGBColor(243, 243, 243);
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:_tableView];
    _tableView.tableFooterView = [[UIView alloc]init];//去除掉多余的线
    
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
    NSString *isLogin = (NSString *)[mUserDefaults valueForKey:@"isLogin"];
    if (![isLogin isEqualToString:@"1"]) {
        ghostView.message = @"请先登录";
        [ghostView show];
        return;
    }
    /*获取消息列表
     /*http://192.168.8.223:8080 /sys/getSystemMessage ?pageIndex=1&pageSize=20
     * @param userId 当前查看挑战者的用户id
     * @param logId
     * @param token
     @param pageIndex
     * @param pageSize
     
     * @return	{"error":0,"msg":"","currTime":1474446457369,"data":[{"avatarUrl":"/face/2016/08/30/9117995fe64743259fea07bf70992ee2.png","challengeId":9,"create_time":1474446290000,"fromUserId":16,"toUserId":32,"user":{"age":36,"avatar":"/face/2016/08/29/117cd7495fa1483a9b00ac532b0f8c7d.jpg","mobile":"15063941036","name":"nihao","selfIntroduction":"self","sex":1,"third":0,"total_score":1681,"userId":16}}]}
     */
    //NSString *logId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"logId"]];
   // NSString *token = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"token"]];
    NSString *userId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"userId"]];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",page],@"pageIndex",@"10",@"pageSize",userId,@"userId",nil];//logId,@"logId",token,@"token",
    
    loadView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [MyUtil requestPostURL:[NSString stringWithFormat:@"%@%@",kFFAPI,kFFAPI_FFGetSystemMessage] params:params success:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]] ) {
            [loadView hide:YES];
            NSString *error = [NSString stringWithFormat:@"%@",responseObject[@"error"]];
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
                NSLog(@"dataArray is %@ count is %d",dataArray,(int)dataArray.count);
                NSMutableArray *trashArray = [[NSMutableArray alloc] init];
                
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float Height = 0;
    if (dataArray.count > 0) {
        NSMutableDictionary * dic = dataArray[indexPath.row];
        NSString * message = dic[@"message"];
    Height = [self heightForString:message fontSize:15 andWidth:SCREEN_WIDTH - 100 - 10 - 20];
        NSLog(@"height is %f",Height);
    }
    return Height + 80;
}

- (CGFloat) heightForString:(NSString *)value fontSize:(float)fontSize andWidth:(float)width
{
    CGSize sizeToFit = [value sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:CGSizeMake(width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];//此处的换行类型（lineBreakMode）可根据自己的实际情况进行设置
    return sizeToFit.height;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *FFMessageCellId = @"FFMessageCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:FFMessageCellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FFMessageCellId"];
        //左边头像
        UIImageView * imageV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 8, 30, 30)];
        imageV.image = [UIImage imageNamed:@"personalCenter_message"];
        [cell.contentView addSubview:imageV];
        //系统通知
        UILabel * systemLab = [self createLabelWithFrame:CGRectMake(imageV.frame.origin.x + imageV.frame.size.width + 15, imageV.frame.origin.y, 250, 20) textAlignment:NSTextAlignmentLeft fontSize:18 textColor:[UIColor redColor] numberOfLines:0 text:@"系统通知"];
        systemLab.tag = 250;
        systemLab.adjustsFontSizeToFitWidth = NO;
        systemLab.lineBreakMode = NSLineBreakByTruncatingTail;
        [cell.contentView addSubview:systemLab];
        //通知内容
        UILabel * contentLab = [self createLabelWithFrame:CGRectMake(systemLab.frame.origin.x, systemLab.frame.origin.y + systemLab.frame.size.height + 10, SCREEN_WIDTH - systemLab.frame.origin.x - 10 - 20, 20) textAlignment:NSTextAlignmentLeft fontSize:15 textColor:[UIColor blackColor] numberOfLines:1 text:@"参与斗脸活动 晒全家福 聊春运 写春脸 聊春晚 即可点亮新春特别徽章,更有豪华大礼包过大年,立即参与活动!!!👇"];
        contentLab.tag = 251;
        contentLab.numberOfLines = 0;
        //contentLab.backgroundColor = [UIColor orangeColor];
        contentLab.adjustsFontSizeToFitWidth = NO;
        contentLab.lineBreakMode = NSLineBreakByTruncatingTail;
        [cell.contentView addSubview:contentLab];
        //通知时间
        UILabel * timeLab = [self createLabelWithFrame:CGRectMake(contentLab.frame.origin.x, contentLab.frame.origin.y + contentLab.frame.size.height + 5, 200, 20) textAlignment:NSTextAlignmentLeft fontSize:14 textColor:[UIColor lightGrayColor] numberOfLines:0 text:@"2012-02-05 18:56"];
        timeLab.tag = 252;
        [cell.contentView addSubview:timeLab];
    }
    if (dataArray.count > 0) {
        NSMutableDictionary * dic = dataArray[indexPath.row];
        
        UILabel * systemLab = (UILabel *)[cell viewWithTag:250];
        systemLab.text = [NSString stringWithFormat:@"%@",dic[@"title"]];
        NSString * message = dic[@"message"];
        //调整内容高度frame
       float Height = [self heightForString:message fontSize:15 andWidth:SCREEN_WIDTH - 100 - 10 - 20];
        UILabel * contentLab = (UILabel *)[cell viewWithTag:251];
        contentLab.frame = CGRectMake(systemLab.frame.origin.x, systemLab.frame.origin.y + systemLab.frame.size.height + 10, SCREEN_WIDTH - systemLab.frame.origin.x - 10 - 20, Height);
        contentLab.text = [NSString stringWithFormat:@"%@",message];

        UILabel * timeLab = (UILabel *)[cell viewWithTag:252];
        timeLab.frame = CGRectMake(contentLab.frame.origin.x, contentLab.frame.origin.y + contentLab.frame.size.height + 5, 200, 20);
        NSString * startStr = [NSString stringWithFormat:@"%@",dic[@"create_time"]];
        NSTimeInterval startTime = [startStr doubleValue] / 1000;
        NSDate * startLocalDate = [NSDate dateWithTimeIntervalSince1970:startTime];
        NSDateFormatter * startFormatter = [[NSDateFormatter alloc]init];
        [startFormatter setDateFormat:@"MM-dd HH:mm"];
        NSString * startDate = [startFormatter stringFromDate:startLocalDate];
        timeLab.text = [NSString stringWithFormat:@"%@",startDate];
    }
    
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (dataArray.count > 0) {
        NSMutableDictionary * dic = dataArray[indexPath.row];
        ghostView.message = dic[@"url"];
        [ghostView show];
        FFIntroduceWebViewController * vc = [[FFIntroduceWebViewController alloc]init];
        NSString * fullUrl;
        if (![dic[@"url"] hasPrefix:@"http"] && ![dic[@"url"] hasPrefix:@"https"]) {
            //无法跳转
            return;
        }else{
            fullUrl = dic[@"url"];
        }
        vc.jumpRequest = fullUrl;
        vc.webTitle = dic[@"title"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
