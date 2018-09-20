//
//  FFWirteCommentsViewController.m
//  doulian
//
//  Created by Suny on 16/9/13.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import "FFWirteCommentsViewController.h"

@implementation FFWirteCommentsViewController
{
    OLGhostAlertView *ghostView;
    MBProgressHUD *loadView;
    int pageIndex;
    NSMutableArray *dataArray;
    UITextField *tfComment;
}

-(void)viewDidLoad{
    [super viewDidLoad];
//    [self configHeadView];
    [self addBackBtn];
    [self addRightBtnwithImgName:nil Title:@"发表"];
    [self initView];
    ghostView = [[OLGhostAlertView alloc] initWithTitle:nil message:nil timeout:0.6 dismissible:YES];
    ghostView.position = OLGhostAlertViewPositionCenter;
}

-(void)onClickRightBtn:(UIButton *)sender{
    
    //发布评论
    [self postCommentsData];
    
}

-(void)initView{
    tfComment = [[UITextField alloc] initWithFrame:CGRectMake(15, 64+15,SCREEN_WIDTH-15*2, 120)];
    tfComment.backgroundColor = [UIColor greenColor];
    [tfComment becomeFirstResponder];
    [tfComment setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [tfComment setContentVerticalAlignment:UIControlContentVerticalAlignmentTop];
    [self.view addSubview:tfComment];
}

-(void)postCommentsData{
    NSString *isLogin = (NSString *)[mUserDefaults valueForKey:@"isLogin"];
    if (![isLogin isEqualToString:@"1"]) {
        ghostView.message = @"请先登录";
        [ghostView show];
        return;
    }
        NSString *logId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"logId"]];
        NSString *token = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"token"]];
        NSString *userId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"userId"]];
    NSString *fightId = _fightId;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:fightId,@"fightId",userId,@"fromUserId",token,@"token",logId,@"logId",tfComment.text,@"comment",nil];
    
    loadView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [MyUtil requestPostURL:[NSString stringWithFormat:@"%@%@",kFFAPI,kFFAPI_FFPostComments] params:params success:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]] ) {
            [loadView hide:YES];
            NSString *error = [NSString stringWithFormat:@"%@",responseObject[@"error"]];
            if (error.integerValue==0) {
                ghostView.message = @"评论成功";
                [ghostView show];
                [self performSelector:@selector(popViewController) withObject:nil afterDelay:2.0];
            }else{
                ghostView.message = @"评论失败";
                [ghostView show];
            }
        }
    } failure:^(NSError *error) {
        [loadView hide:YES];
        ghostView.message = @"网络出现问题，请稍后重试";
        [ghostView show];
        
    }];
    
}


-(void)popViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
