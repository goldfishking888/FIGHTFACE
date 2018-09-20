//
//  PersonolCenterViewController.h
//  doulian
//
//  Created by WangJinyu on 16/8/24.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import "BaseViewController.h"
#import "UserInfo.h"//返回下界面返回的图
@interface PersonalCenterViewController : BaseViewController<UIActionSheetDelegate>


@property (nonatomic,strong)UserInfo * userInfo;
@end
