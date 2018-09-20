//
//  FFFightRoomViewController.m
//  doulian
//
//  Created by Suny on 16/8/31.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import "FFFightRoomViewController.h"

#import "FFListModel.h"
#import "FFListFightUserModel.h"
#import "FFListFUDetailUserModel.h"

#import "FFWirteCommentsViewController.h"
#import "FFAskForHelpViewController.h"//求帮列表 传一个fightid

#import "FFCommentModel.h"

#import "MainTouchTableTableView.h"
#import "MYSegmentView.h"

#import "FFRoomCommentsViewController.h"
#import "FFInFightRecordViewController.h"
#import "FFInFightPresentsViewController.h"

#import "YSProgressView.h"

#import "RootViewController.h"
#import "FFPersonalDetailVC.h"

#import "FFCreateRoomViewController.h"

#import "FFShowFightScoreModel.h"

#import <UMSocialCore/UMSocialCore.h>
#import "UMSocialUIManager.h"

#import "FFShareModel.h"

#import "FFTimerManager.h"

#define FFTableCellHeight 50

#define Main_Screen_Height      [[UIScreen mainScreen] bounds].size.height
#define Main_Screen_Width       [[UIScreen mainScreen] bounds].size.width
#define ImageWidth (SCREEN_WIDTH-4*InnerSpace)/2
#define TitleStr @"斗脸房间"
static CGFloat headViewHeight = 364;



CGFloat presentBackViewHeight = 370+44;


static CGFloat const InnerSpace = 8;
//static CGFloat const ImageWidth = (SCREEN_WIDTH-4*InnerSpace)/2;

static CGFloat const cupImageHeight = 30;
static CGFloat const cupImageWidth = 20;

static CGFloat timeLabelWidth = 95;
static CGFloat timeLabelHeight = 32;

static CGFloat  btnVoteWidth = 100;
static CGFloat  btnVoteHeight = 32;


@interface FFFightRoomViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic ,strong)MainTouchTableTableView * mainTableView;
@property (nonatomic, strong) MYSegmentView * RCSegView;
@property(nonatomic,strong)UIImageView *headImageView;//头部图片
@property(nonatomic,strong)UIImageView * avatarImage;
@property(nonatomic,strong)UILabel *countentLabel;

@property(nonatomic,strong) UILabel *label_winloseLeft;
@property(nonatomic,strong) UILabel *label_winloseRight;

@property(nonatomic,strong) YSProgressView *line_winlose_left;
@property(nonatomic,strong) YSProgressView *line_winlose_right;

@property(nonatomic,strong) UILabel *label_timeLeft;

@property(nonatomic,strong) UIImageView *image_end;//已结束

@property(nonatomic,strong) UIImageView *image_left;
@property(nonatomic,strong) UIImageView *image_right;

@property(nonatomic,strong) UILabel *label_scoreLeft;
@property(nonatomic,strong) UILabel *label_scoreRight;

@property(nonatomic,strong) YSProgressView *line_score;

@property(nonatomic,strong) UIButton *btn_voteLeft;
@property(nonatomic,strong) UIButton *btn_voteRight;

@property (nonatomic, assign) BOOL canScrollHere;
@property (nonatomic, assign) BOOL isTopIsCanNotMoveTabView;
@property (nonatomic, assign) BOOL isTopIsCanNotMoveTabViewPre;

@end


@implementation FFFightRoomViewController
{
    OLGhostAlertView *ghostView;
    
    OLGhostAlertView *ghostView_Image;
    
    MBProgressHUD *loadView;
    int pageIndex;
    NSMutableArray *dataArray;
    
    NSMutableArray *commentArray;
    
    UIImageView *leftImgV;
    
    UIImageView *rightImgV;
    
    UIImagePickerController *imagePickerController;
    
    UIImage *imageCurrent;
    
    UIButton *btnStart;
    
    BOOL isSearching;//正在搜寻匹配
    
    FFListModel *roomModel;
    FFListFightUserModel *fightUserModelLeft;
    FFListFUDetailUserModel *userDetailModelLeft;
    FFListFightUserModel *fightUserModelRight;
    FFListFUDetailUserModel *userDetailModelRight;
    
    NSString *comment;
    
    UIButton *btn_AddFriendLeft;
    UIButton *btn_AddFriendRight;
    UIButton *btn_VoteLeft;
    UIButton *btn_VoteRight;
    
    UILabel *score_left;
    UILabel *score_right;
    UILabel *timeLeft;
    
    NSTimer *timerWait;
    long int timeInLine;
    NSString *str_timeRemainFromModel;
    
    UIView *view_present_back;//使用道具黑色背景
    
    NSString *presentId_current;
    
    UIView *view_user_back;//用户展示黑色背景
    
    UIView *moreView;
    
    UIView *moreView_back;//
    
    CGFloat rate;
    
    NSString *scoreByVote;//投票成功获得的积分，由投票接口返回
    
    UIImageView *shareImage;
    
    NSMutableArray *scoreArray;//获得的积分array
    
    UIScrollView *scrollView_user;
    
    CGFloat headViewWithNoVoteBtnHeight;//隐藏投票按钮的头部高度
    
    BOOL isShowUserVoteBtn;//是否显示点击斗图弹出的用户介绍里的投票按钮
}

@synthesize mainTableView;

-(void)viewWillDisappear:(BOOL)animated{
    NSLog(@"room viewWillDisappear");
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(postRefreshNotification) object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FightRoomAutoRefreshData" object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    NSLog(@"room viewWillAppear");
    [self requestData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestData) name:@"FightRoomAutoRefreshData" object:nil];
}

-(void)viewDidLoad{
    NSLog(@"room viewDidLoad");
    [super viewDidLoad];
    [self addBackBtn];
    [self addHeadViewLine];
    [self addTitleLabel:TitleStr];
    ghostView = [[OLGhostAlertView alloc] initWithTitle:nil message:nil timeout:0.6 dismissible:YES];
    ghostView.position = OLGhostAlertViewPositionCenter;
    
    ghostView_Image = [[OLGhostAlertView alloc] initWithFrame:CGRectZero ImageName:@"toast_back"];
    ghostView_Image.position = OLGhostAlertViewPositionCenter;
//    ghostView_Image.title = @"厉害了我滴个";
//    ghostView_Image.timeout = 1.5;
//    [ghostView_Image showWithAnimation];
    
    scoreByVote = @"0";
    [self addRightBtnwithImgName:nil Title:@"更多"];
    rate = 1;
    if (isiPhoneBelow5s) {
        rate = 320.0/375.0;
        btnVoteWidth = 72;
        btnVoteHeight = 30;
        headViewHeight = 304;
        timeLabelWidth = 78;
        timeLabelHeight = 24;
        presentBackViewHeight = 370;
    }else if (isiPhoneUpper6plus){
        rate = 414.0/375.0;
        headViewHeight = 374;
        presentBackViewHeight = 374+64;
        timeLabelWidth = 120;
        timeLabelHeight = 33;
    }
    
    pageIndex = 0;
    
    [self.view addSubview:self.mainTableView];
    [self.mainTableView addSubview:self.headImageView];
    [mainTableView sendSubviewToBack:_headImageView];
    [self initData];
    [self refreshHeaderData];
    /*
     *
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsg:) name:@"leaveTop" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetContentInset:) name:@"resetContentInset" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChooseSegVC:) name:@"SelectVC" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setCommentsCount:) name:@"setlabelNumber" object:nil];
    
    [self getShareInfo];
    
}

-(void)initData{
    roomModel = [FFListModel modelWithDictionary:_dataDic];
    fightUserModelLeft = [FFListFightUserModel modelWithDictionary:roomModel.fightUsers[0]];
    fightUserModelRight = [FFListFightUserModel modelWithDictionary:roomModel.fightUsers[1]];
    userDetailModelLeft =fightUserModelLeft.user;
    userDetailModelRight =fightUserModelRight.user;
    NSString *userId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"userId"]];
    if ([userId isEqualToString:fightUserModelLeft.userId]||[userId isEqualToString:fightUserModelRight.userId]) {
        if (roomModel.remainingTime>0) {
            _isShowRoomScore = YES;
        }else{
            _isShowRoomScore = NO;
        }
    }else{
        _isShowRoomScore = NO;
    }
    if ([roomModel.remainingTime longLongValue]<=0) {
        headViewWithNoVoteBtnHeight = headViewHeight - rate*32*2;
        
    }else{
        headViewWithNoVoteBtnHeight = headViewHeight;
    }

}

-(UIImageView *)headImageView
{
    if (_headImageView == nil)
    {
        _headImageView= [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bg.jpg"]];
        _headImageView.frame=CGRectMake(0, -headViewHeight ,Main_Screen_Width,headViewHeight);
        _headImageView.userInteractionEnabled = YES;
        
        UIView *view_backWhite = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Main_Screen_Width, headViewHeight-10)];
        view_backWhite.backgroundColor = [UIColor whiteColor];
        [_headImageView addSubview:view_backWhite];
        
        UIImageView *image_cupLeft = [[UIImageView alloc] initWithFrame:CGRectMake(InnerSpace, InnerSpace, cupImageWidth, cupImageHeight)];
        image_cupLeft.image = [UIImage imageNamed:@"img_winlose"];
        [view_backWhite addSubview:image_cupLeft];
        
        UIImageView *image_cupRight = [[UIImageView alloc] initWithFrame:CGRectMake(Main_Screen_Width-cupImageWidth-InnerSpace, InnerSpace, cupImageWidth, cupImageHeight)];
        image_cupRight.image = [UIImage imageNamed:@"img_winlose"];
        [view_backWhite addSubview:image_cupRight];
        //左边胜负场
        _label_winloseLeft= [[UILabel alloc] initWithFrame:CGRectMake(cupImageWidth+2*InnerSpace, InnerSpace, 100*rate, 16)];
        _label_winloseLeft.text = @"胜512 - 负11";
        _label_winloseLeft.font = [UIFont systemFontOfSize:13];
        [view_backWhite addSubview:_label_winloseLeft];
        
        //右边胜负场
        _label_winloseRight= [[UILabel alloc] initWithFrame:CGRectMake(Main_Screen_Width-cupImageWidth-2*InnerSpace-100*rate, InnerSpace, 100*rate, 16)];
        _label_winloseRight.text = @"胜512 - 负11";
        _label_winloseRight.font = [UIFont systemFontOfSize:13];
        _label_winloseRight.textAlignment = NSTextAlignmentRight;
        [view_backWhite addSubview:_label_winloseRight];
        
        //左边胜负比例条
        _line_winlose_left = [[YSProgressView alloc] initWithFrame:CGRectMake(cupImageWidth+2*InnerSpace, _label_winloseLeft.frame.origin.y+CGRectGetHeight(_label_winloseLeft.frame)+InnerSpace*1, 100, 4)];
        //        [_line_score setBackgroundColor:[UIColor yellowColor]];
        _line_winlose_left.progressTintColor = RGBColor(59, 87, 137);
        _line_winlose_left.trackTintColor = RGBColor(92, 203, 242);
        [view_backWhite addSubview:_line_winlose_left];
        
        //右边胜负比例条
        _line_winlose_right = [[YSProgressView alloc] initWithFrame:CGRectMake(Main_Screen_Width-cupImageWidth-2*InnerSpace-100, _label_winloseLeft.frame.origin.y+CGRectGetHeight(_label_winloseLeft.frame)+InnerSpace*1, 100, 4)];
        //        [_line_score setBackgroundColor:[UIColor yellowColor]];
        _line_winlose_right.progressTintColor = RGBColor(59, 87, 137);
        _line_winlose_right.trackTintColor = RGBColor(92, 203, 242);
        [view_backWhite addSubview:_line_winlose_right];
        
        //剩余时间（倒计时）
        _label_timeLeft= [[UILabel alloc] initWithFrame:CGRectMake(Main_Screen_Width/2-timeLabelWidth/2, 5, timeLabelWidth, timeLabelHeight)];
        //        _label_timeLeft.text = @" 04' 45\"";
        _label_timeLeft.font = [UIFont systemFontOfSize:20];
        if (isiPhoneBelow5s) {
            _label_timeLeft.font = [UIFont systemFontOfSize:18];
        }else if(isiPhoneUpper6plus){
            _label_timeLeft.font = [UIFont systemFontOfSize:25];
        }
        FFViewBorderRadius(_label_timeLeft, 5, 1, [UIColor clearColor]);
        _label_timeLeft.backgroundColor = RGBColor(251, 226, 84);
        _label_timeLeft.textColor = RGBColor(74, 74, 74);
        _label_timeLeft.textAlignment = NSTextAlignmentCenter;
        [view_backWhite addSubview:_label_timeLeft];
        
        UIView *view_line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, timeLabelHeight-10)];
        view_line.backgroundColor = RGBColor(142, 74, 21);
        view_line.center = _label_timeLeft.center;
        [_label_timeLeft addSubview:view_line];
        
        _image_end = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 55*rate, 43*rate)];
        _image_end.image = [UIImage imageNamed:@"已结束"];
        _image_end.center = _label_timeLeft.center;
        _image_end.hidden = YES;
        [view_backWhite addSubview:_image_end];
        
        //左边斗脸图
        _image_left = [[UIImageView alloc] initWithFrame:CGRectMake(InnerSpace, cupImageHeight+2*InnerSpace, ImageWidth, ImageWidth)];
        _image_left.tag = 2000;
        [_image_left setContentMode:UIViewContentModeScaleAspectFill];
        _image_left.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapBack = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickUserPhoto:)];
        [_image_left addGestureRecognizer:tapBack];
        _image_left.backgroundColor = [UIColor redColor];
        FFViewBorderRadius(_image_left, 4, 1, [UIColor whiteColor]);
        [view_backWhite addSubview:_image_left];
        
        //右边斗脸图
        _image_right = [[UIImageView alloc] initWithFrame:CGRectMake(Main_Screen_Width-ImageWidth-InnerSpace, cupImageHeight+2*InnerSpace, ImageWidth, ImageWidth)];
        _image_right.tag = 2001;
        [_image_right setContentMode:UIViewContentModeScaleAspectFill];
        _image_right.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapBack2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickUserPhoto:)];
        [_image_right addGestureRecognizer:tapBack2];
        _image_right.backgroundColor = [UIColor redColor];
        FFViewBorderRadius(_image_right, 4, 1, [UIColor whiteColor]);
        [view_backWhite addSubview:_image_right];
        
        
        //左边分数
        _label_scoreLeft= [[UILabel alloc] initWithFrame:CGRectMake(0, _image_left.frame.origin.y+CGRectGetHeight(_image_left.frame)+InnerSpace*2, Main_Screen_Width/2 , 25)];
        if (isiPhoneBelow5s) {
            [_label_scoreLeft setFrame:CGRectMake(0, _image_left.frame.origin.y+CGRectGetHeight(_image_left.frame)+InnerSpace*1, Main_Screen_Width/2 , 25)];
        }else if(isiPhoneUpper6plus){
            [_label_scoreLeft setFrame:CGRectMake(0, _image_left.frame.origin.y+CGRectGetHeight(_image_left.frame)+InnerSpace*2, Main_Screen_Width/2 , 25)];
        }
        _label_scoreLeft.textColor = RGBColor(56, 56, 21);
        _label_scoreLeft.font = [UIFont systemFontOfSize:20];
        _label_scoreLeft.textAlignment = NSTextAlignmentCenter;
        [view_backWhite addSubview:_label_scoreLeft];
        
        
        //右边分数
        _label_scoreRight= [[UILabel alloc] initWithFrame:CGRectMake(Main_Screen_Width/2, _image_left.frame.origin.y+CGRectGetHeight(_image_left.frame)+InnerSpace*1*2, Main_Screen_Width/2, 25)];
        if (isiPhoneBelow5s) {
            [_label_scoreRight setFrame:CGRectMake(Main_Screen_Width/2, _image_left.frame.origin.y+CGRectGetHeight(_image_left.frame)+InnerSpace*1, Main_Screen_Width/2, 25)];
        }else if(isiPhoneUpper6plus){
            [_label_scoreRight setFrame:CGRectMake(Main_Screen_Width/2, _image_left.frame.origin.y+CGRectGetHeight(_image_left.frame)+InnerSpace*1*2, Main_Screen_Width/2, 25)];
        }
        //        _label_scoreRight.text = @"50票";
        _label_scoreRight.textColor = RGBColor(56, 56, 21);
        _label_scoreRight.font = [UIFont systemFontOfSize:20];
        _label_scoreRight.textAlignment = NSTextAlignmentCenter;
        [view_backWhite addSubview:_label_scoreRight];
        
        UIImageView *image_vs = [[UIImageView alloc] initWithFrame:CGRectMake(Main_Screen_Width/2 - 20, cupImageHeight+ImageWidth+2*InnerSpace-20, 40, 40)];
        image_vs.image = [UIImage imageNamed:@"vs"];
        [view_backWhite addSubview:image_vs];
        
        //分数比例条
        _line_score = [[YSProgressView alloc] initWithFrame:CGRectMake(InnerSpace, _label_scoreLeft.frame.origin.y+CGRectGetHeight(_label_scoreLeft.frame)+InnerSpace*2, Main_Screen_Width-2*InnerSpace, 8)];
        if (isiPhoneBelow5s) {
            [_line_score setFrame:CGRectMake(InnerSpace, _label_scoreLeft.frame.origin.y+CGRectGetHeight(_label_scoreLeft.frame)+InnerSpace*1, Main_Screen_Width-2*InnerSpace, 8)];
        }else if(isiPhoneUpper6plus){
            [_line_score setFrame:CGRectMake(InnerSpace, _label_scoreLeft.frame.origin.y+CGRectGetHeight(_label_scoreLeft.frame)+InnerSpace*2, Main_Screen_Width-2*InnerSpace, 8)];
        }
        //        [_line_score setBackgroundColor:[UIColor yellowColor]];
        _line_score.progressTintColor = RGBColor(241, 228, 46);
        _line_score.trackTintColor = RGBColor(92, 203, 242);
        [view_backWhite addSubview:_line_score];
        [view_backWhite sendSubviewToBack:_line_score];
        
        _btn_voteLeft = [[UIButton alloc] initWithFrame:CGRectMake(InnerSpace, _line_score.frame.origin.y+CGRectGetHeight(_line_score.frame)+InnerSpace*2.5, btnVoteWidth, btnVoteHeight)];
        _btn_voteLeft.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 60);
        if (isiPhoneBelow5s) {
            [_btn_voteLeft setFrame:CGRectMake(InnerSpace, _line_score.frame.origin.y+CGRectGetHeight(_line_score.frame)+InnerSpace*1.5, btnVoteWidth, btnVoteHeight)];
            _btn_voteLeft.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 60);
        }else if(isiPhoneUpper6plus){
            [_btn_voteLeft setFrame:CGRectMake(InnerSpace, _line_score.frame.origin.y+CGRectGetHeight(_line_score.frame)+InnerSpace*2, btnVoteWidth, btnVoteHeight)];
        }
        [_btn_voteLeft setBackgroundImage:[UIImage imageNamed:@"btn_vote_left"] forState:UIControlStateNormal];
        _btn_voteLeft.tag = 1001;
        [_btn_voteLeft setTitleColor:RGBColor(74, 74, 74) forState:UIControlStateNormal];
        //button图片的偏移量，距上左下右分别(10, 10, 10, 60)像素点
        [_btn_voteLeft setImage:[UIImage imageNamed:@"投票左"] forState:UIControlStateNormal];
        
        //button标题的偏移量，这个偏移量是相对于图片的
        _btn_voteLeft.titleEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
        _btn_voteLeft.imageEdgeInsets = UIEdgeInsetsMake(6, 10, 6, 60);
        if (isiPhoneBelow5s) {
            [_btn_voteLeft.titleLabel setFont:[UIFont systemFontOfSize:13]];
            _btn_voteLeft.titleEdgeInsets = UIEdgeInsetsMake(0, -6, 0, 0);
            _btn_voteLeft.imageEdgeInsets = UIEdgeInsetsMake(6, 6, 6, 36);
        }else if(isiPhoneUpper6plus){
            _btn_voteLeft.imageEdgeInsets = UIEdgeInsetsMake(6, 6, 6, 52);
        }
        if (fightUserModelLeft.voted) {
            [_btn_voteLeft setTitle:@"已投票" forState:UIControlStateNormal];
            [_btn_voteLeft setEnabled:NO];
        }else{
            [_btn_voteLeft setTitle:@"投票" forState:UIControlStateNormal];
            [_btn_voteLeft setEnabled:YES];
        }
        [_btn_voteLeft addTarget:self action:@selector(voteBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [view_backWhite addSubview:_btn_voteLeft];
        
        _btn_voteRight = [[UIButton alloc] initWithFrame:CGRectMake(Main_Screen_Width-InnerSpace-btnVoteWidth, _line_score.frame.origin.y+CGRectGetHeight(_line_score.frame)+InnerSpace*2.5, btnVoteWidth, btnVoteHeight)];
        if (isiPhoneBelow5s) {
            [_btn_voteRight setFrame:CGRectMake(Main_Screen_Width-InnerSpace-btnVoteWidth, _line_score.frame.origin.y+CGRectGetHeight(_line_score.frame)+InnerSpace*1.5, btnVoteWidth, btnVoteHeight)];
        }else if(isiPhoneUpper6plus){
            [_btn_voteRight setFrame:CGRectMake(Main_Screen_Width-InnerSpace-btnVoteWidth, _line_score.frame.origin.y+CGRectGetHeight(_line_score.frame)+InnerSpace*2, btnVoteWidth, btnVoteHeight)];
        }
        [_btn_voteRight setBackgroundImage:[UIImage imageNamed:@"btn_vote_right"] forState:UIControlStateNormal];
        _btn_voteRight.tag = 1002;
        [_btn_voteRight setTitleColor:RGBColor(74, 74, 74) forState:UIControlStateNormal] ;
        UIImage *imgRight = [UIImage imageNamed:@"投票右"];
        [_btn_voteRight setImage:imgRight forState:UIControlStateNormal];
        _btn_voteRight.titleEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 10);
        _btn_voteRight.imageEdgeInsets = UIEdgeInsetsMake(6, 75, 6, -_btn_voteRight.titleLabel.bounds.size.width);
        if (isiPhoneBelow5s) {
            [_btn_voteRight.titleLabel setFont:[UIFont systemFontOfSize:13]];
            _btn_voteRight.titleEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 10);
            _btn_voteRight.imageEdgeInsets = UIEdgeInsetsMake(6, 54, 6, -_btn_voteRight.titleLabel.bounds.size.width);
        }else if(isiPhoneUpper6plus){
           _btn_voteRight.imageEdgeInsets = UIEdgeInsetsMake(6, 76, 6, -_btn_voteRight.titleLabel.bounds.size.width);
        }
        
        //button标题的偏移量，这个偏移量是相对于图片的
        
        if (fightUserModelRight.voted) {
            [_btn_voteRight setTitle:@"已投票" forState:UIControlStateNormal];
            [_btn_voteRight setEnabled:NO];
        }else{
            [_btn_voteRight setTitle:@"投票" forState:UIControlStateNormal];
            [_btn_voteRight setEnabled:YES];
        }
        [_btn_voteRight addTarget:self action:@selector(voteBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [view_backWhite addSubview:_btn_voteRight];
        
    }
    return _headImageView;
}


-(void)refreshHeaderData{
    if ([roomModel.remainingTime longLongValue]<=0) {
        _headImageView.frame=CGRectMake(0, -headViewWithNoVoteBtnHeight ,Main_Screen_Width,headViewWithNoVoteBtnHeight);
        mainTableView.contentInset = UIEdgeInsetsMake(headViewWithNoVoteBtnHeight,0, 0, 0);
        _label_timeLeft.hidden = YES;
        _image_end.hidden = NO;
    }else{
        
        _headImageView.frame = CGRectMake(0, -headViewHeight ,Main_Screen_Width,headViewHeight);
        mainTableView.contentInset = UIEdgeInsetsMake(headViewHeight,0, 0, 0);
        [mainTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        _label_timeLeft.hidden = NO;
        _image_end.hidden = YES;
    }
    
    [_image_left setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kFFAPI,fightUserModelLeft.avatar]] placeholderImage:[UIImage imageNamed:@"比赛图片占位"]];
    [_image_right setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kFFAPI,fightUserModelRight.avatar]] placeholderImage:[UIImage imageNamed:@"比赛图片占位"]];
    _label_scoreLeft.text = [NSString stringWithFormat:@"%@票",fightUserModelLeft.score];
    _label_scoreRight.text = [NSString stringWithFormat:@"%@票",fightUserModelRight.score];
    
    _label_winloseLeft.text = [NSString stringWithFormat:@"胜%@ - 负%@",fightUserModelLeft.user.win,fightUserModelLeft.user.lose];
    _label_winloseRight.text = [NSString stringWithFormat:@"胜%@ - 负%@",fightUserModelRight.user.win,fightUserModelRight.user.lose];
    CGFloat tempValueLeft = (CGFloat)(fightUserModelLeft.user.win.floatValue/(fightUserModelLeft.user.win.floatValue+fightUserModelLeft.user.lose.floatValue)) *10.0f;
    
    CGFloat progressWidthLeft = tempValueLeft/10.f;
    
    if (isnan(progressWidthLeft)) {
        progressWidthLeft = 0.5f;
    }
    _line_winlose_left.progressValue = progressWidthLeft;
    
    CGFloat tempValueRight = (CGFloat)(fightUserModelRight.user.win.floatValue/(fightUserModelRight.user.win.floatValue+fightUserModelRight.user.lose.floatValue)) *10.0f;
    
    CGFloat progressWidthRight = tempValueRight/10.f;
    
    if (isnan(progressWidthRight)) {
        progressWidthRight = 0.5f;
    }
    _line_winlose_right.progressValue = progressWidthRight;
    
    //    int reTime = [roomModel.remainingTime intValue];
    //    if(reTime<=0){
    //        _label_timeLeft.text = @"已结束";
    //    }else{
    //        _label_timeLeft.text = [MyUtil ConvertStrToTime:roomModel.remainingTime toFormat:@" mm\' ss\""];
    //    }
    
    //    int maxValue = 280;
    // 变量
    CGFloat tempValue = (CGFloat)(fightUserModelLeft.score.floatValue/(fightUserModelLeft.score.floatValue+fightUserModelRight.score.floatValue)) *10.0f;
    
    CGFloat progressWidth = tempValue/10.f;
    
    if (isnan(progressWidth)) {
        progressWidth = 0.5f;
    }
    
    
    _line_score.progressValue = progressWidth;
    
    if ([fightUserModelLeft.voted isEqualToString:@"1"]) {
        [_btn_voteLeft setTitle:@"已投票" forState:UIControlStateNormal];
        [_btn_voteLeft setEnabled:NO];
    }else{
        [_btn_voteLeft setTitle:@"投票" forState:UIControlStateNormal];
    }
    
    if ([fightUserModelRight.voted isEqualToString:@"1"]) {
        [_btn_voteRight setTitle:@"已投票" forState:UIControlStateNormal];
        [_btn_voteRight setEnabled:NO];
    }else{
        [_btn_voteRight setTitle:@"投票" forState:UIControlStateNormal];
    }
    
    
    //    [self getCommentsData];
}

-(UITableView *)mainTableView
{
    if (mainTableView == nil)
    {
        mainTableView= [[MainTouchTableTableView alloc]initWithFrame:CGRectMake(0,64,Main_Screen_Width,Main_Screen_Height-64)];
        mainTableView.delegate=self;
        mainTableView.dataSource=self;
        mainTableView.showsVerticalScrollIndicator = YES;
        mainTableView.contentInset = UIEdgeInsetsMake(headViewHeight,0, 0, 0);
        mainTableView.backgroundColor = [UIColor clearColor];
        mainTableView.bounces = NO;
    }
    return mainTableView;
}

//底部Segments
-(UIView *)setPageViewControllers
{
    if (!_RCSegView) {
        
        FFInFightPresentsViewController * Third=[[FFInFightPresentsViewController alloc]init];
        
        FFRoomCommentsViewController *First=[[FFRoomCommentsViewController alloc]init];
        First.fightId = roomModel.fightId;
        First.createTime = roomModel.create_time;
        
        FFInFightRecordViewController * Second=[[FFInFightRecordViewController alloc]init];
        Second.fightId = roomModel.fightId;
        Second.leftUserId = userDetailModelLeft.userId;
        Second.createTime = roomModel.create_time;
        
        
        NSArray *controllers=@[First,Second,Third];
        
        NSArray *titleArray =@[@"评论",@"实况直播",@"使用道具"];
        
        MYSegmentView * rcs=[[MYSegmentView alloc]initWithFrame:CGRectMake(0, 0, Main_Screen_Width, Main_Screen_Height-64) controllers:controllers titleArray:titleArray ParentController:self lineWidth:Main_Screen_Width/3 lineHeight:3.];
        
        _RCSegView = rcs;
    }
    return _RCSegView;
}

//设置评论数
-(void)setCommentsCount:(NSNotification *)notif{
    NSString *num = [notif.userInfo valueForKey:@"Num"];
    [_RCSegView setlabelNumber:num];
}


//票数放大动画
- (void)startBiggerAnimationDuration:(NSTimeInterval)interval View:(UIView *)view
{
    [UIView animateKeyframesWithDuration:interval delay:0 options:0 animations:^{
        
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1/2.0 animations:^{
            view.transform = CGAffineTransformMakeScale(4, 4);
        }];
        [UIView addKeyframeWithRelativeStartTime:1/2.0 relativeDuration:1/2.0 animations:^{
            view.transform = CGAffineTransformMakeScale(0.8, 0.8);
        }];
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.4 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            view.transform = CGAffineTransformMakeScale(1.0, 1.0);
        } completion:^(BOOL finished) {
            if (![scoreByVote isEqualToString:@"0"]) {
                
                ghostView_Image.title = [NSString stringWithFormat:@"积分+%@",scoreByVote];
                ghostView_Image.timeout = 1.0;
                [ghostView_Image showWithAnimation];
                //加完之后复原
                scoreByVote = @"0";
            }
            
        }];
        
    }];
}

//定时器方法，1s
-(void)timeInLineMethod{
    if(timeInLine<=0){
        if (_isShowRoomScore) {
            //显示结束时本场获得的积分
            [self showScoreRecordsViewWithScoreArray:scoreArray];
        }
        
        [timerWait invalidate];
        _label_timeLeft.text = @" 00\'   00\"";
        
        _label_timeLeft.hidden = YES;
        _image_end.hidden = NO;
        
        headViewWithNoVoteBtnHeight = headViewHeight - rate*32*2;
        _headImageView.frame=CGRectMake(0, -headViewWithNoVoteBtnHeight ,Main_Screen_Width,headViewWithNoVoteBtnHeight);
        mainTableView.contentInset = UIEdgeInsetsMake(headViewWithNoVoteBtnHeight,0, 0, 0);
        
        isShowUserVoteBtn = NO;
        return;
    }
    NSString *newTimeStr = [NSString stringWithFormat:@"%ld",timeInLine];
    //    newTimeStr  = @"262077";
    
    NSString *rawTimeStr = [MyUtil ConvertStrToTime:newTimeStr toFormat:@"mmss"];
    _label_timeLeft.text = [NSString stringWithFormat:@" %@\'   %@\"",[rawTimeStr substringToIndex:2],[rawTimeStr substringFromIndex:2]];
    timeInLine -=1000*1;
    
}

#pragma mark -
#pragma mark - User Interactions

#pragma mark - 更多按钮
-(void)onClickRightBtn:(UIButton *)sender
{
    if ([MyUtil jumpToLoginVCIfNoLogin]) {
        return;
    }
    [self createMoreView];
    
}

- (void)createMoreView
{
    if (moreView_back) {
        [self removeMoreView];
        return;
    }
    NSArray *titleArray;
    if([roomModel.remainingTime intValue]>0){
        titleArray = @[@"求帮", @"分享", @"举报"];
    }else{
        titleArray = @[@"分享", @"举报"];
    }
    
    moreView_back = [MyUtil viewWithAlpha:0];
    moreView_back.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapback = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeMoreView)];
    [moreView_back addGestureRecognizer:tapback];
    [self.view addSubview:moreView_back];

    moreView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width, 57, 0, 0)];
    moreView.backgroundColor = [UIColor whiteColor];
    FFViewBorderRadius(moreView, 2, 1, RGBColor(231, 231, 231));
    moreView.userInteractionEnabled = YES;
    //        moreView.image = [UIImage imageNamed:@"popupwindow_bgMyCard"];
    [UIView animateWithDuration:0.1 animations:^{
        moreView.frame = CGRectMake(self.view.frame.size.width - 107, 57, 107, 35 * titleArray.count );
        [moreView_back addSubview:moreView];
    } completion:^(BOOL finished) {
        for (int index = 0; index < titleArray.count; index++)
        {
            UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeSystem];
            moreButton.frame = CGRectMake(0,  35 * index, 112, 35);
            [moreButton setTitle:titleArray[index] forState:UIControlStateNormal];
            moreButton.titleLabel.font = [UIFont systemFontOfSize:14];
            [moreButton setTitleColor:RGBColor(74, 74, 74) forState:UIControlStateNormal];
            if (index == 0)
            {
                moreButton.tag = 0;
            }else if (index == 1){
                moreButton.tag = 1;
            }else{
                moreButton.tag = 2;
            }
            
            [moreButton addTarget:self action:@selector(moreButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            [moreView addSubview:moreButton];
            if (index != titleArray.count - 1)
            {
                UIView *line = [[UIView alloc] initWithFrame:CGRectMake(7, 35 * index + 34, moreView.frame.size.width, 1)];
                line.backgroundColor = RGBColor(231, 231, 231);
                [moreView addSubview:line];
            }
        }
    }];

}

- (void)removeMoreView
{
    [moreView_back removeFromSuperview];
    moreView_back = nil;
}

- (void)moreButtonClick:(UIButton *)sender
{
    if (sender.tag == 0){
        if([roomModel.remainingTime intValue]>0){
            NSLog(@"求帮");
            NSString *fightId = roomModel.fightId;
            NSLog(@"求帮列表要传给下个界面的fightid是---%@",fightId);
            FFAskForHelpViewController * vc= [[FFAskForHelpViewController alloc]init];
            vc.fightIdStr = fightId;
            [self.navigationController pushViewController:vc animated:YES];
            
        }else{
            NSLog(@"分享");
            __weak typeof(self) weakSelf = self;
            [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMShareMenuSelectionView *shareSelectionView, UMSocialPlatformType platformType) {
                
                [weakSelf shareWebPageToPlatformType:platformType ShareModel:_shareModel];
            }];
        }
        
        [self removeMoreView];
    }else if (sender.tag == 1){
        if([roomModel.remainingTime intValue]>0){
            NSLog(@"分享");
            __weak typeof(self) weakSelf = self;
            [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMShareMenuSelectionView *shareSelectionView, UMSocialPlatformType platformType) {
                
                [weakSelf shareWebPageToPlatformType:platformType ShareModel:_shareModel];
            }];
            
        }else{
            NSLog(@"举报");
            [self showReportActionSheet];
        }
        
        [self createMoreView];
    }else if (sender.tag == 2){
        NSLog(@"举报");
        [self showReportActionSheet];
        [self createMoreView];
    }
}


-(void)showReportActionSheet{
    UIAlertController *sheetController = [UIAlertController alertControllerWithTitle:@"举报" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *Action1 = [UIAlertAction actionWithTitle:@"垃圾广告" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        ghostView.message = @"举报成功";
        [ghostView show];
    }];
    
    UIAlertAction *Action2 = [UIAlertAction actionWithTitle:@"低俗淫秽" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        ghostView.message = @"举报成功";
        [ghostView show];
    }];
    
    UIAlertAction *Action3 = [UIAlertAction actionWithTitle:@"内容不实" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        ghostView.message = @"举报成功";
        [ghostView show];
    }];
    
    UIAlertAction *Action4 = [UIAlertAction actionWithTitle:@"涉嫌抄袭" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        ghostView.message = @"举报成功";
        [ghostView show];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [sheetController addAction:Action1];
    [sheetController addAction:Action2];
    [sheetController addAction:Action3];
    [sheetController addAction:Action4];
    [sheetController addAction:cancelAction];
    
    [self presentViewController:sheetController animated:YES completion:nil];
}

-(void)backUp:(id)sender{
    if (_isFromHistory) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        for (UIViewController *item in self.navigationController.viewControllers) {
            if ([item isKindOfClass:[RootViewController class]]) {
                [self.navigationController popToViewController:item animated:true];
            }
        }
    }
}

#pragma mark - 更多按钮

-(void)didChooseSegVC: (NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    NSString *tagStr = notification.object;
    
    if ([tagStr isEqualToString:@"00"]) {
        [UIView animateWithDuration:0.5 animations:^{
            _headImageView.frame=CGRectMake(0, -headViewHeight ,Main_Screen_Width,headViewHeight);
            mainTableView.contentInset = UIEdgeInsetsMake(headViewHeight, 0, 0, 0);
            [mainTableView setContentOffset:CGPointMake(0, mainTableView.contentSize.height -mainTableView.bounds.size.height) animated:YES];
            [mainTableView reloadData];
            [self.mainTableView setScrollEnabled:NO];
        }];
        //这里写动画代码
        
        
        
    }else{
        [self.mainTableView setScrollEnabled:YES];
    }
    if ([tagStr isEqualToString:@"1"]) {
        if (!_isTopIsCanNotMoveTabViewPre&&!_isTopIsCanNotMoveTabViewPre) {
            //神奇 勿动
        }else{
            UIImageView *naviView = (UIImageView *)[self.view viewWithTag:1001];
            naviView.backgroundColor = RGBColor(248, 231, 28);
            
            UILabel *label_title = (UILabel *)[self.view viewWithTag:1002];
            label_title.text = [NSString stringWithFormat:@"%@ : %@",fightUserModelLeft.score,fightUserModelRight.score];
        }
        
    }else{
        UIImageView *naviView = (UIImageView *)[self.view viewWithTag:1001];
        naviView.backgroundColor = RGBColor(255, 255, 255);
        
        UILabel *label_title = (UILabel *)[self.view viewWithTag:1002];
        label_title.text = TitleStr;
    }
    
    if ([tagStr isEqualToString:@"2"]) {
        [UIView animateWithDuration:0 animations:^{
            
        }];
        //这里写动画代码
        _headImageView.frame=CGRectMake(0, -headViewWithNoVoteBtnHeight ,Main_Screen_Width,headViewWithNoVoteBtnHeight);
        mainTableView.contentInset = UIEdgeInsetsMake(headViewWithNoVoteBtnHeight, 0, 0, 0);
        [mainTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        [mainTableView reloadData];
        [self.mainTableView setScrollEnabled:NO];
        
        
    }else{
        [self.mainTableView setScrollEnabled:YES];
    }
}

-(void)resetContentInset:(NSNotification *)notification{
    presentId_current = [notification.userInfo valueForKey:@"presentId"];
    //    _headImageView.frame=CGRectMake(0, -headViewHeight+80 ,Main_Screen_Wivvvvdth,headViewHeight);
    
    
    if(view_present_back){
        return;
    }
    //    [UIView animateWithDuration:0.2 animations:^{
    //        //这里写动画代码
    //        _headImageView.frame=CGRectMake(0, -headViewHeight+voteAreaViewHeight ,Main_Screen_Width,headViewHeight);
    //        mainTableView.contentInset = UIEdgeInsetsMake(headViewHeight-voteAreaViewHeight, 0, 0, 0);
    //        [mainTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    //
    //    }];
    //    [mainTableView reloadData];
    [self performSelector:@selector(showPresentChooseView) withObject:nil afterDelay:0];
}


-(void)showPresentChooseView{
    
    if (roomModel.remainingTime.integerValue<=0) {
        ghostView.message = @"比赛已结束";
        [ghostView show];
        return;
    }
    
    view_present_back = [MyUtil viewWithAlpha:0.55];
    view_present_back.frame = CGRectMake(0, 0, SCREEN_WIDTH, presentBackViewHeight);
    UITapGestureRecognizer *tapBack = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidePresentBackView)];
    
    [view_present_back addGestureRecognizer:tapBack];
    view_present_back.userInteractionEnabled = YES;
    [self.view addSubview:view_present_back];
    //    [self.view bringSubviewToFront:view_present_back];
    
    for (int i = 0; i<2; i++) {
        UIImageView *image ;
        if (i == 0) {
            image= [[UIImageView alloc] initWithFrame:CGRectMake(InnerSpace, cupImageHeight+2*InnerSpace+64, ImageWidth, ImageWidth)];
            [image setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kFFAPI,fightUserModelLeft.avatar]] placeholderImage:nil];
        }else{
            image= [[UIImageView alloc] initWithFrame:CGRectMake(Main_Screen_Width-ImageWidth-InnerSpace, cupImageHeight+2*InnerSpace+64, ImageWidth, ImageWidth)];
            [image setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kFFAPI,fightUserModelRight.avatar]] placeholderImage:nil];
        }
        [image setContentMode:UIViewContentModeScaleAspectFill];
        
        
        image.backgroundColor = [UIColor redColor];
        FFViewBorderRadius(image, 4, 1, [UIColor clearColor]);
        [view_present_back addSubview:image];
        
        UIButton *btn;
        if (i==0) {
            btn = [[UIButton alloc] initWithFrame:CGRectMake(InnerSpace*2, image.frame.origin.y+image.frame.size.height+InnerSpace, 120, 44)];
            [btn setImage:[UIImage imageNamed:@"使用道具"] forState:UIControlStateNormal];
            btn.tag = 3000+i;
            
        }else{
            btn = [[UIButton alloc] initWithFrame:CGRectMake(Main_Screen_Width-120-InnerSpace*2, image.frame.origin.y+image.frame.size.height+InnerSpace, 120, 44)];
            [btn setImage:[UIImage imageNamed:@"使用道具"] forState:UIControlStateNormal];
            btn.tag = 3000+i;
            
        }
        [view_present_back addSubview:btn];
        [btn addTarget:self action:@selector(usePresentCLicked:) forControlEvents:UIControlEventTouchUpInside];
        
    }
}

-(void)hidePresentBackView{
    view_present_back.hidden = YES;
    view_present_back = nil;
    
    
    //    [UIView animateWithDuration:0.2 animations:^{
    //        //这里写动画代码
    //        _headImageView.frame=CGRectMake(0, -headViewHeight ,Main_Screen_Width,headViewHeight);
    //        mainTableView.contentInset = UIEdgeInsetsMake(headViewHeight, 0, 0, 0);
    //        [mainTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    //    }];
    
    
}

//斗脸倒计时结束时显示用户获得的积分
-(void)showScoreRecordsViewWithScoreArray:(NSMutableArray *)array{
    //TODO
    if (!array) {
        return;
    }
    if (array.count==0) {
        return;
    }
    if (![MyUtil isLogin]) {
        return;
    }
    
    int score = 0;
    for (NSDictionary *dic in array) {
        FFShowFightScoreModel *model = [FFShowFightScoreModel modelWithDictionary:dic];
        NSString *userId = model.userId;
        NSString *userId_local =[NSString stringWithFormat:@"%@", [mUserDefaults valueForKey:@"userId"]];
        if ([userId isEqualToString:userId_local]) {
            if([model.type isEqualToString:@"5"]){
                score = model.score.intValue;
            }
            
        }
    }
    if (score ==0) {
        return;
    }
    ghostView_Image.title = [NSString stringWithFormat:@"获胜积分+%d",score];
    [ghostView_Image showWithAnimation];
//    NSString *contentStr = [NSString stringWithFormat:@"本场共获得%d积分",score];
//    UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:@"本场积分" message:contentStr preferredStyle:UIAlertControllerStyleAlert];
//    
//    [alertCon addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
//        
//    }]];
//    [alertCon addAction:[UIAlertAction actionWithTitle:@"再来一场" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//        
//        FFCreateRoomViewController *croom = [[FFCreateRoomViewController alloc] init];
//        [self.navigationController pushViewController:croom animated:YES];
//        
//    }]];
//    [self.navigationController presentViewController:alertCon animated:YES completion:nil];
    
}

//点击斗图弹出用户展示页
-(void)onClickUserPhoto:(id)sender{
    
    UITapGestureRecognizer *singleTap = (UITapGestureRecognizer *)sender;
    //    NSLog(@"%d",[singleTap view].tag]);
    long int i = [singleTap view].tag-2000;
    FFListFightUserModel *model;
    if (i==0) {
        model = fightUserModelLeft;
    }else{
        model = fightUserModelRight;
    }
    [self showUserInfoViewWithModelTag:i];
}

-(void)showUserInfoViewWithModelTag:(long int)tag{
    
    if ([MyUtil jumpToLoginVCIfNoLogin]) {
        return;
    }
    
    FFListFightUserModel *model;

    view_user_back = [MyUtil viewWithAlpha:0.55];
    view_user_back.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapBack = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideUserInfoView)];
    [view_user_back addGestureRecognizer:tapBack];
    [self.view addSubview:view_user_back];
    
    CGFloat ViewWhiteWidth = 320.0;
    CGFloat ViewWhiteHeight = 490.0;
    rate = 1;
    //6 6s 7 375
    //5 5s se 320
    //6p 6sp 7p 414
    if (isiPhoneBelow5s) {
        rate = 320.0/375.0;
        ViewWhiteWidth = rate*ViewWhiteWidth;
        ViewWhiteHeight = 320.0/375.0*ViewWhiteHeight;
    }else if(isiPhoneUpper6plus){
        rate = 414.0/375.0;
        ViewWhiteWidth = rate*ViewWhiteWidth;
        ViewWhiteHeight = rate*ViewWhiteHeight;
    }
    
    scrollView_user = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, ViewWhiteHeight)];
    scrollView_user.backgroundColor = [UIColor clearColor];
    scrollView_user.contentSize = CGSizeMake(SCREEN_WIDTH*4, ViewWhiteHeight);
//    scrollView_user.contentOffset = CGPointMake(SCREEN_WIDTH, 0);
    scrollView_user.bounces = NO;
    scrollView_user.tag = 1;
    scrollView_user.delegate = self;
    scrollView_user.showsHorizontalScrollIndicator = NO;
    scrollView_user.pagingEnabled = YES;
    scrollView_user.userInteractionEnabled = YES;
    if(tag == 0){
        [scrollView_user scrollRectToVisible:CGRectMake(SCREEN_WIDTH*1, 0, SCREEN_WIDTH, ViewWhiteHeight) animated:NO];
    }else{
        [scrollView_user scrollRectToVisible:CGRectMake(SCREEN_WIDTH*2, 0, SCREEN_WIDTH, ViewWhiteHeight) animated:NO];
    }
    
    [view_user_back addSubview:scrollView_user];
    
    for (int i = 0; i<4; i++) {
        
        if (i==1||i==3) {
            model = fightUserModelLeft;
        }else{
            model = fightUserModelRight;
        }
        
        UIView *view_white = [[UIView alloc] initWithFrame:CGRectMake(i*SCREEN_WIDTH+SCREEN_WIDTH/2-ViewWhiteWidth/2, 0, ViewWhiteWidth, ViewWhiteHeight)];
        view_white.backgroundColor = [UIColor whiteColor];
        view_white.tag = 10+tag;
        view_white.userInteractionEnabled = YES;
        FFViewBorderRadius(view_white, 2, 1, [UIColor clearColor]);
        [scrollView_user addSubview:view_white];
        
        UIImageView *image_photo = [[UIImageView alloc] initWithFrame:CGRectMake(18.0*rate, 22.0*rate, 285.0*rate, 285.0*rate)];
        [image_photo setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kFFAPI,model.avatar]] placeholderImage:[UIImage imageNamed:@"比赛图片占位大图"]];
        [image_photo setContentMode:UIViewContentModeScaleAspectFit];
        [view_white addSubview:image_photo];
        
        UILabel *label_word = [[UILabel alloc] initWithFrame:CGRectMake(36.0*rate,image_photo.frame.origin.y+image_photo.frame.size.height+20.0*rate, 247.0*rate, 42*rate)];
        label_word.font = [UIFont systemFontOfSize:floor(14*rate)];
        label_word.textColor = RGBColor(74, 74, 74);
        NSString *tempCatchWordStr = model.catchWord;
        tempCatchWordStr = [self stringByDecodingURLFormat:tempCatchWordStr];
        label_word.text = tempCatchWordStr;
        [view_white addSubview:label_word];
        
        UIView *view_line = [[UIView alloc] initWithFrame:CGRectMake(22.0*rate, label_word.frame.origin.y+label_word.frame.size.height+23.0*rate, 276.0*rate, 1)];
        view_line.backgroundColor = RGBColor(236, 236, 236);
        [view_white addSubview:view_line];
        
        UIImageView *image_avatar = [[UIImageView alloc] initWithFrame:CGRectMake(26.0*rate,view_line.frame.origin.y+view_line.frame.size.height+ 12.0*rate, 48.0*rate, 48.0*rate)];
        FFViewBorderRadius(image_avatar, image_avatar.frame.size.width/2, 1, [UIColor clearColor]);
        [image_avatar setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kFFAPI,model.user.avatar]] placeholderImage:[UIImage imageNamed:@"person_person_icon"]];
        image_avatar.userInteractionEnabled = YES;
        image_avatar.contentMode = UIViewContentModeScaleAspectFill;
        UITapGestureRecognizer *tapAvatar = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userAvatarClicked:)];
        [image_avatar addGestureRecognizer:tapAvatar];
        image_avatar.tag = 2000+i;
        [view_white addSubview:image_avatar];
        
        UILabel *label_name = [[UILabel alloc] initWithFrame:CGRectMake(25*rate, image_avatar.frame.origin.y+image_avatar.frame.size.height+12.0*rate, 180.0*rate, floor(14.0*rate))];
        label_name.font = [UIFont systemFontOfSize:floor(14.0*rate)];
        label_name.textColor = RGBColor(74, 74, 74);
        label_name.text = model.user.name;
        label_name.textAlignment = NSTextAlignmentLeft;
        [view_white addSubview:label_name];
        
        if (isShowUserVoteBtn) {
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake((view_white.frame.size.width-34*rate-32*rate), (ViewWhiteHeight-41*rate-31*rate), 32*rate, 31*rate)];
            BOOL canVoted = [model.voted isEqualToString:@"1"]?NO:YES;
            
            [btn setImage:[UIImage imageNamed:@"投票大"] forState:UIControlStateNormal];
            btn.enabled = canVoted;
            btn.tag = 1000+i;
            [btn addTarget:self action:@selector(voteBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [view_white addSubview:btn];
            
            UILabel *label_vote = [[UILabel alloc] initWithFrame:CGRectMake(btn.center.x-60/2, (view_white.frame.size.height-10*rate-14*rate), 60, floor(14*rate))];
            label_vote.font = [UIFont systemFontOfSize:floor(14*rate)];
            label_vote.textColor = RGBColor(74, 74, 74);
            label_vote.text = btn.enabled?@"投票":@"已投票";
            label_vote.textAlignment = NSTextAlignmentCenter;
            label_vote.tag = 2001+i;
            [view_white addSubview:label_vote];
        }
        
    }
    
}

- (NSString *)stringByDecodingURLFormat:(NSString *)string
{
    
    NSString *result = string;
    result = [result stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    result = [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return result;
}

-(void)hideUserInfoView{
    view_user_back.hidden = YES;
    view_user_back = nil;
}

-(void)usePresentCLicked:(UIButton *)sender{
    switch (sender.tag) {
        case 3000:
        {
            [self usePresentToUserWithUserId:userDetailModelLeft.userId];
        }
            break;
        case 3001:
        {
            [self usePresentToUserWithUserId:userDetailModelRight.userId];
        }
            break;
            
        default:
            break;
    }
}

-(void)userAvatarClicked:(id)sender{
    UITapGestureRecognizer *singleTap = (UITapGestureRecognizer *)sender;
    //    NSLog(@"%d",[singleTap view].tag]);
    long int tag = [singleTap view].tag-2000;
    FFListFightUserModel *model;
    if (tag==0||tag==2) {
        model = fightUserModelRight;
    }else{
        model = fightUserModelLeft;
    }
    
    FFPersonalDetailVC *detail = [[FFPersonalDetailVC alloc] init];
    detail.userIDStr = model.userId;
    [self.navigationController pushViewController:detail animated:YES];
}


-(void)postRefreshNotification{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FightRoomAutoRefreshData" object:nil];
}

#pragma mark-投票按钮点击
-(void)voteBtnClicked:(UIButton*)sender{
    if ([MyUtil jumpToLoginVCIfNoLogin]) {
        return;
    }
    
    switch (sender.tag) {
        case 1001:
        {
            
            [self voteForUserWithToUserId:userDetailModelLeft.userId BtnTag:1001];
        }
            break;
        case 1002:
        {
            [self voteForUserWithToUserId:userDetailModelRight.userId BtnTag:1002];
        }
            break;
        case 1000:
        {
            
            [self voteForUserWithToUserId:userDetailModelRight.userId BtnTag:1002];
        }
            break;
        case 1003:
        {
            [self voteForUserWithToUserId:userDetailModelLeft.userId BtnTag:1001];
        }
            break;
            
        default:
            break;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.tag ==1) {
        return;
    }
    if (_RCSegView.selectTag == 2) {
//        [self.mainTableView setScrollEnabled:NO];
        return;
    }else{
//        [self.mainTableView setScrollEnabled:YES];
    }
    /**
     * 处理联动
     */
    
    //获取滚动视图y值的偏移量
    CGFloat yOffset  = scrollView.contentOffset.y;
    
    CGFloat tabOffsetY = [mainTableView rectForSection:0].origin.y;
    CGFloat offsetY = scrollView.contentOffset.y;
    
    _isTopIsCanNotMoveTabViewPre = _isTopIsCanNotMoveTabView;
    if (offsetY>=tabOffsetY) {
        scrollView.contentOffset = CGPointMake(0, tabOffsetY);
        _isTopIsCanNotMoveTabView = YES;
    }else{
        _isTopIsCanNotMoveTabView = NO;
    }
    if (_isTopIsCanNotMoveTabView != _isTopIsCanNotMoveTabViewPre) {
        if (!_isTopIsCanNotMoveTabViewPre && _isTopIsCanNotMoveTabView) {
            //NSLog(@"滑动到顶端");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"goTop" object:nil userInfo:@{@"canScroll":@"1"}];
            _canScrollHere = NO;
            if (_RCSegView.selectTag == 1){
                UIImageView *naviView = (UIImageView *)[self.view viewWithTag:1001];
                naviView.backgroundColor = RGBColor(248, 231, 28);
                
                UILabel *label_title = (UILabel *)[self.view viewWithTag:1002];
                label_title.text = [NSString stringWithFormat:@"%@ : %@",fightUserModelLeft.score,fightUserModelRight.score];
                
            }
        }
        if(_isTopIsCanNotMoveTabViewPre && !_isTopIsCanNotMoveTabView){
            //NSLog(@"离开顶端");
            if (!_canScrollHere) {
                scrollView.contentOffset = CGPointMake(0, tabOffsetY);
            }
            UIImageView *naviView = (UIImageView *)[self.view viewWithTag:1001];
            naviView.backgroundColor = RGBColor(255, 255, 255);
            
            UILabel *label_title = (UILabel *)[self.view viewWithTag:1002];
            label_title.text = TitleStr;
        }
    }
    
    
    /**
     * 处理头部视图
     */
    if(yOffset < -headViewHeight) {
        
        CGRect f = self.headImageView.frame;
        f.origin.y= yOffset ;
        f.size.height=  -yOffset;
        f.origin.y= yOffset;
        
        //改变头部视图的fram
        self.headImageView.frame= f;
        CGRect avatarF = CGRectMake(f.size.width/2-40, (f.size.height-headViewHeight)+56, 80, 80);
        _avatarImage.frame = avatarF;
        _countentLabel.frame = CGRectMake((f.size.width-Main_Screen_Width)/2+40, (f.size.height-headViewHeight)+172, Main_Screen_Width-80, 36);
    }
    
}

-(void)acceptMsg : (NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    NSString *canScroll = userInfo[@"canScroll"];
    if ([canScroll isEqualToString:@"1"]) {
        _canScrollHere = YES;
    }
}

//以下两方法用于点击弹出的用户详情scroolview_user


/**
 *  当滑动试图停止减速（停止）调用（用于手动拖拽）
 *
 *  @param scrollView 滑动试图
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView.tag == 1) {
        [self updatePageCtrlWithContentOffset:scrollView.contentOffset.x];
    }
    
}

/**
 *  更新PageController的当前页
 *
 *  @param contentOffset_x 当前滑动试图内容的偏移量
 */
- (void)updatePageCtrlWithContentOffset:(CGFloat)contentOffset_x{
    // 一定要用float类型，非常重要
    CGFloat index = contentOffset_x / (SCREEN_WIDTH) ;
    if (index >= 4 - 1) {
        // 滑到最后一个按钮（表面是第一个）
        //设置视图的偏移量到第二个按钮
        scrollView_user.contentOffset = CGPointMake(SCREEN_WIDTH, 0);
        //        [self setPageCtrlCurrentPage:0];
        //        self.titleLabel.text = [self.titles firstObject];
    }else if(index <= 0){
        // 滑到第一个按钮（表面是最后一个）
        scrollView_user.contentOffset = CGPointMake((4 - 2) *SCREEN_WIDTH, 0);
        //        [self setPageCtrlCurrentPage:self.images.count - 3];
        //        NSInteger arrIndex = self.images.count - 3;
        //        self.titleLabel.text = self.titles[arrIndex];
    } else {
        //设置_pageCtrl显示的页数（减去第一个按钮）
        //        [self setPageCtrlCurrentPage:index - 1];
        //        NSInteger arrIndex = index - 1;
        //        self.titleLabel.text = self.titles[arrIndex];
    }
    
    // 通知代理当前展示的页发生变化
    //    if ([self.delegate respondsToSelector:@selector(bannerView:didChangeViewWithIndex:)]) {
    //        //        [self.delegate bannerView:self didChangeViewWithIndex:]
    //    }
}


#pragma mark-
#pragma mark- NetWork

//拉取房间斗脸信息
-(void)requestData{

    __weak typeof(self) weakSelf = self;
    NSString *logId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"logId"]];
    NSString *token = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"token"]];
    NSString *userId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"userId"]];
    if (!userId||[userId isEqualToString:@"(null)"]) {
        userId = @"0";
    }
    if (!logId||[logId isEqualToString:@"(null)"]) {
        logId = @"0";
    }
    if (!token||[token isEqualToString:@"(null)"]) {
        token = @"0";
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:logId,@"logId",token,@"token",_fightIdStr?_fightIdStr:roomModel.fightId,@"fightId",userId,@"userId",nil];
    
    //    loadView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [MyUtil requestPostURL:[NSString stringWithFormat:@"%@%@",kFFAPI,kFFAPI_FFFightRoomInfo] params:params success:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]] ) {
            [loadView hide:YES];
            NSString *error = [NSString stringWithFormat:@"%@",responseObject[@"error"]];
            [_tableView headerEndRefreshing];
            [_tableView footerEndRefreshing];
            if (error.integerValue==0) {
                //                NSString *msg = [NSString stringWithFormat:@"%@",responseObject[@"msg"]];
                //                ghostView.message = msg;
                //                [ghostView show];
                _responseDic = responseObject;
                
                _dataDic = [_responseDic valueForKey:@"data"];
                [self initData];
                
                if (_isShowCreateRoomScore) {
                    if (fightUserModelLeft.scoreRecords.count>0) {
                        for (NSDictionary *dic in fightUserModelLeft.scoreRecords) {
                            FFShowFightScoreModel *model = [FFShowFightScoreModel modelWithDictionary:dic];
                            if ([model.type isEqualToString:@"2"]) {
                                ghostView_Image.title = [NSString stringWithFormat:@"开局积分+%@",model.score];
                                ghostView_Image.timeout = 1.5;
                                [ghostView_Image show];
                                _isShowCreateRoomScore = NO;
                            }
                        }
                        
                    }
                }
                
                scoreArray = fightUserModelLeft.scoreRecords;
                
                if([roomModel.remainingTime intValue]>0){
                    [timerWait invalidate];
                    timerWait = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timeInLineMethod) userInfo:nil repeats:YES];
                    timeInLine = [[[NSNumberFormatter alloc] numberFromString:roomModel.remainingTime] longValue];
                    
                    isShowUserVoteBtn = YES;
                }else{
                    _label_timeLeft.text = @" 00\'   00\"";
                    
                    isShowUserVoteBtn = NO;
                }
                [_tableView reloadData];
                [weakSelf refreshHeaderData];
                
                //斗脸进行中，轮询接口
                if ([roomModel.remainingTime intValue]>0) {
                    [weakSelf performSelector:@selector(postRefreshNotification) withObject:nil afterDelay:5];
                    NSString *userId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"userId"]];
                    if ([userId isEqualToString:userDetailModelLeft.userId ]||[userId isEqualToString:userDetailModelRight.userId]) {
                        [[FFTimerManager defaultManager] addFightId:roomModel.fightId remainingTime:roomModel.remainingTime dataDic:_dataDic];
                    }
                    
                }else{
                    [[FFTimerManager defaultManager] addFightId:roomModel.fightId remainingTime:@"0" dataDic:_dataDic];
//                    roomModel = [FFListModel modelWithDictionary:_dataDic];
//                    fightUserModelLeft = [FFListFightUserModel modelWithDictionary:roomModel.fightUsers[0]];
//                    fightUserModelRight = [FFListFightUserModel modelWithDictionary:roomModel.fightUsers[1]];
//                    for (NSString *item in _dataDic.allKeys) {
//                        if ([item isEqualToString:@"scoreRecords"]) {
//                            if ([_dataDic valueForKey:item]) {
////                                [self showScoreRecordsViewWithScoreArray:[_dataDic valueForKey:item]];
//                            }
//                        }
//                    }
                }
            }else{
                ghostView.message = @"获取内容失败，请重新登陆后重试";
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

//对用户使用道具
-(void)usePresentToUserWithUserId:(NSString *)userId{

        NSString *logId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"logId"]];
        NSString *token = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"token"]];
    //    NSString *userId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"userId"]];
    NSString *fightId = roomModel.fightId;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:fightId,@"fightId",logId,@"logId",token,@"token",userId,@"toUserId",presentId_current,@"presentId",nil];
    
    loadView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [MyUtil requestPostURL:[NSString stringWithFormat:@"%@%@",kFFAPI,kFFAPI_FFUserPropInFight] params:params success:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]] ) {
            [loadView hide:YES];
            NSString *error = [NSString stringWithFormat:@"%@",responseObject[@"error"]];
            if (error.integerValue==0) {
                NSDictionary *dataDic = [responseObject valueForKey:@"data"];
                int varScore = [[dataDic valueForKey:@"score"] intValue];
                [self hidePresentBackView];
                if ([userId isEqualToString:userDetailModelLeft.userId]) {
                    fightUserModelLeft.score = [NSString stringWithFormat:@"%d",[fightUserModelLeft.score intValue]+varScore];
//                    [roomModel.fightUsers[0] setValue:fightUserModelLeft.score forKey:@"score"];
                    _label_scoreLeft.text = [NSString stringWithFormat:@"%@票",fightUserModelLeft.score];
                    [self startBiggerAnimationDuration:0.5 View:_label_scoreLeft];
                }else{
                    fightUserModelRight.score = [NSString stringWithFormat:@"%d",[fightUserModelRight.score intValue]+varScore];
//                    [roomModel.fightUsers[1] setValue:fightUserModelRight.score forKey:@"score"];
                    _label_scoreRight.text = [NSString stringWithFormat:@"%@票",fightUserModelRight.score];
                    [self startBiggerAnimationDuration:0.5 View:_label_scoreRight];
                }
                CGFloat tempValue = (CGFloat)(fightUserModelLeft.score.floatValue/(fightUserModelLeft.score.floatValue+fightUserModelRight.score.floatValue)) *10.0f;
                
                CGFloat progressWidth = tempValue/10.f;
                
                _line_score.progressValue = progressWidth;
                //成功使用道具后，刷新道具列表
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DidUsePresent" object:nil];
            }else{
                ghostView.message = @"使用道具失败";
                [ghostView show];
            }
        }
    } failure:^(NSError *error) {
        [loadView hide:YES];
        ghostView.message = @"网络出现问题，请稍后重试";
        [ghostView show];
        
    }];

}

-(void)voteForUserWithToUserId:(NSString *)toUserId BtnTag:(int)btnTag{

    NSString *logId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"logId"]];
    NSString *token = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"token"]];
    NSString *userId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"userId"]];
    NSString *fightId = roomModel.fightId;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:logId,@"logId",token,@"token",userId,@"fromUserId",toUserId,@"toUserId",fightId,@"fightId",comment,@"comment",nil];
    
    loadView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [MyUtil requestPostURL:[NSString stringWithFormat:@"%@%@",kFFAPI,kFFAPI_FFFightVote] params:params success:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]] ) {
            [loadView hide:YES];
            NSString *error = [NSString stringWithFormat:@"%@",responseObject[@"error"]];
            if (error.integerValue==2006) {
                FFShowFightScoreModel *model = [FFShowFightScoreModel modelWithDictionary:responseObject[@"data"]];
                scoreByVote = model.score;//投票获得的积分
                
                if (btnTag==1001) {
                    //如果存在userInfoview,修改其中的投票按钮和label
                    UILabel *label_User_vote = [[[view_user_back viewWithTag:1] viewWithTag:10] viewWithTag:2001];
                    UIButton *btn_User_vote = [[[view_user_back viewWithTag:1] viewWithTag:10] viewWithTag:1001];
                    if (label_User_vote) {
                        label_User_vote.text = @"已投票";
                        btn_User_vote.enabled = NO;
                    }
                    
                    //主界面的投票按钮及分数修改，数据源修改
                    [_btn_voteLeft setTitle:@"已投票" forState:UIControlStateNormal];
                    [_btn_voteLeft setEnabled:NO];
//                    ((FFListFightUserModel *)roomModel.fightUsers[0]).voted = @"1";
                    fightUserModelLeft.voted = @"1";
                    fightUserModelLeft.score = [NSString stringWithFormat:@"%d",[fightUserModelLeft.score intValue]+1];
//                    ((FFListFightUserModel *)roomModel.fightUsers[0]).score = fightUserModelLeft.score;
                    _label_scoreLeft.text = [NSString stringWithFormat:@"%@票",fightUserModelLeft.score];
                    [self startBiggerAnimationDuration:0.5 View:_label_scoreLeft];
                    
                }else{
                    //如果存在userInfoview,修改其中的投票按钮和label
                    UILabel *label_User_vote = [[[view_user_back viewWithTag:1] viewWithTag:11] viewWithTag:2002];
                    UIButton *btn_User_vote = [[[view_user_back viewWithTag:1] viewWithTag:11] viewWithTag:1002];
                    if (label_User_vote) {
                        label_User_vote.text = @"已投票";
                        btn_User_vote.enabled = NO;
                    }
                    
                    //主界面的投票按钮及分数修改，数据源修改
                    [_btn_voteRight setTitle:@"已投票" forState:UIControlStateNormal];
                    [_btn_voteRight setEnabled:NO];
//                    ((FFListFightUserModel *)roomModel.fightUsers[1]).voted = @"1";
                    fightUserModelRight.voted = @"1";
                    fightUserModelRight.score = [NSString stringWithFormat:@"%d",[fightUserModelRight.score intValue]+1];
                    _label_scoreRight.text = [NSString stringWithFormat:@"%@票",fightUserModelRight.score];
                    [self startBiggerAnimationDuration:0.5 View:_label_scoreRight];
                }
                CGFloat tempValue = (CGFloat)(fightUserModelLeft.score.floatValue/(fightUserModelLeft.score.floatValue+fightUserModelRight.score.floatValue)) *10.0f;
                
                CGFloat progressWidth = tempValue/10.f;
                
                _line_score.progressValue = progressWidth;
            }else if (error.integerValue==2005) {
                ghostView.message = @"比赛已结束";
                [ghostView show];
            }else if (error.integerValue==2008) {
                ghostView.message = @"已投票";
                [ghostView show];
            }else{
                ghostView.message = @"投票失败";
                [ghostView show];
            }
        }
    } failure:^(NSError *error) {
        [loadView hide:YES];
        ghostView.message = @"网络出现问题，请稍后重试";
        [ghostView show];
        
    }];
    
}

//拉取房间分享信息
-(void)getShareInfo{
    
    __weak typeof(self) weakSelf = self;
    NSString *logId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"logId"]];
    NSString *token = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"token"]];
    NSString *userId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"userId"]];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"1",@"type",_fightIdStr?_fightIdStr:roomModel.fightId,@"fightId",userId,@"userId",@"0",@"presentId",nil];
    
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
//                ghostView.message = @"获取内容失败，请重新登陆后重试";
//                [ghostView show];
            }
        }
    } failure:^(NSError *error) {
        [loadView hide:YES];
        ghostView.message = @"网络出现问题，请稍后重试";
        [ghostView show];
        
    }];
    
}

#pragma mark -
#pragma mark - 分享相关
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



#pragma mark -UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return Main_Screen_Height-64;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //添加pageView
    [cell.contentView addSubview:self.setPageViewControllers];
    
    return cell;
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




#pragma mark - 下拉刷新的方法、上拉刷新的方法
- (void)headerRefresh{
    [self requestData];
    
}
- (void)footerRefresh{
    [self requestData];
}




@end
