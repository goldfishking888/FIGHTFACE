//
//  FFPresentDetailViewController.m
//  doulian
//
//  Created by Suny on 16/9/20.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import "FFPresentDetailViewController.h"
#import "FFContactAddressViewController.h"
#import "FFExchangeResultViewController.h"
#import "FFIntroduceWebViewController.h"

@implementation FFPresentDetailViewController
{
    OLGhostAlertView *ghostView;
    MBProgressHUD *loadView;
    int pageIndex;
    NSMutableArray *dataArray;
    
    UIImageView *leftImgV;
    
    UIImage *imageCurrent;
    
    UIButton *btnBuy;
    
    CGFloat ViewHeaderHeight;
    CGFloat ViewFooterHeight;
    
    CGFloat rate;
    
    UIScrollView *maintScrollView;
    
    UILabel *label_nameAndPhone;
    
    UILabel *label_addr;
    
    NSDictionary *paramsDic;
    
    UIWebView *webView_content;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    [self addBackBtn];
    [self addTitleLabel:@"礼品订单填写" withTitleColor:RGBColor(74, 74, 74)];
    [self addRightBtnwithImgName:nil Title:@"兑换说明" TitleColor:RGBColor(74, 74, 74)];
    [self initData];
    [self initScrollView];
    [self.view addSubview:self.footerView];
//    [self initView];
    ghostView = [[OLGhostAlertView alloc] initWithTitle:nil message:nil timeout:0.6 dismissible:YES];
    ghostView.position = OLGhostAlertViewPositionCenter;
    NSString *logId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"logId"]];
    NSString *token = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"token"]];
    NSString *urlStr = [NSString stringWithFormat:@"%@%@?logId=%@&token=%@&presentId=%@",kFFAPI,kFFAPI_FFGetPresentDescribe,logId,token,_pModel.presentId];
    [webView_content loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
    
    
}

-(void)initData{
    ViewHeaderHeight = 81.0;
    ViewFooterHeight = 67.0;
    rate = 1;
    //6 6s 7 375
    //5 5s se 320
    //6p 6sp 7p 414
    if (isiPhoneBelow5s) {
        rate = 320.0/375.0;
        ViewHeaderHeight = rate*ViewHeaderHeight;
        ViewFooterHeight = rate*ViewFooterHeight;
    }else if(isiPhoneUpper6plus){
        rate = 414.0/375.0;
        ViewHeaderHeight = rate*ViewHeaderHeight;
        ViewFooterHeight = rate*ViewFooterHeight;
    }
}

-(void)initScrollView{
    maintScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREENH_HEIGHT-64-ViewFooterHeight)];
    maintScrollView.delegate = self;
    [maintScrollView addSubview:self.headerView];
    [maintScrollView addSubview:self.contentView];
    [self.view addSubview:maintScrollView];
    
    maintScrollView.contentSize = CGSizeMake(SCREEN_WIDTH, SCREENH_HEIGHT-64-67);
}

-(UIView *)headerView{
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, ViewHeaderHeight)];
        _headerView.backgroundColor = RGBColor(231, 231, 231);
        _headerView.userInteractionEnabled = YES;
        [self.view addSubview:_headerView];
        
        UITapGestureRecognizer *tapHeader = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickHeaderView:)];
        [_headerView addGestureRecognizer:tapHeader];
        
        
        UIImageView *image_location = [[UIImageView alloc] initWithFrame:CGRectMake(15*rate, 32*rate, 18*rate, 18*rate)];
        [image_location setImage:[UIImage imageNamed:@"icon_location"]];
        [_headerView addSubview:image_location];
        
        label_nameAndPhone = [[UILabel alloc] initWithFrame:CGRectMake(48*rate, 16*rate, 250*rate, floor(rate*14))];
        label_nameAndPhone.font = [UIFont systemFontOfSize:floor(rate*14)];
        label_nameAndPhone.text = @"姓名 联系方式";
        label_nameAndPhone.textColor = RGBColor(74, 74, 74);
        [_headerView addSubview:label_nameAndPhone];
        
        label_addr = [[UILabel alloc] initWithFrame:CGRectMake(48*rate, 35*rate, 288*rate, floor(rate*12*2))];
        label_addr.font = [UIFont systemFontOfSize:floor(rate*12)];
        label_addr.text = @"收货地址:";
        label_addr.textColor = RGBColor(74, 74, 74);
        [_headerView addSubview:label_addr];
        
        UILabel *label_j = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-22*rate, 35*rate, 7*rate, 14*rate)];
        label_j.font = [UIFont systemFontOfSize:14];
        label_j.text = @">";
        label_j.textColor = RGBColor(74, 74, 74);
        [_headerView addSubview:label_j];
        NSDictionary *dic = [mUserDefaults valueForKey:@"UserContatsInfo"];
        if (dic) {
            [self setContactInfoDic:dic];
        }
    }
    
    return _headerView;
}


-(UIView *)contentView{
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, ViewHeaderHeight, SCREEN_WIDTH, maintScrollView.frame.size.height-ViewHeaderHeight)];
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.userInteractionEnabled = YES;
        [self.view addSubview:_contentView];
        
        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(16*rate, 16*rate, 112*rate, 112*rate)];
        [image setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kFFAPI,_pModel.photos]] placeholderImage:[UIImage imageNamed:@"比赛图片占位"]];
        [_contentView addSubview:image];
        
        UILabel *label_name = [[UILabel alloc] initWithFrame:CGRectMake(140*rate, 35*rate, 170*rate, floor(18*rate))];
        label_name.text = _pModel.name;
        label_name.textColor = RGBColor(74, 74, 74);
        label_name.font = [UIFont systemFontOfSize:floor(18*rate)];
        [_contentView addSubview:label_name];
        
        UILabel *label_num = [[UILabel alloc] initWithFrame:CGRectMake(140*rate, 70*rate, 50*rate, floor(14*rate))];
        label_num.text = @"件数：1";
        label_num.textColor = RGBColor(74, 74, 74);
        label_num.font = [UIFont systemFontOfSize:floor(14*rate)];
        [_contentView addSubview:label_num];
        
        UILabel *label_price = [[UILabel alloc] initWithFrame:CGRectMake(140*rate, 105*rate, 120*rate, floor(17*rate))];
        label_price.text = [NSString stringWithFormat:@"%@积分",_pModel.price];
        label_price.textColor = RGBColor(239, 77, 97);
        label_price.font = [UIFont systemFontOfSize:floor(17*rate)];
        [_contentView addSubview:label_price];
        
        UIView *view_line = [[UIView alloc] initWithFrame:CGRectMake(18*rate, 142*rate, SCREEN_WIDTH-18*rate, 1)];
        view_line.backgroundColor = RGBColor(231, 231, 231);
        [_contentView addSubview:view_line];
        
//        UILabel *label_content = [[UILabel alloc] initWithFrame:CGRectMake(18*rate, 150*rate, SCREEN_WIDTH-2*18*rate, _contentView.frame.size.height-142)];
//        label_content.numberOfLines = 0;
//        label_content.textAlignment = NSTextAlignmentLeft;
//        label_content.contentMode = UIViewContentModeTop;
//        label_content.textColor = RGBColor(74, 74, 74);
//        label_content.font = [UIFont systemFontOfSize:floor(14*rate)];
//        label_content.text = _pModel.describe;
//        [label_content sizeToFit];
//        [_contentView addSubview:label_content];
        
        webView_content = [[UIWebView alloc] initWithFrame:CGRectMake(0, view_line.frame.origin.y+1, SCREEN_WIDTH, _contentView.frame.size.height-view_line.frame.origin.y-1)];
        webView_content.delegate = self;
        webView_content.scrollView.showsHorizontalScrollIndicator = NO;
        webView_content.scrollView.showsVerticalScrollIndicator = NO;
        UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        singleTap.numberOfTouchesRequired = 1;
        singleTap.numberOfTapsRequired = 1;
        singleTap.delegate = self;
        singleTap.cancelsTouchesInView = NO;
        [webView_content addGestureRecognizer:singleTap];
        [webView_content setUserInteractionEnabled:YES];
        
        [_contentView addSubview:webView_content];
        
    }
    return _contentView;
}

-(UIView *)footerView{
    if (!_footerView) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREENH_HEIGHT-ViewFooterHeight, SCREEN_WIDTH, ViewFooterHeight)];
        _footerView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_footerView];
        
        UIView *view_line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
        view_line.backgroundColor = RGBColor(231, 231, 231);
        [_footerView addSubview:view_line];
        
        UILabel *label_total = [[UILabel alloc] initWithFrame:CGRectMake(18*rate, 24*rate, 55*rate, floor(17*rate))];
        label_total.text = @"合计：";
        label_total.textColor = RGBColor(74, 74, 74);
        label_total.font = [UIFont systemFontOfSize:floor(17*rate)];
        [_footerView addSubview:label_total];
        
        UILabel *label_price = [[UILabel alloc] initWithFrame:CGRectMake((18+55)*rate, 24*rate, 120*rate, floor(17*rate))];
        label_price.text = [NSString stringWithFormat:@"%@积分",_pModel.price];
        label_price.textColor = RGBColor(239, 77, 97);
        label_price.font = [UIFont systemFontOfSize:floor(17*rate)];
        [_footerView addSubview:label_price];
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(245*rate, 8*rate, 111*rate, 48*rate)];
        [btn setTitle:@"兑换" forState:UIControlStateNormal];
        btn.backgroundColor = RGBColor(251, 226, 84);
        [btn setTitleColor:RGBColor(60, 61, 39) forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:floor(rate*17)]];
        FFViewBorderRadius(btn, 48*rate/2, 1, RGBColor(54, 28, 29));
        [btn addTarget:self action:@selector(exchangePresent) forControlEvents:UIControlEventTouchUpInside];
        [_footerView addSubview:btn];

    }
    return _footerView;
}

//兑换说明
-(void)onClickRightBtn:(UIButton *)sender{
    FFIntroduceWebViewController * vc = [[FFIntroduceWebViewController alloc]init];
    vc.jumpRequest = [NSString stringWithFormat:@"%@%@",kFFAPI,kFFAPI_FFGetExchangeExplanation];
    vc.webTitle = @"兑换说明";
    [self.navigationController pushViewController:vc animated:YES];

}

//兑换说明
-(void)onClickHeaderView:(id *)sender{
    FFContactAddressViewController *conVC = [[FFContactAddressViewController alloc] init];
    conVC.delegate = self;
    conVC.infoDic = paramsDic;
    [self.navigationController pushViewController:conVC animated:YES];
}

-(void)exchangePresent{
    NSString *isLogin = (NSString *)[mUserDefaults valueForKey:@"isLogin"];
    if (![isLogin isEqualToString:@"1"]) {
        ghostView.message = @"请先登录";
        [ghostView show];
        return;
    }
    if(!paramsDic){
        ghostView.message = @"请填写联系方式";
        [ghostView show];
        return;
    }
    
    NSString *logId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"logId"]];
    NSString *token = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"token"]];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:logId,@"logId",token,@"token",@"1",@"num",_pModel.presentId,@"presentId",[paramsDic valueForKey:@"name"],@"realName",[paramsDic valueForKey:@"phone"],@"mobile",[paramsDic valueForKey:@"addr"],@"addr",nil];
    NSString *url =[NSString stringWithFormat:@"%@%@",kFFAPI,kFFAPI_FFExchangePresent];
    [MyUtil requestPostURL:url params:params success:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]] ) {
            
            NSString *error = [NSString stringWithFormat:@"%@",responseObject[@"error"]];
            if (error.integerValue==0) {
                [loadView hide:YES];
//                ghostView.message = [responseObject valueForKey:@"msg"];
//                [ghostView show];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ExchangePresentSucceed" object:nil];
                FFExchangeResultViewController *result = [[FFExchangeResultViewController alloc] init];
                result.isSucceed = YES;
                result.presentId = _pModel.presentId;
                result.msg = responseObject[@"msg"];
                [self.navigationController pushViewController:result animated:YES];
            }else if(error.integerValue==2010){
                [loadView hide:YES];
                ghostView.message = @"积分不足";
                [ghostView show];
            }else if(error.integerValue==2011){
                [loadView hide:YES];
//                ghostView.message = @"兑换失败";
//                [ghostView show];
                FFExchangeResultViewController *result = [[FFExchangeResultViewController alloc] init];
                result.isSucceed = NO;
                result.msg = responseObject[@"msg"];
                [self.navigationController pushViewController:result animated:YES];
            }else{
                [loadView hide:YES];
//                ghostView.message = @"兑换失败";
//                [ghostView show];
                FFExchangeResultViewController *result = [[FFExchangeResultViewController alloc] init];
                result.isSucceed = NO;
                [self.navigationController pushViewController:result animated:YES];
            }
        }
    } failure:^(NSError *error) {
        [loadView hide:YES];
        ghostView.message = @"网络出现问题，请稍后重试";
        [ghostView show];
        
    }];
    
}

-(void)setContactInfoDic:(NSDictionary *)dicInfo{
    label_nameAndPhone.text = [NSString stringWithFormat:@"%@ %@",[dicInfo valueForKey:@"name"],[dicInfo valueForKey:@"phone"]];
    label_addr.text = [dicInfo valueForKey:@"addr"];
    paramsDic = dicInfo;
}


//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//    return YES;
//}

-(void)handleSingleTap:(UITapGestureRecognizer *)sender{
//    CGPoint point = [sender locationInView:self.view];
//    NSLog(@"handleSingleTap!pointx:%f,y:%f",point.x,point.y);
    [webView_content stringByEvaluatingJavaScriptFromString:@"document.activeElement.blur()"];
}


#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    return YES;
}

@end
