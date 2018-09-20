//
//  FFFightRoomViewController.h
//  doulian
//
//  Created by Suny on 16/8/31.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import "BaseViewController.h"
#import "FFShareModel.h"

@interface FFFightRoomViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>

@property (nonatomic,strong) NSDictionary *responseDic;

@property (nonatomic,strong) NSDictionary *dataDic;

@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic,strong) NSString *fightIdStr;

@property (nonatomic)BOOL isFromHistory;

@property (nonatomic,strong) FFShareModel *shareModel;

@property (nonatomic)BOOL isShowCreateRoomScore;//是否显示由开局获得的积分

@property (nonatomic)BOOL isShowRoomScore;//是否显示结束时获得的积分

@end
