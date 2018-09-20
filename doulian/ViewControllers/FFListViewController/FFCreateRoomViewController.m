//
//  FFCreateRoomViewController.m
//  doulian
//
//  Created by Suny on 16/8/29.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import "FFCreateRoomViewController.h"
#import "FFFightRoomViewController.h"
#import "FFFaceHistoryViewController.h"

#import "FFPresentOuterModel.h"
#import "FFPresentListModel.h"

#import "FFNotificationCenter.h"
#import "FFFindingFightViewController.h"

#import "FFFaceHistoryCell.h"

#import "FFStoreViewController.h"

#define cellWidth (SCREEN_WIDTH-20)/3

#define ImageWidth 170
#define ImageHeight 254

#define FFTableCellHeight 70
#define FFTableCellPicSize 50

#define ScroolViewHeight 330
#define ScroolViewWidth 250

CGFloat ViewBackHeight = 470;
CGFloat ViewCatchHeight = 80;
CGFloat ViewToolHeight = 45;

@implementation FFCreateRoomViewController
{
    OLGhostAlertView *ghostView;
    MBProgressHUD *loadView;
    int pageIndex;
    NSMutableArray *dataArray;
    
    UIImageView *leftImgV;
    
    UIImagePickerController *imagePickerController;
    
    UIImage *imageCurrent;
    
    NSString *url_imageCurrent;
    
    UIButton *btnStart;
    
    BOOL isSearching;//持续搜寻匹配
    
    BOOL isNewUploadedPic;
    NSString *imageUrlHis;
    
    NSTimer *timerWait;
    int timeInLine;
    
    NSString *presentId;
    
    NSString *catchWord;//斗脸宣言
    
    int pageIndex_history;//历史图片pageIndex
    
    NSIndexPath *chosenIndexPath;//选中图片的indexPath;
    
    UITextField *tf_catchWord;//宣言输入框
    
    UIView *view_black;//道具黑背景
    UIView *view_black_rule;//rule黑背景
    
    UIScrollView *scrollview_tool;
    
    UIButton *btn_choosePresend;
    
    UIButton *btn_goLeft;
    UIButton *btn_goRight;
    
    UIView *view_fight_black;//匹配中黑背景
    
    UILabel *label_searchingTimeLeft;//5s剩余时间
    NSString *isShowSearchingView;
    
    CGFloat rate;
}

#pragma mark -
#pragma mark View Init

-(void)viewDidLoad{
    [super viewDidLoad];
    [self addBackBtn];
    [self initData];
    [self initView];
    [self addRightBtnwithImgName:nil Title:@"匹配对手"];
    ghostView = [[OLGhostAlertView alloc] initWithTitle:nil message:nil timeout:0.6 dismissible:YES];
    ghostView.position = OLGhostAlertViewPositionCenter;
    [self initToolView];
//    [self getAvailableToolInFight];
    isShowSearchingView = [mUserDefaults valueForKey:@"isShowSearchingView"];
    if (isShowSearchingView&&[isShowSearchingView isEqualToString:@"1"]) {
        [self initSearchingBack];
    }else{
//        view_fight_black.hidden = YES;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveSearchingFightSucceedNoti:) name:@"SearchingFightSucceed" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveSearchingFightSucceedNoti:) name:@"CancelFightSucceed" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestCheckFight) name:@"OnRefreshTool" object:nil];
    
    NSString *isShowRules = [mUserDefaults valueForKey:@"isShowRules"];
    if (!isShowRules) {
        [self initRuleView];
        [mUserDefaults  setValue:@"1" forKey:@"isShowRules"];
    }
    
}

-(void)initData{
    
    
    if (![mUserDefaults valueForKey:@"isShowSearchingView"]) {
        isShowSearchingView = @"0";
    }else{
        isShowSearchingView = [mUserDefaults valueForKey:@"isShowSearchingView"];
    }
    
    isSearching = YES;
    [self initTimer];
    presentId = @"0";
    catchWord = @"";
    pageIndex_history  = 1;
    rate = 1;
    if (isiPhoneBelow5s) {
        rate = 320.0/375.0;
        ViewBackHeight = 420;
    }else if (isiPhoneUpper6plus) {
        ViewBackHeight = 510;
        rate = 414.0/375.0;
    }
    
    [self getHistoryFaceListsWithPage:(int)pageIndex_history];
}

-(void)initTableView{
    //高度减去tabbar高度50
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, btnStart.frame.origin.y+btnStart.frame.size.height+20, SCREEN_WIDTH, SCREENH_HEIGHT-btnStart.frame.origin.y-btnStart.frame.size.height-20 ) style:UITableViewStylePlain];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
}

-(void)initView{
    [self.view setBackgroundColor:RGBColor(231, 231, 231)];
    [self.view addSubview:self.viewBack];
    [self.viewBack addSubview:self.collectionView];
    
    UIView *view_line = [[UIView alloc] initWithFrame:CGRectMake(5, self.collectionView.frame.size.height+5 +5, _viewBack.frame.size.width-2*5, 1)];
    view_line.backgroundColor = mRGBToColor(0xf0f0f0);
    [self.viewBack addSubview:view_line];
    
    tf_catchWord = [[UITextField alloc] initWithFrame:CGRectMake(5, view_line.frame.origin.y+1+ 5, _viewBack.frame.size.width-5*2, ViewCatchHeight-2*5)];
    tf_catchWord.placeholder = @"说点啥";
    tf_catchWord.font = [UIFont systemFontOfSize:13];
    tf_catchWord.contentMode = UIViewContentModeTopLeft;
    //tf_catchWord.backgroundColor = [UIColor blueColor];
    [self.viewBack addSubview:tf_catchWord];
    
    UIView *view_line2 = [[UIView alloc] initWithFrame:CGRectMake(0, tf_catchWord.frame.origin.y+CGRectGetHeight(tf_catchWord.frame)+5, _viewBack.frame.size.width, 1)];
    view_line2.backgroundColor = mRGBToColor(0xf0f0f0);
    [self.viewBack addSubview:view_line2];
    
    UILabel *label_use = [[UILabel alloc] initWithFrame:CGRectMake(10, view_line2.frame.origin.y+5, 80, ViewToolHeight-2*5)];
    label_use.text = @"使用道具";
    label_use.font = [UIFont systemFontOfSize:14];
    [self.viewBack addSubview:label_use];
    
    btn_choosePresend = [[UIButton alloc] initWithFrame:CGRectMake(self.viewBack.frame.size.width-30-5, view_line2.frame.origin.y+5, 30, 30)];
    [btn_choosePresend setBackgroundImage:[UIImage imageNamed:@"道具容器"] forState:UIControlStateNormal];
    [btn_choosePresend setImage:[UIImage imageNamed:@"空道具"] forState:UIControlStateNormal];
    btn_choosePresend.imageEdgeInsets = UIEdgeInsetsMake(3, 3, 3, 3);
    [btn_choosePresend addTarget:self action:@selector(onClickAddToolBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewBack addSubview:btn_choosePresend];
    
}

-(TPKeyboardAvoidingScrollView *)viewBack{
    if (_viewBack == nil) {
        _viewBack = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:CGRectMake(5, 5+64, SCREEN_WIDTH-5*2, SCREENH_HEIGHT-64-5*2)];
        _viewBack.backgroundColor =[UIColor whiteColor];
        _viewBack.delegate = self;
    }
    return _viewBack;
}

-(UICollectionView *)collectionView{
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 5, _viewBack.frame.size.width, SCREENH_HEIGHT-64-ViewToolHeight-ViewCatchHeight-5*3) collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        flowLayout.itemSize = CGSizeMake((_viewBack.frame.size.width-5*4)/3, (_viewBack.frame.size.width-5*4)/3);
        flowLayout.minimumLineSpacing = 5;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 5, 5, 5);
        [_collectionView registerClass:[FFFaceHistoryCell class] forCellWithReuseIdentifier:@"cell"];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }
    
    __weak __typeof(self) weakSelf = self;
    int page = pageIndex;
    [_collectionView addHeaderWithCallback:^(){
        NSLog(@"1");
        [weakSelf getHistoryFaceListsWithPage:page];
    }];
    
    return _collectionView;
}

-(void)initRuleView{
    view_black_rule = [MyUtil viewWithAlpha:0.55];
    view_black_rule.userInteractionEnabled = YES;
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideRuleView)];
//    [view_black_rule addGestureRecognizer:tap];
    [self.view addSubview:view_black_rule];
    
    UIView *view_white = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-320*rate/2, 0, 314*rate, (333+64)*rate)];
    view_white.backgroundColor = [UIColor whiteColor];
    view_white.center = self.view.center;
    view_white.userInteractionEnabled = YES;
    FFViewBorderRadius(view_white, 2, 1, [UIColor clearColor]);
    [view_black_rule addSubview:view_white];
    
    UIImageView *image_photo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 314*rate, 333*rate)];
    [image_photo setImage:[UIImage imageNamed:@"斗-提示上"]];
    [image_photo setContentMode:UIViewContentModeScaleAspectFit];
    [view_white addSubview:image_photo];
    
    UIButton *btn_know = [[UIButton alloc] initWithFrame:CGRectMake(0, 333*rate+1, 314*rate, 64*rate)];
    [btn_know setImage:[UIImage imageNamed:@"斗-提示下"] forState:UIControlStateNormal];
    [btn_know setImage:[UIImage imageNamed:@"斗-提示下"] forState:UIControlStateHighlighted];
    [btn_know addTarget:self action:@selector(hideRuleView) forControlEvents:UIControlEventTouchUpInside];
    [view_white addSubview:btn_know];

    
    
}

-(void)initToolView{
    view_black = [MyUtil viewWithAlpha:0.55];
    view_black.hidden = YES;
    view_black.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideToolView)];
    [view_black addGestureRecognizer:tap];
    [self.view addSubview:view_black];
    [self showScroolView];
    
    btn_goLeft = [[UIButton alloc] initWithFrame:CGRectMake(30, SCREENH_HEIGHT/2, 26, 35)];
    [btn_goLeft setImage:[UIImage imageNamed:@"选择道具左箭头"] forState:UIControlStateNormal];
    [btn_goLeft addTarget:self action:@selector(goLeftOrRight:) forControlEvents:UIControlEventTouchUpInside];
    btn_goLeft.tag = 1;
    [view_black addSubview:btn_goLeft];
    
    btn_goRight = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-30-26, SCREENH_HEIGHT/2, 26, 35)];
    [btn_goRight setImage:[UIImage imageNamed:@"选择道具右箭头"] forState:UIControlStateNormal];
    [btn_goRight addTarget:self action:@selector(goLeftOrRight:) forControlEvents:UIControlEventTouchUpInside];
    btn_goRight.tag = 2;
    [view_black addSubview:btn_goRight];
    
}

-(void)showScroolView{
    if (scrollview_tool) {
        scrollview_tool=nil;
    }
    scrollview_tool = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, ScroolViewWidth, ScroolViewHeight)];
    scrollview_tool.center = view_black.center;
    //scrollview_tool.backgroundColor = [UIColor greenColor];
    scrollview_tool.showsHorizontalScrollIndicator = NO;
    scrollview_tool.showsVerticalScrollIndicator = NO;
    scrollview_tool.delegate = self;
    scrollview_tool.pagingEnabled = YES;
    scrollview_tool.hidden = YES;
    scrollview_tool.contentSize = CGSizeMake(_arrayPresents.count * ScroolViewWidth, ScroolViewHeight);
    [self.view addSubview:scrollview_tool];
    
    btn_goLeft.hidden = YES;
    if (_arrayPresents.count<=1) {
        btn_goRight.hidden = YES;
        if (_arrayPresents.count==0) {
            scrollview_tool.contentSize = CGSizeMake(ScroolViewWidth, ScroolViewHeight);
            [self showNoToolView];
            return;
        }
    }
    
    for (int i = 0; i<_arrayPresents.count; i++) {
        
        FFPresentOuterModel *pmodel_outer = [FFPresentOuterModel modelWithDictionary:_arrayPresents[i]];
        FFPresentListModel *pmodel = pmodel_outer.present;
        
        UIImageView *view_gray = [[UIImageView alloc] initWithFrame:CGRectMake(ScroolViewWidth/2-240/2 +ScroolViewWidth*i, 7.5,242, 300)];
        view_gray.image = [UIImage imageNamed:@"道具大卡片"];
        view_gray.tag = 2000+i;
        view_gray.userInteractionEnabled = YES;
        [scrollview_tool addSubview:view_gray];
        
        UILabel *label_name = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, view_gray.frame.size.width, 30)];
        label_name.textAlignment = NSTextAlignmentCenter;
        label_name.text = pmodel.name;
        label_name.font = [UIFont systemFontOfSize:18];
        [view_gray addSubview:label_name];
        
        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(view_gray.frame.size.width/2-120/2, label_name.frame.origin.y+label_name.frame.size.height+10, 120, 120)];
        image.tag = 3000+i;
        [image setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kFFAPI,pmodel.photos]] placeholderImage:[UIImage imageNamed:@"比赛图片占位"]];
        [view_gray addSubview:image];
        
        UIImageView *imagex = [[UIImageView alloc] initWithFrame:CGRectMake(image.frame.origin.x+image.frame.size.width+5, image.frame.origin.y+image.frame.size.height-12, 12, 13)];
//        imagex.tag = 3000+i;
        [imagex setImage:[UIImage imageNamed:@"x"]];
        [view_gray addSubview:imagex];
        
        if (pmodel_outer.num.intValue>=10) {
            UIImageView *imageNum = [[UIImageView alloc] initWithFrame:CGRectMake(imagex.frame.origin.x+imagex.frame.size.width, imagex.frame.origin.y-2, 14, 15)];
            //        imagex.tag = 3000+i;
            [imageNum setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d",pmodel_outer.num.intValue/10]]];
            //        [imageNum setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@",@"1"]]];
            [view_gray addSubview:imageNum];
            
            UIImageView *imageNum2 = [[UIImageView alloc] initWithFrame:CGRectMake(imageNum.frame.origin.x+imageNum.frame.size.width, imagex.frame.origin.y-2, 14, 15)];
            //        imagex.tag = 3000+i;
            [imageNum2 setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d",pmodel_outer.num.intValue%10]]];
            //        [imageNum setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@",@"1"]]];
            [view_gray addSubview:imageNum2];
            if (pmodel_outer.num.intValue>=100) {
                [imageNum setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d",9]]];
                [imageNum2 setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d",9]]];
            }
        }else{
            UIImageView *imageNum = [[UIImageView alloc] initWithFrame:CGRectMake(imagex.frame.origin.x+imagex.frame.size.width, imagex.frame.origin.y-6, 18, 19)];
            //        imagex.tag = 3000+i;
            [imageNum setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@",pmodel_outer.num]]];
            //        [imageNum setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@",@"1"]]];
            [view_gray addSubview:imageNum];
        }
        
        
        UILabel *label_intro = [[UILabel alloc] initWithFrame:CGRectMake(10, image.frame.origin.y+image.frame.size.height+10, view_gray.frame.size.width -2*10, 40)];
        label_intro.numberOfLines = 0;
        //label_intro.backgroundColor = [UIColor yellowColor];
        label_intro.lineBreakMode = NSLineBreakByWordWrapping;
        label_intro.textAlignment = NSTextAlignmentCenter;
        label_intro.text = pmodel.describe;
        [view_gray addSubview:label_intro];
        
        UIButton *btn_use = [[UIButton alloc] initWithFrame:CGRectMake(20, label_intro.frame.origin.y+label_intro.frame.size.height+10, view_gray.frame.size.width-2*20, 40)];
        [btn_use setBackgroundImage:[UIImage imageNamed:@"选择道具空按钮"] forState:UIControlStateNormal];
        if ([presentId isEqualToString:pmodel.presentId]) {
            [btn_use setTitle:@"取消选择" forState:UIControlStateNormal];
        }else{
            [btn_use setTitle:@"选择道具" forState:UIControlStateNormal];
        }
        btn_use.tag = 1000+i;
        [btn_use addTarget:self action:@selector(onClickChooseToolBtn:) forControlEvents:UIControlEventTouchUpInside];
        [btn_use setUserInteractionEnabled:YES];
        [view_gray addSubview:btn_use];
    }

}

-(void)showNoToolView{
    UIImageView *view_gray = [[UIImageView alloc] initWithFrame:CGRectMake(ScroolViewWidth/2-240/2 , 7.5,242, 300)];
    view_gray.image = [UIImage imageNamed:@"道具大卡片"];
    view_gray.tag = 2000;
    view_gray.userInteractionEnabled = YES;
    [scrollview_tool addSubview:view_gray];
    
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(view_gray.frame.size.width/2-120/2, 20+30+10, 120, 120)];
    image.tag = 3000;
//    [image setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kFFAPI,pmodel.photos]]];
    [image setImage:[UIImage imageNamed:@"暂无道具"]];
    [view_gray addSubview:image];
    
    UILabel *label_intro = [[UILabel alloc] initWithFrame:CGRectMake(10, image.frame.origin.y+image.frame.size.height+10, view_gray.frame.size.width -2*10, 18)];
    label_intro.numberOfLines = 0;
    //label_intro.backgroundColor = [UIColor yellowColor];
//    label_intro.lineBreakMode = NSLineBreakByWordWrapping;
    label_intro.font = [UIFont systemFontOfSize:18];
    label_intro.textAlignment = NSTextAlignmentCenter;
    label_intro.text = @"你还没有道具卡";
    [view_gray addSubview:label_intro];
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"~去商城兑换吧~"];
    [str addAttribute:NSForegroundColorAttributeName value:RGBColor(85, 164, 255) range:NSMakeRange(2,4)];
    
    UILabel *label_intro2 = [[UILabel alloc] initWithFrame:CGRectMake(10, label_intro.frame.origin.y+label_intro.frame.size.height, view_gray.frame.size.width -2*10, 30)];
    label_intro2.numberOfLines = 0;
    //label_intro.backgroundColor = [UIColor yellowColor];
    //    label_intro.lineBreakMode = NSLineBreakByWordWrapping;
    label_intro2.font = [UIFont systemFontOfSize:18];
    label_intro2.textAlignment = NSTextAlignmentCenter;
    label_intro2.attributedText = str;;
    label_intro2.userInteractionEnabled = YES;
    [view_gray addSubview:label_intro2];
    
    UITapGestureRecognizer *tapStore = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoStoreVC:)];
    [label_intro2 addGestureRecognizer:tapStore];

}

-(void)gotoStoreVC:(id)sender{
    FFStoreViewController *store = [[FFStoreViewController alloc] init];
    store.isFromCreateOrRoom = YES;
    [self.navigationController pushViewController:store animated:YES];
}

#pragma mark 匹配中界面
-(void)initSearchingBack{
    if (view_fight_black) {
        view_fight_black = nil;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setBtnSearching" object:nil];
    
    view_fight_black = [MyUtil viewWithAlpha:0.55];
    if ([isShowSearchingView isEqualToString:@"1"]) {
        view_fight_black.hidden = NO;
    }else{
        view_fight_black.hidden = YES;
    }
    
    view_fight_black.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backUp:)];
    [view_fight_black addGestureRecognizer:tap];
    [self.view addSubview:view_fight_black];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(15, 35, 40, 40)];
    [btn setTitle:@"返回" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [view_fight_black addSubview:btn];
    
    UIView *view_white = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 284, 383)];
    view_white.center = self.view.center;
    
    FFViewBorderRadius(view_white, 8, 1, [UIColor clearColor]);
    view_white.backgroundColor = [UIColor whiteColor];
    [view_fight_black addSubview:view_white];
    
    UIImageView *image_loading = [[UIImageView alloc] initWithFrame:CGRectMake(48*rate, 60*rate, 187, 187)];
    [image_loading setImage:[UIImage imageNamed:@"loading"]];
    image_loading.backgroundColor = [UIColor clearColor];
    [view_white addSubview:image_loading];
    
    UIButton *btn_cancel = [[UIButton alloc] initWithFrame:CGRectMake(view_white.frame.size.width/2-169/2, 317, 169, 44)];
    [btn_cancel setTitle:@"取消匹配" forState:UIControlStateNormal];
    FFViewBorderRadius(btn_cancel, 3, 1, RGBColor(71, 46, 40));
    [btn_cancel setBackgroundColor:kDefaultYellowColor];
    [btn_cancel setTitleColor:RGBColor(74, 74, 74) forState:UIControlStateNormal];
    [btn_cancel addTarget:self action:@selector(cancelSearching:) forControlEvents:UIControlEventTouchUpInside];
    [view_white addSubview:btn_cancel];
    
    UILabel *label_loading = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 17)];
    label_loading.center = image_loading.center;
    label_loading.textAlignment = NSTextAlignmentCenter;
    [label_loading setText:@"匹配结果中..."];
    label_loading.font = [UIFont systemFontOfSize:17];
    [label_loading setTextColor:RGBColor(74, 74, 74)];
    [view_white addSubview:label_loading];
    
    label_searchingTimeLeft = [[UILabel alloc] initWithFrame:CGRectMake(label_loading.frame.origin.x, label_loading.frame.origin.y+25, 98, 17)];
    [label_searchingTimeLeft setText:@""];//5s后自动隐藏
    label_searchingTimeLeft.textAlignment = NSTextAlignmentCenter;
    label_searchingTimeLeft.font = [UIFont systemFontOfSize:14];
    [label_searchingTimeLeft setTextColor:RGBColor(74, 74, 74)];
    [view_white addSubview:label_searchingTimeLeft];
    
        double durationValue = 10.0;
    [self startLoadingAnimationWithImage:image_loading];

}

-(void)hideSearchingBack{
    [view_fight_black removeFromSuperview];
    view_fight_black = nil;
}

-(void)startLoadingAnimationWithImage:(UIImageView *)imageView{
    double durationValue = 0.1;
//    [UIView animateWithDuration:durationValue animations:^{
//        
//        [imageView setTransform:CGAffineTransformMakeRotation(i*(M_PI / 180.0))]  ;
//        //            NSLog(@"%d",i);
//    } completion:^(BOOL finished){
//        i+=15;
//        [self startLoadingAnimationWithImage:imageView];
//    }];
    
    
    
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = 2.5;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 100;
    
    [imageView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    

}

#pragma mark-
#pragma mark NetWork Request

-(void)getHistoryFaceListsWithPage:(int)pageIndex{
    
    NSString *logId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"logId"]];
    NSString *token = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"token"]];
    NSString *userId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"userId"]];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:logId,@"logId",token,@"token",userId,@"userId",@"50",@"pageSize",[NSNumber numberWithInt:pageIndex_history],@"pageIndex",nil];
    
    loadView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [MyUtil requestPostURL:[NSString stringWithFormat:@"%@%@",kFFAPI,kFFAPI_FFHistoryFace] params:params success:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]] ) {
            [loadView hide:YES];
            NSString *error = [NSString stringWithFormat:@"%@",responseObject[@"error"]];
            [_collectionView headerEndRefreshing];
            if (error.integerValue==0) {
                //                NSString *msg = [NSString stringWithFormat:@"%@",responseObject[@"msg"]];
                //                ghostView.message = @"";
                //                [ghostView show];
                
                dataArray = [responseObject valueForKey:@"data"];
                [_collectionView reloadData];
                
            }else{
                ghostView.message = @"获取历史图片失败";
                [ghostView show];
            }
        }
    } failure:^(NSError *error) {
        [loadView hide:YES];
        ghostView.message = @"网络出现问题，请稍后重试";
        [ghostView show];
        
    }];
    
}

-(void)upLoadFaceWithImage:(UIImage *)image andFileName:(NSString *)fileName{

    NSString *logId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"logId"]];
    NSString *token = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"token"]];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:logId,@"logId",token,@"token",nil];
    NSString *url =[NSString stringWithFormat:@"%@%@",kFFAPI,kFFAPI_FFUploadFightFace];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];//初始化请求对象
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];//设置服务器允许的请求格式内容
    //对于图片进行压缩
    //NSData *data = UIImageJPEGRepresentation(image, 0.1);
    NSData *data = UIImagePNGRepresentation(image);
    
    [manager POST:url parameters:params constructingBodyWithBlock:^(id  _Nonnull formData) {
        
        //第一个代表文件转换后data数据，第二个代表和服务器商定的图片的字段，第三个代表图片放入文件夹的名字，第四个代表文件的类型
        [formData appendPartWithFileData:data name:@"fileData" fileName:fileName mimeType:@"image/jpg"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"uploadProgress = %@",uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject = %@, task = %@",responseObject,task);
        id obj = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSString *error = [NSString stringWithFormat:@"%@",obj[@"error"]];
            if (error.integerValue==0) {
                NSString *url = [[obj valueForKey:@"data"] valueForKey:@"avatar"];
                url_imageCurrent = url;//
                isNewUploadedPic = YES;
                [self getHistoryFaceListsWithPage:pageIndex_history];
                //                [self startFightWithImgUrl:url];//不包括api头部的url
            }else{
                
                [loadView hide:YES];
                ghostView.message = @"上传斗脸图片失败";
                [ghostView show];
            }
            
        }else{
            [loadView hide:YES];
            ghostView.message = @"上传斗脸图片失败";
            [ghostView show];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error = %@",error);
        [loadView hide:YES];
        ghostView.message = @"上传斗脸图片失败";
        [ghostView show];
        
    }];
    
}

//-(void)startFightWithImgUrl:(NSString *)imgUrl{
//    
//    NSString *logId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"logId"]];
//    NSString *token = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"token"]];
//    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:logId,@"logId",token,@"token",imgUrl,@"avatarUrl",presentId,@"presentId",tf_catchWord.text?tf_catchWord:@"",@"catchWord",nil];
//    //    [loadView showWhileExecuting:@selector(myProgressTask) onTarget:self withObject:nil animated:YES];
//    
//    [MyUtil requestPostURL:[NSString stringWithFormat:@"%@%@",kFFAPI,kFFAPI_FFStartFight] params:params success:^(id responseObject) {
//        if ([responseObject isKindOfClass:[NSDictionary class]] ) {
//            
//            NSString *error = [NSString stringWithFormat:@"%@",responseObject[@"error"]];
//            if (error.integerValue==2001) {
//                //                NSString *msg = [NSString stringWithFormat:@"%@",responseObject[@"msg"]];
//                //                ghostView.message = msg;
//                //                [ghostView show];
//                [self initTimer];
//                isShowSearchingView = @"0";
//                [mUserDefaults setValue:isShowSearchingView forKey:@"isShowSearchingView"];
//                view_fight_black.hidden = YES;
//                [loadView hide:YES];
//                ghostView.message = @"匹配成功";
//                [ghostView show];
//                NSDictionary *dataDic = responseObject;
//                
//                FFFightRoomViewController *r = [FFFightRoomViewController new];
//                r.responseDic = dataDic;
//                r.dataDic = [dataDic valueForKey:@"data"];
//                [self.navigationController pushViewController:r animated:YES];
//            }else if (error.integerValue==2002){
//                if (isSearching == YES) {
//                    [self startFightWithImgUrl:imgUrl];
//                }
//            }else if (error.integerValue==2003){
//                [loadView hide:YES];
//                //                ghostView.message = @"正在比赛";
//                //                [ghostView show];
//                
//                NSDictionary *dataDic = responseObject;
//                
//                isShowSearchingView = @"0";
//                [mUserDefaults setValue:isShowSearchingView forKey:@"isShowSearchingView"];
//                
//                FFFightRoomViewController *r = [FFFightRoomViewController new];
//                r.responseDic = dataDic;
//                r.dataDic = [dataDic valueForKey:@"data"];
//                [self.navigationController pushViewController:r animated:YES];
//            }else{
//                [self initTimer];
//                [loadView hide:YES];
//                
//                isShowSearchingView = @"0";
//                [mUserDefaults setValue:isShowSearchingView forKey:@"isShowSearchingView"];
//                
//                view_fight_black.hidden = YES;
//                ghostView.message = @"匹配失败";
//                [ghostView show];
//            }
//        }
//    } failure:^(NSError *error) {
//        [loadView hide:YES];
//        ghostView.message = @"匹配失败，请稍后重试";
//        [ghostView show];
//        
//    }];
//    
//}

//取消匹配
-(void)cancelFight{

    NSString *logId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"logId"]];
    NSString *token = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"token"]];
    //    NSString *userId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"userId"]];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:logId,@"logId",token,@"token",nil];
    
    //    loadView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [MyUtil requestPostURL:[NSString stringWithFormat:@"%@%@",kFFAPI,kFFAPI_FFCancelFight] params:params success:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]] ) {
            NSString *error = [NSString stringWithFormat:@"%@",responseObject[@"error"]];
            if (error.integerValue==2004) {
            //取消成功
                view_fight_black.hidden = YES;
                [self initTimer];
                isSearching = NO;
                isShowSearchingView = @"0";
                [mUserDefaults setValue:isShowSearchingView forKey:@"isShowSearchingView"];
                view_fight_black.hidden = YES;
//                [[FFNotificationCenter defaultManager] cancelFight];
            }else{
                ghostView.message = @"取消匹配失败";
                [ghostView show];
            }
        }
    } failure:^(NSError *error) {
        [loadView hide:YES];
        ghostView.message = @"网络出现问题，请稍后重试";
        [ghostView show];
        
    }];
}

//重新拉去道具
-(void)requestCheckFight{

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
                            _arrayPresents = [dataDic valueForKey:@"userPresents"];
                        }
                    }
                }
            }else{
                
            }
        }
    } failure:^(NSError *error) {

        
    }];
    
}


#pragma mark-
#pragma mark User Interactions

-(void)backUp:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)onClickRightBtn:(UIButton *)sender{
    [self startFightBtnClicked];
}

-(void)hideRuleView{
    view_black_rule.hidden = YES;
}

-(void)hideToolView{
    view_black.hidden = YES;
    scrollview_tool.hidden = YES;
}

-(void)startFightBtnClicked{
    if (!url_imageCurrent) {
        ghostView.message = @"请先选一张图片";
        [ghostView show];
        return;
    }
 
    [[FFNotificationCenter defaultManager] setIsSearching:YES];
    [[FFNotificationCenter defaultManager] startFightWithImageUrl:url_imageCurrent catchWord:catchWord presentId:presentId];
    isShowSearchingView = @"1";
    [mUserDefaults setValue:@"1" forKey:@"isShowSearchingView"];
    [self initTimer];
    timerWait = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timeInLine) userInfo:nil repeats:YES];
//    [self startFightWithImgUrl:url_imageCurrent];
    [self initSearchingBack];
    
}

-(void)onClickChooseToolBtn:(UIButton *)sender{
    long int tag = sender.tag -1000;
    FFPresentOuterModel *pmodel_outer = [FFPresentOuterModel modelWithDictionary:_arrayPresents[sender.tag-1000]];
    FFPresentListModel *pmodel = pmodel_outer.present;
    if ([presentId isEqualToString:pmodel.presentId]) {
        presentId = @"0";
        UIButton *tempBtn = (UIButton *)[[scrollview_tool viewWithTag:2000+tag] viewWithTag:1000+tag];
        [tempBtn setTitle:@"选择道具" forState:UIControlStateNormal];
//        UIImageView *tempImageV = (UIImageView *)[[scrollview_tool viewWithTag:2000+tag] viewWithTag:3000+tag];
        [btn_choosePresend setImage:[UIImage imageNamed:@"空道具"] forState:UIControlStateNormal];
    }else{
        presentId = pmodel.presentId;
        UIButton *tempBtn = (UIButton *)[[scrollview_tool viewWithTag:2000+tag] viewWithTag:1000+tag];
        [tempBtn setTitle:@"取消选择" forState:UIControlStateNormal];
        UIImageView *tempImageV = (UIImageView *)[[scrollview_tool viewWithTag:2000+tag] viewWithTag:3000+tag];
        [btn_choosePresend setImage:tempImageV.image forState:UIControlStateNormal];

    }
    
    [self hideToolView];
}

-(void)onClickAddToolBtn:(UIButton *)sender{
    if (!_arrayPresents||_arrayPresents.count==0) {
        ghostView.message = @"当前没有可使用的道具";
        [ghostView show];
        return;
    }
    
    if (view_black.hidden) {
        view_black.hidden = NO;
        
        if(_arrayPresents.count >=1){
            btn_goRight.hidden = NO;
        }
        [self showScroolView];
        scrollview_tool.hidden = NO;
    }else{
        view_black.hidden = YES;
        scrollview_tool.hidden = YES;
    }
}

//道具scroolview翻页
-(void)goLeftOrRight:(UIButton *)sender{
    switch (sender.tag) {
        case 1:
        {
            CGPoint point = CGPointMake(scrollview_tool.contentOffset.x-scrollview_tool.frame.size.width, scrollview_tool.contentOffset.y);
            [scrollview_tool setContentOffset:point animated:true];
        }
            break;
        case 2:
        {
            CGPoint point = CGPointMake(scrollview_tool.contentOffset.x+scrollview_tool.frame.size.width, scrollview_tool.contentOffset.y);
            [scrollview_tool setContentOffset:point animated:true];
        }
            break;
            
        default:
            break;
    }
    
    CGFloat pageWidth = scrollview_tool.frame.size.width;
    int page = floor((scrollview_tool.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    NSLog(@"Image: %d",page) ;
    
    if(page-1 == 0){
        btn_goLeft.hidden = YES;
        btn_goRight.hidden = NO;
    }else if (page+1 == _arrayPresents.count-1){
        btn_goLeft.hidden = NO;
        btn_goRight.hidden = YES;
    }else{
        btn_goLeft.hidden = NO;
        btn_goRight.hidden = NO;
    }
    
}

//取消匹配
-(void)cancelSearching:(UIButton *)sender{
    [[FFNotificationCenter defaultManager] cancelFight];
//    [self cancelFight];
}

//接收到匹配成功的通知
-(void)onReceiveSearchingFightSucceedNoti:(NSNotification *)noti{
    [self initTimer];
    [self hideSearchingBack];
}

#pragma mark -
#pragma mark <UIScrollViewDelegate>
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {

}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {

}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = 290;
    
    //初始为第一页
//
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    CGFloat pageWidth = scrollview_tool.frame.size.width;
    int page = floor((scrollview_tool.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    NSLog(@"Image: %d",page) ;
    
    if(page == 0){
        btn_goLeft.hidden = YES;
        btn_goRight.hidden = NO;
    }else if (page == _arrayPresents.count-1){
        btn_goLeft.hidden = NO;
        btn_goRight.hidden = YES;
    }else{
        btn_goLeft.hidden = NO;
        btn_goRight.hidden = NO;
    }
    
}

#pragma mark -
#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return dataArray.count+1;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identify = @"cell";
    FFFaceHistoryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identify forIndexPath:indexPath];
    cell.delegate = self;
    cell.indexPath = indexPath;
    if (indexPath.item==0) {
//        [cell.imageBack setImageWithURL:nil];
//        [cell.imageBack setBackgroundColor:[UIColor grayColor]];
        [cell.imageBack setImage:[UIImage imageNamed:@"btn_camera"]];
        cell.btnTag.hidden = YES;
        [cell.imageBack setUserInteractionEnabled:NO];
        return cell;
    }else{
        NSDictionary *dic = dataArray[indexPath.item-1];
        [cell.imageBack setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kFFAPI,[dic valueForKey:@"avatar"]]] placeholderImage:[UIImage imageNamed:@"比赛图片占位"]];
        if (url_imageCurrent) {
            if ([url_imageCurrent isEqualToString:[dic valueForKey:@"avatar"]]) {
                cell.btnTag.selected = YES;
                chosenIndexPath = [NSIndexPath indexPathForItem:1 inSection:0];
            }
        }
        [cell sizeToFit];
        cell.btnTag.hidden = NO;
        [cell.imageBack setUserInteractionEnabled:YES];
    }

    return cell;
}



- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"row%ld,item%ld",(long)indexPath.row,(long)indexPath.item);
    
    if (indexPath.item == 0) {
        if (chosenIndexPath) {
            FFFaceHistoryCell *cell = (FFFaceHistoryCell *)[_collectionView cellForItemAtIndexPath:chosenIndexPath];
            [cell.btnTag setSelected:NO];
        }
        
        UIAlertController *sheetController = [UIAlertController alertControllerWithTitle:@"上传照片" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            NSLog(@"相册");
            imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.delegate = self;
            imagePickerController.allowsEditing = YES;
            imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            
            [self presentViewController:imagePickerController animated:YES completion:^{}];
            
        }];
        
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            NSLog(@"相机");
            imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.delegate = self;
            imagePickerController.allowsEditing = YES;
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            
            [self presentViewController:imagePickerController animated:YES completion:^{}];
            
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        
        [sheetController addAction:saveAction];
        
        [sheetController addAction:deleteAction];
        
        [sheetController addAction:cancelAction];
        
        [self presentViewController:sheetController animated:YES completion:nil];
    }
//    NSDictionary *dic = dataArray[indexPath.item];

    
}


-(void) myProgressTask{
    float progress = 0.0f;
    while (progress < 100.0f) {
        progress += 0.01f;
        loadView.progress = progress;
        usleep(50000);
    }
}

- (void)magnifyImage:(UITapGestureRecognizer*)tap
{
    UIImageView *imageView=(UIImageView*)tap.view;
    if (imageView.image==nil) {
        return;
    }
    NSLog(@"局部放大");
    [SJAvatarBrowser showImage:imageView];//调用方法
}






- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    chosenIndexPath = nil;
    
    imageCurrent = [info objectForKey:UIImagePickerControllerEditedImage];//得到当前的image
    btnStart.backgroundColor = [UIColor orangeColor];
    [btnStart setEnabled:YES];

    NSIndexPath *first_indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    FFFaceHistoryCell *cell = (FFFaceHistoryCell *)[_collectionView cellForItemAtIndexPath:first_indexPath];
    [cell.imageBack setImage:imageCurrent];
    
    NSString *fileName = nil;//代表图片放入文件夹中的名字 一般是拿到当前时间作为参数
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    fileName = [[NSString alloc]initWithFormat:@"%@.jpg",[formatter stringFromDate:[NSDate date]]];
    if (imagePickerController.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImageWriteToSavedPhotosAlbum(leftImgV.image,self, @selector(image:didFinishSavingWithError:contextInfo:),nil);
    }
    
    //压缩图片至<=60k
    imageCurrent = [MyUtil zipImage:imageCurrent];
    
    [self upLoadFaceWithImage:imageCurrent andFileName:fileName];

    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

//拍照保存到相册失败
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)info
{
    NSLog(@"error------------------------%@",error);
}

//定时器方法，1s
-(void)timeInLine{
    label_searchingTimeLeft.text = [NSString stringWithFormat:@"%ds后自动隐藏",timeInLine--];
    if (timeInLine == 0) {
        [timerWait invalidate];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

//初始化定时器
-(void)initTimer{
    timeInLine = 5;
    [timerWait invalidate];
}

#pragma mark- 
#pragma mark <UITableViewDelegate>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _arrayPresents.count;
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
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        //背景
        UIImageView *imgBack = [[UIImageView alloc]initWithImage:[[UIImage imageNamed:@"hr_circle_item"] stretchableImageWithLeftCapWidth:30 topCapHeight:14]];
        imgBack.backgroundColor = mRGBToColor(0xf9f9f9);
        [imgBack setFrame:CGRectMake(0, 0, SCREEN_WIDTH, FFTableCellHeight-5)];
        //        imgV.tag = 13001;
        [cell addSubview:imgBack];
        //
        //        UIImageView *imgVS = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"vs"]];
        //        [imgVS setFrame:CGRectMake((SCREEN_WIDTH-65)/2, 35, 70, 77)];
        ////        imgVS.center = cell.center;
        //        [cell addSubview:imgVS];
        
        //斗图左
        UIImageView *imgV = [[UIImageView alloc]initWithImage:[[UIImage imageNamed:@"hr_circle_item"] stretchableImageWithLeftCapWidth:30 topCapHeight:14]];
//        imgV.backgroundColor = [UIColor blueColor];
        [imgV setContentMode:UIViewContentModeScaleAspectFill];
        [imgV setFrame:CGRectMake(10, 10, FFTableCellPicSize, FFTableCellPicSize)];
        imgV.tag = 13001;
        [imgV setUserInteractionEnabled:YES];
        [cell addSubview:imgV];
        
        //添加点击查看大图
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(magnifyImage:)];
        [imgV addGestureRecognizer:tap];
        
        
        //名称
        UILabel *nameLabel = [self createLabelWithFrame:CGRectMake(15+FFTableCellPicSize +15, 15, SCREEN_WIDTH-15*3-FFTableCellPicSize, 20) textAlignment:NSTextAlignmentLeft fontSize:18 textColor:mRGBToColor(0x5c5c5c) numberOfLines:0 text:nil];
        [nameLabel setFont:[UIFont boldSystemFontOfSize:15]];
        nameLabel.tag = 14001;
        [cell addSubview:nameLabel];
        //价格
        UILabel *priceLabel = [self createLabelWithFrame:CGRectMake(FFTableCellPicSize+15*2,35, 80, 25) textAlignment:NSTextAlignmentLeft fontSize:18 textColor:mRGBToColor(0x5c5c5c) numberOfLines:0 text:nil];
        [priceLabel setFont:[UIFont boldSystemFontOfSize:19]];
        priceLabel.tag = 14002;
        [cell addSubview:priceLabel];
        
        
    }
    
    NSDictionary *dic = _arrayPresents[indexPath.row];
    FFPresentOuterModel *ffpoModel = [FFPresentOuterModel modelWithDictionary:dic];
    FFPresentListModel *pModel = ffpoModel.present;
    
    UILabel *nameTempLabel = (UILabel *)[cell viewWithTag:14001];
    [nameTempLabel setText:pModel.name];
    
    UILabel *priceTempLabel = (UILabel *)[cell viewWithTag:14002];
    [priceTempLabel setText:pModel.price]; 
    
    UIImageView *imgV = (UIImageView *)[cell viewWithTag:13001];
    NSString *imgurlV = kConJoinURL(kFFAPI, pModel.photos);
    [imgV setImageWithURL:[NSURL URLWithString:imgurlV] placeholderImage:nil];
    //
    return cell;

    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic = _arrayPresents[indexPath.row];
    FFPresentOuterModel *ffpoModel = [FFPresentOuterModel modelWithDictionary:dic];
    if (presentId == ffpoModel.presentId) {
        [[_tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
        presentId = @"0";
    }else{
        presentId = ffpoModel.presentId;
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

#pragma mark- FFFaceHistoryCellDelegate

-(void)setChosenDataWithIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic = dataArray[indexPath.item-1];

    if (chosenIndexPath) {
        if (chosenIndexPath == indexPath) {
            FFFaceHistoryCell *cell = (FFFaceHistoryCell *)[_collectionView cellForItemAtIndexPath:chosenIndexPath];
            if (cell.btnTag.selected) {
                [cell.btnTag setSelected:NO];
                 url_imageCurrent = nil;
                chosenIndexPath = nil;
            }else{
                [cell.btnTag setSelected:YES];
                url_imageCurrent = [dic valueForKey:@"avatar"];
            }
        }else{
            FFFaceHistoryCell *cell = (FFFaceHistoryCell *)[_collectionView cellForItemAtIndexPath:chosenIndexPath];
            [cell.btnTag setSelected:NO];
            FFFaceHistoryCell *cellChosen = (FFFaceHistoryCell *)[_collectionView cellForItemAtIndexPath:indexPath];
            [cellChosen.btnTag setSelected:YES];
            url_imageCurrent = [dic valueForKey:@"avatar"];
        }
    }else{
        FFFaceHistoryCell *cellChosen = (FFFaceHistoryCell *)[_collectionView cellForItemAtIndexPath:indexPath];
        [cellChosen.btnTag setSelected:YES];
        url_imageCurrent = [dic valueForKey:@"avatar"];
    }
     chosenIndexPath = indexPath;
}

#pragma mark- 
#pragma mark- FFNotificationCenter



@end
