//
//  FFFindingFightViewController.m
//  doulian
//
//  Created by Suny on 2016/10/13.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import "FFFindingFightViewController.h"
#import "lhCircleView.h"
#import "LLProgressView.h"
#import "RootViewController.h"

#define DefaultTimeToHide 5

@interface FFFindingFightViewController ()
{
    UILabel *label_center;
}
@property (nonatomic, strong)    LLProgressView * circleView;

@end

@implementation FFFindingFightViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    [self addBackBtn];
    [self initView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReveiveFightNotification:) name:@"FoundFaceFight" object:nil];
    [self performSelector:@selector(backUp:) withObject:nil afterDelay:DefaultTimeToHide];
}

-(void)initView{
    _circleView = [[LLProgressView alloc]initWithFrame:CGRectMake(0, 0, 250, 250)];
    //    circleView.backgroundColor = [UIColor orangeColor];
    _circleView.center = self.view.center;
    [self.view addSubview:_circleView];
    
    label_center = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 60)];
    label_center.center = self.view.center;
    label_center.text = @"匹配结果中...";
    label_center.font = [UIFont systemFontOfSize:20];
    [label_center setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:label_center];
    
    [self startAnimation:nil];
    
    
}

//返回到首页
-(void)backUp:(id)sender{
    NSMutableArray *array = (NSMutableArray *)[self.navigationController viewControllers];
    for (UIViewController *item in array) {
        if ([item isKindOfClass:[RootViewController class]]   ) {
            [self.navigationController popToViewController:item animated:YES];
        }
    }
}

//收到了匹配成功的通知
-(void)didReveiveFightNotification:(NSNotification *)noti{
    
}

- (IBAction)startAnimation:(id)sender {
    [_circleView startCircleAnimation:^(BOOL isFinish) {
        NSLog(@"整个动画结束了！！！");
    }];
//    __block LLProgressView *targetView = _circleView;
//    dispatch_time_t time_after = dispatch_time(DISPATCH_TIME_NOW, 5.0*NSEC_PER_SEC);
//    dispatch_after(time_after, dispatch_get_main_queue(), ^{
//        targetView.isCircleStop = YES;
//        NSLog(@"耗时工作结束了！！！兄弟！！！");
//    });
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
