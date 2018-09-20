//
//  FFEditingInformationViewController.h
//  doulian
//
//  Created by WangJinyu on 2016/11/16.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import "BaseViewController.h"
#import "UserInfo.h"//用来把image传给上个界面

@interface FFEditingInformationViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>
@property(nonatomic,strong)NSString * avatarStr;
@property(nonatomic,strong)NSString * nameStr;
@property(nonatomic,strong)NSString * sexStr;
@property(nonatomic,strong)NSString * birthdayStr;
@property(nonatomic,strong)NSString * selfIntroStr;
@property(nonatomic,strong)NSString * mobileStr;

@property (nonatomic,strong) UIButton *backButton;
@property(nonatomic,strong)UIButton * headImageBtn;

@property (nonatomic,strong)UserInfo * userInfo;

@end
