//
//  FFStoreViewController.m
//  doulian
//
//  Created by Suny on 16/9/18.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import "FFStoreViewController.h"

#import "FFPresentListModel.h"

#import "FFPresentDetailViewController.h"

#import "FFIntegralListViewController.h"

#import "AppDelegate.h"

#import "FFGetPurchaseHistoryVC.h"//兑换记录

#import "FFExchangeResultViewController.h"

//#define FFTableCellHeight 105
#define FFTableCellPicSize 70

@interface FFStoreViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>

@property(nonatomic,strong)UIImageView *headImageView;//头部图片
@property (nonatomic,strong) UITableView *tableView;

@end

@implementation FFStoreViewController
{
    OLGhostAlertView *ghostView;
    MBProgressHUD *loadView;
    int pageIndex;
    NSMutableArray *dataArray;//初始数据
    
    NSMutableArray *array_v;//虚拟商品array
    NSMutableArray *array_r;//真实商品array
    
    CGFloat ViewHeaderWidth;
    CGFloat ViewHeaderHeight;
    CGFloat TableCellHeight ;
    CGFloat rate;
    UIScrollView *scroolView_Present;
    
    UIButton *btn_goLeft;
    UIButton *btn_goRight;
    
    NSString *str_user_score;
    
    UIView *view_tool_back;
    
    int tempNum_VirtualTool;
    
    UIButton *btn_title;//积分title
}


-(void)viewDidLoad{
    [super viewDidLoad];
    [self configHeadView];
    [self initData];
//    [self addLeftBtnwithImgName:nil Title:@"登录"];
//    [self addRightBtnwithImgName:nil Title:@"创建房间"];
    [self initTableView];
    
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];  
    if (_isFromCreateOrRoom) {
        [self addBackBtnWithNoHeader];
    }
    
    ghostView = [[OLGhostAlertView alloc] initWithTitle:nil message:nil timeout:0.6 dismissible:YES];
    ghostView.position = OLGhostAlertViewPositionCenter;
    pageIndex =1;
    array_v = [[NSMutableArray alloc] init];
    array_r = [[NSMutableArray alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveLoginSucceedNotif:) name:@"LoginSucceed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveLoginSucceedNotif:) name:@"ExchangePresentSucceed" object:nil];
    [self requestDataWithPage:pageIndex];
    
}

-(void)initData{
    str_user_score = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"total_score"]];
    if (!str_user_score||[str_user_score isEqualToString:@"(null)"]) {
        str_user_score = @"0";
    }
    
    ViewHeaderHeight = 430.0;
    TableCellHeight = 142.0;
    rate = 1;
    //6 6s 7 375
    //5 5s se 320
    //6p 6sp 7p 414
    if (isiPhoneBelow5s) {
        rate = 320.0/375.0;
        ViewHeaderHeight = rate*ViewHeaderHeight;
        TableCellHeight *= rate;
    }else if(isiPhoneUpper6plus){
        rate = 414.0/375.0;
        ViewHeaderHeight = rate*ViewHeaderHeight;
        TableCellHeight *= rate;
    }
}

-(void)initTableView{
    //高度减去tabbar高度50
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREENH_HEIGHT-50 ) style:UITableViewStylePlain];
    if (_isFromCreateOrRoom) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREENH_HEIGHT ) style:UITableViewStylePlain];
    }
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView setTableHeaderView:self.headImageView];
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
    _tableView.backgroundColor = [UIColor whiteColor];
}

-(UIImageView *)headImageView{
    if (_headImageView == nil) {
        //380
        _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, ViewHeaderHeight)];
        _headImageView.backgroundColor = [UIColor clearColor];
        _headImageView.userInteractionEnabled = YES;
        [self.view addSubview:_headImageView];
        
        UIImageView *image_header_back = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, rate*158)];
        [image_header_back setImage:[UIImage imageNamed:@"商城"]];
        image_header_back.userInteractionEnabled = YES;
        [_headImageView addSubview:image_header_back];
        
        UILabel *label_title = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-100/2*rate, 34*rate, 100*rate, floor(17*rate))];
        label_title.font = [UIFont systemFontOfSize:floor(17*rate)];
        label_title.textColor = RGBColor(74, 74, 74);
        label_title.text = @"我的积分";
        label_title.textAlignment = NSTextAlignmentCenter;
        [image_header_back addSubview:label_title];
        
        btn_title = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-182*rate/2, label_title.frame.origin.y+label_title.frame.size.height +rate*9, 182*rate, 40*rate)];
        [btn_title setTitle:str_user_score forState:UIControlStateNormal];
        [btn_title setTitleColor:RGBColor(239, 77, 97) forState:UIControlStateNormal];
        [btn_title.titleLabel setFont:[UIFont systemFontOfSize:floor(28*rate)]];
        [btn_title setBackgroundColor:RGBColor(243, 190, 43)];
        FFViewBorderRadius(btn_title, 40*rate/2, 1, [UIColor clearColor]);
        [image_header_back addSubview:btn_title];
        
        UILabel *label_tool = [[UILabel alloc] initWithFrame:CGRectMake(19*rate, image_header_back.frame.size.height-floor(14*rate/2), 60*rate, floor(14*rate))];
        label_tool.font = [UIFont systemFontOfSize:floor(14*rate)];
        label_tool.textColor = RGBColor(74, 74, 74);
        label_tool.text = @"道具兑换";
        [_headImageView addSubview:label_tool];
        
        UIButton *btn_his = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-93*rate, image_header_back.frame.size.height-floor(14*rate/2), 80*rate, floor(14*rate))];
        [btn_his setTitle:@"历史记录 >" forState:UIControlStateNormal];
        [btn_his.titleLabel setFont:[UIFont systemFontOfSize:floor(14*rate)]];
        [btn_his setTitleColor:RGBColor(74, 74, 74) forState:UIControlStateNormal];
        [btn_his addTarget:self action:@selector(onClickHistoryBtn:) forControlEvents:UIControlEventTouchUpInside];
        [image_header_back addSubview:btn_his];
        
        UILabel *label_present = [[UILabel alloc] initWithFrame:CGRectMake(19*rate, ViewHeaderHeight-15*rate, 60*rate, floor(14*rate))];
        label_present.font = [UIFont systemFontOfSize:floor(14*rate)];
        label_present.textColor = RGBColor(74, 74, 74);
        label_present.text = @"礼品兑换";
        [_headImageView addSubview:label_present];
        
        btn_goLeft = [[UIButton alloc] initWithFrame:CGRectMake(6*rate, 262*rate, 26, 35)];
        [btn_goLeft setImage:[UIImage imageNamed:@"选择道具左箭头"] forState:UIControlStateNormal];
        [btn_goLeft addTarget:self action:@selector(goLeftOrRight:) forControlEvents:UIControlEventTouchUpInside];
        btn_goLeft.tag = 1;
        [_headImageView addSubview:btn_goLeft];
        
        btn_goRight = [[UIButton alloc] initWithFrame:CGRectMake(346*rate, 262*rate, 26, 35)];
        [btn_goRight setImage:[UIImage imageNamed:@"选择道具右箭头"] forState:UIControlStateNormal];
        [btn_goRight addTarget:self action:@selector(goLeftOrRight:) forControlEvents:UIControlEventTouchUpInside];
        btn_goRight.tag = 2;
        [_headImageView addSubview:btn_goRight];

    }
    return _headImageView;
}

-(void)refreshToolScroolView{
    if (scroolView_Present) {
        [scroolView_Present removeFromSuperview];
    }
    scroolView_Present = [[UIScrollView alloc] initWithFrame:CGRectMake(0, rate*158+20*rate, SCREEN_WIDTH, 213*rate)];
    scroolView_Present.backgroundColor = [UIColor clearColor];
    scroolView_Present.delegate = self;
    scroolView_Present.pagingEnabled = YES;
    scroolView_Present.showsHorizontalScrollIndicator = NO;
    scroolView_Present.bounces = YES;
    scroolView_Present.contentSize = CGSizeMake(SCREEN_WIDTH*(array_v.count%2+array_v.count/2), 213*rate);
    [scroolView_Present setUserInteractionEnabled:YES];
    [_headImageView addSubview:scroolView_Present];
    
    
    CGFloat space = (SCREEN_WIDTH-158*2*rate)/3;
    if (array_v.count>0) {
        for (int i = 0; i<array_v.count; i++) {
            
            FFPresentListModel *pmodel = [FFPresentListModel modelWithDictionary:array_v[i]];
            UIImageView *view_gray;
            view_gray = [[UIImageView alloc] initWithFrame:CGRectMake(space*(i+1)+space*(i/2)+i*rate*158, 0,158*rate, 215*rate)];
            view_gray.image = [UIImage imageNamed:@"道具大卡片"];
            view_gray.tag = 2000+i;
            view_gray.userInteractionEnabled = YES;
            UITapGestureRecognizer *tapBak = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapChooseToolBack:)];
            [view_gray addGestureRecognizer:tapBak];
            [scroolView_Present addSubview:view_gray];
            
            UILabel *label_name = [[UILabel alloc] initWithFrame:CGRectMake(20*rate, 12*rate, view_gray.frame.size.width-20*rate*2, floor(rate*17))];
            label_name.textAlignment = NSTextAlignmentCenter;
            label_name.text = pmodel.name;
            label_name.font = [UIFont boldSystemFontOfSize:floor(rate*17)];
            label_name.textAlignment = NSTextAlignmentCenter;
            label_name.textColor = RGBColor(96, 77, 79);
            [view_gray addSubview:label_name];
            
            UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(31*rate, 40*rate, 77*rate, 77*rate)];
            image.tag = 3000+i;
            [image setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kFFAPI,pmodel.photos]] placeholderImage:[UIImage imageNamed:@"比赛图片占位"]];
//            [image setImage:[UIImage imageNamed:@"骰子"]];
//            image.backgroundColor = [UIColor greenColor];
            image.contentMode  = UIViewContentModeScaleAspectFit;
            [view_gray addSubview:image];
            
            UIImageView *imagex = [[UIImageView alloc] initWithFrame:CGRectMake(image.frame.origin.x+image.frame.size.width+5*rate, image.frame.origin.y+image.frame.size.height-16*rate, 15*rate, 16*rate)];
            //        imagex.tag = 3000+i;
            [imagex setImage:[UIImage imageNamed:@"x"]];
            [view_gray addSubview:imagex];
            
            UIImageView *imageNum = [[UIImageView alloc] initWithFrame:CGRectMake(imagex.frame.origin.x+imagex.frame.size.width, imagex.frame.origin.y, 15*rate, 16*rate)];
            //        imagex.tag = 3000+i;
            [imageNum setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d",1]]];
            //        [imageNum setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@",@"1"]]];
            [view_gray addSubview:imageNum];
            
            UILabel *label_intro = [[UILabel alloc] initWithFrame:CGRectMake(16*rate, 122*rate, 130*rate, 40*rate)];
            label_intro.numberOfLines = 0;
            label_intro.font = [UIFont systemFontOfSize:floor(11*rate)];
            //label_intro.backgroundColor = [UIColor yellowColor];
            label_intro.lineBreakMode = NSLineBreakByWordWrapping;
            label_intro.textAlignment = NSTextAlignmentCenter;
            label_intro.text = pmodel.describe;
            [view_gray addSubview:label_intro];
            
            UIButton *btn_use = [[UIButton alloc] initWithFrame:CGRectMake(26*rate, 173*rate, 105*rate, 34*rate)];
            [btn_use setBackgroundImage:[UIImage imageNamed:@"v_back"] forState:UIControlStateNormal];
            [btn_use setTitle:[NSString stringWithFormat:@"%@积分",pmodel.price] forState:UIControlStateNormal];
            btn_use.tag = 1000+i;
            [btn_use.titleLabel setFont:[UIFont systemFontOfSize:floor(14*rate)]];
            [btn_use setTitleColor:RGBColor(74, 74, 74) forState:UIControlStateNormal];
            [btn_use setTitleEdgeInsets:UIEdgeInsetsMake(10*rate, 20*rate, 10*rate, 0)];
            [btn_use addTarget:self action:@selector(onClickChooseToolBtn:) forControlEvents:UIControlEventTouchUpInside];
            [btn_use setUserInteractionEnabled:YES];
            [view_gray addSubview:btn_use];
        }

    }
    
    [_headImageView bringSubviewToFront:btn_goLeft];
    [_headImageView bringSubviewToFront:btn_goRight];
    btn_goLeft.hidden = YES;
    if (array_v.count<=2) {
        btn_goRight.hidden = YES;
    }
    
}

#pragma mark - Notifications
-(void)onReceiveLoginSucceedNotif:(NSNotification *)noti{
    [self requestDataWithPage:1];
}

#pragma mark - User Interactions

-(void)backUp:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

//道具scroolview翻页
-(void)goLeftOrRight:(UIButton *)sender{
    CGPoint point;
    switch (sender.tag) {
        case 1:
        {
            point = CGPointMake(scroolView_Present.contentOffset.x-scroolView_Present.frame.size.width, scroolView_Present.contentOffset.y);
            [scroolView_Present setContentOffset:point animated:true];
        }
            break;
        case 2:
        {
            point = CGPointMake(scroolView_Present.contentOffset.x+scroolView_Present.frame.size.width, scroolView_Present.contentOffset.y);
            [scroolView_Present setContentOffset:point animated:true];
        }
            break;
            
        default:
            break;
    }
//    [self performSelector:@selector(resetBtnGOGOGO) withObject:nil afterDelay:0.1];
    
    [self resetBtnGOGOGOWithContentOffsetX:point.x];
}

-(void)resetBtnGOGOGOWithContentOffsetX:(CGFloat)offsetX{
    CGFloat pageWidth = scroolView_Present.frame.size.width;
    int page = floor((offsetX - pageWidth / 2) / pageWidth) + 1;
    NSLog(@"page is: %d",page) ;
    
    if(page == 0){
        btn_goLeft.hidden = YES;
        if (array_v.count>2) {
            btn_goRight.hidden = NO;
        }
        
    }else if (page == array_v.count/2+array_v.count%2-1){
        btn_goLeft.hidden = NO;
        btn_goRight.hidden = YES;
    }else{
        btn_goLeft.hidden = NO;
        btn_goRight.hidden = NO;
    }
}

//点击斗图弹出用户展示页
-(void)onTapChooseToolBack:(id)sender{
    
    UITapGestureRecognizer *singleTap = (UITapGestureRecognizer *)sender;
    //    NSLog(@"%d",[singleTap view].tag]);
    long int tag = [singleTap view].tag-2000;
    [self showExchangeVirtualToolViewWithTag:tag];
}

-(void)onClickChooseToolBtn:(UIButton *)sender{
    long int tag = sender.tag-1000;
    [self showExchangeVirtualToolViewWithTag:tag];
}

-(void)showExchangeVirtualToolViewWithTag:(long int)tag{
    
    if ([MyUtil jumpToLoginVCIfNoLogin]) {
        return;
    }
    
    FFPresentListModel *model = [FFPresentListModel modelWithDictionary:array_v[tag]];
    if (model.price.intValue> str_user_score.intValue) {
        //
        ghostView.message = @"积分不足";
        [ghostView show];
        return;
    }
    
    view_tool_back = [MyUtil viewWithAlpha:0.55];
    view_tool_back.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapBack = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideExchangeVirtualToolView)];
    [view_tool_back addGestureRecognizer:tapBack];
    [[MyUtil getFrontView] addSubview:view_tool_back];
    
    UIImageView *view_tool = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-274*rate)/2, 89*rate, 274*rate, 375*rate)];
    [view_tool setImage:[UIImage imageNamed:@"道具大卡片"]];
    view_tool.userInteractionEnabled = YES;
    view_tool.tag = 1;
    [view_tool_back addSubview:view_tool];
    
    UIButton *btn_buy = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-176*rate)/2, 504*rate, 176*rate, 56*rate)];
    [btn_buy setImage:[UIImage imageNamed:@"确定兑换"] forState:UIControlStateNormal];
//    btn_buy.backgroundColor = [UIColor greenColor];
    [btn_buy addTarget:self action:@selector(onClickBuyToolBtn:) forControlEvents:UIControlEventTouchUpInside];
    btn_buy.tag =1000+tag;
    [view_tool_back addSubview:btn_buy];
    
    UILabel *label_name = [[UILabel alloc] initWithFrame:CGRectMake(20*rate, 30*rate, view_tool.frame.size.width-20*rate*2, floor(rate*23))];
    label_name.textAlignment = NSTextAlignmentCenter;
    label_name.text = model.name;
    label_name.font = [UIFont boldSystemFontOfSize:floor(rate*23)];
    label_name.textAlignment = NSTextAlignmentCenter;
    label_name.textColor = RGBColor(96, 77, 79);
    [view_tool addSubview:label_name];
    
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(54*rate, 70*rate, 134*rate, 134*rate)];
//    image.tag = 3000+i;
    [image setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kFFAPI,model.photos]] placeholderImage:[UIImage imageNamed:@"比赛图片占位"]];
    [image setContentMode:UIViewContentModeScaleAspectFit];
    [view_tool addSubview:image];
    
    UILabel *label_holdNum = [[UILabel alloc] initWithFrame:CGRectMake((view_tool.frame.size.width-rate*117)/2, 222*rate, 117*rate, floor(24*rate))];
    label_holdNum.text = [NSString stringWithFormat:@"持有%@个",model.holdingQuantity];
    label_holdNum.textAlignment = NSTextAlignmentCenter;
    label_holdNum.textColor = RGBColor(74, 74, 74);
    label_holdNum.font = [UIFont systemFontOfSize:floor(24*rate)];
    [view_tool addSubview:label_holdNum];
    
    UIView *view_changeBack = [[UIView alloc] initWithFrame:CGRectMake((view_tool.frame.size.width-rate*240)/2, 257*rate, 240*rate, 72*rate)];
    view_changeBack.backgroundColor = [UIColor whiteColor];
    view_changeBack.tag = 1;
    FFViewBorderRadius(view_changeBack, 15*rate, 1, [UIColor clearColor]);
    [view_tool addSubview:view_changeBack];
    
    UIButton *btn_miner = [[UIButton alloc] initWithFrame:CGRectMake(17*rate, 7*rate, 51*rate, 51*rate)];
    [btn_miner setImage:[UIImage imageNamed:@"道具-"] forState:UIControlStateNormal];
    btn_miner.tag = 100*tag+1;
    [btn_miner addTarget:self action:@selector(onClickToolAddorMiner:) forControlEvents:UIControlEventTouchUpInside];
    [view_changeBack addSubview:btn_miner];
    
    UIButton *btn_add = [[UIButton alloc] initWithFrame:CGRectMake((view_changeBack.frame.size.width-rate*17-rate*51), 7*rate, 51*rate, 51*rate)];
    [btn_add setImage:[UIImage imageNamed:@"道具+"] forState:UIControlStateNormal];
    btn_add.tag = 100*tag+2;
    [btn_add addTarget:self action:@selector(onClickToolAddorMiner:) forControlEvents:UIControlEventTouchUpInside];
    [view_changeBack addSubview:btn_add];
    
    UILabel *label_num = [[UILabel alloc] initWithFrame:CGRectMake((view_tool.frame.size.width-rate*60)/2, 22*rate, 60*rate, floor(27*rate))];
    label_num.font = [UIFont boldSystemFontOfSize:floor(27*rate)];
    label_num.textColor = RGBColor(74, 74, 74);
    label_num.text = @"1";
    label_num.tag = 2001;
    label_num.textAlignment = NSTextAlignmentCenter;
    [view_changeBack addSubview:label_num];
    
    UILabel *label_totalScore = [[UILabel alloc] initWithFrame:CGRectMake((view_tool.frame.size.width-rate*116)/2, 336*rate, 116*rate, floor(18*rate))];
    label_totalScore.font = [UIFont systemFontOfSize:floor(18*rate)];
    label_totalScore.textColor = RGBColor(74, 74, 74);
    label_totalScore.text = [NSString stringWithFormat:@"共需%@积分",model.price];
    label_totalScore.tag = 2002;
    label_totalScore.textAlignment = NSTextAlignmentCenter;
    [view_tool addSubview:label_totalScore];
    
    tempNum_VirtualTool = 1;
    
}

-(void)hideExchangeVirtualToolView{
    if (view_tool_back) {
        view_tool_back.hidden = YES;
        [view_tool_back removeFromSuperview];
    }
    
}

-(void)onClickToolAddorMiner:(UIButton *)sender{
    BOOL isAdd = sender.tag%100==2?YES:NO;
    
    FFPresentListModel *model = [FFPresentListModel modelWithDictionary:array_v[sender.tag/100]];
    UILabel *label_num = [[[view_tool_back viewWithTag:1] viewWithTag:1] viewWithTag:2001];
    UILabel *label_totleScore = [[view_tool_back viewWithTag:1] viewWithTag:2002];

    if ([label_num.text isEqualToString:@"1"]&&!isAdd) {
        //最少数量为1
        return;
    }
    
    str_user_score = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"total_score"]];
    
    int tempNum = label_num.text.intValue;
    int tempScore_total = tempNum*model.price.intValue;
    if (!isAdd) {
        //减
        label_num.text = [NSString stringWithFormat:@"%d",tempNum-1];
        label_totleScore.text = [NSString stringWithFormat:@"共需%d积分",tempScore_total-model.price.intValue];
        tempNum_VirtualTool = label_num.text.intValue;
    }else{
        if ((tempNum+1)*model.price.intValue> str_user_score.intValue) {
            //
            ghostView.message = @"积分不足";
            [ghostView show];
            return;
        }
        //加
        label_num.text = [NSString stringWithFormat:@"%d",tempNum+1];
        label_totleScore.text = [NSString stringWithFormat:@"共需%d积分",tempScore_total+model.price.intValue];
        tempNum_VirtualTool = label_num.text.intValue;
    }
    
    
}

//点击确定兑换按钮
-(void)onClickBuyToolBtn:(UIButton *)sender{
    FFPresentListModel *model = [FFPresentListModel modelWithDictionary:array_v[sender.tag-1000]];
    [self exchangeVirtualToolWithTag:model Num:tempNum_VirtualTool];
}

//历史记录
-(void)onClickHistoryBtn:(UIButton *)sender{
    if ([MyUtil jumpToLoginVCIfNoLogin]) {
        return;
    }
    
    FFGetPurchaseHistoryVC *hist = [[FFGetPurchaseHistoryVC alloc] init];
    [self.navigationController pushViewController:hist animated:YES];
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
    
    
    NSString *userId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"userId"]];
    NSString *logId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"logId"]];
    NSMutableDictionary *params ;
    if ([MyUtil isLogin]) {
        params =[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",page==1000?1:page],@"pageIndex",@"100",@"pageSize",userId,@"userId",logId,@"logId",nil];

    }else{
        params =[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",page==1000?1:page],@"pageIndex",@"100",@"pageSize",nil];

    }
    loadView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [MyUtil requestPostURL:[NSString stringWithFormat:@"%@%@",kFFAPI,kFFAPI_FFPresentList] params:params success:^(id responseObject) {
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
                array_v = [[NSMutableArray alloc] init];
                array_r = [[NSMutableArray alloc] init];
                str_user_score = [NSString stringWithFormat:@"%@",[responseObject valueForKey:@"currScore"]];
                if ([str_user_score isEqualToString:@"(null)"]) {
                    str_user_score = @"0";
                }
                [mUserDefaults setValue:str_user_score forKey:@"total_score"];
                [btn_title setTitle:str_user_score forState:UIControlStateNormal];
                if(page==1||page==1000){
                    dataArray = [dataDic valueForKey:@"data"];
                }else{
                    NSMutableArray *arrayTemp = [[NSMutableArray alloc] init];
                    [arrayTemp addObjectsFromArray:dataArray];
                    [arrayTemp addObjectsFromArray:[dataDic valueForKey:@"data"]];
                    dataArray = arrayTemp;
                }
                
                for (NSDictionary *item in dataArray) {
                    if([[item valueForKey:@"isVirtual"] isEqualToNumber:@1]){
                        FFPresentListModel *model = [FFPresentListModel modelWithDictionary:item];
                        [array_v addObject:item];
                    }else{
                        FFPresentListModel *model = [FFPresentListModel modelWithDictionary:item];
                        [array_r addObject:item];
                    }
                }
                
                if (page!=1000) {
                    [self refreshToolScroolView];
                }else{
                    [self hideExchangeVirtualToolView];
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

-(void)exchangeVirtualToolWithTag:(FFPresentListModel *)model Num:(int)num{
//    FFPresentListModel *model = [FFPresentListModel modelWithDictionary:array_v[tag]];
    
    NSString *token = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"token"]];
    NSString *logId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"logId"]];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:model.presentId,@"presentId",[NSString stringWithFormat:@"%d",num],@"num",logId,@"logId",token,@"token",nil];
    
    loadView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [MyUtil requestPostURL:[NSString stringWithFormat:@"%@%@",kFFAPI,kFFAPI_FFExchangePresent] params:params success:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]] ) {
            [loadView hide:YES];
            NSString *error = [NSString stringWithFormat:@"%@",responseObject[@"error"]];
            if (error.integerValue==0) {
                [loadView hide:YES];
                ghostView.message = [responseObject valueForKey:@"msg"];
                [ghostView show];
                str_user_score = [NSString stringWithFormat:@"%d",str_user_score.intValue-model.price.intValue*num];
//                str_user_score = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"total_score"]];
                [mUserDefaults setValue:str_user_score forKey:@"total_score"];
                [btn_title setTitle:str_user_score forState:UIControlStateNormal];
                
                //通知创建房间、挑战\应战、斗脸房间刷新道具数据
                [[NSNotificationCenter defaultCenter] postNotificationName:@"OnRefreshTool" object:nil];
                [self requestDataWithPage:1000];
                
            }else if(error.integerValue==2010){
                [loadView hide:YES];
                ghostView.message = @"积分不足";
                [ghostView show];
            }else{
                [loadView hide:YES];
                ghostView.message = @"兑换失败";
                [ghostView show];
            }        }
    } failure:^(NSError *error) {
        [loadView hide:YES];
        ghostView.message = @"网络出现问题，请稍后重试";
        [ghostView show];
        
    }];
}

#pragma mark- UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return array_r.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return TableCellHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *recomendTavleViewCellId = @"FFTavleViewCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:recomendTavleViewCellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:recomendTavleViewCellId];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

        UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(18*rate, 18*rate, 112*rate , 112*rate)];
        imgV.tag = 13001;
        FFViewBorderRadius(imgV, 3, 1, RGBColor(210, 210, 210));
        [cell addSubview:imgV];
        
        
        //名称
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(140*rate, (19+18)*rate, 200*rate, floor(18*rate))];
        [nameLabel setFont:[UIFont systemFontOfSize:floor(18*rate)]];
        nameLabel.tag = 14001;
        nameLabel.textColor = RGBColor(74, 74, 74);
        [cell addSubview:nameLabel];
        
        //价格
        UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(140*rate, nameLabel.frame.origin.y+nameLabel.frame.size.height+26*rate , 100*rate, floor(17*rate))];
        [priceLabel setFont:[UIFont systemFontOfSize:floor(17*rate)]];
        priceLabel.textColor = RGBColor(239, 77, 97);
        priceLabel.tag = 14002;
        [cell addSubview:priceLabel];
        
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(292*rate, 67*rate, 68*rate, 28*rate)];
        [btn setBackgroundColor:RGBColor(251, 226, 84)];
        FFViewBorderRadius(btn, 2, 1, RGBColor(54, 28, 29));
        btn.tag = indexPath.row+3000;
        [btn setTitle:@"兑换" forState:UIControlStateNormal];
        [btn setTitleColor:RGBColor(74, 74, 74) forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:floor(14*rate)]];
        btn.userInteractionEnabled = NO;
        [cell addSubview:btn];
        
        UIView *view_line = [[UIView alloc] initWithFrame:CGRectMake(18*rate, TableCellHeight-1, SCREEN_WIDTH-18*rate, 1)];
        [view_line setBackgroundColor:RGBColor(231, 231, 231)];
        [cell addSubview:view_line];
        
    }
    
    NSDictionary *dic = array_r[indexPath.row];
    FFPresentListModel *ffpModel = [FFPresentListModel modelWithDictionary:dic];

    
    UILabel *nameTempLabel = (UILabel *)[cell viewWithTag:14001];
    [nameTempLabel setText:ffpModel.name];
    
    UILabel *priceTempLabel = (UILabel *)[cell viewWithTag:14002];
    [priceTempLabel setText:[NSString stringWithFormat:@"%@积分",ffpModel.price]];
    
    
    UIImageView *imgV = (UIImageView *)[cell viewWithTag:13001];
    NSString *imgurlV = kConJoinURL(kFFAPI, ffpModel.photos);
    [imgV setImageWithURL:[NSURL URLWithString:imgurlV] placeholderImage:[UIImage imageNamed:@"比赛图片占位"]];
    
    UIButton *btn = (UIButton *)[cell viewWithTag:indexPath.row+3000];

//
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([MyUtil jumpToLoginVCIfNoLogin]) {
        return;
    }
    
    NSDictionary *dic = array_r[indexPath.row];
    FFPresentListModel *ffpModel = [FFPresentListModel modelWithDictionary:dic];
    FFPresentDetailViewController *detail = [FFPresentDetailViewController new];
    detail.pModel = ffpModel;
    [self.navigationController pushViewController:detail animated:YES];
//    FFExchangeResultViewController *result = [[FFExchangeResultViewController alloc] init];
//    result.isSucceed = YES;
////    result.presentId = _pModel.presentId;
//    [self.navigationController pushViewController:result animated:YES];
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

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self resetBtnGOGOGOWithContentOffsetX:scroolView_Present.contentOffset.x];
    
}

@end
