//
//  FFIntroduceWebViewController.m
//  doulian
//
//  Created by WangJinyu on 16/9/29.
//  Copyright © 2016年 maomao. All rights reserved.
//关于斗脸web

#import "FFIntroduceWebViewController.h"

@interface FFIntroduceWebViewController ()<UIWebViewDelegate>
{
    UIWebView *_webView;
    OLGhostAlertView *_ghostView;
    MBProgressHUD *_progressView;
    WebViewJavascriptBridge* bridge;
}
@end

@implementation FFIntroduceWebViewController
-(void)addTitleLabel:(NSString*)title
{
    UILabel *titleLabel4 = [[UILabel alloc]initWithFrame:CGRectMake(30, 10+self.num, SCREEN_WIDTH - 30 * 2, 25)] ;
    [titleLabel4 setTextAlignment:NSTextAlignmentCenter];
    [titleLabel4 setBackgroundColor:[UIColor clearColor]];
    [titleLabel4 setTextColor:[UIColor blackColor]];
    [titleLabel4 setFont:[UIFont fontWithName:@"Courier" size: 17]];
    [titleLabel4 setText:title];
    [self.view addSubview:titleLabel4];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackBtn];
    [self addHeadViewLine];
   
    [self addTitleLabel:_webTitle];
    _ghostView=[[OLGhostAlertView alloc]initWithTitle:nil message:nil timeout:1 dismissible:YES];
    _ghostView.position=OLGhostAlertViewPositionCenter;
    
    _webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 44 + self.num, SCREEN_WIDTH, SCREENH_HEIGHT - 44 - self.num)];
    _webView.delegate = self;
//    _webView.scalesPageToFit = YES;
    _webView.scrollView.showsHorizontalScrollIndicator = NO;
    _webView.scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_webView];
    [self initJsBridge];
    
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_jumpRequest]]];
    _progressView=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _progressView.userInteractionEnabled=NO;
}

#pragma mark 初始化jsBridge
- (void) initJsBridge{
    
    if (_bridge) {
        return;
    }
    //    __block typeof(self) weakSelf = self;
    [WebViewJavascriptBridge enableLogging];
    _bridge = [WebViewJavascriptBridge bridgeForWebView:_webView webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) {
        responseCallback(@"WebViewJavascriptBridge connect");
    }];
    
//    //申请入职奖金
//    [_bridge registerHandler:@"applyBonus" handler:^(id data, WVJBResponseCallback responseCallback) {
//        NSLog(@"applyBonus %@", data);
//        
//        //        HRLogin *loginVC = [[HRLogin alloc]init];
//        //        [self.navigationController pushViewController:loginVC animated:YES];
//        
//        ApplyEntryBounsViewController *vc = [[ApplyEntryBounsViewController alloc] init];
//        [self.navigationController pushViewController:vc animated:YES];
//    }];
//    
//    //申请私信
//    [_bridge registerHandler:@"checkJobList" handler:^(id data, WVJBResponseCallback responseCallback) {
//        for (UIViewController *item in self.navigationController.viewControllers) {
//            if ([item isKindOfClass:[ICSDrawerController class]]) {
//                [(ICSDrawerController *)item close];
//                [self.navigationController popToViewController:item animated:YES];
//                return ;
//            }
//        }
//        //若从普通职位列表进入web跳转，需要重新创建
//        SeniorJobListViewController *main = [[SeniorJobListViewController alloc] init];
//        SeniorJobRightViewController *right = [[SeniorJobRightViewController alloc] init];
//        ICSDrawerController *drawer = [[ICSDrawerController alloc] initWithRightViewController:right
//                                                                          centerViewController:main];
//        [self.navigationController pushViewController:drawer animated:YES];
//    }];
    
}



#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    if (_progressView) {
        [_progressView hide:YES];
    }
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    if (_progressView) {
        [_progressView hide:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
