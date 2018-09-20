//
//  FFPersonalDetailVC.h
//  doulian
//
//  Created by WangJinyu on 16/9/23.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import "BaseViewController.h"

@interface FFPersonalDetailVC : BaseViewController<UIActionSheetDelegate>
{
    
    
}
@property (nonatomic,strong) UIButton *backButton;
@property (nonatomic,strong)NSString * userIDStr;//通过上个界面的好友的userId来请求好友新的详情
@end
