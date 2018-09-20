//
//  BaseViewController.h
//  doulian
//
//  Created by Suny on 16/8/24.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController

@property (strong, nonatomic, readonly) UIButton *rightBtn;
@property (strong, nonatomic, readonly) UIButton *leftBtn;
@property (nonatomic,assign) int num;

@property (nonatomic,strong) UIButton *backBtn;


- (void)addBackBtn;  //添加返回按钮

- (void)addBackBtnWithNoHeader;

- (void)configHeadView;//添加headView
- (void)addHeadViewLine;//添加headView底部line
- (void)addRightBtnwithImgName:(NSString *)imgName Title:(NSString *)str;//添加右键

- (void)addLeftBtnwithImgName:(NSString *)imgName Title:(NSString *)str;//添加左键

- (void)addLeftBtnwithImgName:(NSString *)imgName Title:(NSString *)str TitleColor:(UIColor *)color;//添加左键带颜色

- (void)addRightBtnwithImgName:(NSString *)imgName Title:(NSString *)str TitleColor:(UIColor *)color;//添加右键带颜色

-(void)onClickRightBtn:(UIButton *)sender;

- (void)backUp:(id)sender;

-(void)addTitleLabel:(NSString*)title withTitleColor:(UIColor *)titleColor;//添加头部 自定义头部颜色

-(void)addTitleLabel:(NSString*)title;

- (UILabel *)createLabelWithFrame:(CGRect)frame textAlignment:(NSTextAlignment)textAlignment fontSize:(float)fontSize textColor:(UIColor *)textColor numberOfLines:(int)numberOfLines text:(id)text;//label的快速创建
@end
