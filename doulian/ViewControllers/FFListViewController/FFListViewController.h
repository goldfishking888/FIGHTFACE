//
//  FFListViewController.h
//  doulian
//
//  Created by Suny on 16/8/24.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import "BaseViewController.h"

@class LoopPageView;
@interface FFListViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) LoopPageView * loopView;
@end
