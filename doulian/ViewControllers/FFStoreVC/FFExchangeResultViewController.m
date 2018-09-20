//
//  FFExchangeResultViewController.m
//  doulian
//
//  Created by 孙扬 on 16/11/8.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import "FFExchangeResultViewController.h"
#import "RootViewController.h"
#import "UMSocialUIManager.h"
#import "FFShareModel.h"

@interface FFExchangeResultViewController ()

@end

@implementation FFExchangeResultViewController{
    CGFloat rate;
    UIImageView *shareImage;
    OLGhostAlertView *ghostView;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackBtn];
    [self addTitleLabel:@"礼品兑换" withTitleColor:RGBColor(74, 74, 74)];
    [self initData];
    [self initView];
    
    ghostView = [[OLGhostAlertView alloc] initWithTitle:nil message:nil timeout:0.6 dismissible:YES];
    ghostView.position = OLGhostAlertViewPositionCenter;
    
    [self getShareInfo];
}

-(void)initData{
    rate = 1;
    //6 6s 7 375
    //5 5s se 320
    //6p 6sp 7p 414
    if (isiPhoneBelow5s) {
        rate = 320.0/375.0;
    }else if(isiPhoneUpper6plus){
        rate = 414.0/375.0;
    }
}

-(void)initView{
    UIView *view_back = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-296*rate)/2, 138*rate, 296*rate, 371*rate)];
    view_back.backgroundColor = [UIColor whiteColor];
    FFViewBorderRadius(view_back, 6, 1, RGBColor(231, 231, 231));
    [self.view addSubview:view_back];
    
    UIImageView *image_back = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-87*rate)/2, 106*rate, 87*rate, 87*rate)];
    image_back.backgroundColor = RGBColor(251, 226, 84);
    [self.view addSubview:image_back];
    
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, 54*rate, 54*rate)];
    image.center = image_back.center;
    if (_isSucceed) {
        [image setImage:[UIImage imageNamed:@"成功"]];
    }else{
        [image setImage:[UIImage imageNamed:@"失败"]];
    }
    [self.view addSubview:image];
    
    UILabel *label_title = [[UILabel alloc] initWithFrame:CGRectMake(111 *rate, 82*rate, 74*rate, floor(18*rate))];
    label_title.textAlignment = NSTextAlignmentCenter;
    label_title.textColor = RGBColor(74, 74, 74);
    label_title.font = [UIFont systemFontOfSize:floor(18*rate)];
    if (_isSucceed) {
        [label_title setText:@"兑换成功"];
    }else{
        [label_title setText:@"兑换失败"];
    }
    [view_back addSubview:label_title];
    
    UILabel *label_content = [[UILabel alloc] initWithFrame:CGRectMake((view_back.frame.size.width-238*rate)/2, 143*rate, 238*rate, 58*rate)];
//    label_content.text = @"系统会在3天内审核发货并及时给您系统消息通知请注意查收";
    label_content.text = _msg;
    if (!_isSucceed) {
        [label_content setFrame:CGRectMake((view_back.frame.size.width-231*rate)/2, 143*rate, 231*rate, floor(14*rate))];
        label_content.text = @"兑换的人太多了，请喝杯茶再来~";
    }
    label_content.numberOfLines = 0;
    label_content.textAlignment = NSTextAlignmentCenter;
    label_content.textColor = RGBColor(74, 74, 74);
    label_content.font = [UIFont systemFontOfSize:floor(14*rate)];
    [view_back addSubview:label_content];
    
    UIView *view_line = [[UIView alloc] initWithFrame:CGRectMake((view_back.frame.size.width-249*rate)/2, 238*rate, 249*rate, 1)];
    view_line.backgroundColor = RGBColor(231, 231, 231);
    [view_back addSubview:view_line];
    
    UIButton *btn_left = [[UIButton alloc] initWithFrame:CGRectMake(26*rate, 285*rate, 113*rate, 36*rate)];
    btn_left.backgroundColor = RGBColor(251, 226, 84);
    FFViewBorderRadius(btn_left, 36*rate/2, 1, RGBColor(54, 28, 29));
    [btn_left setTitleColor:RGBColor(74, 74, 74) forState:UIControlStateNormal];
    btn_left.tag = 1;
    if (_isSucceed) {
        [btn_left setTitle:@"晒单" forState:UIControlStateNormal];
    }else{
        [btn_left setTitle:@"取消" forState:UIControlStateNormal];
    }
    [btn_left addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [view_back addSubview:btn_left];
    
    UIButton *btn_right = [[UIButton alloc] initWithFrame:CGRectMake(154*rate, 285*rate, 113*rate, 36*rate)];
    btn_right.backgroundColor = RGBColor(251, 226, 84);
    FFViewBorderRadius(btn_right, 36*rate/2, 1, RGBColor(54, 28, 29));
    [btn_right setTitleColor:RGBColor(74, 74, 74) forState:UIControlStateNormal];
    btn_right.tag = 2;
    [btn_right setTitle:@"再去逛逛" forState:UIControlStateNormal];
    [btn_right addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [view_back addSubview:btn_right];
    
}

-(void)btnClicked:(UIButton *)sender{
    switch (sender.tag) {
        case 1:
        {
            if (_isSucceed) {
                //分享晒单
                __weak typeof(self) weakSelf = self;
                 [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMShareMenuSelectionView *shareSelectionView, UMSocialPlatformType platformType) {
                    
                    [weakSelf shareWebPageToPlatformType:platformType ShareModel:_shareModel];
                }];
            }else{
                //取消
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
            break;
        case 2:
        {
            //再去逛逛
            for (UIViewController *item in self.navigationController.viewControllers) {
                if ([item isKindOfClass:[RootViewController class]]) {
                    [self.navigationController popToViewController:item animated:true];
                }
            }
        }
            break;
            
        default:
            break;
    }
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

    }];
}


//拉取房间分享信息
-(void)getShareInfo{
    
    __weak typeof(self) weakSelf = self;
    NSString *logId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"logId"]];
    NSString *token = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"token"]];
    NSString *userId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"userId"]];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"4",@"type",userId,@"userId",@"0",@"fightId",_presentId,@"presentId",nil];
    
    [MyUtil requestPostURL:[NSString stringWithFormat:@"%@%@",kFFAPI,kFFAPI_FFGetShareInfo] params:params success:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]] ) {
            NSString *error = [NSString stringWithFormat:@"%@",responseObject[@"error"]];
            if (error.integerValue==0) {
                _shareModel = [FFShareModel modelWithDictionary:responseObject[@"data"]];
                shareImage  = [[UIImageView alloc] initWithFrame:CGRectMake(0, -100, 30, 30)];
                [shareImage setImageWithURL:[NSURL URLWithString:_shareModel.pic]];
                
            }else{
                ghostView.message = @"获取内容失败，请重新登陆后重试";
                [ghostView show];
            }
        }
    } failure:^(NSError *error) {
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

@end
