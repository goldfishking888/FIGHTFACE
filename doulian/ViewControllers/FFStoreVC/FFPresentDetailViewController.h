//
//  FFPresentDetailViewController.h
//  doulian
//
//  Created by Suny on 16/9/20.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import "BaseViewController.h"
#import "FFPresentListModel.h"
#import "FFContactAddressViewController.h"

@interface FFPresentDetailViewController : BaseViewController<UIScrollViewDelegate,FFContactAddressViewControllerDelegate,UIWebViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic,strong) FFPresentListModel *pModel;

@property(nonatomic,strong) UIView *headerView;//头部图片
@property(nonatomic,strong) UIView *contentView;//头部图片
@property(nonatomic,strong) UIView *footerView;//头部图片

@end
