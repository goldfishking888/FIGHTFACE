//
//  FFContactAddressViewController.m
//  doulian
//
//  Created by 孙扬 on 16/11/7.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import "FFContactAddressViewController.h"

@interface FFContactAddressViewController ()

@end

@implementation FFContactAddressViewController
{
    CGFloat rate;
    NSMutableDictionary *dic;
    UITextField *tf_name;
    UITextField *tf_phone;
    UITextField *tf_addr;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackBtn];
    [self addTitleLabel:@"礼品订单填写" withTitleColor:RGBColor(74, 74, 74)];
    [self addRightBtnwithImgName:nil Title:@"完成" TitleColor:RGBColor(74, 74, 74)];
    [self initData];
    self.view.backgroundColor = RGBColor(227, 227, 227);
    [self initView];

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
    
    UIView *view_name = [[UIView alloc] initWithFrame:CGRectMake(0, 10*rate+64, SCREEN_WIDTH, 63*rate)];
    view_name.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view_name];
    
    tf_name = [[UITextField alloc] initWithFrame:CGRectMake(15*rate, 0, SCREEN_WIDTH-15*2*rate, 63*rate)];
    tf_name.placeholder = @"收货人姓名";
    tf_name.backgroundColor = [UIColor whiteColor];
    tf_name.textColor = RGBColor(74, 74, 74);
    tf_name.font = [UIFont systemFontOfSize:floor(rate*17)];
    tf_name.tag = 1;
    [view_name addSubview:tf_name];
    
    UIView *view_phone = [[UIView alloc] initWithFrame:CGRectMake(0, (10+63)*rate+64+1, SCREEN_WIDTH, 63*rate)];
    view_phone.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view_phone];
    
    tf_phone = [[UITextField alloc] initWithFrame:CGRectMake(15*rate,0, SCREEN_WIDTH-15*2*rate, 63*rate)];
    tf_phone.placeholder = @"收货人手机号码";
    tf_phone.keyboardType = UIKeyboardTypePhonePad;
    tf_phone.backgroundColor = [UIColor whiteColor];
    tf_phone.textColor = RGBColor(74, 74, 74);
    tf_phone.font = [UIFont systemFontOfSize:floor(rate*17)];
    tf_phone.tag = 2;
    [view_phone addSubview:tf_phone];
    
    UIView *view_addr = [[UIView alloc] initWithFrame:CGRectMake(0, (10+63)*rate*2+64+1, SCREEN_WIDTH, 120*rate)];
    view_addr.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view_addr];
    
    tf_addr = [[UITextField alloc] initWithFrame:CGRectMake(15*rate,0, SCREEN_WIDTH-15*2*rate, 120*rate)];
    tf_addr.placeholder = @"请输入收货地址";
    tf_addr.backgroundColor = [UIColor whiteColor];
    tf_addr.textColor = RGBColor(74, 74, 74);
    tf_addr.font = [UIFont systemFontOfSize:floor(rate*17)];
    tf_addr.tag = 3;
    [view_addr addSubview:tf_addr];
    
    if (_infoDic) {
        tf_name.text = [_infoDic valueForKey:@"name"];
        tf_phone.text = [_infoDic valueForKey:@"phone"];
        tf_addr.text = [_infoDic valueForKey:@"addr"];
    }
    
}

-(void)onClickRightBtn:(UIButton *)sender{
    if (!tf_name.text||[tf_name.text isEqualToString:@""]) {
        [tf_name becomeFirstResponder];
        return;
    }
    
    if (!tf_phone.text||[tf_phone.text isEqualToString:@""]||![MyUtil isValidateMobile:tf_phone.text]) {
        [tf_phone becomeFirstResponder];
        return;
    }
    
    if (!tf_addr.text||[tf_addr.text isEqualToString:@""]) {
        [tf_addr becomeFirstResponder];
        return;
    }
    
    dic = [[NSMutableDictionary alloc] init];
    [dic setValue:tf_name.text forKey:@"name"];
    [dic setValue:tf_phone.text forKey:@"phone"];
    [dic setValue:tf_addr.text forKey:@"addr"];
    
    if (!dic) {
        return;
    }else{
        [mUserDefaults setValue:dic forKey:@"UserContatsInfo"];
    }
    
    if ([_delegate respondsToSelector:@selector(setContactInfoDic:)]) {
        [_delegate setContactInfoDic:dic];
        [self.navigationController popViewControllerAnimated:YES];
    }
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
