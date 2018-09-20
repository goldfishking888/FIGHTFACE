//
//  SearchFriendViewController.m
//  doulian
//
//  Created by WangJinyu on 2016/11/8.
//  Copyright © 2016年 maomao. All rights reserved.
// 搜索好友界面

#import "SearchFriendViewController.h"
#import "FFPersonalDetailVC.h"
#import "FFSearchFriendCell.h"
@interface SearchFriendViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
{
    UITextField * userName;
    UITableView * _tableView;
    
    OLGhostAlertView *ghostView;
    MBProgressHUD *loadView;
    NSMutableArray *dataArray;
    
}
@end

@implementation SearchFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createSearch];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    //将触摸事件添加到当前view
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    ghostView = [[OLGhostAlertView alloc] initWithTitle:nil message:nil timeout:1.0 dismissible:YES];
    ghostView.position = OLGhostAlertViewPositionCenter;
    dataArray = [NSMutableArray arrayWithCapacity:0];
    [self initTableView];
    
    
}

#pragma mark - 下拉刷新的方法、上拉刷新的方法
-(void)initTableView{
    //高度减去tabbar高度50
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 44 + self.num, SCREEN_WIDTH, SCREENH_HEIGHT - 44 - self.num) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:_tableView];
    _tableView.tableFooterView = [[UIView alloc]init];
    
    // 下拉刷新
    [_tableView addHeaderWithTarget:self action:@selector(headerRefresh)];
    _tableView.headerPullToRefreshText= @"下拉刷新";
    _tableView.headerReleaseToRefreshText = @"松开马上刷新";
    _tableView.headerRefreshingText = @"努力加载中……";
    
}

#pragma mark - 下拉刷新的方法、上拉刷新的方法
- (void)headerRefresh{
    [self requestData];
    
}

//点击手势让键盘收起来
-(void)keyboardHide:(UITapGestureRecognizer*)tap{
    [userName resignFirstResponder];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    
    if ([userName isFirstResponder]) {
        [userName resignFirstResponder];
        [self requestData];
    }
    
    return YES;
    
}

-(void)requestData
{
    if (!userName.text.length) {
        ghostView.message  =@"搜索内容不能为空";
        [ghostView show];
        [_tableView headerEndRefreshing];
        return;
    }
    
    NSString *isLogin = (NSString *)[mUserDefaults valueForKey:@"isLogin"];
    if (![isLogin isEqualToString:@"1"]) {
        ghostView.message = @"请先登录";
        [ghostView show];
        return;
    }
    
    /* 排行榜
     好友搜索
     http://192.168.8.223:8080 /user/searchMyFriends
     * @param key
     * @param userId
     * @param logId
     * @param token
     添加陌生人搜索
     http://192.168.8.223:8080 /user/searchFriend
     * @param key 关键词
     * @param logId
     * @param token
     */
    NSString *logId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"logId"]];
    NSString *userId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"userId"]];
    NSString * token = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"token"]];
    if (_isSearchStranger == YES) {
        /*添加陌生人搜索
         http://192.168.8.223:8080 /user/searchFriend
         * @param key 关键词
         * @param logId
         * @param token
         */
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:userName.text,@"key",logId,@"logId",token,@"token",nil];
        
        loadView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        NSString * url = [NSString stringWithFormat:@"%@%@",kFFAPI,kFFAPI_FFSearchFriend];
        [MyUtil requestPostURL:url params:params success:^(id responseObject) {
            if ([responseObject isKindOfClass:[NSDictionary class]] ) {
                [loadView hide:YES];
                NSString *error = [NSString stringWithFormat:@"%@",responseObject[@"error"]];
                [_tableView headerEndRefreshing];
                
                if (error.integerValue==0) {
                    NSDictionary *dataDic = responseObject;
                    //自己的数据更新
                    [dataArray removeAllObjects];
                    [dataArray addObjectsFromArray:[dataDic valueForKey:@"data"]];
                    if (dataArray.count == 0) {
                        ghostView.message = @"很抱歉,没有搜索到相关用户,请输入准确的昵称/手机号";
                        [ghostView show];
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
        
    }else if (_isSearchStranger == NO){
        /*好友搜索
         http://192.168.8.223:8080 /user/searchMyFriends
         * @param key
         * @param userId
         * @param logId
         * @param token
         */
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:userId,@"userId",userName.text,@"key",logId,@"logId",token,@"token",nil];
        
        loadView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        NSString * url = [NSString stringWithFormat:@"%@%@",kFFAPI,kFFAPI_FFSearchMyFriends];
        [MyUtil requestPostURL:url params:params success:^(id responseObject) {
            if ([responseObject isKindOfClass:[NSDictionary class]] ) {
                [loadView hide:YES];
                NSString *error = [NSString stringWithFormat:@"%@",responseObject[@"error"]];
                [_tableView headerEndRefreshing];
                
                if (error.integerValue==0) {
                    NSDictionary *dataDic = responseObject;
                    //自己的数据更新
                    [dataArray removeAllObjects];
                    [dataArray addObjectsFromArray:[dataDic valueForKey:@"data"]];
                    if (dataArray.count == 0) {
                        ghostView.message = @"很抱歉,没有搜索到相关用户,请输入准确的昵称或手机号";
                        [ghostView show];
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
    
    
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int i = 0;
    if (dataArray.count > 0) {
        i = (int)dataArray.count;
    }
    return i;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * IDCell = @"IDSearch";
    FFSearchFriendCell * cell = [tableView dequeueReusableCellWithIdentifier:IDCell];
    if (cell == nil)
    {
        cell = [[FFSearchFriendCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:IDCell];
    }
    if (dataArray.count > 0) {
        [cell configDataDicFriend:dataArray[indexPath.row]];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FFPersonalDetailVC * vc = [[FFPersonalDetailVC alloc]init];
    if (dataArray.count > 0) {
        vc.userIDStr = [NSString stringWithFormat:@"%@",dataArray[indexPath.row][@"userId"]];
    }
    [self.navigationController pushViewController: vc animated:YES];
    
}

-(void)createSearch
{
    //搜索背景
    UIView * bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0 + self.num, SCREEN_WIDTH, 50)];
    bgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgView];
    
    //搜索框背景
    UIButton * searchbg = [UIButton buttonWithType:UIButtonTypeCustom];
    searchbg.frame = CGRectMake(10, 10, bgView.frame.size.width - 80, 30);
    [searchbg setBackgroundColor:RGBColor(244, 244, 244)];
    //    [searchBtn setTitleColor:RGBColor(155, 155, 155) forState:UIControlStateNormal];
    searchbg.layer.cornerRadius = 4;
    searchbg.layer.masksToBounds = YES;
    [bgView addSubview:searchbg];
    
    //左边搜索图片
    UIImageView * searchImageV = [[UIImageView alloc]initWithFrame:CGRectMake(5, 7, 16, 16)];
    searchImageV.image = [UIImage imageNamed:@"FFSearch_searchIcon"];
    [searchbg addSubview:searchImageV];
    //查找的账号
    userName = [[UITextField alloc] initWithFrame:CGRectMake(searchImageV.frame.origin.x + searchImageV.frame.size.width + 5, 0, searchbg.frame.size.width -searchImageV.frame.origin.x - searchImageV.frame.size.width - 5, searchbg.frame.size.height)];
    userName.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    //    [userName setBorderStyle:UITextBorderStyleRoundedRect];//设置边框样式
    userName.placeholder = @"请输入昵称或手机号";
    userName.clearButtonMode = UITextFieldViewModeAlways;
    userName.font = [UIFont systemFontOfSize:14];
    userName.delegate=self;
    userName.tag = 2;
    userName.returnKeyType = UIReturnKeySearch;//默认搜索按钮
    [userName becomeFirstResponder];
    [searchbg addSubview:userName];
    
    
    //取消按钮
    UIButton * cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(SCREEN_WIDTH - 80, 10, 80, 30);
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:cancelBtn];
    
}

-(void)cancelBtnClick
{
    NSLog(@"取消");
    [self.navigationController popViewControllerAnimated:NO];
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
