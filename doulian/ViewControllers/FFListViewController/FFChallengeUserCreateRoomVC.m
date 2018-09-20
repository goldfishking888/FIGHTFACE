//
//  FFChallengeUserCreateRoomVC.m
//  doulian
//
//  Created by WangJinyu on 16/9/27.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import "FFChallengeUserCreateRoomVC.h"
#import "FFFightRoomViewController.h"
#import "FFFaceHistoryViewController.h"

#import "FFPresentOuterModel.h"
#import "FFPresentListModel.h"

#import "FFFaceHistoryCell.h"
#import "FFStoreViewController.h"


#define FFTableCellHeight 70
#define FFTableCellPicSize 50

#define ScroolViewHeight 330
#define ScroolViewWidth 250


//@interface FFChallengeUserCreateRoomVC ()
//
//@end

@implementation FFChallengeUserCreateRoomVC
{
    OLGhostAlertView *ghostView;
    MBProgressHUD *loadView;
    int pageIndex;
    NSMutableArray *dataArray;
    
    UIImageView *leftImgV;
    
    UIImagePickerController *imagePickerController;
    
    UIImage *imageCurrent;
    
    UIButton *btnStart;
    
    BOOL isSearching;//正在搜寻匹配
    
    BOOL isHistoryPic;
    NSString *imageUrlHis;
    
    NSTimer *timerWait;
    int timeInLine;
    
    NSString *presentId;//道具id
    
    NSString *catchWord;//斗脸宣言
    int pageIndex_history;
    NSString *url_imageCurrent;
    NSIndexPath *chosenIndexPath;//选中图片的indexPath;
    
    UITextField *tf_catchWord;//宣言输入框
    
    UIView *view_black;//道具黑背景
    
    UIScrollView *scrollview_tool;
    
    UIButton *btn_choosePresend;
    
    UIButton *btn_goLeft;
    UIButton *btn_goRight;
    CGFloat ViewBackHeight;
    
    CGFloat ViewCatchHeight;
    CGFloat ViewToolHeight;
}

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
     [self addBackBtn];
    [self addTitleLabel:@"应战"];
    [self initData];
    [self initView];
    [self addRightBtnwithImgName:nil Title:@"确定"];
    ghostView = [[OLGhostAlertView alloc] initWithTitle:nil message:nil timeout:0.6 dismissible:YES];
    ghostView.position = OLGhostAlertViewPositionCenter;
    [self initToolView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestCheckFight) name:@"OnRefreshTool" object:nil];

}

-(void)initData{

    presentId = @"0";
    catchWord = @"";
    pageIndex_history  = 1;
    
    ViewCatchHeight = 80;
    ViewToolHeight = 45;
    
    if (isiPhoneBelow5s) {
        ViewBackHeight = 420;
    }else if (isiPhoneUpper6plus) {
        ViewBackHeight = 510;
    }else{
        ViewBackHeight = 470;
    }
    [self getHistoryFaceListsWithPage:(int)pageIndex_history];
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

-(void)btnClick:(UIButton *)sender{
    UIButton *btn = (UIButton *)sender;
    switch (btn.tag) {
        case 10000:
        {
            imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.delegate = self;
            imagePickerController.allowsEditing = YES;
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            
            [self presentViewController:imagePickerController animated:YES completion:^{}];
        }
            break;
        case 10001:
        {
            imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.delegate = self;
            imagePickerController.allowsEditing = YES;
            imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            
            [self presentViewController:imagePickerController animated:YES completion:^{}];
            
        }
            break;
        case 10002:
        {
            FFFaceHistoryViewController *h = [FFFaceHistoryViewController new];
            h.delegate = self;
            [self.navigationController pushViewController:h animated:YES];
        }
            break;
            
        default:
            break;
    }
}

-(void)setImageUrl:(NSString *)urlStr{
    NSString *str = kConJoinURL(kFFAPI, urlStr);
    [leftImgV setImageWithURL:[NSURL URLWithString:str]];
    imageUrlHis = urlStr;
    isHistoryPic = YES;
    [btnStart setEnabled:YES];
    [btnStart setBackgroundColor:[UIColor orangeColor]];
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
                //                if (isNewUploadedPic) {
                //                    NSIndexPath *first_indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
                //                    FFFaceHistoryCell *cell = (FFFaceHistoryCell *)[_collectionView cellForItemAtIndexPath:first_indexPath];
                //                    [cell.btnTag setBackgroundColor:[UIColor redColor]];
                //                }
                
                
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
//                isNewUploadedPic = YES;
                [self getHistoryFaceListsWithPage:pageIndex_history];
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

-(void)startChallengeWithImgUrl:(NSString *)imgUrl{
    NSString *logId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"logId"]];
    NSString *token = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"token"]];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:logId,@"logId",token,@"token",imgUrl,@"avatarUrl",presentId?presentId:@"0",@"presentId",[_dataDic valueForKey:@"userId"],@"toUserId",[catchWord stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],@"catchWord",nil];
    //    [loadView showWhileExecuting:@selector(myProgressTask) onTarget:self withObject:nil animated:YES];
    
    [MyUtil requestPostURL:[NSString stringWithFormat:@"%@%@",kFFAPI,kFFAPI_FFChanllengeUser] params:params success:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]] ) {
            
            NSString *error = [NSString stringWithFormat:@"%@",responseObject[@"error"]];
            if (error.integerValue==0) {
                
                ghostView.message = @"发起挑战成功";
                [ghostView show];
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [loadView hide:YES];
                ghostView.message = @"发起挑战失败";
                [ghostView show];
            }
        }
    } failure:^(NSError *error) {
        [loadView hide:YES];
        ghostView.message = @"网络出现问题，请稍后重试";
        [ghostView show];
        
    }];
}

-(void)acceptChallengeWithImgUrl:(NSString *)imgUrl{
    NSString *logId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"logId"]];
    NSString *token = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"token"]];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:logId,@"logId",token,@"token",imgUrl,@"avatarUrl",presentId?presentId:@"0",@"presentId",_challengeId,@"challengeId",[catchWord stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],@"catchWord",nil];
    //    [loadView showWhileExecuting:@selector(myProgressTask) onTarget:self withObject:nil animated:YES];
    
    [MyUtil requestPostURL:[NSString stringWithFormat:@"%@%@",kFFAPI,kFFAPI_FFAcceptChanllenge] params:params success:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]] ) {
            
            NSString *error = [NSString stringWithFormat:@"%@",responseObject[@"error"]];
            if (error.integerValue==0) {
                
                NSDictionary *dataDic = responseObject;
                
                FFFightRoomViewController *r = [FFFightRoomViewController new];
                r.responseDic = dataDic;
                r.dataDic = [dataDic valueForKey:@"data"];
                [self.navigationController pushViewController:r animated:YES];
            }else{
                [loadView hide:YES];
                ghostView.message = @"应战失败";
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
    
    //    if (!catchWord) {
    //        ghostView.message = @"请先选一张图片";
    //        [ghostView show];
    //    }
    
    //    if (!url_imageCurrent) {
    //        ghostView.message = @"请先选一张图片";
    //        [ghostView show];
    //    }
    
    
    
    
    if (_isAcceptChallenge) {
        [self acceptChallengeWithImgUrl:url_imageCurrent];
    }else{
        [self startChallengeWithImgUrl:url_imageCurrent];
    }
    
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


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    chosenIndexPath = nil;
    
    imageCurrent = [info objectForKey:UIImagePickerControllerEditedImage];//得到当前的image
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
    //压缩图片至<=100k
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
