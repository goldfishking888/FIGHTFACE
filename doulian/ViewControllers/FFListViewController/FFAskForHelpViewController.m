//
//  FFAskForHelpViewController.m
//  doulian
//
//  Created by WangJinyu on 16/9/7.
//  Copyright © 2016年 maomao. All rights reserved.
//
#define Font1 [UIFont systemFontOfSize:16]
#define Font2 [UIFont systemFontOfSize:14]

#import "FFAskForHelpViewController.h"
#import "FFAskForHelpModel.h"
//#import "FFAskForHelpFriendCell.h"
@interface FFAskForHelpViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    //    int pageIndex1;
    UITableView * _tableView;
    
    OLGhostAlertView *ghostView;
    MBProgressHUD *loadView;
    NSMutableDictionary * paramsMutableDic;//动态的存取上选择的用户
    NSMutableString * aliasAllStr;
    NSMutableArray *userIddataArray;
    NSMutableArray *contacts;
}
@property (nonatomic,strong)NSMutableArray * dataArray;
@property (nonatomic,strong)NSMutableDictionary * dataDicAll;

//全选
@property (nonatomic, strong) NSString *isAll;//@"0":取消   @"1":全选

@end
@implementation FFAskForHelpViewController

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
- (void)viewDidLoad {//104 求帮id
    [super viewDidLoad];
    [self addBackBtn];
    [self addHeadViewLine];
    [self addTitleLabel:@"寻求帮助" withTitleColor:[UIColor blackColor]];
    
    ghostView = [[OLGhostAlertView alloc] initWithTitle:nil message:nil timeout:0.6 dismissible:YES];
    ghostView.position = OLGhostAlertViewPositionCenter;
    
    self.dataArray = [NSMutableArray arrayWithCapacity:0];
    self.dataDicAll = [NSMutableDictionary dictionaryWithCapacity:0];
    
    userIddataArray = [NSMutableArray array];
    contacts = [NSMutableArray array];
    
    aliasAllStr = [[NSMutableString alloc]init];
    [self createTableView];
    [self requestData];
    /*http://192.168.8.223:8080/push/askHelpIOS
     * @param alias  用户的别名 （用户的id） 多个用户用逗号分开
     * @param logId
     * @param token
     * @return	  {"error":0,"msg":"发送成功","currTime":1473128984216}*/
    paramsMutableDic = [NSMutableDictionary dictionaryWithCapacity:0];
    
    self.isAll = @"0";//这个字段是用来单独判断是否全选 来进行选中和取消选中的效果
    // Do any additional setup after loading the view.
}
#pragma mark - createTableView
-(void)createTableView
{
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 44 + self.num, SCREEN_WIDTH, SCREENH_HEIGHT - 50 - 44 - self.num ) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    // 下拉刷新
    [_tableView addHeaderWithTarget:self action:@selector(headerRefresh)];
    _tableView.headerPullToRefreshText= @"下拉刷新";
    _tableView.headerReleaseToRefreshText = @"松开马上刷新";
    _tableView.headerRefreshingText = @"努力加载中……";
    
    //底部显示全选 求帮
    UIView * footerView = [[UIView alloc]initWithFrame:CGRectMake(0, SCREENH_HEIGHT - 50, SCREEN_WIDTH, 50)];
    footerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:footerView];
    
    UIView * linesView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
    linesView.backgroundColor = RGBColor(231, 231, 231);
    [footerView addSubview:linesView];
    
    UIView * fangkuangView = [[UIView alloc]initWithFrame:CGRectMake(15, 6, 38, 38)];
    fangkuangView.backgroundColor = [UIColor whiteColor];
    fangkuangView.layer.borderWidth = 1;
    fangkuangView.layer.borderColor = [[UIColor blackColor]CGColor];
    [footerView addSubview:fangkuangView];
    
    UIButton * selectBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    selectBtn.frame = CGRectMake(6, 6, 26, 26);
    selectBtn.backgroundColor = [UIColor whiteColor];
    selectBtn.tag = 10086;
    [selectBtn addTarget:self action:@selector(selectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [fangkuangView addSubview:selectBtn];
    
    UILabel * textLabel = [[UILabel alloc]initWithFrame:CGRectMake(fangkuangView.frame.origin.x + fangkuangView.frame.size.width + 5, 10, 100, 30)];
    textLabel.text = @"全选";
    textLabel.textColor = [UIColor blackColor];
    textLabel.font = [UIFont systemFontOfSize:16];
    [footerView addSubview:textLabel];
    
    UIButton * sendBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    sendBtn.frame = CGRectMake(SCREEN_WIDTH - 100, 5, 80, 40);
    sendBtn.backgroundColor = RGBColor(251, 226, 84);
    [sendBtn setTitle:@"求帮" forState:UIControlStateNormal];
    [sendBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    sendBtn.layer.cornerRadius = 4;
    sendBtn.layer.masksToBounds = YES;
    sendBtn.tag = 10010;
    [sendBtn addTarget:self action:@selector(sendBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:sendBtn];
    
    
}
#pragma mark - 全部选择按钮
-(void)selectBtnClick:(UIButton *)sender
{
    if (sender.tag == 10086) {
        [contacts removeAllObjects];
        NSLog(@"点击了选择全部,sender.tag is ----%d",(int)sender.tag);
        
        self.isAll = @"1";
        
        sender.tag = 10087;
        sender.backgroundColor = RGBColor(251, 226, 84);
        for (int i = 0; i < self.dataArray.count; i++) {
            [userIddataArray addObject:self.dataArray[i][@"userId"]];
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setValue:@"YES" forKey:@"checked"];
            [contacts addObject:dic];
            }
        [_tableView reloadData];
    }
    else if (sender.tag == 10087)
    {
        [contacts removeAllObjects];
        NSLog(@"点击了取消选择,sender.tag is ----%d",(int)sender.tag);
        
        self.isAll = @"0";
        
        sender.tag = 10086;
        aliasAllStr = nil;
        for (int i = 0; i < self.dataArray.count; i++) {
            [userIddataArray addObject:self.dataArray[i][@"userId"]];
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setValue:@"NO" forKey:@"checked"];
            [contacts addObject:dic];
        }
        sender.backgroundColor = [UIColor whiteColor];
        [_tableView reloadData];
    }
}

-(void)sendBtnClick:(UIButton *)sender
{
    for (int i = 0; i < userIddataArray.count; i++) {
        if ([aliasAllStr length] == 0) {
            aliasAllStr = [NSMutableString stringWithFormat:@"%@",userIddataArray[i]];

        }else{
        aliasAllStr = [NSMutableString stringWithFormat:@"%@,%@",aliasAllStr,userIddataArray[i]];
        }
    }
    NSLog(@"最后上传的aliasAllStr是 %@",aliasAllStr);
    if (aliasAllStr != nil) {
        NSString *isLogin = (NSString *)[mUserDefaults valueForKey:@"isLogin"];
        if (![isLogin isEqualToString:@"1"]) {
            ghostView.message = @"请先登录";
            [ghostView show];
            return;
        }
        NSString *logId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"logId"]];
        NSString *token = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"token"]];
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:logId,@"logId",token,@"token",aliasAllStr,@"alias",nil];
        
        loadView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [MyUtil requestPostURL:[NSString stringWithFormat:@"%@%@",kFFAPI,kFFAPI_FFSendFriendListForHelp] params:params success:^(id responseObject) {
            if ([responseObject isKindOfClass:[NSDictionary class]] ) {
                [loadView hide:YES];
                NSLog(@"responseObject is ----<>%@",responseObject);
                NSString *error = [NSString stringWithFormat:@"%@",responseObject[@"error"]];
                [_tableView headerEndRefreshing];
                [_tableView footerEndRefreshing];
                if (error.integerValue==0) {
                    ghostView.message = @"发送成功";
                    [ghostView show];
                    [self.navigationController popViewControllerAnimated:YES];
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
    }else
    {
        ghostView.message = @"获取内容失败，请稍后重试,请选择更多的人帮助";
        [ghostView show];
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"选择的indexpath.row is%d",(int)indexPath.row);
    NSUInteger row = [indexPath row];
    // 获取点击cell的标识
    NSMutableDictionary *dic = [contacts objectAtIndex:row];
    // 如何是选中改成未选中，如果是为选中改成选中
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([[dic objectForKey:@"checked"] isEqualToString:@"NO"]) {
        [dic setObject:@"YES" forKey:@"checked"];
        [userIddataArray addObject:self.dataArray[indexPath.row][@"userId"]];
        //        [cell setChecked:YES];
        cell.accessoryType=UITableViewCellAccessoryCheckmark;
    }else {
        [dic setObject:@"NO" forKey:@"checked"];
        for (int i = 0; i < userIddataArray.count; i++) {
            if (userIddataArray[i] == self.dataArray[indexPath.row][@"userId"]) {
                [userIddataArray removeObject:self.dataArray[indexPath.row][@"userId"]];
            }
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    NSLog(@"现在要上传的用户userID的userIddataArray 是%@ \n",userIddataArray);
    
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
        
        UIImageView *logo = [[UIImageView alloc] initWithFrame:CGRectMake(10, 12, 45, 45)];
        logo.layer.cornerRadius = logo.frame.size.width / 2;
        logo.layer.masksToBounds = YES;
        logo.image = [UIImage imageNamed:@"FFFriendIcon"];
        logo.tag = 10000;
        [cell addSubview:logo];
        
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(logo.frame.size.width + logo.frame.origin.x + 12, logo.frame.origin.y + 10, 80, 18)];
        name.text = @"李彦宏";
        name.textAlignment = NSTextAlignmentLeft;
        name.lineBreakMode = NSLineBreakByTruncatingTail;
        name.font = Font1;
        name.tag = 10001;
        [cell addSubview:name];
        
        UIView * fangkuangView = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 33, cell.frame.size.height / 2 + 3 , 20, 20)];
        if (isiPhoneBelow5s) {
            fangkuangView.frame = CGRectMake(SCREEN_WIDTH - 33, cell.frame.size.height / 2 + 3 , 20, 20);
        }else if (isiPhoneUpper6plus){
            fangkuangView.frame = CGRectMake(SCREEN_WIDTH - 37, cell.frame.size.height / 2 + 3 , 20, 20);
        }
        fangkuangView.backgroundColor = [UIColor whiteColor];
        fangkuangView.layer.borderWidth = 1;
        fangkuangView.layer.borderColor = [RGBColor(151, 151, 151) CGColor];
        [cell addSubview:fangkuangView];
        }
    if (self.dataArray.count > 0) {
        NSDictionary *dic = self.dataArray[indexPath.row];
        FFAskForHelpModel *ffAskForHelpModel = [FFAskForHelpModel modelWithDictionary:dic];
        
        UILabel *nameTempLabel = (UILabel *)[cell viewWithTag:10001];
        [nameTempLabel setText:ffAskForHelpModel.name];
        NSLog(@"nameTempLabel--->%@",ffAskForHelpModel.name);
        
//        UILabel *ageTempLabel = (UILabel *)[cell viewWithTag:10002];
//        if ([ffAskForHelpModel.sex intValue] == 1){
//            ageTempLabel.text = [NSString stringWithFormat:@"年龄:%@  性别:男♂",ffAskForHelpModel.age];
//        }else if ([ffAskForHelpModel.sex intValue] == 2)
//        {
//            ageTempLabel.text = [NSString stringWithFormat:@"年龄:%@  性别:女♀",ffAskForHelpModel.age];
//        }
//        else{
//            ageTempLabel.text = [NSString stringWithFormat:@"年龄:%@  性别:不详",ffAskForHelpModel.age];
//        }
        UIImageView * iconImageV = (UIImageView *)[cell viewWithTag:10000];
        [iconImageV setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kFFAPI,ffAskForHelpModel.avatar]] placeholderImage:[UIImage imageNamed:@"FFFriendIcon"]];
        UILabel * selfIntroLab = (UILabel *)[cell viewWithTag:10003];
        [selfIntroLab setText:ffAskForHelpModel.selfIntroduction];
        
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if ([self.isAll isEqualToString:@"1"])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int i = 0;
    if (self.dataArray.count > 0) {
        i = self.dataArray.count;
    }
    return i;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

#pragma mark - 下拉刷新的方法、上拉刷新的方法
- (void)headerRefresh{
    [self requestData];
}
#pragma mark- 获取求帮助的好友列表
-(void)requestData
{
    /*获取可以求助的好友列表
     http://192.168.8.223:8080 /fight/getCanHelpFriends
     * @param fightId
     * @param userId
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
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.fightIdStr,@"fightId",logId,@"logId",token,@"token",userId,@"userId",nil];
    
    loadView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [MyUtil requestPostURL:[NSString stringWithFormat:@"%@%@",kFFAPI,kFFAPI_FFGETAskFriendList] params:params success:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]] ) {
            [loadView hide:YES];
            NSLog(@"responseObject is ----<>%@",responseObject);
            NSString *error = [NSString stringWithFormat:@"%@",responseObject[@"error"]];
            [_tableView headerEndRefreshing];
            [_tableView footerEndRefreshing];
            if (error.integerValue==0) {
                NSDictionary *dataDic = responseObject;
                self.dataArray = [dataDic valueForKey:@"data"];
                for (int i = 0; i < self.dataArray.count; i++) {
                    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                    [dic setValue:@"NO" forKey:@"checked"];
                    [contacts addObject:dic];
                }
                NSLog(@"contacts is%@",contacts);
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
//        UILabel* ageSex = [[UILabel alloc] initWithFrame:CGRectMake(name.frame.size.width + name.frame.origin.x + 16, 10, 120, 14)];
//        ageSex.text = @"年龄:15 性别:男";
//        ageSex.lineBreakMode = NSLineBreakByTruncatingTail;
//        ageSex.textAlignment = NSTextAlignmentLeft;
//        ageSex.font = Font2;
//        ageSex.tag = 10002;
//        [cell addSubview:ageSex];
//
//        UILabel * introduceLab = [[UILabel alloc] initWithFrame:CGRectMake(logo.frame.size.width + logo.frame.origin.x + 12, name.frame.size.height + name.frame.origin.y + 10, 230, 14)];
//        introduceLab.text = @"我们先定个小目标,比如斗脸拿第一";
//        introduceLab.lineBreakMode = NSLineBreakByTruncatingTail;
//        introduceLab.textAlignment = NSTextAlignmentLeft;
//        introduceLab.font = Font2;
//        introduceLab.tag = 10003;
//        [cell addSubview:introduceLab];
@end
