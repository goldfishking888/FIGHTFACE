//
//  RootViewController.m
//  doulian
//
//  Created by Suny on 16/8/23.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import "RootViewController.h"
#import "ViewController.h"
#import "PersonalCenterViewController.h"//我?
#import "FFListViewController.h"
#import "FFFriendListViewController.h"//好友
#import "FFStoreViewController.h"

#import "FFCreateRoomViewController.h"
#import "FFFightRoomViewController.h"

#import "FFTimerManager.h"
@interface RootViewController ()

@end

@implementation RootViewController{
    OLGhostAlertView *ghostView;
    MBProgressHUD *loadView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    NSLog(@"viewWillAppear");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initViewControllers];
    self.tabBar.backgroundColor = [UIColor whiteColor];
    [self.tabBar setItemTitleColor:[UIColor lightGrayColor]];
    [self.tabBar setItemTitleSelectedColor:[UIColor grayColor]];
    // 设置数字样式的badge的位置和大小
    [self.tabBar setNumberBadgeMarginTop:2
                       centerMarginRight:20
                     titleHorizonalSpace:8
                      titleVerticalSpace:2];
    // 设置小圆点样式的badge的位置和大小
    [self.tabBar setDotBadgeMarginTop:5
                    centerMarginRight:10
                           sideLength:10];
    
    
//    UIViewController *controller1 = self.viewControllers[0];
//    UIViewController *controller2 = self.viewControllers[1];
//    UIViewController *controller3 = self.viewControllers[2];
//    UIViewController *controller4 = self.viewControllers[3];
//    controller1.yp_tabItem.badge = 8;
//    controller2.yp_tabItem.badge = 88;
//    controller3.yp_tabItem.badge = 120;
//    controller4.yp_tabItem.badgeStyle = YPTabItemBadgeStyleDot;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setBtnNormal) name:@"setBtnNormal" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setBtnFighting) name:@"setBtnFighting" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setBtnSearching) name:@"setBtnSearching" object:nil];
}

- (void)initViewControllers {
    
    FFListViewController *controller1 = [[FFListViewController alloc] init];
    controller1.yp_tabItemTitle = @"大厅";
    controller1.yp_tabItemImage = [UIImage imageNamed:@"ico2XCopy_2"];
    controller1.yp_tabItemSelectedImage = [UIImage imageNamed:@"icon_home_selected"];
    
    FFFriendListViewController *controller2 = [[FFFriendListViewController alloc] init];
    controller2.yp_tabItemTitle = @"好友";
    controller2.yp_tabItemImage = [UIImage imageNamed:@"ico2XCopy_3"];
    controller2.yp_tabItemSelectedImage = [UIImage imageNamed:@"icon_friend_selected"];
    
    FFStoreViewController *controller3 = [[FFStoreViewController alloc] init];
    controller3.yp_tabItemTitle = @"商城";
    controller3.yp_tabItemImage = [UIImage imageNamed:@"ico2XCopy"];
    controller3.yp_tabItemSelectedImage = [UIImage imageNamed:@"icon_shop_selected"];
    
    PersonalCenterViewController *controller4 = [[PersonalCenterViewController alloc] init];
    controller4.yp_tabItemTitle = @"我";
    controller4.yp_tabItemImage = [UIImage imageNamed:@"ico2XCopy_4"];
    controller4.yp_tabItemSelectedImage = [UIImage imageNamed:@"icon_me_selected"];
    
    //    ViewController *controller5 = [[ViewController alloc] init];
    //    controller5.yp_tabItemTitle = @"普通";
    //    controller5.yp_tabItemImage = [UIImage imageNamed:@"tab_me_normal"];
    //    controller5.yp_tabItemSelectedImage = [UIImage imageNamed:@"tab_me_selected"];
    self.viewControllers = [NSMutableArray arrayWithObjects:controller1, controller2, controller3, controller4, nil];
    YPTabItem *item = [YPTabItem buttonWithType:UIButtonTypeCustom];
    //    item.title = @"+";
    //    item.titleColor = [UIColor yellowColor];
    item.backgroundColor = [UIColor clearColor];
    [item setImage:[UIImage imageNamed:@"ico2XCopy_5"] forState:UIControlStateNormal];
    
    //    item.titleFont = [UIFont boldSystemFontOfSize:40];
    // 设置其size，如果不设置，则默认为与其他item一样
    item.size = CGSizeMake(80, 60);
    // 高度大于tabBar，所以需要将此属性设置为NO
    self.tabBar.clipsToBounds = NO;
    
    __weak __typeof(self) weakSelf = self;
    [self.tabBar setSpecialItem:item
             afterItemWithIndex:1
                  backImageName:@""
                     tapHandler:^(YPTabItem *item) {
                         NSLog(@"item--->%ld", (long)item.index);
                         [weakSelf requestCheckFight];
                     }];
    
    
    
    // 生成一个居中显示的YPTabItem对象，即“+”号按钮
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showTabBadge:) name:@"ShowAllBadge" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showTabBadge:) name:@"ShowChallengeBadge" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideTabBadge:) name:@"HideBadge" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showTabBadge:) name:@"ShowSystemMessageBadge" object:nil];
    
    
}

-(void)requestCheckFight{
    
    if ([MyUtil jumpToLoginVCIfNoLogin]) {
        return;
    }
    
    if (![[[FFTimerManager defaultManager] getNewestFightId] isEqualToString:@"0"]) {
        FFFightRoomViewController *room = [FFFightRoomViewController new];
//        room.responseDic = responseObject;
//        room.dataDic = [dataDic valueForKey:@"fight"];
        NSDictionary *dic = [[FFTimerManager defaultManager] getNewestFightDataDic];
        room.fightIdStr = [dic valueForKey:@"fightId"];
        room.dataDic = [dic valueForKey:@"dataDic"];
        [self.navigationController pushViewController:room animated:true];
        return ;

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
                
                for (NSString *key in dataDic.allKeys) {
                    if ([key isEqualToString:@"fight"]) {
                        NSDictionary *fightDic = [dataDic valueForKey:@"fight"];
                        if (fightDic.allKeys.count>0) {
                            ghostView.message = @"您当前有比赛正在进行中，自动为您跳转";
                            ghostView.timeout = 2.0;
                            [ghostView show];
                            FFFightRoomViewController *room = [FFFightRoomViewController new];
                            room.responseDic = responseObject;
                            room.dataDic = [dataDic valueForKey:@"fight"];
                            [self.navigationController pushViewController:room animated:true];
                            return ;
                        }
                    }
                }
//                [mUserDefaults setValue:@"0" forKey:@"isShowSearchingView"];
                FFCreateRoomViewController *rig = [[FFCreateRoomViewController alloc] init];
                rig.arrayPresents = presentArray;
                [self.navigationController pushViewController:rig animated:true];
                NSLog(@"1");
            }else if(error.integerValue==1){
                ghostView.message = @"参数异常";
                [ghostView show];
            }else{
                ghostView.message = @"服务器正忙，稍后再来";
                [ghostView show];
            }
        }
    } failure:^(NSError *error) {
        [loadView hide:YES];
        ghostView.message = @"网络出现问题，请稍后重试";
        [ghostView show];
        
    }];
    
}

-(void)showTabBadge:(NSNotification *)noti{
    UIViewController *controller4 = self.viewControllers[3];
    controller4.yp_tabItem.badge = 1;
    controller4.yp_tabItem.badgeStyle = YPTabItemBadgeStyleDot;
}

-(void)hideTabBadge:(NSNotification *)noti{
//    if ([mUserDefaults valueForKey:@"ShowAllBadge"]&&[[mUserDefaults valueForKey:@"ShowAllBadge"] isEqualToString:@"0"]&&[mUserDefaults valueForKey:@"ShowChallengeBadge"]&&[[mUserDefaults valueForKey:@"ShowChallengeBadge"] isEqualToString:@"0"]&&[mUserDefaults valueForKey:@"ShowSystemMessageBadge"]&&[[mUserDefaults valueForKey:@"ShowSystemMessageBadge"] isEqualToString:@"0"]) {
        UIViewController *controller4 = self.viewControllers[3];
        controller4.yp_tabItem.badge = 0;
//    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setBtnSearching{
    [self.tabBar setSpecialItemImage:@"btn_searching"];
    [self.tabBar setSpecialItemBackGroundImage:@"btn_searching_back" isAnimated:YES];
    
}

-(void)setBtnFighting{
    [self.tabBar setSpecialItemImage:@"btn_fighting"];
    [self.tabBar setSpecialItemBackGroundImage:@"btn_fighting_back" isAnimated:YES];
}

-(void)setBtnNormal{
    [self.tabBar setSpecialItemImage:@"ico2XCopy_5"];
    [self.tabBar setSpecialItemBackGroundImage:@"" isAnimated:NO];
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
