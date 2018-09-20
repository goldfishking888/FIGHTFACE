//
//  FFInFightPresentsViewController.m
//  doulian
//
//  Created by 孙扬 on 16/10/28.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import "FFInFightPresentsViewController.h"
#import "FFPresentOuterModel.h"
#import "FFPresentModel.h"

#import "FFStoreViewController.h"

#define ScroolViewHeight 240
#define ScroolViewWidth SCREEN_WIDTH
//#define InnerSpace 5

static CGFloat InnerSpace = 10;


@interface FFInFightPresentsViewController ()

@end

@implementation FFInFightPresentsViewController
{
    UIScrollView *scrollview_tool;
    NSMutableArray *arrayPresents;
    OLGhostAlertView *ghostView;
    int count ;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (isiPhoneBelow5s) {
        InnerSpace = 5;
    }

    ghostView = [[OLGhostAlertView alloc] initWithTitle:nil message:nil timeout:0.6 dismissible:YES];
    ghostView.position = OLGhostAlertViewPositionCenter;
    
    [self getAvailableToolInFight];
//    [self initScroolView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAvailableToolInFight) name:@"DidUsePresent" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAvailableToolInFight) name:@"OnRefreshTool" object:nil];
    
    count = 0;

}

-(void)initScroolView{
    if (scrollview_tool) {
        scrollview_tool = nil;
    }
//    scrollview_back = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREENH_HEIGHT - 64 - 41)];
//    //    scrollview_tool.center = view_black.center;
//    scrollview_back.backgroundColor = [UIColor blueColor];
//    scrollview_back.showsHorizontalScrollIndicator = NO;
//    scrollview_back.showsVerticalScrollIndicator = NO;
//    scrollview_back.delegate = self;
//    scrollview_back.pagingEnabled = YES;
//    //    scrollview_tool.hidden = YES;
//    scrollview_back.contentSize = CGSizeMake(SCREEN_WIDTH, SCREENH_HEIGHT);
//    [self.view addSubview:scrollview_back];
    
    UIView *viewBack = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREENH_HEIGHT - 64 - 41)];
    viewBack.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:viewBack];
    
    scrollview_tool = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, ScroolViewHeight)];
//    scrollview_tool.center = view_black.center;
    scrollview_tool.backgroundColor = [UIColor whiteColor];
    scrollview_tool.showsHorizontalScrollIndicator = NO;
    scrollview_tool.showsVerticalScrollIndicator = NO;
    scrollview_tool.delegate = self;
    scrollview_tool.pagingEnabled = YES;
//    scrollview_tool.hidden = YES;
    scrollview_tool.contentSize = CGSizeMake(SCREEN_WIDTH*(arrayPresents.count/2+arrayPresents.count%2), (SCREEN_WIDTH-10*4)/2+10);
    [viewBack addSubview:scrollview_tool];
    
    if (arrayPresents.count==0) {
        [self showNoToolView];
        return;

    }
    
    for (int i = 0; i<arrayPresents.count; i++) {
        
        FFPresentOuterModel *pmodel_outer = [FFPresentOuterModel modelWithDictionary:arrayPresents[i]];
        FFPresentListModel *pmodel = pmodel_outer.present;
        
        UIImageView *view_gray = [[UIImageView alloc] initWithFrame:CGRectMake(i*SCREEN_WIDTH/2+10 , 8,(SCREEN_WIDTH-10*4)/2, (SCREEN_WIDTH-10*4)/2)];
        if (isiPhoneBelow5s) {
            view_gray.frame = CGRectMake(i*SCREEN_WIDTH/2+10 , 8,(SCREEN_WIDTH-10*4)/2, (SCREEN_WIDTH-10*4)/2+10);
        }

        view_gray.image = [UIImage imageNamed:@"道具大卡片"];
        view_gray.tag = 2000+i;
        view_gray.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickPresent:)];

        [view_gray addGestureRecognizer:tap];
        
        [scrollview_tool addSubview:view_gray];
        
//        UIImageView *image_name = [[UIImageView alloc] initWithFrame:CGRectMake(view_gray.frame.size.width/2-80/2, 8, 80, 21)];
//        image_name.image = [UIImage imageNamed:@"胡撕乱打"];
//        [view_gray addSubview:image_name];
        
        UILabel *label_name = [[UILabel alloc] initWithFrame:CGRectMake(view_gray.frame.size.width/2-80/2, 10, 80, 21)];
        label_name.text = pmodel.name;
        label_name.font = [UIFont boldSystemFontOfSize:19];
        label_name.textColor = [UIColor grayColor];
        label_name.textAlignment = NSTextAlignmentCenter;
        [view_gray addSubview:label_name];
//
        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(view_gray.frame.size.width/2-70/2-10, label_name.frame.origin.y+label_name.frame.size.height+InnerSpace, 70, 70)];
        image.tag = 3000+i;
        [image setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kFFAPI,pmodel.photos]] placeholderImage:[UIImage imageNamed:@"比赛图片占位"]];
        image.contentMode  = UIViewContentModeScaleAspectFit;
        [view_gray addSubview:image];
        
        UIImageView *imagex = [[UIImageView alloc] initWithFrame:CGRectMake(image.frame.origin.x+image.frame.size.width+5, image.frame.origin.y+image.frame.size.height-12, 12, 13)];
        [imagex setImage:[UIImage imageNamed:@"x"]];
        [view_gray addSubview:imagex];
        
        if (![pmodel.useInFight isEqualToString:@"1"]) {
            [MyUtil addTopScaleView:image];
            [MyUtil addTopScaleView:imagex];
        }
//
        if (pmodel_outer.num.intValue>=10) {
            UIImageView *imageNum = [[UIImageView alloc] initWithFrame:CGRectMake(imagex.frame.origin.x+imagex.frame.size.width, imagex.frame.origin.y-6, 18, 19)];
            [imageNum setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d",pmodel_outer.num.intValue/10]]];
            [view_gray addSubview:imageNum];
            
            UIImageView *imageNum2 = [[UIImageView alloc] initWithFrame:CGRectMake(imageNum.frame.origin.x+imageNum.frame.size.width, imagex.frame.origin.y-6, 18, 19)];
            [imageNum2 setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d",pmodel_outer.num.intValue%10]]];
            [view_gray addSubview:imageNum2];
            
            if (pmodel_outer.num.intValue>=100) {
                [imageNum setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d",9]]];
                [imageNum2 setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d",9]]];
            }
            if (![pmodel.useInFight isEqualToString:@"1"]) {
                [MyUtil addTopScaleView:imageNum];
                [MyUtil addTopScaleView:imageNum2];
            }
            
            
        }else{
            UIImageView *imageNum = [[UIImageView alloc] initWithFrame:CGRectMake(imagex.frame.origin.x+imagex.frame.size.width, imagex.frame.origin.y-6, 18, 19)];
            [imageNum setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@",pmodel_outer.num]]];
            [view_gray addSubview:imageNum];
            if (![pmodel.useInFight isEqualToString:@"1"]) {
                [MyUtil addTopScaleView:imageNum];
                
            }

        }
        //
        UILabel *label_intro = [[UILabel alloc] initWithFrame:CGRectMake(5, image.frame.origin.y+image.frame.size.height+InnerSpace, view_gray.frame.size.width -2*5, 40)];
        label_intro.numberOfLines = 0;
        label_intro.font = [UIFont systemFontOfSize:13];
        if (isiPhoneBelow5s) {
            label_intro.font = [UIFont systemFontOfSize:11];
        }
//        label_intro.backgroundColor = [UIColor yellowColor];
        label_intro.lineBreakMode = NSLineBreakByWordWrapping;
        label_intro.textAlignment = NSTextAlignmentCenter;
        label_intro.text = pmodel.describe;
        [view_gray addSubview:label_intro];
        
    }

}

-(void)showNoToolView{
    
    UILabel *label_intro = [[UILabel alloc] initWithFrame:CGRectMake(10,20, SCREEN_WIDTH -2*10, 18)];
    label_intro.numberOfLines = 0;
    //label_intro.backgroundColor = [UIColor yellowColor];
    //    label_intro.lineBreakMode = NSLineBreakByWordWrapping;
    label_intro.font = [UIFont systemFontOfSize:18];
    label_intro.textAlignment = NSTextAlignmentCenter;
    label_intro.text = @"你还没有道具卡";
    [scrollview_tool addSubview:label_intro];
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"~去商城兑换吧~"];
    [str addAttribute:NSForegroundColorAttributeName value:RGBColor(85, 164, 255) range:NSMakeRange(2,4)];
    
    UILabel *label_intro2 = [[UILabel alloc] initWithFrame:CGRectMake(10, label_intro.frame.origin.y+label_intro.frame.size.height, SCREEN_WIDTH -2*10, 30)];
    label_intro2.numberOfLines = 0;
    //label_intro.backgroundColor = [UIColor yellowColor];
    //    label_intro.lineBreakMode = NSLineBreakByWordWrapping;
    label_intro2.font = [UIFont systemFontOfSize:18];
    label_intro2.textAlignment = NSTextAlignmentCenter;
    label_intro2.attributedText = str;;
    label_intro2.userInteractionEnabled = YES;
    [scrollview_tool addSubview:label_intro2];
    
    UITapGestureRecognizer *tapStore = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoStoreVC:)];
    [label_intro2 addGestureRecognizer:tapStore];
    
}


-(void)gotoStoreVC:(id)sender{
    FFStoreViewController *store = [[FFStoreViewController alloc] init];
    store.isFromCreateOrRoom = YES;
    [self.navigationController pushViewController:store animated:YES];
}

-(void)getAvailableToolInFight{
    if (![MyUtil isLogin]) {
//        ghostView.message = @"请先登录";
//        [ghostView show];
        return;
    }
    NSString *logId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"logId"]];
    NSString *token = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"token"]];
    //    NSString *userId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"userId"]];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:logId,@"logId",token,@"token",nil];
    
    //    loadView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [MyUtil requestPostURL:[NSString stringWithFormat:@"%@%@",kFFAPI,kFFAPI_FFFightRoomPresentsInFight] params:params success:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]] ) {
//            [loadView hide:YES];
            NSString *error = [NSString stringWithFormat:@"%@",responseObject[@"error"]];

            if (error.integerValue==0) {
                arrayPresents = [responseObject valueForKey:@"data"];
                [self initScroolView];
                //                NSString *msg = [NSString stringWithFormat:@"%@",responseObject[@"msg"]];
                //                ghostView.message = msg;
                //                [ghostView show];
                //                _responseDic = responseObject;
                //
                //                _dataDic = [_responseDic valueForKey:@"data"];
                //斗脸进行中，轮询接口
                NSLog(@"FightPresent count = %d",count++);
                
            }else{
//                ghostView.message = @"获取内容失败，请稍后重试";
//                [ghostView show];
            }
        }
    } failure:^(NSError *error) {
        //        [_tableView headerEndRefreshing];
        //        [_tableView footerEndRefreshing];
//        [loadView hide:YES];
//        ghostView.message = @"网络出现问题，请稍后重试";
//        [ghostView show];
//        
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
            NSString *error = [NSString stringWithFormat:@"%@",responseObject[@"error"]];
            if (error.integerValue==0) {
                NSDictionary *dataDic = [responseObject valueForKey:@"data"];
                for (NSString *key in dataDic.allKeys) {
                    if ([key isEqualToString:@"userPresents"]) {
                        if ([dataDic valueForKey:@"userPresents"]) {
                            arrayPresents = [dataDic valueForKey:@"userPresents"];
                        }
                    }
                }
            }else{
                
            }
        }
    } failure:^(NSError *error) {
        
        
    }];
    
}


-(void)onClickPresent:(id)sender{
    if ([MyUtil jumpToLoginVCIfNoLogin]) {
        return;
    }
    
    UITapGestureRecognizer *singleTap = (UITapGestureRecognizer *)sender;
//    NSLog(@"%d",[singleTap view].tag]);
    long int i = [singleTap view].tag-2000;
    FFPresentOuterModel *pmodel_outer = [FFPresentOuterModel modelWithDictionary:arrayPresents[i]];
    FFPresentListModel *pmodel = pmodel_outer.present;
    
    if (![pmodel.useInFight isEqualToString:@"1"]) {
        ghostView.message = @"该道具对战中不可用";
        [ghostView show];
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"resetContentInset" object:nil userInfo:[NSDictionary dictionaryWithObject:pmodel.presentId forKey:@"presentId"]] ;
//    [mUserDefaults setValue:@"1" forKey:@"IsDuringChoosingPresent"];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
//    NSLog(@"child");
    
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
