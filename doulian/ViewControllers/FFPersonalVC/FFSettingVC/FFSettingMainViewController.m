//
//  FFSettingMainViewController.m
//  doulian
//
//  Created by WangJinyu on 16/10/31.
//  Copyright © 2016年 maomao. All rights reserved.
// 设置主界面

#import "FFSettingMainViewController.h"
#import "FFForgetOrChangePasswordVC.h"//忘记密码修改密码
#import "RootViewController.h"//退出登录回到主界面
#import "FFIntroduceWebViewController.h"//关于斗脸
#import "UMessage.h"
#import "FFTimerManager.h"

#define kHeaderHeight 180 //头部高度

@interface FFSettingMainViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    OLGhostAlertView *ghostView;
    MBProgressHUD *loadView;
    UITableView * _tableView;
}
@end

@implementation FFSettingMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackBtn];
    [self initTableView];
    self.view.backgroundColor = kBackgraoudColorDefault;
    ghostView = [[OLGhostAlertView alloc] initWithTitle:nil message:nil timeout:0.6 dismissible:YES];
    ghostView.position = OLGhostAlertViewPositionCenter;

    // Do any additional setup after loading the view.
}

-(void)initTableView{
    //高度减去tabbar高度50
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 44 + self.num, SCREEN_WIDTH, SCREENH_HEIGHT - 44 - self.num) style:UITableViewStylePlain];
    _tableView.backgroundColor = RGBColor(243, 243, 243);
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    [self.view addSubview:_tableView];
    
//    _tableView.contentInset = UIEdgeInsetsMake(kHeaderHeight + 75 + 55, 0, 0, 0);
    UIView * bgViewWhite = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kHeaderHeight)];
    bgViewWhite.backgroundColor = RGBColor(249, 249, 249);
    [_tableView addSubview:bgViewWhite];
    _tableView.tableHeaderView = bgViewWhite;
    _tableView.tableFooterView = [[UIView alloc]init];//去除掉多余的线
    
    //关于斗脸
    UILabel * aboutFFLab = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 50, 15, 0, 0)];
    [bgViewWhite addSubview:aboutFFLab];
    //关于斗脸图片
    UIImageView * imageVFF = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 45, aboutFFLab.frame.origin.y + aboutFFLab.frame.size.height + 10, 90, 90)];
    imageVFF.image = [UIImage imageNamed:@"AboutFight_logo"];
    [bgViewWhite addSubview:imageVFF];
    //版本
    UILabel * versionLab = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 80,imageVFF.frame.origin.y + imageVFF.frame.size.height + 10, 160, 30)];
    versionLab.textColor = [UIColor blackColor];
    NSString * versionStr = kAppVersion;
    versionLab.text = [NSString stringWithFormat:@"版本:%@",versionStr];
    versionLab.textAlignment = NSTextAlignmentCenter;
    versionLab.font = [UIFont boldSystemFontOfSize:18];
    [bgViewWhite addSubview:versionLab];
    //QQ群号码
//    UILabel * QQGroupLab = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 90, versionLab.frame.origin.y + versionLab.frame.size.height + 10, 180, 30)];
//    QQGroupLab.textColor = [UIColor blackColor];
//    QQGroupLab.text = @"QQ群 291119540";
//    QQGroupLab.textAlignment = NSTextAlignmentCenter;
//    QQGroupLab.font = [UIFont boldSystemFontOfSize:18];
//    [bgViewWhite addSubview:QQGroupLab];
    
    UIView * footView = [[UIView alloc]initWithFrame:CGRectMake(0, kHeaderHeight - 10, SCREEN_WIDTH, 10)];
    footView.backgroundColor = RGBColor(243, 243, 243);
    [bgViewWhite addSubview:footView];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([MyUtil isAppCheck]) {
        return 3;
    }
    return 4;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
static NSString * cellStr = @"SettingCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellStr];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellStr];
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = @"修改密码";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }else if (indexPath.row == 1){
        cell.textLabel.text = @"清空缓存";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }else if (indexPath.row == 2){
        if ([MyUtil isAppCheck]) {
            cell.textLabel.text = @"退出";
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
        }else{
            cell.textLabel.text = @"关于斗脸";
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
        }
        
    }else if (indexPath.row == 3){
        cell.textLabel.text = @"退出";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        //修改密码";
        FFForgetOrChangePasswordVC * vc = [[FFForgetOrChangePasswordVC alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.row == 1){
        //清空缓存";
        ghostView.message = @"清除成功";
        [ghostView show];
        
    }else if (indexPath.row == 2){
        if ([MyUtil isAppCheck]) {
            //退出";
            [self logOut];
            // self.tabBarController.selectedIndex = 0;
            RootViewController * rootVC = [[RootViewController alloc]init];
            [self.navigationController pushViewController:rootVC animated:NO];

        }else{
            //关于斗脸";
            FFIntroduceWebViewController * webVC = [[FFIntroduceWebViewController alloc]init];
            webVC.webTitle = @"关于斗脸";
            // 关于我们http://doulian.qihaoduo.com/sys/aboutUs
            webVC.jumpRequest = [NSString stringWithFormat:@"%@%@",kFFAPI,kFFAPI_AboutUs];
            [self.navigationController pushViewController:webVC animated:NO];
        }
        
    }else if (indexPath.row == 3){
        //退出";
        [self logOut];
        // self.tabBarController.selectedIndex = 0;
        RootViewController * rootVC = [[RootViewController alloc]init];
        [self.navigationController pushViewController:rootVC animated:NO];
    }
}

#pragma mark - 退出登录
-(void)logOut
{
    NSString *isLogin = (NSString *)[mUserDefaults valueForKey:@"isLogin"];
    if (![isLogin isEqualToString:@"1"]) {
        ghostView.message = @"请先登录";
        [ghostView show];
        return;
    }
    //http://192.168.8.223:8080 /user/logout
    NSString *logId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"logId"]];
    NSString *token = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"token"]];
    NSString * ImeiStr = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"imei"]];
    NSLog(@"ImeiStr2222222is%@",ImeiStr);
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:logId,@"logId",token,@"token",ImeiStr,@"imei",nil];
    
    loadView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [MyUtil requestPostURL:[NSString stringWithFormat:@"%@%@",kFFAPI,kFFAPI_FFLogOut] params:params success:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]] ) {
            [loadView hide:YES];
            NSLog(@"responseObject is ----<>%@",responseObject);
            NSString *error = [NSString stringWithFormat:@"%@",responseObject[@"error"]];
            [_tableView headerEndRefreshing];
            [_tableView footerEndRefreshing];
            if (error.integerValue==0) {
                ghostView.message = @"退出登录成功";
                [ghostView show];
                
                [UMessage removeAlias:[NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"userId"]] type:@"face" response:^(id responseObject, NSError *error) {
                    
                    NSLog(@"当前Alias 为 %@face,解除绑定成功",[mUserDefaults valueForKey:@"userId"]);
                }];
                [self removeDefaultInfo];
                [[FFTimerManager defaultManager] removeData];
            }
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

#pragma mark - 退出登录清除缓存
-(void)removeDefaultInfo{
    [mUserDefaults removeObjectForKey:@"age"];
    [mUserDefaults removeObjectForKey:@"avatar"];
    [mUserDefaults removeObjectForKey:@"create_time"];
    [mUserDefaults removeObjectForKey:@"imei"];
    [mUserDefaults removeObjectForKey:@"selfIntroduction"];
    
    [mUserDefaults removeObjectForKey:@"sex"];
    [mUserDefaults removeObjectForKey:@"third"];
    [mUserDefaults removeObjectForKey:@"total_score"];
    [mUserDefaults removeObjectForKey:@"userId"];
    [mUserDefaults removeObjectForKey:@"token"];
    [mUserDefaults removeObjectForKey:@"log_id"];
    [mUserDefaults removeObjectForKey:@"mobile"];
    [mUserDefaults removeObjectForKey:@"userId"];
    [mUserDefaults removeObjectForKey:@"name"];
    
    [mUserDefaults removeObjectForKey:@"password"];
    [mUserDefaults removeObjectForKey:@"isLogin"];
    
    //兑换礼品联系信息
    [mUserDefaults removeObjectForKey:@"UserContatsInfo"];
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
