//
//  FFSeeFightHistoryViewController.h
//  doulian
//
//  Created by WangJinyu on 16/8/25.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import "BaseViewController.h"

@interface FFSeeFightHistoryViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;

@end
