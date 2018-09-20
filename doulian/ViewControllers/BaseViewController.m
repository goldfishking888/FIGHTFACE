//
//  BaseViewController.m
//  doulian
//
//  Created by Suny on 16/8/24.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()
{

}
@end

@implementation BaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    float topdistance = 0;
    long losVersion = [[UIDevice currentDevice].systemVersion floatValue] * 10000;
    if (losVersion >= 70000) {
        topdistance = 20;
    }
    self.num =topdistance;
    self.view.backgroundColor = kBackgraoudColorDefault;
}

- (void)addBackBtn
{
    [self configHeadView];
    _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _backBtn.frame = CGRectMake(10,10+self.num,51,21);
    [_backBtn.titleLabel setFont:[UIFont fontWithName:@"Courier" size:17]];
    [_backBtn addTarget:self action:@selector(backUp:) forControlEvents:UIControlEventTouchUpInside];
    [_backBtn setBackgroundImage:[UIImage imageNamed:@"btn_back.png"] forState:UIControlStateNormal];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 80, 44);
    [button addTarget:self action:@selector(backUp:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    [self.view addSubview:_backBtn];
}

- (void)addBackBtnWithNoHeader
{
    _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _backBtn.frame = CGRectMake(10,10+self.num,51,21);
    [_backBtn.titleLabel setFont:[UIFont fontWithName:@"Courier" size:17]];
    [_backBtn addTarget:self action:@selector(backUp:) forControlEvents:UIControlEventTouchUpInside];
    [_backBtn setBackgroundImage:[UIImage imageNamed:@"btn_back.png"] forState:UIControlStateNormal];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 80, 44);
    [button addTarget:self action:@selector(backUp:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    [self.view addSubview:_backBtn];
}

- (void)addRightBtnwithImgName:(NSString *)imgName Title:(NSString *)str
{
    _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightBtn.frame = CGRectMake(SCREEN_WIDTH-110,10+self.num,100,25);
    _rightBtn.contentHorizontalAlignment = NSTextAlignmentRight;
    [_rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_rightBtn.titleLabel setFont:[UIFont fontWithName:@"Courier" size:17]];
    [_rightBtn addTarget:self action:@selector(onClickRightBtn:) forControlEvents:UIControlEventTouchUpInside];
    if (imgName) {
        [_rightBtn setBackgroundImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    }else{
        [_rightBtn setTitle:str forState:UIControlStateNormal];
    }

    [self.view addSubview:_rightBtn];
}
- (void)addRightBtnwithImgName:(NSString *)imgName Title:(NSString *)str TitleColor:(UIColor *)color
{
    _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightBtn.frame = CGRectMake(SCREEN_WIDTH-110,10+self.num,100,25);
    _rightBtn.contentHorizontalAlignment = NSTextAlignmentRight;
    [_rightBtn setTitleColor:color forState:UIControlStateNormal];
    [_rightBtn.titleLabel setFont:[UIFont fontWithName:@"Courier" size:17]];
    [_rightBtn addTarget:self action:@selector(onClickRightBtn:) forControlEvents:UIControlEventTouchUpInside];
    if (imgName) {
        [_rightBtn setBackgroundImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    }else{
        [_rightBtn setTitle:str forState:UIControlStateNormal];
    }
    
    [self.view addSubview:_rightBtn];
}
- (void)addLeftBtnwithImgName:(NSString *)imgName Title:(NSString *)str TitleColor:(UIColor *)color//添加左键带颜色
{
    self.view.backgroundColor = [UIColor whiteColor];
    _leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _leftBtn.frame = CGRectMake(10,10+self.num,50,30);
    [_leftBtn.titleLabel setFont:[UIFont fontWithName:@"Courier" size:17]];
    [_leftBtn setTitleColor:color forState:UIControlStateNormal];
    [_leftBtn addTarget:self action:@selector(onClickLeftBtn:) forControlEvents:UIControlEventTouchUpInside];
    if (imgName) {
        [_leftBtn setBackgroundImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    }else{
        [_leftBtn setTitle:str forState:UIControlStateNormal];
    }
    
    [self.view addSubview:_leftBtn];
}
- (void)addLeftBtnwithImgName:(NSString *)imgName Title:(NSString *)str
{
    self.view.backgroundColor = [UIColor whiteColor];
    _leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _leftBtn.frame = CGRectMake(10,10+self.num,50,30);
    [_leftBtn.titleLabel setFont:[UIFont fontWithName:@"Courier" size:17]];
    [_leftBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_leftBtn addTarget:self action:@selector(onClickLeftBtn:) forControlEvents:UIControlEventTouchUpInside];
    if (imgName) {
        [_leftBtn setBackgroundImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    }else{
        [_leftBtn setTitle:str forState:UIControlStateNormal];
    }
    
    [self.view addSubview:_leftBtn];
}

- (void)configHeadView
{
    UIImageView *titleIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44+self.num)];
    titleIV.userInteractionEnabled = YES;
    titleIV.backgroundColor = RGBAColor(255, 255, 255, 1);
    titleIV.tag = 1001;
    [self.view addSubview:titleIV];
//    [self addHeadViewBlackStatusBackGroudView];
    [self addHeadViewLine];
}

-(void)addHeadViewBlackStatusBackGroudView{
    UIView *view_back = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
    view_back.backgroundColor = [UIColor blackColor];
    [self.view addSubview:view_back];
}

-(void)addHeadViewLine{
    UIView *view_line = [[UIView alloc] initWithFrame:CGRectMake(0, 43+self.num, SCREEN_WIDTH, 1)];
    view_line.backgroundColor = RGBColor(203, 203, 203);
    [self.view addSubview:view_line];
}
#pragma mark - 父类方法 如果自雷有新功能那么在子类中重写
- (void)backUp:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)onClickRightBtn:(UIButton *)sender
{
    NSLog(@"点击右边调到方法");
}

-(void)onClickLeftBtn:(UIButton *)sender
{
    NSLog(@"点击左边调到方法");
}

-(void)addTitleLabel:(NSString*)title withTitleColor:(UIColor *)titleColor
{
    UILabel *titleLabel4 = [[UILabel alloc]initWithFrame:CGRectMake(30, 10+self.num, SCREEN_WIDTH - 30 * 2, 25)] ;
    [titleLabel4 setTextAlignment:NSTextAlignmentCenter];
    [titleLabel4 setBackgroundColor:[UIColor clearColor]];
    [titleLabel4 setTextColor:titleColor];
    titleLabel4.tag = 1002;
    [titleLabel4 setFont:[UIFont fontWithName:@"Courier" size: 17]];
    [titleLabel4 setText:title];
    [self.view addSubview:titleLabel4];
}

-(void)addTitleLabel:(NSString*)title
{
    UILabel *titleLabel4 = [[UILabel alloc]initWithFrame:CGRectMake(30, 10+self.num, SCREEN_WIDTH - 30 * 2, 25)] ;
    [titleLabel4 setTextAlignment:NSTextAlignmentCenter];
    [titleLabel4 setBackgroundColor:[UIColor clearColor]];
    [titleLabel4 setTextColor:RGBColor(26, 26, 26)];
    titleLabel4.tag = 1002;
    [titleLabel4 setFont:[UIFont fontWithName:@"Courier" size: 17]];
    [titleLabel4 setText:title];
    [self.view addSubview:titleLabel4];
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
